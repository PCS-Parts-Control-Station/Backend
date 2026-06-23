(function (window) {
    const ACCESS_TOKEN_KEY = 'pcsAccessToken';
    const AUTH_ERROR_CODES = new Set([
        'AUTH-002',
        'AUTH-003',
        'AUTH-004'
    ]);
    const WORKSPACE_ERROR_CODES = new Set([
        'AUTH-006',
        'COMPANY-001',
        'COMPANY-003'
    ]);
    const PASSWORD_CHANGE_REQUIRED_CODE = 'MEMBER-005';

    let refreshPromise = null;
    let accessToken = '';

    const removeLegacyStoredAccessToken = () => {
        try {
            window.localStorage.removeItem(ACCESS_TOKEN_KEY);
        } catch (error) {
            // localStorage may be unavailable in restrictive browser modes.
        }
    };

    removeLegacyStoredAccessToken();

    class PcsApiError extends Error {
        constructor(message, details = {}) {
            super(message);
            this.name = 'PcsApiError';
            this.status = details.status || 0;
            this.code = details.code || '';
            this.data = details.data || null;
            this.result = details.result || null;
        }
    }

    const getAccessToken = () => accessToken;

    const setAccessToken = (nextAccessToken) => {
        removeLegacyStoredAccessToken();
        if (!nextAccessToken) {
            accessToken = '';
            return;
        }
        accessToken = nextAccessToken;
    };

    const clearAccessToken = () => {
        accessToken = '';
        removeLegacyStoredAccessToken();
    };

    const isAuthError = (error) => {
        return error?.status === 401 || AUTH_ERROR_CODES.has(error?.code);
    };

    const isWorkspaceAccessError = (error) => {
        return WORKSPACE_ERROR_CODES.has(error?.code);
    };

    const getCompanyCodeFromPath = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : '';
    };

    const workspaceErrorType = (error) => {
        if (error?.code === 'AUTH-006') {
            return 'access';
        }
        if (error?.code === 'COMPANY-003') {
            return 'inactive';
        }
        return 'workspace';
    };

    const redirectToInvalidAccess = (error, companyCode = '') => {
        const targetCompanyCode = companyCode || getCompanyCodeFromPath();
        const params = new URLSearchParams({
            type: workspaceErrorType(error)
        });

        if (targetCompanyCode) {
            params.set('code', targetCompanyCode);
        }
        if (error?.code) {
            params.set('reason', error.code);
        }

        window.location.href = `/workspace-not-found?${params.toString()}`;
    };

    const parseJsonResult = async (response) => {
        const result = await response.json().catch(() => null);

        if (!response.ok || result?.success === false) {
            throw new PcsApiError(result?.message || '요청을 처리할 수 없습니다.', {
                status: response.status,
                code: result?.code,
                data: result?.data,
                result
            });
        }

        return result;
    };

    const validateWorkspacePublic = async (companyCode) => {
        if (!companyCode) {
            redirectToInvalidAccess({ code: 'COMPANY-001' });
            return false;
        }

        try {
            const response = await fetch(`/api/workspaces/${encodeURIComponent(companyCode)}/public-info`, {
                method: 'GET',
                credentials: 'same-origin',
                headers: {
                    'Accept': 'application/json'
                }
            });
            await parseJsonResult(response);
            return true;
        } catch (error) {
            if (isWorkspaceAccessError(error)) {
                redirectToInvalidAccess(error, companyCode);
                return false;
            }
            throw error;
        }
    };

    const normalizeHeaders = (headers, hasJsonBody) => {
        const normalized = new Headers(headers || {});
        normalized.set('Accept', 'application/json');

        if (hasJsonBody && !normalized.has('Content-Type')) {
            normalized.set('Content-Type', 'application/json');
        }

        const accessToken = getAccessToken();
        if (accessToken) {
            normalized.set('Authorization', `Bearer ${accessToken}`);
        }

        return normalized;
    };

    const normalizeBody = (body) => {
        if (!body || typeof body === 'string' || body instanceof FormData) {
            return {
                body,
                hasJsonBody: false
            };
        }

        return {
            body: JSON.stringify(body),
            hasJsonBody: true
        };
    };

    const refreshAccessToken = async () => {
        if (!refreshPromise) {
            refreshPromise = fetch('/api/auth/refresh', {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Accept': 'application/json'
                }
            })
                .then(parseJsonResult)
                .then((result) => {
                    const accessToken = result?.data?.accessToken;
                    if (!accessToken) {
                        throw new PcsApiError('재발급된 access token이 없습니다.', {
                            status: 401,
                            code: 'AUTH-003',
                            result
                        });
                    }
                    setAccessToken(accessToken);
                    return result;
                })
                .catch((error) => {
                    clearAccessToken();
                    throw error;
                })
                .finally(() => {
                    refreshPromise = null;
                });
        }

        return refreshPromise;
    };

    const redirectToLogin = (companyCode) => {
        const nextPath = companyCode ? `/w/${encodeURIComponent(companyCode)}` : '/w';
        if (window.location.pathname !== nextPath) {
            window.location.href = nextPath;
        }
    };

    const redirectToPasswordChange = (companyCode) => {
        const targetCompanyCode = companyCode || getCompanyCodeFromPath();
        if (!targetCompanyCode) {
            return;
        }
        const nextPath = `/w/${encodeURIComponent(targetCompanyCode)}/mypage`;
        if (window.location.pathname !== nextPath) {
            window.location.href = `${nextPath}?section=password&required=true`;
        }
    };

    const request = async (url, options = {}) => {
        const retryOnAuthError = options.retryOnAuthError !== false;
        const authRedirect = options.authRedirect === true;
        const loginCompanyCode = options.loginCompanyCode || '';
        const { body, hasJsonBody } = normalizeBody(options.body);

        const execute = async () => {
            const response = await fetch(url, {
                ...options,
                body,
                credentials: options.credentials || 'same-origin',
                headers: normalizeHeaders(options.headers, hasJsonBody)
            });
            return parseJsonResult(response);
        };

        try {
            return await execute();
        } catch (error) {
            if (error?.code === PASSWORD_CHANGE_REQUIRED_CODE) {
                redirectToPasswordChange(loginCompanyCode);
                throw error;
            }

            if (options.workspaceErrorRedirect !== false && isWorkspaceAccessError(error)) {
                redirectToInvalidAccess(error, loginCompanyCode);
                throw error;
            }

            if (!retryOnAuthError || !isAuthError(error)) {
                throw error;
            }

            try {
                await refreshAccessToken();
                return await execute();
            } catch (refreshError) {
                if (options.workspaceErrorRedirect !== false && isWorkspaceAccessError(refreshError)) {
                    redirectToInvalidAccess(refreshError, loginCompanyCode);
                    throw refreshError;
                }
                if (authRedirect) {
                    redirectToLogin(loginCompanyCode);
                }
                throw refreshError;
            }
        }
    };

    const getData = async (url, options = {}) => {
        const result = await request(url, options);
        return result.data;
    };

    const logout = async () => {
        try {
            await fetch('/api/auth/logout', {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Accept': 'application/json'
                }
            });
        } finally {
            clearAccessToken();
        }
    };

    window.PcsApi = {
        request,
        getData,
        refreshAccessToken,
        getAccessToken,
        setAccessToken,
        clearAccessToken,
        redirectToInvalidAccess,
        redirectToPasswordChange,
        validateWorkspacePublic,
        logout,
        PcsApiError
    };
})(window);
