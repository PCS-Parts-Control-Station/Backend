const companyCode = window.location.pathname.split('/').filter(Boolean)[1] || 'workspace';
const routeLinks = document.querySelectorAll('[data-route]');
const companyCodeTexts = document.querySelectorAll('[data-company-code]');
const sessionName = document.querySelector('[data-session-name]');

companyCodeTexts.forEach((element) => {
    element.textContent = companyCode;
});

routeLinks.forEach((link) => {
    const route = link.dataset.route;
    if (!route) {
        return;
    }

    link.href = `/w/${encodeURIComponent(companyCode)}/${route}`;
});

const loadSession = async () => {
    if (!window.PcsApi || !companyCode) {
        return;
    }

    try {
        const me = await window.PcsApi.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/me`, {
            authRedirect: true,
            loginCompanyCode: companyCode
        });

        if (sessionName && me?.name) {
            sessionName.textContent = `${me.name} (${me.role})`;
        }
    } catch (error) {
        if (sessionName) {
            sessionName.textContent = '로그인 필요';
        }
    }
};

window.PcsUi?.consumeFlashToast();
loadSession();
