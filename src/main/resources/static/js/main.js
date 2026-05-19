document.documentElement.dataset.page = 'main';

const workspaceForm = document.querySelector('#workspaceForm');
const companyCodeInput = document.querySelector('#companyCode');

workspaceForm?.addEventListener('submit', (event) => {
    event.preventDefault();

    const companyCode = companyCodeInput.value.trim();
    if (!companyCode) {
        companyCodeInput.focus();
        return;
    }

    window.location.href = `/w/${encodeURIComponent(companyCode)}`;
});
