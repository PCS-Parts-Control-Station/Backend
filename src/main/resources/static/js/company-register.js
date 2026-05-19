document.documentElement.dataset.page = 'company-register';

const registerForm = document.querySelector('#companyRegisterForm');
const companyNameInput = document.querySelector('#companyName');
const companyCodeInput = document.querySelector('#companyCode');
const ownerLoginIdInput = document.querySelector('#ownerLoginId');
const formMessage = document.querySelector('#formMessage');
const workspaceUrl = document.querySelector('#workspaceUrl');
const previewCompanyName = document.querySelector('#previewCompanyName');
const previewOwnerLoginId = document.querySelector('#previewOwnerLoginId');

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

companyCodeInput?.addEventListener('blur', () => {
    companyCodeInput.value = normalizeCompanyCode(companyCodeInput.value);
    updatePreview();
});

[companyNameInput, companyCodeInput, ownerLoginIdInput].forEach((input) => {
    input?.addEventListener('input', () => {
        input.classList.remove('is-invalid');
        updatePreview();
    });
});

registerForm?.addEventListener('submit', (event) => {
    event.preventDefault();

    const firstInvalidField = markInvalidFields();
    if (firstInvalidField) {
        formMessage.textContent = '필수 입력값을 확인해 주세요.';
        formMessage.classList.add('is-error');
        firstInvalidField.focus();
        return;
    }

    companyCodeInput.value = normalizeCompanyCode(companyCodeInput.value);
    updatePreview();
    formMessage.textContent = '회사 등록 정보가 확인되었습니다.';
    formMessage.classList.remove('is-error');
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
