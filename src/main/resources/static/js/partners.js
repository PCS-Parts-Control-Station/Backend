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

    let currentPage = 0;

    const getCompanyCode = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : "";
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

    const createActionCell = (partner) => {
        const cell = document.createElement("span");
        cell.setAttribute("role", "cell");
        cell.className = "row-actions";

        const editButton = document.createElement("button");
        editButton.type = "button";
        editButton.textContent = "수정";
        editButton.dataset.partnerId = String(partner.partnerId);

        const activeButton = document.createElement("button");
        activeButton.type = "button";
        activeButton.textContent = partner.active ? "제한" : "재개";
        activeButton.dataset.partnerId = String(partner.partnerId);

        cell.append(editButton, activeButton);
        return cell;
    };

    const renderRows = (items) => {
        clearRows();
        if (!items.length) {
            setEmptyMessage("조회된 거래처가 없습니다.");
            return;
        }

        items.forEach((partner) => {
            const row = document.createElement("div");
            row.className = "data-row partner-data-row";
            row.setAttribute("role", "row");

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
                createTextCell("수정일", formatDate(partner.updatedAt)),
                createActionCell(partner)
            );

            table.append(row);
        });
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

    form.addEventListener("submit", (event) => {
        event.preventDefault();
        loadPartners(0);
    });

    prevButton.addEventListener("click", () => {
        if (currentPage > 0) {
            loadPartners(currentPage - 1, { preserveScroll: true });
        }
    });

    nextButton.addEventListener("click", () => {
        loadPartners(currentPage + 1, { preserveScroll: true });
    });

    loadPartners(0);
})();
