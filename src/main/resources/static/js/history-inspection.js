(function () {
    const PAGE_SIZE = 15;

    const filterForm = document.querySelector("[data-history-filter-form]");
    const table = document.querySelector("[data-history-table]");
    const pagination = document.querySelector("[data-history-pagination]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const searchButton = filterForm?.querySelector("button[type='submit']");

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
            const [year, month, day, hour, minute] = value;
            if (year && month && day) {
                const datePart = `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
                if (hour != null && minute != null) {
                    return `${datePart} ${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`;
                }
                return datePart;
            }
        }
        return String(value).slice(0, 16).replace('T', ' ');
    };

    const clearRows = () => {
        table?.querySelectorAll(".data-row:not(.table-head)").forEach((row) => row.remove());
    };

    const setEmptyMessage = (message) => {
        clearRows();
        const row = document.createElement("div");
        row.className = "data-row document-data-row empty-data-row";
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

    const createBadgeCell = (label, text, type) => {
        const cell = document.createElement("span");
        cell.setAttribute("role", "cell");
        if (label) {
            cell.setAttribute("data-label", label);
        }
        const badge = document.createElement("i");
        
        if (type === 'GREEN') {
            badge.className = "badge badge-green";
        } else if (type === 'RED') {
            badge.className = "badge badge-red";
        } else if (type === 'ORANGE') {
            badge.className = "badge badge-orange";
        } else {
            badge.className = "badge badge-blue";
        }
        
        badge.textContent = text || "-";
        cell.append(badge);
        return cell;
    };

    const renderRows = (items) => {
        clearRows();

        if (!items.length) {
            setEmptyMessage("조회된 이력이 없습니다.");
            return;
        }

        items.forEach((item) => {
            const row = document.createElement("div");
            row.className = "data-row document-data-row";
            row.setAttribute("role", "row");
            
            // Map status logic
            const statusType = item.inspectionStatus === 'COMPLETED' ? 'GREEN' : 'ORANGE';
            const gradeType = item.grade === 'DEFECTIVE' ? 'RED' : 'GREEN';

            row.append(
                createTextCell("부품명", item.partName, "strong"),
                createTextCell("관리번호", item.unitIdentifier, "code"),
                createBadgeCell("검수 상태", item.inspectionStatus || "확인 불가", statusType),
                createBadgeCell("등급", item.grade || "미정", gradeType),
                createTextCell("처리자", item.processorName || item.createdBy),
                createTextCell("처리일", formatDate(item.createdAt))
            );

            table.append(row);
        });
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

    const loadHistory = async (page = 0, options = {}) => {
        const companyCode = getCompanyCode();
        if (!companyCode) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const preserveScroll = options.preserveScroll === true;
        const fetchPage = async (targetPage) => {
            const params = buildParams(targetPage);
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/history/inspections?${params.toString()}`,
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
                setEmptyMessage("이력을 불러오는 중입니다.");
            }

            let pageData = await fetchPage(page);
            if (pageData.content.length === 0 && pageData.totalElements > 0 && pageData.page > 0) {
                pageData = await fetchPage(pageData.page - 1);
            }
            currentPage = pageData.page;

            renderRows(pageData.content);
            updatePagination(pageData);
        };

        const execute = async () => {
            try {
                await requestPage();
            } catch (error) {
                setEmptyMessage(error?.message || "이력을 불러오지 못했습니다.");
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


    if (!filterForm || !table || !pagination || !window.PcsApi || !window.PcsPagination) {
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
            
            // Set default dates for last 30 days
            const end = new Date();
            const start = new Date();
            start.setDate(start.getDate() - 30);
            
            filterForm.elements.startDate.value = start.toISOString().split('T')[0];
            filterForm.elements.endDate.value = end.toISOString().split('T')[0];
            
            await loadHistory(0);
        } catch (error) {
            setEmptyMessage(error?.message || "업체 주소를 확인할 수 없습니다.");
        }
    };

    filterForm.addEventListener("submit", (event) => {
        event.preventDefault();
        loadHistory(0);
    });

    prevButton.addEventListener("click", () => {
        if (currentPage > 0) {
            loadHistory(currentPage - 1, { preserveScroll: true });
        }
    });

    nextButton.addEventListener("click", () => {
        loadHistory(currentPage + 1, { preserveScroll: true });
    });

    initializePage();
})();
