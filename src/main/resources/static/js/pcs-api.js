(function (window) {
    const ACCESS_TOKEN_KEY = 'pcsAccessToken';
    const AUTH_ERROR_CODES = new Set([
        'AUTH-002',
        'AUTH-003',
        'AUTH-004'
    ]);

    let refreshPromise = null;

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

    const getAccessToken = () => window.localStorage.getItem(ACCESS_TOKEN_KEY);

    const setAccessToken = (accessToken) => {
        if (!accessToken) {
            window.localStorage.removeItem(ACCESS_TOKEN_KEY);
            return;
        }
        window.localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
    };

    const clearAccessToken = () => {
        window.localStorage.removeItem(ACCESS_TOKEN_KEY);
    };

    const isAuthError = (error) => {
        return error?.status === 401 || AUTH_ERROR_CODES.has(error?.code);
    };

    const parseJsonResult = async (response) => {
        const result = await response.json().catch(() => null);

        if (!response.ok || result?.success === false) {
            throw new PcsApiError(result?.message || 'API 요청을 처리할 수 없습니다.', {
                status: response.status,
                code: result?.code,
                data: result?.data,
                result
            });
        }

        return result;
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
            if (!retryOnAuthError || !isAuthError(error)) {
                throw error;
            }

            try {
                await refreshAccessToken();
                return await execute();
            } catch (refreshError) {
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
        logout,
        PcsApiError
    };
})(window);
