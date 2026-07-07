(function () {
    const PAGE_SIZE = 10;
    const ROLE_LABELS = {
        ADMIN: "관리자",
        STAFF: "작업자"
    };
    const ROLE_OPTION_LABELS = {
        ADMIN: "관리자",
        STAFF: "작업자"
    };

    const filterForm = document.querySelector("[data-user-filter-form]");
    const table = document.querySelector("[data-user-table]");
    const pagination = document.querySelector("[data-user-pagination]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const searchButton = filterForm?.querySelector("button[type='submit']");
    const panelViews = document.querySelectorAll("[data-user-panel]");
    const detailDrawer = document.querySelector("[data-user-detail-drawer]");
    const createDrawerButtons = document.querySelectorAll("[data-user-create-drawer]");
    const createDrawerButton = Array.from(createDrawerButtons)
            .find((button) => !button.closest("[data-workspace-quick-bar]"))
            || createDrawerButtons[0]
            || null;
    const createForm = document.querySelector("[data-user-create-form]");
    const editForm = document.querySelector("[data-user-edit-form]");
    const staffPermissionModal = document.querySelector("[data-staff-permission-modal]");
    const openStaffPermissionModalButtons = document.querySelectorAll("[data-open-staff-permission-modal]");
    const closeStaffPermissionModalButtons = document.querySelectorAll("[data-close-staff-permission-modal]");
    const staffPermissionForm = document.querySelector("[data-staff-permission-form]");
    const staffPermissionInputs = document.querySelectorAll("[data-staff-permission-input]");
    const detailFields = {
        name: document.querySelector("[data-detail-name]"),
        loginId: document.querySelector("[data-detail-login-id]"),
        createdAt: document.querySelector("[data-detail-created-at]"),
        updatedAt: document.querySelector("[data-detail-updated-at]"),
        roleBadge: document.querySelector("[data-detail-role-badge]"),
        passwordBadge: document.querySelector("[data-detail-password-badge]")
    };
    const summaryFields = {
        total: document.querySelector("[data-summary-total]"),
        admin: document.querySelector("[data-summary-admin]"),
        staff: document.querySelector("[data-summary-staff]")
    };
    const passwordModal = document.querySelector("[data-reset-password-modal]");
    const openPasswordModalButton = document.querySelector("[data-open-reset-password-modal]");
    const closePasswordModalButtons = document.querySelectorAll("[data-close-reset-password-modal]");
    const confirmPasswordButton = document.querySelector("[data-confirm-reset-password]");
    const copyTemporaryPasswordButton = document.querySelector("[data-copy-temp-password]");
    const passwordModalFields = {
        title: document.querySelector("[data-password-modal-title]"),
        description: document.querySelector("[data-password-modal-description]"),
        targetName: document.querySelector("[data-reset-password-target-name]"),
        tempPasswordContainer: document.querySelector("[data-temp-password-container]"),
        tempPasswordValue: document.querySelector("[data-temp-password-value]"),
        tempPasswordExpiryContainer: document.querySelector("[data-temp-password-expiry-container]"),
        tempPasswordExpiry: document.querySelector("[data-temp-password-expiry]"),
        notice: document.querySelector("[data-temp-password-notice]"),
        message: document.querySelector("[data-reset-password-message]")
    };

    let currentPage = 0;
    let currentUsers = [];
    let selectedUserId = null;
    let currentSession = null;
    let lastDrawerTrigger = null;

    const getCompanyCode = window.PcsWorkspace?.getCompanyCode;
    const formatDate = window.PcsFormat?.date;
    const numberText = window.PcsFormat?.number;
    const clearRows = () => window.PcsTable.clearRows(table);
    const showToast = window.PcsFeedback?.toast;
    const setFormSaving = window.PcsForm?.setSaving;
    const setEmptyMessage = (message) => window.PcsTable.emptyRow(table, {
        rowClassName: "data-row management-data-row user-management-data-row empty-data-row",
        label: "안내",
        message
    });

    const manageableRoles = () => {
        if (currentSession?.role === "OWNER") {
            return ["ADMIN", "STAFF"];
        }
        if (currentSession?.role === "ADMIN") {
            return ["STAFF"];
        }
        return [];
    };

    const canManageRole = (role) => manageableRoles().includes(role);

    const roleLabel = (role) => {
        if (role === "OWNER") {
            return "소유자";
        }
        return ROLE_LABELS[role] || "작업자";
    };

    const roleBadgeClass = (role) => {
        if (role === "OWNER") {
            return "badge-blue";
        }
        if (role === "ADMIN") {
            return "badge-pending";
        }
        return "badge-inactive";
    };

    const setBadge = (element, text, className) => {
        if (!element) {
            return;
        }
        element.className = `badge ${className}`;
        element.textContent = text;
    };

    const configureRoleSelect = (select, options = {}) => {
        if (!select) {
            return;
        }

        const roles = manageableRoles();
        const previousValue = select.value;
        select.innerHTML = "";

        if (options.includeAll) {
            const allOption = document.createElement("option");
            allOption.value = "";
            allOption.textContent = "전체";
            select.append(allOption);
        } else {
            const placeholder = document.createElement("option");
            placeholder.value = "";
            placeholder.textContent = "선택";
            placeholder.disabled = options.placeholderDisabled === true;
            select.append(placeholder);
        }

        roles.forEach((role) => {
            const option = document.createElement("option");
            option.value = role;
            option.textContent = ROLE_OPTION_LABELS[role] || role;
            select.append(option);
        });

        if (roles.includes(previousValue) || (options.includeAll && previousValue === "")) {
            select.value = previousValue;
            return;
        }

        if (!options.includeAll && roles.length === 1) {
            select.value = roles[0];
        } else {
            select.value = "";
        }
    };

    const configureRoleControls = () => {
        configureRoleSelect(filterForm?.elements.role, { includeAll: true });
        configureRoleSelect(createForm?.elements.role, { placeholderDisabled: true });
        configureRoleSelect(editForm?.elements.role, { placeholderDisabled: true });
    };

    const createBadgeCell = (label, text, badgeClass, cellClass) => {
        const cell = document.createElement("span");
        cell.setAttribute("role", "cell");
        cell.className = cellClass;
        if (label) {
            cell.setAttribute("data-label", label);
        }
        const badge = document.createElement("i");
        badge.className = `badge ${badgeClass}`;
        badge.textContent = text;
        cell.append(badge);
        return cell;
    };

    const createDateCell = (label, value) => {
        const cell = window.PcsTable.textCell(label, formatDate(value));
        cell.classList.add("user-date-cell");
        return cell;
    };

    const createUserIdentityCell = (user) => {
        const cell = document.createElement("span");
        cell.className = "user-identity-cell";
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", "사용자");

        const name = document.createElement("strong");
        name.textContent = user.memberName || "-";
        const loginId = document.createElement("small");
        loginId.textContent = user.loginId || "-";
        cell.append(name, loginId);
        return cell;
    };

    const setPanelMode = (mode) => {
        panelViews.forEach((panel) => {
            const isActive = panel.dataset.userPanel === mode;
            panel.hidden = !isActive;
            panel.classList.toggle("is-active", isActive);
        });
    };

    const setDrawerOpen = (isOpen) => {
        detailDrawer?.classList.toggle("is-open", isOpen);
        detailDrawer?.setAttribute("aria-hidden", String(!isOpen));
        createDrawerButtons.forEach((button) => {
            button.setAttribute("aria-expanded", String(isOpen));
        });
    };

    const openDrawer = (trigger = null) => {
        if (trigger instanceof HTMLElement) {
            lastDrawerTrigger = detailDrawer?.contains(trigger) ? createDrawerButton : trigger;
        }
        setDrawerOpen(true);
    };

    const closeDrawer = (options = {}) => {
        selectedUserId = null;
        setDrawerOpen(false);
        updateSelectedRow();
        if (options.restoreFocus !== false && lastDrawerTrigger?.isConnected) {
            lastDrawerTrigger.focus({ preventScroll: true });
        }
    };

    const getSelectedUser = () => {
        return currentUsers.find((user) => String(user.memberId) === String(selectedUserId)) || null;
    };

    const updateSelectedRow = () => {
        table?.querySelectorAll("[data-user-id]").forEach((row) => {
            const isSelected = String(row.dataset.userId) === String(selectedUserId);
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
        });
    };

    const renderDetail = (user) => {
        if (!user) {
            return;
        }

        detailFields.name.textContent = user.memberName || "-";
        detailFields.loginId.textContent = user.loginId || "-";
        detailFields.createdAt.textContent = formatDate(user.createdAt);
        detailFields.updatedAt.textContent = formatDate(user.updatedAt);

        setBadge(detailFields.roleBadge, roleLabel(user.role), roleBadgeClass(user.role));
        setBadge(
                detailFields.passwordBadge,
                user.passwordStatus === "TEMPORARY" ? "변경 필요" : "비밀번호 정상",
                user.passwordStatus === "TEMPORARY" ? "badge-pending" : "badge-blue"
        );

        const canManage = canManageRole(user.role);
        const editButton = document.querySelector("[data-user-edit-mode]");
        if (editButton) {
            editButton.hidden = !canManage;
        }
        if (openPasswordModalButton) {
            openPasswordModalButton.hidden = !canManage;
        }
    };

    const fillEditForm = (user) => {
        if (!editForm || !user) {
            return;
        }
        configureRoleSelect(editForm.elements.role, { placeholderDisabled: true });
        editForm.elements.memberName.value = user.memberName || "";
        editForm.elements.loginId.value = user.loginId || "";
        editForm.elements.role.value = user.role || "";
    };

    const selectUser = (userId, trigger = null) => {
        selectedUserId = userId;
        const user = getSelectedUser();
        updateSelectedRow();
        if (!user) {
            return;
        }
        openDrawer(trigger);
        renderDetail(user);
        setPanelMode("detail");
    };

    const showCreatePanel = (trigger = null, options = {}) => {
        selectedUserId = null;
        updateSelectedRow();
        createForm?.reset();
        configureRoleSelect(createForm?.elements.role, { placeholderDisabled: true });
        setPanelMode("create");
        if (options.open === true) {
            openDrawer(trigger);
        }
    };

    const renderSummary = (pageData) => {
        if (!summaryFields.total || !pageData) {
            return;
        }

        const summary = pageData.summary || {};
        summaryFields.total.textContent = numberText(summary.totalCount ?? pageData.totalElements);
        summaryFields.admin.textContent = numberText(summary.adminCount ?? 0);
        summaryFields.staff.textContent = numberText(summary.staffCount ?? 0);
    };

    const renderRows = (items) => {
        clearRows();
        currentUsers = items;

        if (!items.length) {
            setEmptyMessage("조회된 사용자가 없습니다.");
            showCreatePanel(null, { open: false });
            return;
        }

        items.forEach((user) => {
            const row = document.createElement("div");
            row.className = "data-row management-data-row user-management-data-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.dataset.userId = String(user.memberId);

            row.append(
                createUserIdentityCell(user),
                createBadgeCell("계정 유형", roleLabel(user.role), roleBadgeClass(user.role), "user-role-cell"),
                createBadgeCell(
                        "비밀번호",
                        user.passwordStatus === "TEMPORARY" ? "변경 필요" : "정상",
                        user.passwordStatus === "TEMPORARY" ? "badge-pending" : "badge-blue",
                        "user-password-status-cell"
                ),
                createDateCell("가입일", user.createdAt),
                createDateCell("수정일", user.updatedAt)
            );

            row.addEventListener("click", () => selectUser(user.memberId, row));
            row.addEventListener("keydown", (event) => {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    selectUser(user.memberId, row);
                }
            });

            table.append(row);
        });

        if (getSelectedUser()) {
            renderDetail(getSelectedUser());
            updateSelectedRow();
        } else {
            showCreatePanel(null, { open: false });
        }
    };

    const updatePagination = (pageData) => {
        window.PcsPagination.updateControls({
            pageData,
            container: pagination,
            info: pageInfo,
            prevButton,
            nextButton
        });
    };

    const buildParams = (page) => {
        return window.PcsPagination.buildParams({
            page,
            size: PAGE_SIZE,
            form: filterForm
        });
    };

    const setLoading = (isLoading) => {
        if (!searchButton) {
            return;
        }
        searchButton.disabled = isLoading;
        searchButton.textContent = isLoading ? "조회 중" : "검색";
    };

    const readUserForm = (targetForm) => ({
        memberName: targetForm.elements.memberName.value.trim(),
        loginId: targetForm.elements.loginId.value.trim(),
        role: targetForm.elements.role.value || null
    });

    const loadCurrentSession = async (companyCode) => {
        currentSession = await window.PcsApi.getData(
            `/api/workspaces/${encodeURIComponent(companyCode)}/me`,
            {
                authRedirect: true,
                loginCompanyCode: companyCode
            }
        );

        if (!["OWNER", "ADMIN"].includes(currentSession?.role)) {
            window.PcsApi.redirectToInvalidAccess?.({ code: "AUTH-006" }, companyCode);
            return false;
        }

        configureRoleControls();
        return true;
    };

    const applyStaffPermissionSettings = (settings) => {
        const enabledPermissions = new Set(
                (settings?.permissions || [])
                        .filter((permission) => permission.enabled)
                        .map((permission) => permission.code)
        );

        staffPermissionInputs.forEach((input) => {
            input.checked = enabledPermissions.has(input.value);
        });
    };

    const loadStaffPermissionSettings = async (companyCode) => {
        if (!staffPermissionForm) {
            return;
        }

        try {
            setFormSaving(staffPermissionForm, true, "조회 중");
            const settings = await window.PcsApi.getData(
                    `/api/workspaces/${encodeURIComponent(companyCode)}/users/staff-permissions`,
                    {
                        authRedirect: true,
                        loginCompanyCode: companyCode
                    }
            );
            applyStaffPermissionSettings(settings);
        } catch (error) {
            showToast(error?.message || "직원 권한 설정을 불러오지 못했습니다.", "error");
        } finally {
            setFormSaving(staffPermissionForm, false);
        }
    };

    const readEnabledStaffPermissions = () => {
        return Array.from(staffPermissionInputs)
                .filter((input) => input.checked)
                .map((input) => input.value);
    };

    const openStaffPermissionModal = async () => {
        if (!staffPermissionModal) {
            return;
        }

        staffPermissionModal.showModal();
        await loadStaffPermissionSettings(getCompanyCode());
    };

    const closeStaffPermissionModal = () => {
        if (!staffPermissionModal || staffPermissionForm?.dataset.saving === "true") {
            return;
        }
        staffPermissionModal.close();
    };

    const loadUsers = async (page = 0, options = {}) => {
        const companyCode = getCompanyCode();
        if (!companyCode) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const preserveScroll = options.preserveScroll === true;
        const fetchPage = async (targetPage) => {
            const params = buildParams(targetPage);
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/users?${params.toString()}`,
                {
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );
            return window.PcsPagination.normalizePageData(data, PAGE_SIZE);
        };

        const requestPage = async () => {
            currentPage = page;
            setLoading(true);
            if (!preserveScroll) {
                setEmptyMessage("사용자 목록을 불러오는 중입니다.");
            }

            let pageData = await fetchPage(page);
            if (pageData.content.length === 0 && pageData.totalElements > 0 && pageData.page > 0) {
                pageData = await fetchPage(pageData.page - 1);
            }
            currentPage = pageData.page;

            if (options.keepSelection !== true) {
                selectedUserId = null;
            }

            renderRows(pageData.content);
            updatePagination(pageData);
            renderSummary(pageData);
        };

        const execute = async () => {
            try {
                await requestPage();
            } catch (error) {
                setEmptyMessage(error?.message || "사용자 목록을 불러오지 못했습니다.");
                updatePagination({
                    totalElements: 0,
                    totalPages: 0,
                    page: 0,
                    hasPrevious: false,
                    hasNext: false
                });
                showCreatePanel(null, { open: false });
            } finally {
                setLoading(false);
            }
        };

        if (preserveScroll) {
            await window.PcsPagination.withPreservedScroll(execute);
            return;
        }

        await execute();
    };

    const setPasswordModalMessage = (message = "") => {
        if (!passwordModalFields.message) {
            return;
        }
        passwordModalFields.message.textContent = message;
        passwordModalFields.message.hidden = !message;
    };

    const formatExpiry = (value) => {
        if (!value) {
            return "-";
        }
        const date = new Date(value);
        if (Number.isNaN(date.getTime())) {
            return value;
        }
        return new Intl.DateTimeFormat("ko-KR", {
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }).format(date);
    };

    const copyText = async (value) => {
        if (navigator.clipboard?.writeText) {
            await navigator.clipboard.writeText(value);
            return;
        }
        const input = document.createElement("textarea");
        input.value = value;
        input.style.position = "fixed";
        input.style.opacity = "0";
        document.body.append(input);
        input.select();
        document.execCommand("copy");
        input.remove();
    };

    const openPasswordModal = () => {
        const user = getSelectedUser();
        if (!passwordModal || !user) {
            return;
        }

        passwordModalFields.title.textContent = "임시 비밀번호를 발급할까요?";
        passwordModalFields.description.textContent = "현재 비밀번호를 사용할 수 없게 되고 새 임시 비밀번호가 발급됩니다.";
        passwordModalFields.targetName.textContent = `${user.memberName} (${user.loginId})`;
        passwordModalFields.tempPasswordContainer.hidden = true;
        passwordModalFields.tempPasswordValue.textContent = "-";
        passwordModalFields.tempPasswordExpiryContainer.hidden = true;
        passwordModalFields.tempPasswordExpiry.textContent = "-";
        passwordModalFields.notice.hidden = true;
        
        setPasswordModalMessage();
        confirmPasswordButton.hidden = false;
        passwordModal.showModal();
    };

    const showCreatedTemporaryPassword = (created) => {
        const user = created?.member;
        if (!passwordModal || !user) {
            return;
        }
        passwordModalFields.title.textContent = "사용자 등록이 완료되었습니다.";
        passwordModalFields.description.textContent = "아래 임시 비밀번호를 지금 안전하게 전달해 주세요.";
        passwordModalFields.targetName.textContent = `${user.memberName} (${user.loginId})`;
        passwordModalFields.tempPasswordContainer.hidden = false;
        passwordModalFields.tempPasswordValue.textContent = created.temporaryPassword || "-";
        passwordModalFields.tempPasswordExpiryContainer.hidden = false;
        passwordModalFields.tempPasswordExpiry.textContent = formatExpiry(created.expiresAt);
        passwordModalFields.notice.hidden = false;
        confirmPasswordButton.hidden = true;
        setPasswordModalMessage();
        passwordModal.showModal();
    };

    const closePasswordModal = () => {
        if (!passwordModal || passwordModal.dataset.saving === "true") {
            return;
        }
        setPasswordModalMessage();
        passwordModalFields.tempPasswordValue.textContent = "-";
        passwordModal.close();
    };

    if (
        !filterForm ||
        !table ||
        !pagination ||
        !window.PcsApi ||
        !window.PcsPagination ||
        !window.PcsWorkspace ||
        !window.PcsFormat ||
        !window.PcsFeedback ||
        !window.PcsForm ||
        !window.PcsTable
    ) {
        return;
    }

    const initializePage = async () => {
        const companyCode = getCompanyCode();

        try {
            if (window.PcsApi.validateWorkspacePublic) {
                const isValidWorkspace = await window.PcsApi.validateWorkspacePublic(companyCode);
                if (!isValidWorkspace) {
                    return;
                }
            }
            const canUsePage = await loadCurrentSession(companyCode);
            if (!canUsePage) {
                return;
            }
            await loadStaffPermissionSettings(companyCode);
            await loadUsers(0);
        } catch (error) {
            setEmptyMessage(error?.message || "업체 주소를 확인할 수 없습니다.");
        }
    };

    filterForm.addEventListener("submit", (event) => {
        event.preventDefault();
        loadUsers(0);
    });

    document.querySelectorAll("[data-user-create-mode]").forEach((button) => {
        button.addEventListener("click", (event) => showCreatePanel(event.currentTarget, { open: true }));
    });

    createDrawerButtons.forEach((button) => {
        button.addEventListener("click", (event) => {
            showCreatePanel(event.currentTarget, { open: true });
        });
    });

    document.querySelectorAll("[data-close-user-drawer]").forEach((button) => {
        button.addEventListener("click", () => closeDrawer());
    });

    document.querySelector("[data-user-edit-mode]")?.addEventListener("click", () => {
        const user = getSelectedUser();
        if (!user) {
            return;
        }
        fillEditForm(user);
        setPanelMode("edit");
    });

    document.querySelector("[data-user-detail-mode]")?.addEventListener("click", () => {
        const user = getSelectedUser();
        if (!user) {
            showCreatePanel(null, { open: false });
            return;
        }
        renderDetail(user);
        setPanelMode("detail");
    });

    window.PcsDrawer?.bindDismiss({
        drawer: detailDrawer,
        close: closeDrawer,
        keepOpenSelector: "[data-user-create-drawer], [data-user-id], [data-open-staff-permission-modal]"
    });

    createForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        if (!companyCode || createForm.dataset.saving === "true") {
            return;
        }

        try {
            setFormSaving(createForm, true);
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/users`,
                {
                    method: "POST",
                    body: readUserForm(createForm),
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            selectedUserId = data.member.memberId;
            await loadUsers(0, { keepSelection: true });
            showToast("사용자를 등록했습니다.", "success");
            createForm.reset();
            configureRoleSelect(createForm.elements.role, { placeholderDisabled: true });
            showCreatedTemporaryPassword(data);
        } catch (error) {
            showToast(error?.message || "사용자를 등록하지 못했습니다.", "error");
        } finally {
            setFormSaving(createForm, false);
        }
    });

    editForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        const user = getSelectedUser();
        if (!companyCode || !user || editForm.dataset.saving === "true") {
            return;
        }

        try {
            setFormSaving(editForm, true);
            
            await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/users/${user.memberId}`,
                {
                    method: "PATCH",
                    body: { memberName: editForm.elements.memberName.value.trim(), role: editForm.elements.role.value },
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            selectedUserId = user.memberId;
            await loadUsers(currentPage, { keepSelection: true, preserveScroll: true });
            const refreshedUser = getSelectedUser();
            if (refreshedUser) {
                renderDetail(refreshedUser);
                setPanelMode("detail");
            }
            showToast("사용자 정보를 수정했습니다.", "success");
        } catch (error) {
            showToast(error?.message || "사용자를 수정하지 못했습니다.", "error");
        } finally {
            setFormSaving(editForm, false);
        }
    });

    staffPermissionForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        if (!companyCode || staffPermissionForm.dataset.saving === "true") {
            return;
        }

        try {
            setFormSaving(staffPermissionForm, true);
            const settings = await window.PcsApi.getData(
                    `/api/workspaces/${encodeURIComponent(companyCode)}/users/staff-permissions`,
                    {
                        method: "PATCH",
                        body: {
                            enabledPermissions: readEnabledStaffPermissions()
                        },
                        authRedirect: true,
                        loginCompanyCode: companyCode
                    }
            );
            applyStaffPermissionSettings(settings);
            showToast("작업자 권한 설정을 저장했습니다.", "success");
            staffPermissionModal?.close();
        } catch (error) {
            showToast(error?.message || "작업자 권한 설정을 저장하지 못했습니다.", "error");
        } finally {
            setFormSaving(staffPermissionForm, false);
        }
    });

    openStaffPermissionModalButtons.forEach((button) => {
        button.addEventListener("click", openStaffPermissionModal);
    });

    closeStaffPermissionModalButtons.forEach((button) => {
        button.addEventListener("click", closeStaffPermissionModal);
    });

    staffPermissionModal?.addEventListener("click", (event) => {
        if (event.target === staffPermissionModal) {
            closeStaffPermissionModal();
        }
    });

    staffPermissionModal?.addEventListener("cancel", (event) => {
        if (staffPermissionForm?.dataset.saving === "true") {
            event.preventDefault();
        }
    });

    openPasswordModalButton?.addEventListener("click", openPasswordModal);

    closePasswordModalButtons.forEach((button) => {
        button.addEventListener("click", closePasswordModal);
    });

    passwordModal?.addEventListener("click", (event) => {
        if (event.target === passwordModal && !confirmPasswordButton.disabled) {
            closePasswordModal();
        }
    });

    confirmPasswordButton?.addEventListener("click", async () => {
        const companyCode = getCompanyCode();
        const user = getSelectedUser();
        if (!companyCode || !user || passwordModal?.dataset.saving === "true") {
            return;
        }

        try {
            passwordModal.dataset.saving = "true";
            confirmPasswordButton.disabled = true;
            confirmPasswordButton.textContent = "발급 중";
            
            const response = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/users/${user.memberId}/temporary-password`,
                {
                    method: "POST",
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            passwordModalFields.tempPasswordContainer.hidden = false;
            passwordModalFields.tempPasswordValue.textContent = response.temporaryPassword || "생성 완료";
            passwordModalFields.tempPasswordExpiryContainer.hidden = false;
            passwordModalFields.tempPasswordExpiry.textContent = formatExpiry(response.expiresAt);
            passwordModalFields.notice.hidden = false;
            confirmPasswordButton.hidden = true;
            showToast("비밀번호를 초기화했습니다.", "success");
        } catch (error) {
            const message = error?.message || "비밀번호를 초기화하지 못했습니다.";
            setPasswordModalMessage(message);
            showToast(message, "error");
        } finally {
            passwordModal.dataset.saving = "false";
            confirmPasswordButton.disabled = false;
            confirmPasswordButton.textContent = "발급하기";
        }
    });

    copyTemporaryPasswordButton?.addEventListener("click", async () => {
        const temporaryPassword = passwordModalFields.tempPasswordValue.textContent.trim();
        if (!temporaryPassword || temporaryPassword === "-") {
            return;
        }
        try {
            await copyText(temporaryPassword);
            showToast("임시 비밀번호를 복사했습니다.", "success");
        } catch (error) {
            showToast("임시 비밀번호를 복사하지 못했습니다.", "error");
        }
    });


    prevButton.addEventListener("click", () => {
        if (currentPage > 0) {
            loadUsers(currentPage - 1, { preserveScroll: true });
        }
    });

    nextButton.addEventListener("click", () => {
        loadUsers(currentPage + 1, { preserveScroll: true });
    });

    initializePage();
})();
