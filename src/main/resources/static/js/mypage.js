(function () {
    const companyCode = window.PcsWorkspace.getCompanyCode();

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

    const profileForm = document.querySelector("[data-mypage-profile-form]");
    const ownerCompanyForm = document.querySelector("[data-owner-company-form]");
    const passwordForm = document.querySelector("[data-mypage-password-form]");
    const passwordSection = document.querySelector("[data-password-section]");
    const passwordRequiredNotice = document.querySelector("[data-password-required-notice]");
    const showToast = window.PcsFeedback.toast;
    const setFormSaving = window.PcsForm.setSaving;

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

    const trimOrNull = (value) => {
        const normalized = String(value || "").trim();
        return normalized || null;
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

    const updateWorkspaceLinks = (resolvedCompanyCode) => {
        document.querySelectorAll("[data-users-link]").forEach((link) => {
            link.href = `/w/${encodeURIComponent(resolvedCompanyCode)}/users`;
        });
        document.querySelectorAll("[data-dashboard-link]").forEach((link) => {
            link.href = `/w/${encodeURIComponent(resolvedCompanyCode)}/dashboard`;
        });
    };

    const renderSession = (session) => {
        const role = String(session?.role || "").toUpperCase();
        const name = session?.name || "접속 계정";
        const loginId = session?.loginId || "-";
        const resolvedCompanyCode = session?.companyCode || companyCode;
        const roleLabel = roleLabels[role] || role || "-";
        const passwordStatusLabel = passwordStatusLabels[session?.passwordStatus] || session?.passwordStatus || "-";
        const passwordChangeRequired = session?.passwordStatus === "TEMPORARY";

        text("[data-mypage-name]", name);
        text("[data-mypage-description]", `${loginId} 계정으로 접속 중입니다.`);
        text("[data-mypage-company-code]", resolvedCompanyCode);
        text("[data-mypage-login-id]", loginId);
        text("[data-mypage-role]", roleLabel);
        text("[data-mypage-role-badge]", roleLabel);
        text("[data-mypage-password-status]", passwordStatusLabel);
        text("[data-side-name]", name);
        text("[data-side-role]", roleLabel);
        text("[data-side-company-code]", resolvedCompanyCode);
        text("[data-side-login-id]", loginId);
        text("[data-session-name]", `${name} (${role})`);

        value("[data-member-name-input]", name);
        value("[data-member-login-id-input]", loginId);
        value("[data-member-role-input]", roleLabel);
        value("[data-member-password-status-input]", passwordStatusLabel);
        value("[data-owner-company-code]", resolvedCompanyCode);

        updateWorkspaceLinks(resolvedCompanyCode);
        showRoleSection(role);
        renderStaffPermissions(session?.staffPermissions || []);
        passwordRequiredNotice.hidden = !passwordChangeRequired;
        document.body.classList.toggle("is-password-change-required", passwordChangeRequired);

        if (passwordChangeRequired) {
            profileForm?.querySelectorAll("input, button").forEach((control) => {
                control.disabled = true;
            });
            ownerCompanyForm?.querySelectorAll("input, button").forEach((control) => {
                control.disabled = true;
            });
            const currentPasswordInput = passwordForm?.elements.currentPassword;
            if (currentPasswordInput) {
                currentPasswordInput.placeholder = "발급받은 임시 비밀번호";
            }
        }
    };

    const renderOwnerCompany = (company) => {
        value("[data-owner-company-code]", company?.companyCode || companyCode);
        value("[data-owner-company-name]", company?.companyName || "");
        value("[data-owner-company-email]", company?.representativeEmail || "");
        value("[data-owner-company-phone]", company?.representativePhone || "");
        value("[data-owner-company-business-no]", company?.businessRegistrationNo || "");
    };

    const loadOwnerCompany = async () => {
        const company = await window.PcsApi.getData("/api/owners/company", {
            authRedirect: true,
            loginCompanyCode: companyCode
        });
        renderOwnerCompany(company);
    };

    const loadMypage = async () => {
        if (!companyCode || !window.PcsApi) {
            return;
        }

        try {
            const session = await window.PcsApi.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/mypage`, {
                authRedirect: true,
                loginCompanyCode: companyCode
            });
            renderSession(session);

            if (session?.role === "OWNER" && session?.passwordStatus !== "TEMPORARY") {
                await loadOwnerCompany();
            }

            if (session?.passwordStatus === "TEMPORARY") {
                passwordSection?.scrollIntoView({ block: "start" });
                passwordForm?.elements.currentPassword?.focus({ preventScroll: true });
            }
        } catch (error) {
            text("[data-mypage-name]", "계정 확인 실패");
            text("[data-mypage-description]", "로그인 정보를 다시 확인해 주세요.");
            showToast(error.message || "마이페이지 정보를 불러오지 못했습니다.", "error");
        }
    };

    const bindProfileForm = () => {
        if (!profileForm) {
            return;
        }

        profileForm.addEventListener("submit", async (event) => {
            event.preventDefault();

            const name = String(profileForm.elements.name?.value || "").trim();
            if (!name) {
                showToast("이름을 입력해 주세요.", "warning");
                profileForm.elements.name?.focus();
                return;
            }

            setFormSaving(profileForm, true, "저장 중");
            try {
                const result = await window.PcsApi.request(`/api/workspaces/${encodeURIComponent(companyCode)}/mypage`, {
                    method: "PATCH",
                    body: { name },
                    authRedirect: true,
                    loginCompanyCode: companyCode
                });
                renderSession(result.data);
                showToast(result.message || "내 정보가 저장되었습니다.", "success");
            } catch (error) {
                showToast(error.message || "내 정보를 저장하지 못했습니다.", "error");
            } finally {
                setFormSaving(profileForm, false);
            }
        });
    };

    const bindOwnerCompanyForm = () => {
        if (!ownerCompanyForm) {
            return;
        }

        ownerCompanyForm.addEventListener("submit", async (event) => {
            event.preventDefault();

            const companyName = String(ownerCompanyForm.elements.companyName?.value || "").trim();
            if (!companyName) {
                showToast("회사명을 입력해 주세요.", "warning");
                ownerCompanyForm.elements.companyName?.focus();
                return;
            }

            const payload = {
                companyName,
                representativeEmail: trimOrNull(ownerCompanyForm.elements.representativeEmail?.value),
                representativePhone: trimOrNull(ownerCompanyForm.elements.representativePhone?.value),
                businessRegistrationNo: trimOrNull(ownerCompanyForm.elements.businessRegistrationNo?.value)
            };

            setFormSaving(ownerCompanyForm, true, "저장 중");
            try {
                const result = await window.PcsApi.request("/api/owners/company", {
                    method: "PATCH",
                    body: payload,
                    authRedirect: true,
                    loginCompanyCode: companyCode
                });
                renderOwnerCompany(result.data);
                showToast(result.message || "회사 정보가 저장되었습니다.", "success");
            } catch (error) {
                showToast(error.message || "회사 정보를 저장하지 못했습니다.", "error");
            } finally {
                setFormSaving(ownerCompanyForm, false);
            }
        });
    };

    const bindPasswordForm = () => {
        if (!passwordForm) {
            return;
        }

        passwordForm.addEventListener("submit", async (event) => {
            event.preventDefault();

            const currentPassword = passwordForm.elements.currentPassword?.value || "";
            const newPassword = passwordForm.elements.newPassword?.value || "";
            const newPasswordConfirm = passwordForm.elements.newPasswordConfirm?.value || "";

            if (!currentPassword || !newPassword || !newPasswordConfirm) {
                showToast("비밀번호 입력 항목을 모두 채워 주세요.", "warning");
                return;
            }
            if (newPassword.length < 8) {
                showToast("새 비밀번호는 8자 이상으로 입력해 주세요.", "warning");
                passwordForm.elements.newPassword?.focus();
                return;
            }
            if (newPassword !== newPasswordConfirm) {
                showToast("새 비밀번호 확인이 일치하지 않습니다.", "warning");
                passwordForm.elements.newPasswordConfirm?.focus();
                return;
            }

            setFormSaving(passwordForm, true, "변경 중");
            try {
                const result = await window.PcsApi.request(`/api/workspaces/${encodeURIComponent(companyCode)}/mypage/password`, {
                    method: "PATCH",
                    body: {
                        currentPassword,
                        newPassword,
                        newPasswordConfirm
                    },
                    authRedirect: true,
                    loginCompanyCode: companyCode
                });
                passwordForm.reset();
                showToast(result.message || "비밀번호가 변경되었습니다. 다시 로그인해 주세요.", "success");
                await window.PcsApi.logout();
                window.location.href = `/w/${encodeURIComponent(companyCode)}`;
            } catch (error) {
                showToast(error.message || "비밀번호를 변경하지 못했습니다.", "error");
            } finally {
                setFormSaving(passwordForm, false);
            }
        });
    };

    bindProfileForm();
    bindOwnerCompanyForm();
    bindPasswordForm();
    loadMypage();
})();
