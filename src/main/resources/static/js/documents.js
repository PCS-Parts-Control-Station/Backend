(() => {
    const PAGE_SIZE = 10;

    const filterForm = document.querySelector("[data-documents-filter-form]");
    const resetButton = document.querySelector("[data-documents-filter-reset]");
    const searchButton = filterForm?.querySelector("button[type='submit']");
    const listCard = document.querySelector(".documents-list-card");
    const table = document.querySelector("[data-documents-table]");
    const emptyRow = document.querySelector("[data-documents-empty]");
    const pagination = document.querySelector("[data-documents-pagination]");
    const paginationStatus = document.querySelector("[data-documents-pagination-status]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const summaryTotal = document.querySelector("[data-documents-summary-total]");
    const summaryQuantity = document.querySelector("[data-documents-summary-quantity]");
    const summaryCanceled = document.querySelector("[data-documents-summary-canceled]");
    const detailDrawer = document.querySelector("[data-documents-detail-drawer]");
    const closeDetailButtons = document.querySelectorAll("[data-close-detail-panel]");
    const detailFields = {
        subtitle: document.querySelector("[data-detail-subtitle]"),
        documentNo: document.querySelector("[data-detail-document-no]"),
        type: document.querySelector("[data-detail-type]"),
        status: document.querySelector("[data-detail-status]"),
        partner: document.querySelector("[data-detail-partner]"),
        createdAt: document.querySelector("[data-detail-created-at]"),
        processedBy: document.querySelector("[data-detail-processed-by]"),
        reason: document.querySelector("[data-detail-reason]"),
        lineSummary: document.querySelector("[data-detail-line-summary]"),
        lines: document.querySelector("[data-detail-lines]"),
        actions: document.querySelector("[data-detail-actions]"),
    };

    let currentPage = 0;
    let currentPageData = null;
    let selectedDocumentId = null;
    let lastDetailTrigger = null;
    let paginationStatusTimer = null;

    if (!filterForm || !table || !window.PcsApi || !window.PcsPagination) {
        return;
    }

    const getCompanyCode = () => {
        if (window.PcsWorkspace?.getCompanyCode) {
            return window.PcsWorkspace.getCompanyCode();
        }
        const segments = window.location.pathname.split("/").filter(Boolean);
        return segments[0] === "w" && segments[1] ? decodeURIComponent(segments[1]) : "";
    };

    const apiBase = () => {
        const companyCode = getCompanyCode();
        return companyCode ? `/api/workspaces/${encodeURIComponent(companyCode)}` : "";
    };

    const apiOptions = () => ({
        authRedirect: true,
        loginCompanyCode: getCompanyCode(),
    });

    const escapeHtml = (value) => String(value ?? "").replace(/[&<>"']/g, (letter) => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#039;",
    }[letter]));

    const numberText = (value) => Number(value || 0).toLocaleString("ko-KR");

    const formatDate = (value) => {
        if (!value) {
            return "-";
        }
        const text = String(value);
        if (/^\d{4}-\d{2}-\d{2}/.test(text)) {
            return text.slice(0, 16).replace("T", " ");
        }
        const date = new Date(value);
        if (Number.isNaN(date.getTime())) {
            return text.slice(0, 16) || "-";
        }
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, "0");
        const day = String(date.getDate()).padStart(2, "0");
        const hour = String(date.getHours()).padStart(2, "0");
        const minute = String(date.getMinutes()).padStart(2, "0");
        return `${year}-${month}-${day} ${hour}:${minute}`;
    };

    const documentTypeLabel = (type) => {
        if (type === "INBOUND") return "입고";
        if (type === "OUTBOUND") return "출고";
        return type || "-";
    };

    const documentTypeClass = (type) => {
        if (type === "INBOUND") return "badge-blue";
        if (type === "OUTBOUND") return "badge-orange";
        return "badge-gray";
    };

    const documentStatusLabel = (status) => status === "CANCELED" ? "취소" : "완료";

    const documentStatusClass = (status) => status === "CANCELED" ? "badge-inactive" : "badge-active";

    const buildDocumentSubText = (stockDocument) => {
        const firstPartName = stockDocument.firstPartName || "-";
        const lineCount = Number(stockDocument.lineCount || 0);
        const extra = lineCount > 1 ? ` 외 ${lineCount - 1}종` : "";
        const processedByName = stockDocument.processedByName || "-";
        return `${firstPartName}${extra} · ${processedByName} 처리`;
    };

    const buildRouteUrl = (route, documentNo) => {
        const companyCode = encodeURIComponent(getCompanyCode());
        const keyword = encodeURIComponent(documentNo || "");
        return `/w/${companyCode}/${route}?documentNo=${keyword}&keyword=${keyword}`;
    };

    const renderActionLinks = (stockDocument, options = {}) => {
        const documentNo = stockDocument?.documentNo || "";
        const className = options.className || "document-action-link";
        const links = [];
        if (stockDocument?.documentType === "INBOUND") {
            links.push(`<a class="${className}" href="${buildRouteUrl("inbound", documentNo)}">입고 관리에서 보기</a>`);
            links.push(`<a class="${className} document-action-link-primary" href="${buildRouteUrl("inspection", documentNo)}">검수 관리로 이동</a>`);
        }
        if (stockDocument?.documentType === "OUTBOUND") {
            links.push(`<a class="${className} document-action-link-primary" href="${buildRouteUrl("outbound", documentNo)}">출고 관리에서 보기</a>`);
        }
        return links.join("");
    };

    const setDetailDrawerOpen = (isOpen) => {
        if (!detailDrawer) {
            return;
        }
        detailDrawer.classList.toggle("is-open", isOpen);
        detailDrawer.setAttribute("aria-hidden", String(!isOpen));
    };

    const openDetailDrawer = () => {
        setDetailDrawerOpen(true);
    };

    const closeDetailDrawer = (options = {}) => {
        if (!detailDrawer) {
            return;
        }
        setDetailDrawerOpen(false);
        selectedDocumentId = null;
        updateSelectedRows();
        if (options.restoreFocus !== false && lastDetailTrigger instanceof HTMLElement) {
            lastDetailTrigger.focus({ preventScroll: true });
        }
    };

    const setBadge = (element, label, className) => {
        if (!element) {
            return;
        }
        element.className = `badge ${className}`;
        element.textContent = label;
    };

    const updateSelectedRows = () => {
        table.querySelectorAll("[data-document-id]").forEach((row) => {
            const isSelected = String(row.dataset.documentId) === String(selectedDocumentId || "");
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
        });
    };

    const renderDetailLines = (lines) => {
        if (!detailFields.lines) {
            return;
        }
        if (!lines?.length) {
            detailFields.lines.innerHTML = '<p class="detail-empty-text">등록된 품목이 없습니다.</p>';
            if (detailFields.lineSummary) {
                detailFields.lineSummary.textContent = "0개 품목 · 총 0개";
            }
            return;
        }

        const totalQuantity = lines.reduce((sum, line) => sum + Number(line.quantity || 0), 0);
        if (detailFields.lineSummary) {
            detailFields.lineSummary.textContent = `${numberText(lines.length)}개 품목 · 총 ${numberText(totalQuantity)}개`;
        }
        detailFields.lines.innerHTML = lines.map((line) => `
            <article class="documents-detail-line">
                <span>
                    <strong>${escapeHtml(line.partName || "-")}</strong>
                    ${line.modelName ? `<small>${escapeHtml(line.modelName)}</small>` : ""}
                </span>
                <b>${numberText(line.quantity)}개</b>
            </article>
        `).join("");
    };

    const setDetailLoading = (message, documentId = null) => {
        selectedDocumentId = documentId;
        openDetailDrawer();
        if (detailFields.subtitle) detailFields.subtitle.textContent = message;
        if (detailFields.documentNo) detailFields.documentNo.textContent = "-";
        setBadge(detailFields.type, "-", "badge-gray");
        setBadge(detailFields.status, "-", "badge-gray");
        if (detailFields.partner) detailFields.partner.textContent = "-";
        if (detailFields.createdAt) detailFields.createdAt.textContent = "-";
        if (detailFields.processedBy) detailFields.processedBy.textContent = "-";
        if (detailFields.reason) detailFields.reason.textContent = "-";
        if (detailFields.lineSummary) detailFields.lineSummary.textContent = "-";
        if (detailFields.lines) detailFields.lines.innerHTML = `<p class="detail-empty-text">${escapeHtml(message)}</p>`;
        if (detailFields.actions) detailFields.actions.innerHTML = "";
        updateSelectedRows();
    };

    const renderDocumentDetail = (detail) => {
        selectedDocumentId = detail.documentId;
        if (detailFields.subtitle) {
            detailFields.subtitle.textContent = `${detail.partnerName || "-"} · ${formatDate(detail.createdAt)}`;
        }
        if (detailFields.documentNo) detailFields.documentNo.textContent = detail.documentNo || "-";
        setBadge(detailFields.type, documentTypeLabel(detail.documentType), documentTypeClass(detail.documentType));
        setBadge(detailFields.status, documentStatusLabel(detail.documentStatus), documentStatusClass(detail.documentStatus));
        if (detailFields.partner) detailFields.partner.textContent = detail.partnerName || "-";
        if (detailFields.createdAt) detailFields.createdAt.textContent = formatDate(detail.createdAt);
        if (detailFields.processedBy) detailFields.processedBy.textContent = detail.processedByName || "-";
        if (detailFields.reason) detailFields.reason.textContent = detail.reason || "-";
        if (detailFields.actions) {
            detailFields.actions.innerHTML = renderActionLinks(detail, { className: "btn btn-secondary documents-detail-action" });
        }
        renderDetailLines(detail.lines || []);
        updateSelectedRows();
    };

    const loadDocumentDetail = async (documentId, trigger = null) => {
        const base = apiBase();
        if (trigger instanceof HTMLElement) {
            lastDetailTrigger = trigger;
        }
        if (!base) {
            setDetailLoading("전표 상세를 불러올 수 없습니다.", documentId);
            return;
        }

        setDetailLoading("전표 상세를 불러오는 중입니다.", documentId);
        try {
            const detail = await window.PcsApi.getData(`${base}/stock/documents/${encodeURIComponent(documentId)}`, apiOptions());
            renderDocumentDetail(detail);
        } catch (error) {
            setDetailLoading(error?.message || "전표 상세를 불러오지 못했습니다.", documentId);
        }
    };

    const clearRows = () => {
        table.querySelectorAll(".documents-row:not(.table-head):not([data-documents-empty])").forEach((row) => {
            row.remove();
        });
    };

    const setEmptyMessage = (message, options = {}) => {
        clearRows();
        if (!emptyRow) {
            return;
        }
        emptyRow.hidden = false;
        emptyRow.classList.toggle("is-loading", options.loading === true);
        emptyRow.querySelector("[role='cell']").textContent = message;
    };

    const hideEmptyMessage = () => {
        if (!emptyRow) {
            return;
        }
        emptyRow.hidden = true;
        emptyRow.classList.remove("is-loading");
    };

    const updateSummary = (pageData) => {
        const summary = pageData?.summary || {};
        if (summaryTotal) {
            summaryTotal.textContent = numberText(summary.totalCount);
        }
        if (summaryQuantity) {
            summaryQuantity.textContent = numberText(summary.totalQuantity);
        }
        if (summaryCanceled) {
            summaryCanceled.textContent = numberText(summary.canceledCount);
        }
    };

    const createDocumentRow = (stockDocument) => {
        const row = document.createElement("div");
        row.className = "data-row documents-row is-selectable";
        row.setAttribute("role", "row");
        row.setAttribute("tabindex", "0");
        row.setAttribute("aria-selected", "false");
        row.dataset.documentId = String(stockDocument.documentId);
        row.innerHTML = `
            <span role="cell" data-label="구분"><em class="badge ${documentTypeClass(stockDocument.documentType)}">${documentTypeLabel(stockDocument.documentType)}</em></span>
            <strong role="cell" data-label="전표번호">${escapeHtml(stockDocument.documentNo)}</strong>
            <span role="cell" class="cell-stack" data-label="거래처 / 내용">
                <b>${escapeHtml(stockDocument.partnerName || "-")}</b>
                <small>${escapeHtml(buildDocumentSubText(stockDocument))}</small>
            </span>
            <span role="cell" data-label="수량">${numberText(stockDocument.totalQuantity)}개</span>
            <span role="cell" data-label="상태"><em class="badge ${documentStatusClass(stockDocument.documentStatus)}">${documentStatusLabel(stockDocument.documentStatus)}</em></span>
            <span role="cell" data-label="처리일">${formatDate(stockDocument.createdAt)}</span>
        `;
        return row;
    };

    const updatePagination = (pageData) => {
        currentPageData = pageData;
        if (!pagination) {
            return;
        }
        window.PcsPagination.updateControls({
            pageData,
            container: pagination,
            info: pageInfo,
            prevButton,
            nextButton,
            onPageClick: (page) => {
                closeDetailDrawer({ restoreFocus: false });
                const execute = () => loadDocuments(page, { keepRows: true });
                if (window.PcsPagination?.withPreservedScroll) {
                    void window.PcsPagination.withPreservedScroll(execute);
                    return;
                }
                void execute();
            }
        });
    };

    const setPaginationStatus = (message = "", type = "loading") => {
        if (!paginationStatus) {
            return;
        }
        window.clearTimeout(paginationStatusTimer);
        paginationStatus.classList.toggle("is-error", type === "error");
        paginationStatus.hidden = !message;
        const text = paginationStatus.querySelector("span");
        if (text) {
            text.textContent = message;
        }
        if (message && type === "error") {
            paginationStatusTimer = window.setTimeout(() => {
                paginationStatus.hidden = true;
                paginationStatus.classList.remove("is-error");
            }, 3200);
        }
    };

    const setPageLoading = (isLoading) => {
        listCard?.classList.toggle("is-page-loading", isLoading);
        table.setAttribute("aria-busy", String(isLoading));
        if (prevButton) {
            prevButton.disabled = isLoading || !currentPageData?.hasPrevious;
        }
        if (nextButton) {
            nextButton.disabled = isLoading || !currentPageData?.hasNext;
        }
        if (isLoading) {
            setPaginationStatus("불러오는 중", "loading");
        } else if (!paginationStatus?.classList.contains("is-error")) {
            setPaginationStatus("");
        }
    };

    const renderDocuments = (pageData) => {
        clearRows();
        updateSummary(pageData);
        updatePagination(pageData);

        const documents = pageData.content || [];
        if (!documents.length) {
            setEmptyMessage("조회된 전표가 없습니다.");
            return;
        }

        hideEmptyMessage();
        documents.forEach((stockDocument) => {
            table.appendChild(createDocumentRow(stockDocument));
        });
        updateSelectedRows();
    };

    const buildParams = (page) => window.PcsPagination.buildParams({
        page,
        size: PAGE_SIZE,
        form: filterForm,
    });

    const setLoading = (isLoading) => {
        if (searchButton) {
            searchButton.disabled = isLoading;
            searchButton.textContent = isLoading ? "검색 중" : "검색";
        }
    };

    const loadDocuments = async (page = currentPage, options = {}) => {
        const keepRows = options.keepRows === true;
        const base = apiBase();
        if (!base) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        setLoading(true);
        if (keepRows) {
            setPageLoading(true);
        } else {
            setEmptyMessage("전표 목록을 불러오는 중입니다.", { loading: true });
        }

        try {
            const params = buildParams(page);
            const data = await window.PcsApi.getData(`${base}/stock/documents?${params.toString()}`, apiOptions());
            const pageData = window.PcsPagination.normalizePageData(data, PAGE_SIZE);
            currentPage = pageData.page;
            renderDocuments(pageData);
        } catch (error) {
            const message = error?.message || "전표 목록을 불러오지 못했습니다.";
            if (keepRows) {
                setPaginationStatus(message, "error");
                window.PcsUi?.toast({ message, type: "error" });
                updatePagination(currentPageData || {
                    content: [],
                    page: 0,
                    size: PAGE_SIZE,
                    totalElements: 0,
                    totalPages: 0,
                    hasPrevious: false,
                    hasNext: false,
                    summary: null,
                });
            } else {
                updateSummary(null);
                updatePagination({
                    content: [],
                    page: 0,
                    size: PAGE_SIZE,
                    totalElements: 0,
                    totalPages: 0,
                    hasPrevious: false,
                    hasNext: false,
                    summary: null,
                });
                setEmptyMessage(message);
            }
        } finally {
            if (keepRows) {
                setPageLoading(false);
            }
            setLoading(false);
        }
    };

    const applyUrlParams = () => {
        const params = new URLSearchParams(window.location.search);
        ["keyword", "documentType", "documentStatus", "dateFrom", "dateTo"].forEach((name) => {
            const value = params.get(name);
            if (value !== null && filterForm.elements[name]) {
                filterForm.elements[name].value = value;
            }
        });
        const documentNo = params.get("documentNo");
        if (documentNo && filterForm.elements.keyword && !filterForm.elements.keyword.value) {
            filterForm.elements.keyword.value = documentNo;
        }
    };

    filterForm.addEventListener("submit", (event) => {
        event.preventDefault();
        closeDetailDrawer({ restoreFocus: false });
        void loadDocuments(0);
    });

    resetButton?.addEventListener("click", () => {
        filterForm.reset();
        closeDetailDrawer({ restoreFocus: false });
        void loadDocuments(0);
    });

    prevButton?.addEventListener("click", () => {
        if (!currentPageData?.hasPrevious) {
            return;
        }
        closeDetailDrawer({ restoreFocus: false });
        const execute = () => loadDocuments(Math.max(0, currentPage - 1), { keepRows: true });
        if (window.PcsPagination?.withPreservedScroll) {
            void window.PcsPagination.withPreservedScroll(execute);
            return;
        }
        void execute();
    });

    nextButton?.addEventListener("click", () => {
        if (!currentPageData?.hasNext) {
            return;
        }
        closeDetailDrawer({ restoreFocus: false });
        const execute = () => loadDocuments(currentPage + 1, { keepRows: true });
        if (window.PcsPagination?.withPreservedScroll) {
            void window.PcsPagination.withPreservedScroll(execute);
            return;
        }
        void execute();
    });

    table.addEventListener("click", (event) => {
        const row = event.target.closest("[data-document-id]");
        if (!row) {
            return;
        }
        void loadDocumentDetail(row.dataset.documentId, row);
    });

    table.addEventListener("keydown", (event) => {
        if (event.key !== "Enter" && event.key !== " ") {
            return;
        }
        const row = event.target.closest("[data-document-id]");
        if (!row) {
            return;
        }
        event.preventDefault();
        void loadDocumentDetail(row.dataset.documentId, row);
    });

    closeDetailButtons.forEach((button) => {
        button.addEventListener("click", () => closeDetailDrawer());
    });

    window.PcsDrawer?.bindDismiss({
        drawer: detailDrawer,
        close: closeDetailDrawer,
        keepOpenSelector: "[data-document-id]",
    });

    const initialize = async () => {
        const companyCode = getCompanyCode();
        if (!companyCode) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        try {
            if (window.PcsApi.validateWorkspacePublic) {
                const valid = await window.PcsApi.validateWorkspacePublic(companyCode);
                if (!valid) {
                    return;
                }
            }
            applyUrlParams();
            await loadDocuments(0);
        } catch (error) {
            setEmptyMessage(error?.message || "화면을 초기화하지 못했습니다.");
        }
    };

    void initialize();
})();
