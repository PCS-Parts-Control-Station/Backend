const workspaceLoginForm = document.querySelector('#workspaceLoginForm');
const companyCodeField = document.querySelector('#companyCodeField');
const companyCodeInput = document.querySelector('#companyCode');
const loginIdInput = document.querySelector('#loginId');
const passwordInput = document.querySelector('#password');
const loginButton = document.querySelector('#loginButton');
const loginMessage = document.querySelector('#loginMessage');
const loginTitle = document.querySelector('#login-title');
const loginDescription = document.querySelector('#login-description');
const guideTitle = document.querySelector('#guide-title');
const guideBadge = document.querySelector('#guideBadge');
const currentAccessLabel = document.querySelector('#currentAccessLabel');
const workspaceChip = document.querySelector('#workspaceChip');
const workspaceCodeText = document.querySelector('#workspaceCodeText');
const currentAccessTitle = document.querySelector('#currentAccessTitle');
const currentAccessDescription = document.querySelector('#currentAccessDescription');

const getCompanyCodeFromPath = () => {
    const pathSegments = window.location.pathname.split('/').filter(Boolean);

    if (pathSegments[0] !== 'w' || pathSegments.length < 2) {
        return '';
    }

    return decodeURIComponent(pathSegments[1]).trim();
};

const normalizeCompanyCode = (value) => value.trim().toLowerCase();

const setMessage = (message, isError = false) => {
    loginMessage.textContent = message;
    loginMessage.classList.toggle('is-error', isError);
};

const setInvalid = (input, invalid) => {
    input.classList.toggle('is-invalid', invalid);
};

const resolveCompanyCode = () => {
    const companyCodeFromUrl = getCompanyCodeFromPath();

    if (companyCodeFromUrl) {
        return companyCodeFromUrl;
    }

    return normalizeCompanyCode(companyCodeInput.value);
};

const updateRouteMode = () => {
    const companyCodeFromUrl = getCompanyCodeFromPath();
    const hasCompanyCodeInUrl = Boolean(companyCodeFromUrl);

    companyCodeField.hidden = hasCompanyCodeInUrl;
    companyCodeInput.required = !hasCompanyCodeInUrl;
    companyCodeInput.value = companyCodeFromUrl ? '' : companyCodeInput.value;
    workspaceChip.hidden = !hasCompanyCodeInUrl;
    workspaceCodeText.textContent = companyCodeFromUrl;

    if (hasCompanyCodeInUrl) {
        guideTitle.textContent = '아이디와 비밀번호를 입력하세요.';
        if (guideBadge) {
            guideBadge.textContent = '업체 확인 완료';
            guideBadge.classList.add('is-confirmed');
        }
        if (currentAccessLabel) currentAccessLabel.textContent = '업체 코드 확인됨';
        currentAccessTitle.textContent = '업체 코드가 확인되었습니다.';
        currentAccessDescription.textContent = '아이디와 비밀번호만 입력하면 업무 페이지로 이동합니다.';
        loginTitle.textContent = `${companyCodeFromUrl} 작업공간 로그인`;
        if (loginDescription) loginDescription.textContent = '업체 코드가 확인되었습니다. 아이디와 비밀번호로 업무 화면에 접속하세요.';
        loginIdInput.focus();
        return;
    }

    guideTitle.textContent = '업체 코드와 계정 정보를 입력하세요.';
    if (guideBadge) {
        guideBadge.textContent = '업체 선택 필요';
        guideBadge.classList.remove('is-confirmed');
    }
    if (currentAccessLabel) currentAccessLabel.textContent = '현재 접속 방식';
    currentAccessTitle.textContent = '업체 코드를 입력해야 합니다.';
    currentAccessDescription.textContent = '회사 관리자에게 받은 업체 코드, 아이디, 비밀번호를 입력하세요.';
    loginTitle.textContent = '로그인';
    if (loginDescription) loginDescription.textContent = '회사에서 받은 계정으로 로그인하면 부품, 입고, 검수, 출고 업무를 바로 이어서 처리할 수 있습니다.';
};

companyCodeInput?.addEventListener('input', () => {
    setInvalid(companyCodeInput, false);
});

[loginIdInput, passwordInput].forEach((input) => {
    input?.addEventListener('input', () => {
        setInvalid(input, false);
    });
});

workspaceLoginForm?.addEventListener('submit', async (event) => {
    event.preventDefault();

    const companyCode = resolveCompanyCode();
    const loginId = loginIdInput.value.trim();
    const password = passwordInput.value;
    const hasCompanyCodeInUrl = Boolean(getCompanyCodeFromPath());

    setMessage('');
    setInvalid(companyCodeInput, !companyCode && !hasCompanyCodeInUrl);
    setInvalid(loginIdInput, !loginId);
    setInvalid(passwordInput, !password);

    if (!companyCode) {
        setMessage('업체 코드를 입력해 주세요.', true);
        companyCodeInput.focus();
        return;
    }

    if (!loginId) {
        setMessage('아이디를 입력해 주세요.', true);
        loginIdInput.focus();
        return;
    }

    if (!password) {
        setMessage('비밀번호를 입력해 주세요.', true);
        passwordInput.focus();
        return;
    }

    loginButton.disabled = true;
    setMessage('로그인 정보를 확인하는 중입니다.');

    try {
        const response = await fetch('/api/workspaces/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                companyCode,
                loginId,
                password
            })
        });

        const result = await response.json().catch(() => null);

        if (!response.ok || result?.success === false) {
            setMessage(result?.message || '업체 코드, 아이디 또는 비밀번호를 확인해 주세요.', true);
            return;
        }

        const responseData = result?.data || {};
        const nextCompanyCode = responseData.companyCode || companyCode;

        if (responseData.accessToken) {
            window.PcsApi?.setAccessToken(responseData.accessToken);
        }

        window.location.href = `/w/${encodeURIComponent(nextCompanyCode)}/dashboard`;
    } catch (error) {
        setMessage('로그인 정보를 확인할 수 없습니다. 잠시 후 다시 시도해 주세요.', true);
    } finally {
        loginButton.disabled = false;
    }
});

updateRouteMode();
