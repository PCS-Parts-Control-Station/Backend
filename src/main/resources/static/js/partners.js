(function () {
    const PAGE_SIZE = 10;

    const partnerTypeLabels = {
        PC_CAFE: "PC방",
        PERSON: "개인",
        COMPANY: "기업",
        ETC: "기타"
    };

    const partnerTypeBadgeClasses = {
        PC_CAFE: "badge-pending",
        PERSON: "badge-inactive",
        COMPANY: "badge-blue",
        ETC: "badge-inactive"
    };

    const partnerRoleLabels = {
        SUPPLIER: "공급처",
        CUSTOMER: "고객",
        BOTH: "공급+고객"
    };

    const partnerRoleBadgeClasses = {
        SUPPLIER: "badge-info",
        CUSTOMER: "badge-info",
        BOTH: "badge-active"
    };

    const form = document.querySelector(".management-filter-form");
    const table = document.querySelector("[data-partner-table]");
    const pagination = document.querySelector("[data-partner-pagination]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const searchButton = form?.querySelector("button[type='submit']");
    const summaryTotal = document.querySelector("[data-summary-total]");
    const summarySupplier = document.querySelector("[data-summary-supplier]");
    const summaryCustomer = document.querySelector("[data-summary-customer]");
    const summaryActive = document.querySelector("[data-summary-active]");
    const panelViews = document.querySelectorAll("[data-partner-panel]");
    const detailDrawer = document.querySelector("[data-partner-detail-drawer]");
    const createDrawerButtons = document.querySelectorAll("[data-partner-create-drawer]");
    const createDrawerButton = Array.from(createDrawerButtons)
            .find((button) => !button.closest("[data-workspace-quick-bar]"))
            || createDrawerButtons[0]
            || null;
    const createForm = document.querySelector("[data-partner-create-form]");
    const editForm = document.querySelector("[data-partner-edit-form]");
    const detailFields = {
        name: document.querySelector("[data-detail-name]"),
        type: document.querySelector("[data-detail-type]"),
        role: document.querySelector("[data-detail-role]"),
        active: document.querySelector("[data-detail-active]"),
        phone: document.querySelector("[data-detail-phone]"),
        email: document.querySelector("[data-detail-email]"),
        address: document.querySelector("[data-detail-address]"),
        memo: document.querySelector("[data-detail-memo]"),
        updatedAt: document.querySelector("[data-detail-updated-at]")
    };
    let currentPage = 0;
    let currentPartners = [];
    let selectedPartnerId = null;
    let lastDrawerTrigger = null;

    const getCompanyCode = window.PcsWorkspace.getCompanyCode;
    const updateWorkspaceLinks = window.PcsWorkspace.updateWorkspaceLinks;
    const formatDate = window.PcsFormat.date;
    const numberText = window.PcsFormat.number;
    const clearRows = () => window.PcsTable.clearRows(table);
    const setEmptyMessage = (message) => window.PcsTable.emptyRow(table, {
        rowClassName: "data-row management-data-row empty-data-row",
        message
    });
    const createTextCell = window.PcsTable.textCell;

    const createBadgeCell = (label, badgeText, badgeClass) => {
        const cell = document.createElement("span");
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", label);

        const badge = document.createElement("em");
        badge.className = `badge ${badgeClass}`;
        badge.textContent = badgeText;
        cell.append(badge);
        return cell;
    };

    const setPanelMode = (mode) => {
        panelViews.forEach((panel) => {
            const isActive = panel.dataset.partnerPanel === mode;
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
        selectedPartnerId = null;
        setDrawerOpen(false);
        updateSelectedRow();
        if (options.restoreFocus !== false && lastDrawerTrigger?.isConnected) {
            lastDrawerTrigger.focus({ preventScroll: true });
        }
    };

    const getSelectedPartner = () => {
        return currentPartners.find((partner) => String(partner.partnerId) === String(selectedPartnerId)) || null;
    };

    const updateSelectedRow = () => {
        table?.querySelectorAll("[data-partner-id]").forEach((row) => {
            const isSelected = String(row.dataset.partnerId) === String(selectedPartnerId);
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
        });
    };

    const setDetailBadge = (element, text, badgeClass) => {
        if (!element) {
            return;
        }
        element.className = `badge ${badgeClass}`;
        element.textContent = text;
    };

    const renderDetail = (partner) => {
        if (!partner) {
            return;
        }
        detailFields.name.textContent = partner.partnerName || "-";
        setDetailBadge(
                detailFields.type,
                partnerTypeLabels[partner.partnerType] || partner.partnerType || "-",
                partnerTypeBadgeClasses[partner.partnerType] || "badge-inactive"
        );
        setDetailBadge(
                detailFields.role,
                partnerRoleLabels[partner.partnerRole] || partner.partnerRole || "-",
                partnerRoleBadgeClasses[partner.partnerRole] || "badge-info"
        );
        setDetailBadge(
                detailFields.active,
                partner.active ? "거래 가능" : "거래 불가",
                partner.active ? "badge-available" : "badge-inactive"
        );
        detailFields.phone.textContent = partner.phone || "-";
        detailFields.email.textContent = partner.email || "-";
        detailFields.address.textContent = partner.address || "-";
        detailFields.memo.textContent = partner.memo || "-";
        detailFields.updatedAt.textContent = formatDate(partner.updatedAt);

    };

    const fillEditForm = (partner) => {
        if (!editForm || !partner) {
            return;
        }
        editForm.elements.partnerName.value = partner.partnerName || "";
        editForm.elements.partnerType.value = partner.partnerType || "";
        editForm.elements.partnerRole.value = partner.partnerRole || "";
        editForm.elements.phone.value = partner.phone || "";
        editForm.elements.email.value = partner.email || "";
        editForm.elements.address.value = partner.address || "";
        editForm.elements.memo.value = partner.memo || "";
        editForm.elements.active.checked = partner.active === true;
    };

    const selectPartner = (partnerId, trigger = null) => {
        selectedPartnerId = partnerId;
        const partner = getSelectedPartner();
        updateSelectedRow();
        if (!partner) {
            return;
        }
        openDrawer(trigger);
        renderDetail(partner);
        setPanelMode("detail");
    };

    const showCreatePanel = (trigger = null, options = {}) => {
        selectedPartnerId = null;
        updateSelectedRow();
        createForm?.reset();
        setPanelMode("create");
        if (options.open === true) {
            openDrawer(trigger);
        }
    };

    const renderRows = (items) => {
        clearRows();
        currentPartners = items;
        if (!items.length) {
            setEmptyMessage("조회된 거래처가 없습니다.");
            showCreatePanel(null, { open: false });
            return;
        }

        items.forEach((partner) => {
            const row = document.createElement("div");
            row.className = "data-row management-data-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.dataset.partnerId = String(partner.partnerId);

            row.append(
                createTextCell("거래처명", partner.partnerName, "strong"),
                createBadgeCell(
                    "유형",
                    partnerTypeLabels[partner.partnerType] || partner.partnerType || "-",
                    partnerTypeBadgeClasses[partner.partnerType] || "badge-inactive"
                ),
                createBadgeCell(
                    "역할",
                    partnerRoleLabels[partner.partnerRole] || partner.partnerRole || "-",
                    partnerRoleBadgeClasses[partner.partnerRole] || "badge-info"
                ),
                createBadgeCell(
                    "거래 상태",
                    partner.active ? "거래 가능" : "거래 불가",
                    partner.active ? "badge-available" : "badge-inactive"
                ),
                createTextCell("연락처", partner.phone),
                createTextCell("수정일", formatDate(partner.updatedAt))
            );

            row.addEventListener("click", () => selectPartner(partner.partnerId, row));
            row.addEventListener("keydown", (event) => {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    selectPartner(partner.partnerId, row);
                }
            });

            table.append(row);
        });

        if (getSelectedPartner()) {
            renderDetail(getSelectedPartner());
            updateSelectedRow();
        } else {
            showCreatePanel(null, { open: false });
        }
    };

    const updateSummary = (pageData) => {
        const summary = pageData.summary || {};
        summaryTotal.textContent = numberText(summary.totalCount ?? pageData.totalElements);
        summarySupplier.textContent = numberText(summary.supplierCount);
        summaryCustomer.textContent = numberText(summary.customerCount);
        summaryActive.textContent = numberText(summary.activeCount);
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
            form
        });
    };

    const setLoading = (isLoading) => {
        if (searchButton) {
            searchButton.disabled = isLoading;
            searchButton.textContent = isLoading ? "조회 중" : "검색";
        }
    };

    const showToast = window.PcsFeedback.toast;
    const setFormSaving = window.PcsForm.setSaving;

    const readPartnerForm = (targetForm, options = {}) => ({
        partnerName: targetForm.elements.partnerName.value.trim(),
        partnerType: targetForm.elements.partnerType.value,
        partnerRole: targetForm.elements.partnerRole.value,
        phone: targetForm.elements.phone.value.trim() || null,
        email: targetForm.elements.email.value.trim() || null,
        address: targetForm.elements.address.value.trim() || null,
        memo: targetForm.elements.memo.value.trim() || null,
        ...(options.includeActive ? { active: targetForm.elements.active?.checked !== false } : {})
    });

    const loadPartners = async (page = 0, options = {}) => {
        const companyCode = getCompanyCode();
        if (!companyCode) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const preserveScroll = options.preserveScroll === true;

        const requestPage = async () => {
            currentPage = page;
            setLoading(true);
            if (!preserveScroll) {
                setEmptyMessage("거래처 목록을 불러오는 중입니다.");
            }
            const params = buildParams(page);
            const data = await window.PcsApi.getData(
                    `/api/workspaces/${encodeURIComponent(companyCode)}/partners?${params.toString()}`,
                    {
                        authRedirect: true,
                        loginCompanyCode: companyCode
                    }
            );
            const pageData = window.PcsPagination.normalizePageData(data, PAGE_SIZE);
            currentPage = pageData.page;
            if (options.keepSelection !== true) {
                selectedPartnerId = null;
            }
            renderRows(pageData.content);
            updateSummary(pageData);
            updatePagination(pageData);
        };

        const execute = async () => {
            try {
                await requestPage();
            } catch (error) {
                setEmptyMessage(error?.message || "거래처 목록을 불러오지 못했습니다.");
                updateSummary({
                    totalElements: 0,
                    summary: {
                        totalCount: 0,
                        supplierCount: 0,
                        customerCount: 0,
                        activeCount: 0
                    }
                });
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

    if (!form || !table || !pagination || !window.PcsApi || !window.PcsPagination) {
        return;
    }

    const initializePage = async () => {
        const companyCode = getCompanyCode();
        updateWorkspaceLinks(companyCode);

        try {
            if (window.PcsApi.validateWorkspacePublic) {
                const isValidWorkspace = await window.PcsApi.validateWorkspacePublic(companyCode);
                if (!isValidWorkspace) {
                    return;
                }
            }
            await loadPartners(0);
        } catch (error) {
            setEmptyMessage(error?.message || "업체 주소를 확인할 수 없습니다.");
        }
    };

    form.addEventListener("submit", (event) => {
        event.preventDefault();
        loadPartners(0);
    });

    document.querySelectorAll("[data-partner-create-mode]").forEach((button) => {
        button.addEventListener("click", (event) => showCreatePanel(event.currentTarget, { open: true }));
    });

    createDrawerButtons.forEach((button) => {
        button.addEventListener("click", (event) => {
            showCreatePanel(event.currentTarget, { open: true });
        });
    });

    document.querySelectorAll("[data-close-partner-drawer]").forEach((button) => {
        button.addEventListener("click", () => closeDrawer());
    });

    document.querySelector("[data-partner-edit-mode]")?.addEventListener("click", () => {
        const partner = getSelectedPartner();
        if (!partner) {
            return;
        }
        fillEditForm(partner);
        setPanelMode("edit");
    });

    document.querySelector("[data-partner-detail-mode]")?.addEventListener("click", () => {
        const partner = getSelectedPartner();
        if (!partner) {
            showCreatePanel(null, { open: false });
            return;
        }
        renderDetail(partner);
        setPanelMode("detail");
    });

    document.addEventListener("click", (event) => {
        if (!detailDrawer?.classList.contains("is-open")) {
            return;
        }
        const target = event.target;
        if (!(target instanceof Element)) {
            return;
        }
        if (
            detailDrawer.contains(target) ||
            target.closest("[data-partner-create-drawer]") ||
            target.closest("[data-partner-id]")
        ) {
            return;
        }
        closeDrawer({ restoreFocus: false });
    });

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && detailDrawer?.classList.contains("is-open")) {
            closeDrawer();
        }
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
                `/api/workspaces/${encodeURIComponent(companyCode)}/partners`,
                {
                    method: "POST",
                    body: readPartnerForm(createForm, { includeActive: true }),
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            selectedPartnerId = data.partnerId;
            await loadPartners(0, { keepSelection: true });
            showToast("거래처를 등록했습니다.", "success");
            createForm.reset();
        } catch (error) {
            showToast(error?.message || "거래처를 등록하지 못했습니다.", "error");
        } finally {
            setFormSaving(createForm, false);
        }
    });

    editForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        const partner = getSelectedPartner();
        if (!companyCode || !partner || editForm.dataset.saving === "true") {
            return;
        }

        try {
            setFormSaving(editForm, true);
            await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/partners/${partner.partnerId}`,
                {
                    method: "PATCH",
                    body: readPartnerForm(editForm, { includeActive: true }),
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            await loadPartners(currentPage, { keepSelection: true, preserveScroll: true });
            const refreshedPartner = getSelectedPartner();
            if (refreshedPartner) {
                renderDetail(refreshedPartner);
                setPanelMode("detail");
            }
            showToast("거래처 정보를 수정했습니다.", "success");
        } catch (error) {
            showToast(error?.message || "거래처를 수정하지 못했습니다.", "error");
        } finally {
            setFormSaving(editForm, false);
        }
    });

    prevButton.addEventListener("click", () => {
        if (currentPage > 0) {
            loadPartners(currentPage - 1, { preserveScroll: true });
        }
    });

    nextButton.addEventListener("click", () => {
        loadPartners(currentPage + 1, { preserveScroll: true });
    });

    initializePage();
})();
