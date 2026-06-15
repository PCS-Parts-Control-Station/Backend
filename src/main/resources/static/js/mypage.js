(function () {
    const companyCode = window.PcsWorkspace?.getCompanyCode?.() || window.location.pathname.split("/").filter(Boolean)[1] || "";

    const roleLabels = {
        OWNER: "최고 관리자",
        ADMIN: "관리자",
        STAFF: "작업자"
    };

    const passwordStatusLabels = {
        TEMPORARY: "임시 비밀번호",
        ACTIVE: "정상"
    };

    const staffPermissionLabels = {
        STAFF_PARTNER_MANAGE: "거래처 관리",
        STAFF_PART_CREATE: "품목 관리",
        STAFF_CATEGORY_MANAGE: "품목 분류",
        STAFF_INBOUND: "입고",
        STAFF_INSPECTION: "검수",
        STAFF_OUTBOUND: "출고"
    };

    const text = (selector, value) => {
        const element = document.querySelector(selector);
        if (element) {
            element.textContent = value || "-";
        }
    };

    const value = (selector, nextValue) => {
        const element = document.querySelector(selector);
        if (element) {
            element.value = nextValue || "";
        }
    };

    const showRoleSection = (role) => {
        document.querySelectorAll("[data-role-section]").forEach((section) => {
            section.hidden = section.dataset.roleSection !== role;
        });
    };

    const renderPermissionList = (selector, permissions = []) => {
        const list = document.querySelector(selector);
        if (!list) {
            return;
        }

        list.innerHTML = "";
        if (permissions.length === 0) {
            const empty = document.createElement("span");
            empty.className = "badge badge-inactive";
            empty.textContent = "사용 가능한 업무 메뉴가 없습니다";
            list.append(empty);
            return;
        }

        permissions.forEach((permission) => {
            const chip = document.createElement("span");
            chip.className = "badge badge-blue";
            chip.textContent = staffPermissionLabels[permission] || permission;
            list.append(chip);
        });
    };

    const renderStaffPermissions = (permissions = []) => {
        renderPermissionList("[data-staff-permission-list]", permissions);
        renderPermissionList("[data-staff-permission-aside-list]", permissions);
    };

    const bindUiOnlyActions = () => {
        document.querySelectorAll("[data-ui-only-action]").forEach((button) => {
            button.addEventListener("click", () => {
                window.PcsFeedback?.toast("마이페이지 화면만 준비되어 있습니다.", "info");
            });
        });
    };

    const renderSession = (session) => {
        const role = String(session?.role || "").toUpperCase();
        const name = session?.name || "접속 계정";
        const loginId = session?.loginId || "-";
        const resolvedCompanyCode = session?.companyCode || companyCode;

        text("[data-mypage-name]", name);
        text("[data-mypage-description]", `${loginId} 계정으로 접속 중입니다.`);
        text("[data-mypage-company-code]", resolvedCompanyCode);
        text("[data-mypage-login-id]", loginId);
        text("[data-mypage-role]", roleLabels[role] || role || "-");
        text("[data-mypage-role-badge]", roleLabels[role] || role || "ROLE");
        text("[data-mypage-password-status]", passwordStatusLabels[session?.passwordStatus] || session?.passwordStatus || "-");
        text("[data-side-name]", name);
        text("[data-side-role]", roleLabels[role] || role || "-");
        text("[data-side-company-code]", resolvedCompanyCode);
        text("[data-side-login-id]", loginId);
        value("[data-member-name-input]", name);
        value("[data-member-login-id-input]", loginId);
        value("[data-member-role-input]", roleLabels[role] || role || "");
        value("[data-member-password-status-input]", passwordStatusLabels[session?.passwordStatus] || session?.passwordStatus || "");
        value("[data-owner-company-code]", resolvedCompanyCode);

        document.querySelectorAll("[data-users-link]").forEach((link) => {
            link.href = `/w/${encodeURIComponent(resolvedCompanyCode)}/users`;
        });
        document.querySelectorAll("[data-dashboard-link]").forEach((link) => {
            link.href = `/w/${encodeURIComponent(resolvedCompanyCode)}/dashboard`;
        });

        showRoleSection(role);
        renderStaffPermissions(session?.staffPermissions || []);
    };

    const loadMypage = async () => {
        if (!companyCode || !window.PcsApi) {
            return;
        }

        try {
            const session = await window.PcsApi.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/me`, {
                authRedirect: true,
                loginCompanyCode: companyCode
            });
            renderSession(session);
        } catch (error) {
            text("[data-mypage-name]", "계정 확인 실패");
            text("[data-mypage-description]", "로그인 정보를 다시 확인해야 합니다.");
        }
    };

    bindUiOnlyActions();
    loadMypage();
})();
