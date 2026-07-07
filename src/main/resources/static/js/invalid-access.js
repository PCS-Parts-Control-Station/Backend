(function () {
    const params = new URLSearchParams(window.location.search);
    const type = params.get('type') || inferTypeFromPath();
    const companyCode = params.get('code') || inferCompanyCodeFromPath();
    const path = params.get('path') || window.location.pathname;

    const content = {
        workspace: {
            eyebrow: '업체 주소 오류',
            title: '업체 주소를 확인할 수 없습니다.',
            description: '입력한 업체 코드가 잘못되었거나 더 이상 사용할 수 없는 주소입니다.',
            label: '확인한 업체 코드',
            primaryText: '업체 로그인으로 이동',
            primaryHref: '/w'
        },
        inactive: {
            eyebrow: '업체 사용 중지',
            title: '사용이 중지된 업체입니다.',
            description: '해당 업체 작업공간은 현재 사용할 수 없습니다. 회사 관리자에게 상태를 확인하세요.',
            label: '확인한 업체 코드',
            primaryText: '업체 로그인으로 이동',
            primaryHref: '/w'
        },
        access: {
            eyebrow: '접근 권한 오류',
            title: '접근할 수 없는 업무 공간입니다.',
            description: '로그인한 계정의 업체 정보와 주소의 업체 코드가 일치하지 않습니다.',
            label: '요청한 주소',
            primaryText: '다시 로그인',
            primaryHref: companyCode ? `/w/${encodeURIComponent(companyCode)}` : '/w'
        },
        page: {
            eyebrow: '페이지 없음',
            title: '요청한 페이지를 찾을 수 없습니다.',
            description: '주소가 잘못되었거나 아직 제공하지 않는 업무 페이지입니다.',
            label: '요청한 주소',
            primaryText: '업무 로그인으로 이동',
            primaryHref: '/w'
        }
    };

    const selected = content[type] || content.page;

    setText('#notice-eyebrow', selected.eyebrow);
    setText('#notice-title', selected.title);
    setText('#notice-description', selected.description);
    setText('#targetLabel', selected.label);
    setText('#targetValue', companyCode || path);

    const primaryAction = document.querySelector('#primaryAction');
    if (primaryAction) {
        primaryAction.textContent = selected.primaryText;
        primaryAction.href = selected.primaryHref;
    }

    const targetBox = document.querySelector('#targetBox');
    if (targetBox) {
        targetBox.hidden = !(companyCode || path);
    }

    function setText(selector, value) {
        const element = document.querySelector(selector);
        if (element) {
            element.textContent = value;
        }
    }

    function inferCompanyCodeFromPath() {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : '';
    }

    function inferTypeFromPath() {
        if (window.location.pathname.startsWith('/access-denied')) {
            return 'access';
        }
        if (window.location.pathname.startsWith('/workspace-not-found')) {
            return 'workspace';
        }
        return 'page';
    }
})();
