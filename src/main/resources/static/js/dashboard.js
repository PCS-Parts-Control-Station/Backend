const companyCode = window.location.pathname.split('/').filter(Boolean)[1] || 'workspace';
const routeLinks = document.querySelectorAll('[data-route]');
const companyCodeTexts = document.querySelectorAll('[data-company-code]');

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
