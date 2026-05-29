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

    const form = document.querySelector(".partner-filter-form");
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

    const getCompanyCode = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : "";
    };

    const updateWorkspaceLinks = (companyCode) => {
        if (!companyCode) {
            return;
        }
        document.querySelectorAll("a[href^='/w/pcs-seoul']").forEach((link) => {
            link.href = link.getAttribute("href").replace("/w/pcs-seoul", `/w/${encodeURIComponent(companyCode)}`);
        });
        const brandWorkspace = document.querySelector(".sidebar-brand small");
        if (brandWorkspace) {
            brandWorkspace.textContent = companyCode;
        }
    };

    const formatDate = (value) => {
        if (!value) {
            return "-";
        }
        if (Array.isArray(value)) {
            const [year, month, day] = value;
            if (year && month && day) {
                return `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
            }
        }
        return String(value).slice(0, 10);
    };

    const numberText = (value) => {
        return Number(value || 0).toLocaleString("ko-KR");
    };

    const clearRows = () => {
        table?.querySelectorAll(".data-row:not(.table-head)").forEach((row) => row.remove());
    };

    const setEmptyMessage = (message) => {
        clearRows();
        const row = document.createElement("div");
        row.className = "data-row partner-data-row partner-empty-row";
        row.setAttribute("role", "row");

        const cell = document.createElement("span");
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", "안내");
        cell.textContent = message;

        row.append(cell);
        table.append(row);
    };

    const createTextCell = (label, text, tagName = "span") => {
        const cell = document.createElement(tagName);
        cell.setAttribute("role", "cell");
        if (label) {
            cell.setAttribute("data-label", label);
        }
        cell.textContent = text || "-";
        return cell;
    };

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
                partner.active ? "badge-available" : "badge-unavailable"
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

    const selectPartner = (partnerId) => {
        selectedPartnerId = partnerId;
        const partner = getSelectedPartner();
        updateSelectedRow();
        if (!partner) {
            return;
        }
        renderDetail(partner);
        setPanelMode("detail");
    };

    const showCreatePanel = () => {
        selectedPartnerId = null;
        updateSelectedRow();
        createForm?.reset();
        setPanelMode("create");
    };

    const renderRows = (items) => {
        clearRows();
        currentPartners = items;
        if (!items.length) {
            setEmptyMessage("조회된 거래처가 없습니다.");
            showCreatePanel();
            return;
        }

        items.forEach((partner) => {
            const row = document.createElement("div");
            row.className = "data-row partner-data-row is-selectable";
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
                    partner.active ? "badge-available" : "badge-unavailable"
                ),
                createTextCell("연락처", partner.phone),
                createTextCell("수정일", formatDate(partner.updatedAt))
            );

            row.addEventListener("click", () => selectPartner(partner.partnerId));
            row.addEventListener("keydown", (event) => {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    selectPartner(partner.partnerId);
                }
            });

            table.append(row);
        });

        if (getSelectedPartner()) {
            renderDetail(getSelectedPartner());
            updateSelectedRow();
        } else {
            showCreatePanel();
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
                showCreatePanel();
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
        button.addEventListener("click", showCreatePanel);
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
            showCreatePanel();
            return;
        }
        renderDetail(partner);
        setPanelMode("detail");
    });

    createForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        if (!companyCode) return;

        const body = {
            partnerName: createForm.elements.partnerName.value.trim(),
            partnerType: createForm.elements.partnerType.value,
            partnerRole: createForm.elements.partnerRole.value,
            phone: createForm.elements.phone.value.trim() || null,
            email: createForm.elements.email.value.trim() || null,
            address: createForm.elements.address.value.trim() || null,
            memo: createForm.elements.memo.value.trim() || null
        };

        try {
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/partners`,
                {
                    method: "POST",
                    body,
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );
            alert("거래처 등록이 완료되었습니다.");
            selectedPartnerId = data.partnerId;
            await loadPartners(0, { keepSelection: true });
        } catch (error) {
            alert(error?.message || "거래처를 등록하지 못했습니다.");
        }
    });

    editForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        const partner = getSelectedPartner();
        if (!companyCode || !partner) {
            return;
        }

        const body = {
            partnerName: editForm.elements.partnerName.value.trim(),
            partnerType: editForm.elements.partnerType.value,
            partnerRole: editForm.elements.partnerRole.value,
            phone: editForm.elements.phone.value.trim() || null,
            email: editForm.elements.email.value.trim() || null,
            address: editForm.elements.address.value.trim() || null,
            memo: editForm.elements.memo.value.trim() || null
        };

        try {
            // 1. 정보 수정
            const updated = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/partners/${partner.partnerId}`,
                {
                    method: "PATCH",
                    body,
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            // 2. active 변경이 필요할 경우 호출
            const activeChanged = editForm.elements.active.checked !== partner.active;
            if (activeChanged) {
                await window.PcsApi.request(
                    `/api/workspaces/${encodeURIComponent(companyCode)}/partners/${partner.partnerId}/active`,
                    {
                        method: "PATCH",
                        body: { active: editForm.elements.active.checked },
                        authRedirect: true,
                        loginCompanyCode: companyCode
                    }
                );
            }

            alert("거래처 수정이 완료되었습니다.");
            await loadPartners(currentPage, { keepSelection: true, preserveScroll: true });
        } catch (error) {
            alert(error?.message || "거래처를 수정하지 못했습니다.");
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
