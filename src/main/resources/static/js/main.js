document.documentElement.dataset.page = 'main';

const workspaceForm = document.querySelector('#workspaceForm');
const companyCodeInput = document.querySelector('#companyCode');
const revealTargets = document.querySelectorAll([
    '.hero-copy',
    '.workspace-card',
    '.operation-panel',
    '.section-heading',
    '.workflow-list li',
    '.focus-grid article'
].join(','));

workspaceForm?.addEventListener('submit', (event) => {
    event.preventDefault();

    const companyCode = companyCodeInput.value.trim();
    if (!companyCode) {
        companyCodeInput.focus();
        return;
    }

    window.location.href = `/w/${encodeURIComponent(companyCode)}`;
});

if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches && 'IntersectionObserver' in window) {
    revealTargets.forEach((target, index) => {
        target.classList.add('reveal');
        target.style.setProperty('--reveal-delay', `${Math.min(index % 5, 4) * 45}ms`);
    });

    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
            entry.target.classList.toggle('is-visible', entry.isIntersecting);
        });
    }, {
        threshold: 0.16,
        rootMargin: '0px 0px -8% 0px'
    });

    revealTargets.forEach((target) => revealObserver.observe(target));
}
