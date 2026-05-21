document.documentElement.dataset.page = 'company-register';

const registerPage = document.querySelector('.register-page');
const registerForm = document.querySelector('#companyRegisterForm');
const companyNameInput = document.querySelector('#companyName');
const companyCodeInput = document.querySelector('#companyCode');
const businessRegistrationNoInput = document.querySelector('#businessRegistrationNo');
const representativeEmailInput = document.querySelector('#representativeEmail');
const representativePhoneInput = document.querySelector('#representativePhone');
const ownerNameInput = document.querySelector('#ownerName');
const ownerLoginIdInput = document.querySelector('#ownerLoginId');
const ownerPasswordInput = document.querySelector('#ownerPassword');
const submitButton = document.querySelector('#submitButton');
const formMessage = document.querySelector('#formMessage');
const workspaceUrl = document.querySelector('#workspaceUrl');
const previewCompanyName = document.querySelector('#previewCompanyName');
const previewOwnerLoginId = document.querySelector('#previewOwnerLoginId');
const registrationComplete = document.querySelector('#registrationComplete');
const workspaceLoginLink = document.querySelector('#workspaceLoginLink');
const copyWorkspaceUrlButton = document.querySelector('#copyWorkspaceUrlButton');
const copyMessage = document.querySelector('#copyMessage');
const completeCompanyName = document.querySelector('#completeCompanyName');
const completeCompanyCode = document.querySelector('#completeCompanyCode');
const completeWorkspaceUrl = document.querySelector('#completeWorkspaceUrl');
const completeOwnerLoginId = document.querySelector('#completeOwnerLoginId');

const revealTargets = document.querySelectorAll([
    '.page-hero',
    '.register-form',
    '.register-preview'
].join(','));

function normalizeCompanyCode(value) {
    return value
        .trim()
        .toLowerCase()
        .replace(/[^a-z0-9-]/g, '-')
        .replace(/-+/g, '-')
        .replace(/^-|-$/g, '');
}

function updatePreview() {
    const companyCode = normalizeCompanyCode(companyCodeInput.value) || 'company-code';
    const companyName = companyNameInput.value.trim() || '입력 전';
    const ownerLoginId = ownerLoginIdInput.value.trim() || '입력 전';

    workspaceUrl.textContent = `/w/${companyCode}`;
    previewCompanyName.textContent = companyName;
    previewOwnerLoginId.textContent = ownerLoginId;
}

function markInvalidFields() {
    const requiredFields = registerForm.querySelectorAll('[required]');
    let firstInvalidField = null;

    requiredFields.forEach((field) => {
        const isInvalid = !field.value.trim();
        field.classList.toggle('is-invalid', isInvalid);

        if (isInvalid && !firstInvalidField) {
            firstInvalidField = field;
        }
    });

    return firstInvalidField;
}

function optionalValue(input) {
    const value = input.value.trim();
    return value ? value : null;
}

function createRequestBody() {
    return {
        companyName: companyNameInput.value.trim(),
        companyCode: normalizeCompanyCode(companyCodeInput.value),
        businessRegistrationNo: optionalValue(businessRegistrationNoInput),
        representativeEmail: optionalValue(representativeEmailInput),
        representativePhone: optionalValue(representativePhoneInput),
        ownerName: ownerNameInput.value.trim(),
        ownerLoginId: ownerLoginIdInput.value.trim(),
        ownerPassword: ownerPasswordInput.value
    };
}

function resolveErrorMessage(result) {
    if (!result) {
        return '회사 등록 중 오류가 발생했습니다.';
    }

    if (Array.isArray(result.data) && result.data.length > 0) {
        return result.data.map((error) => error.message).join(' ');
    }

    return result.message || '회사 등록 중 오류가 발생했습니다.';
}

function setSaving(isSaving) {
    submitButton.disabled = isSaving;
    submitButton.textContent = isSaving ? '등록 중...' : '회사 등록 완료';
}

function showCompletion(signupResult) {
    const workspaceLoginUrl = signupResult.workspaceLoginUrl || `/w/${signupResult.companyCode}`;

    completeCompanyName.textContent = companyNameInput.value.trim();
    completeCompanyCode.textContent = signupResult.companyCode;
    completeWorkspaceUrl.textContent = workspaceLoginUrl;
    completeOwnerLoginId.textContent = signupResult.ownerLoginId;
    workspaceLoginLink.href = workspaceLoginUrl;
    copyWorkspaceUrlButton.dataset.copyText = `${window.location.origin}${workspaceLoginUrl}`;
    registrationComplete.hidden = false;
    registerPage.classList.add('is-complete');
    registerForm.closest('.register-layout').classList.add('is-complete');
    registrationComplete.scrollIntoView({
        behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth',
        block: 'start'
    });
}

companyCodeInput?.addEventListener('blur', () => {
    companyCodeInput.value = normalizeCompanyCode(companyCodeInput.value);
    updatePreview();
});

[
    companyNameInput,
    companyCodeInput,
    ownerNameInput,
    ownerLoginIdInput,
    ownerPasswordInput
].forEach((input) => {
    input?.addEventListener('input', () => {
        input.classList.remove('is-invalid');
        updatePreview();
    });
});

registerForm?.addEventListener('submit', async (event) => {
    event.preventDefault();
    companyCodeInput.value = normalizeCompanyCode(companyCodeInput.value);

    const firstInvalidField = markInvalidFields();
    if (firstInvalidField) {
        formMessage.textContent = '필수 입력값을 확인해 주세요.';
        formMessage.classList.add('is-error');
        firstInvalidField.focus();
        return;
    }

    updatePreview();
    formMessage.textContent = '';
    formMessage.classList.remove('is-error');
    setSaving(true);

    try {
        const response = await fetch('/api/owners/signup', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(createRequestBody())
        });
        const result = await response.json().catch(() => null);

        if (!response.ok || !result?.success) {
            throw new Error(resolveErrorMessage(result));
        }

        workspaceUrl.textContent = result.data.workspaceLoginUrl;
        formMessage.textContent = '회사 등록이 완료되었습니다.';
        formMessage.classList.remove('is-error');
        showCompletion(result.data);
    } catch (error) {
        formMessage.textContent = error.message;
        formMessage.classList.add('is-error');
    } finally {
        setSaving(false);
    }
});

copyWorkspaceUrlButton?.addEventListener('click', async () => {
    const copyText = copyWorkspaceUrlButton.dataset.copyText || completeWorkspaceUrl.textContent;

    try {
        await navigator.clipboard.writeText(copyText);
        copyMessage.textContent = '업체 접속 주소를 복사했습니다.';
        copyMessage.classList.remove('is-error');
    } catch (error) {
        copyMessage.textContent = copyText;
        copyMessage.classList.add('is-error');
    }
});

if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches && 'IntersectionObserver' in window) {
    revealTargets.forEach((target, index) => {
        target.classList.add('reveal');
        target.style.setProperty('--reveal-delay', `${index * 55}ms`);
    });

    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
            entry.target.classList.toggle('is-visible', entry.isIntersecting);
        });
    }, {
        threshold: 0.14,
        rootMargin: '0px 0px -8% 0px'
    });

    revealTargets.forEach((target) => revealObserver.observe(target));
}

updatePreview();
