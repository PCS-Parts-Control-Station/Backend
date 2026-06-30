(() => {
    const PAGE_SIZE = 10;

    const filterForm = document.querySelector("[data-history-filter-form]");
    const resetButton = document.querySelector("[data-history-filter-reset]");
    const searchButton = filterForm?.querySelector("button[type='submit']");
    const table = document.querySelector("[data-history-table]");
    const emptyRow = document.querySelector("[data-history-empty]");
    const pagination = document.querySelector("[data-history-pagination]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const summaryText = document.querySelector("[data-history-summary]");
    const detailDrawer = document.querySelector("[data-history-detail-drawer]");
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
    };

    let currentPage = 0;
    let selectedDocumentId = null;
    let lastDetailTrigger = null;

    if (!filterForm || !table || !window.PcsApi || !window.PcsPagination) {
        return;
    }

    const getCompanyCode = () => {
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

    const gradeLabel = (grade) => {
        if (!grade || grade === "NONE") return "";
        if (grade === "DEFECTIVE") return "불량";
        return grade;
    };

    const unitStatusLabel = (status) => {
        if (status === "IN_STOCK") return "보관";
        if (status === "OUTBOUND") return "출고";
        if (status === "CANCELED") return "취소";
        if (status === "DISPOSED") return "폐기";
        return status || "-";
    };

    const summarizeGrades = (units) => {
        const counts = new Map();
        units.forEach((unit) => {
            const label = gradeLabel(unit.grade);
            if (!label) {
                return;
            }
            counts.set(label, (counts.get(label) || 0) + 1);
        });
        return Array.from(counts.entries())
            .map(([label, count]) => `${escapeHtml(label)} ${numberText(count)}`)
            .join(" · ");
    };

    const setEmptyMessage = (message, options = {}) => {
        table.querySelectorAll(".document-data-row:not(.table-head):not([data-history-empty])").forEach((row) => {
            row.remove();
        });
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

    const setDetailDrawerOpen = (isOpen) => {
        detailDrawer?.classList.toggle("is-open", isOpen);
        detailDrawer?.setAttribute("aria-hidden", String(!isOpen));
    };

    const openDetailDrawer = (trigger = null) => {
        if (trigger instanceof HTMLElement) {
            lastDetailTrigger = trigger;
        }
        setDetailDrawerOpen(true);
    };

    const closeDetailDrawer = (options = {}) => {
        selectedDocumentId = null;
        setDetailDrawerOpen(false);
        updateSelectedRows();
        if (options.restoreFocus !== false && lastDetailTrigger?.isConnected) {
            lastDetailTrigger.focus({ preventScroll: true });
        }
    };

    const updateSelectedRows = () => {
        table.querySelectorAll("[data-document-id]").forEach((row) => {
            const isSelected = selectedDocumentId && String(row.dataset.documentId) === String(selectedDocumentId);
            row.classList.toggle("is-selected", Boolean(isSelected));
            row.setAttribute("aria-selected", String(Boolean(isSelected)));
        });
    };

    const updateSummary = (pageData) => {
        const summary = pageData?.summary || {};
        const totalCount = Number(summary.totalCount || 0);
        const totalQuantity = Number(summary.totalQuantity || 0);
        const canceledCount = Number(summary.canceledCount || 0);
        if (summaryText) {
            summaryText.textContent = `전표 ${numberText(totalCount)}건 · 수량 ${numberText(totalQuantity)}개 · 취소 ${numberText(canceledCount)}건`;
        }
    };

    const buildDocumentSubText = (document) => {
        const firstPartName = document.firstPartName || "-";
        const lineCount = Number(document.lineCount || 0);
        const extra = lineCount > 1 ? ` 외 ${lineCount - 1}종` : "";
        const processedByName = document.processedByName || "-";
        return `${firstPartName}${extra} · ${processedByName} 처리`;
    };

    const createDocumentRow = (stockDocument) => {
        const row = window.document.createElement("div");
        const isSelected = selectedDocumentId && String(selectedDocumentId) === String(stockDocument.documentId);
        row.className = `data-row document-data-row stock-history-row${isSelected ? " is-selected" : ""}`;
        row.setAttribute("role", "row");
        row.setAttribute("tabindex", "0");
        row.setAttribute("aria-selected", String(Boolean(isSelected)));
        row.dataset.documentId = String(stockDocument.documentId);
        row.innerHTML = `
            <span role="cell" data-label="구분"><em class="badge ${documentTypeClass(stockDocument.documentType)}">${documentTypeLabel(stockDocument.documentType)}</em></span>
            <strong role="cell" data-label="전표번호">${escapeHtml(stockDocument.documentNo)}</strong>
            <span role="cell" class="cell-stack" data-label="내용">
                <b>${escapeHtml(stockDocument.partnerName || "-")}</b>
                <small>${escapeHtml(buildDocumentSubText(stockDocument))}</small>
            </span>
            <span role="cell" data-label="수량">${numberText(stockDocument.totalQuantity)}개</span>
            <span role="cell" data-label="상태"><em class="badge ${documentStatusClass(stockDocument.documentStatus)}">${documentStatusLabel(stockDocument.documentStatus)}</em></span>
            <span role="cell" data-label="처리일">${formatDate(stockDocument.createdAt)}</span>
        `;
        return row;
    };

    const clearRows = () => {
        table.querySelectorAll(".document-data-row:not(.table-head):not([data-history-empty])").forEach((row) => {
            row.remove();
        });
    };

    const renderDocuments = (pageData) => {
        const documents = Array.isArray(pageData?.content) ? pageData.content : [];
        clearRows();
        updateSummary(pageData);

        if (!documents.length) {
            selectedDocumentId = null;
            closeDetailDrawer({ restoreFocus: false });
            setEmptyMessage("조회된 입출고 이력이 없습니다.");
            updatePagination(pageData);
            return;
        }

        hideEmptyMessage();
        documents.forEach((stockDocument) => {
            const row = createDocumentRow(stockDocument);
            if (emptyRow) {
                emptyRow.insertAdjacentElement("beforebegin", row);
            } else {
                table.append(row);
            }
        });
        updatePagination(pageData);
    };

    const updatePagination = (pageData) => {
        window.PcsPagination.updateControls({
            pageData,
            container: pagination,
            info: pageInfo,
            prevButton,
            nextButton,
        });
    };

    const buildParams = (page = 0) => window.PcsPagination.buildParams({
        page,
        size: PAGE_SIZE,
        form: filterForm,
    });

    const setLoading = (isLoading) => {
        if (!searchButton) {
            return;
        }
        searchButton.disabled = isLoading;
        searchButton.textContent = isLoading ? "조회 중" : "검색";
    };

    const setDetailBadge = (element, label, className) => {
        if (!element) {
            return;
        }
        element.className = `badge ${className}`;
        element.textContent = label;
    };

    const renderDetailLines = (lines) => {
        if (!detailFields.lines) {
            return;
        }
        if (!lines?.length) {
            detailFields.lines.innerHTML = '<p class="detail-empty-text">품목 이력이 없습니다.</p>';
            if (detailFields.lineSummary) {
                detailFields.lineSummary.textContent = "0개 품목 · 총 0개";
            }
            return;
        }

        const totalQuantity = lines.reduce((sum, line) => sum + Number(line.quantity || 0), 0);
        if (detailFields.lineSummary) {
            detailFields.lineSummary.textContent = `${numberText(lines.length)}개 품목 · 총 ${numberText(totalQuantity)}개`;
        }

        const unitGroups = lines.map((line) => ({
            partName: line.partName || "-",
            modelName: line.modelName || "",
            quantity: Number(line.quantity || 0),
            units: Array.isArray(line.units) ? line.units : [],
        }));
        const unitCount = unitGroups.reduce((sum, group) => sum + group.units.length, 0);

        const unitSection = `
            <details class="stock-history-unit-details">
                <summary>
                    <span>개별 관리번호</span>
                    <b>${numberText(unitCount)}개 보기</b>
                </summary>
                <div class="unit-group-list">
                    ${unitCount ? unitGroups.map((group) => `
                        <section class="unit-group">
                            <div class="unit-group-title">
                                <span>
                                    <strong>${escapeHtml(group.partName)}</strong>
                                    ${group.modelName ? `<small>${escapeHtml(group.modelName)}</small>` : ""}
                                </span>
                                <b>${numberText(group.units.length || group.quantity)}개</b>
                            </div>
                            <div class="unit-chip-list">
                                ${group.units.length ? group.units.map((unit) => `
                                    <span class="unit-chip">
                                        <code>${escapeHtml(unit.internalSerialNo)}</code>
                                        ${gradeLabel(unit.grade) ? `<em>${escapeHtml(gradeLabel(unit.grade))}</em>` : ""}
                                        <small>${escapeHtml(unitStatusLabel(unit.unitStatus))}</small>
                                    </span>
                                `).join("") : '<p class="detail-empty-text">관리번호가 없습니다.</p>'}
                            </div>
                        </section>
                    `).join("") : '<p class="detail-empty-text">관리번호가 없습니다.</p>'}
                </div>
            </details>
        `;

        detailFields.lines.innerHTML = lines.map((line) => {
            const units = Array.isArray(line.units) ? line.units : [];
            const gradeSummary = summarizeGrades(units);
            return `
                <article class="document-line-item stock-history-line">
                    <div class="stock-history-line-summary">
                        <span>
                            <strong>${escapeHtml(line.partName || "-")}</strong>
                            ${line.modelName ? `<small>${escapeHtml(line.modelName)}</small>` : ""}
                        </span>
                        <b>${numberText(line.quantity)}개</b>
                    </div>
                    ${gradeSummary ? `<p class="stock-history-grade-summary">${gradeSummary}</p>` : ""}
                    ${line.reason ? `<p class="line-reason">${escapeHtml(line.reason)}</p>` : ""}
                </article>
            `;
        }).join("") + unitSection;
    };

    const setDetailLoading = (message, documentId = null) => {
        selectedDocumentId = documentId;
        openDetailDrawer();
        if (detailFields.subtitle) detailFields.subtitle.textContent = message;
        if (detailFields.documentNo) detailFields.documentNo.textContent = "-";
        setDetailBadge(detailFields.type, "-", "badge-gray");
        setDetailBadge(detailFields.status, "-", "badge-gray");
        if (detailFields.partner) detailFields.partner.textContent = "-";
        if (detailFields.createdAt) detailFields.createdAt.textContent = "-";
        if (detailFields.processedBy) detailFields.processedBy.textContent = "-";
        if (detailFields.reason) detailFields.reason.textContent = "-";
        if (detailFields.lineSummary) detailFields.lineSummary.textContent = "-";
        if (detailFields.lines) detailFields.lines.innerHTML = `<p class="detail-empty-text">${escapeHtml(message)}</p>`;
        updateSelectedRows();
    };

    const renderDetail = (detail) => {
        selectedDocumentId = detail.documentId;
        if (detailFields.subtitle) {
            detailFields.subtitle.textContent = `${detail.partnerName || "-"} · ${formatDate(detail.createdAt)}`;
        }
        if (detailFields.documentNo) detailFields.documentNo.textContent = detail.documentNo || "-";
        setDetailBadge(detailFields.type, documentTypeLabel(detail.documentType), documentTypeClass(detail.documentType));
        setDetailBadge(detailFields.status, documentStatusLabel(detail.documentStatus), documentStatusClass(detail.documentStatus));
        if (detailFields.partner) detailFields.partner.textContent = detail.partnerName || "-";
        if (detailFields.createdAt) detailFields.createdAt.textContent = formatDate(detail.createdAt);
        if (detailFields.processedBy) detailFields.processedBy.textContent = detail.processedByName || "-";
        if (detailFields.reason) detailFields.reason.textContent = detail.reason || "-";
        renderDetailLines(detail.lines || []);
        updateSelectedRows();
    };

    const loadDetail = async (documentId, trigger = null) => {
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
            renderDetail(detail);
        } catch (error) {
            setDetailLoading(error.message || "전표 상세를 불러오지 못했습니다.", documentId);
        }
    };

    const loadDocuments = async (page = 0, options = {}) => {
        const base = apiBase();
        if (!base) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const preserveScroll = options.preserveScroll === true;
        const execute = async () => {
            currentPage = page;
            setLoading(true);
            if (!preserveScroll) {
                setEmptyMessage("입출고 이력을 불러오는 중입니다.", { loading: true });
            }

            const params = buildParams(page);
            const data = await window.PcsApi.getData(`${base}/stock/documents?${params.toString()}`, apiOptions());
            let pageData = window.PcsPagination.normalizePageData(data, PAGE_SIZE);
            if (pageData.content.length === 0 && pageData.totalElements > 0 && pageData.page > 0) {
                const fallbackParams = buildParams(pageData.page - 1);
                const fallbackData = await window.PcsApi.getData(`${base}/stock/documents?${fallbackParams.toString()}`, apiOptions());
                pageData = window.PcsPagination.normalizePageData(fallbackData, PAGE_SIZE);
            }
            currentPage = pageData.page;
            renderDocuments(pageData);
        };

        try {
            if (preserveScroll) {
                await window.PcsPagination.withPreservedScroll(execute);
            } else {
                await execute();
            }
        } catch (error) {
            setEmptyMessage(error.message || "입출고 이력을 불러오지 못했습니다.");
            updateSummary({ summary: null });
            updatePagination({
                content: [],
                totalElements: 0,
                totalPages: 0,
                page: 0,
                hasPrevious: false,
                hasNext: false,
            });
        } finally {
            setLoading(false);
        }
    };

    const setDefaultDates = () => {
        const dateFrom = filterForm.elements.dateFrom;
        const dateTo = filterForm.elements.dateTo;
        if (!dateFrom || !dateTo) {
            return;
        }
        const end = new Date();
        const start = new Date();
        start.setDate(start.getDate() - 30);
        dateFrom.value = start.toISOString().slice(0, 10);
        dateTo.value = end.toISOString().slice(0, 10);
    };

    filterForm.addEventListener("submit", (event) => {
        event.preventDefault();
        void loadDocuments(0);
    });

    resetButton?.addEventListener("click", () => {
        filterForm.reset();
        setDefaultDates();
        void loadDocuments(0);
    });

    prevButton?.addEventListener("click", () => {
        if (currentPage > 0) {
            void loadDocuments(currentPage - 1, { preserveScroll: true });
        }
    });

    nextButton?.addEventListener("click", () => {
        void loadDocuments(currentPage + 1, { preserveScroll: true });
    });

    table.addEventListener("click", (event) => {
        const row = event.target.closest("[data-document-id]");
        if (!row) {
            return;
        }
        void loadDetail(row.dataset.documentId, row);
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
        void loadDetail(row.dataset.documentId, row);
    });

    closeDetailButtons.forEach((button) => {
        button.addEventListener("click", () => closeDetailDrawer());
    });

    document.addEventListener("click", (event) => {
        if (!detailDrawer?.classList.contains("is-open")) {
            return;
        }
        if (!(event.target instanceof Element)) {
            return;
        }
        if (detailDrawer.contains(event.target)) {
            return;
        }
        if (event.target.closest("[data-document-id]")) {
            return;
        }
        closeDetailDrawer({ restoreFocus: false });
    });

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && detailDrawer?.classList.contains("is-open")) {
            closeDetailDrawer();
        }
    });

    window.PcsDrawer?.bindDismiss({
        drawer: detailDrawer,
        close: closeDetailDrawer,
        keepOpenSelector: "[data-document-id]"
    });

    const initialize = async () => {
        const companyCode = getCompanyCode();
        try {
            if (window.PcsApi.validateWorkspacePublic) {
                const isValidWorkspace = await window.PcsApi.validateWorkspacePublic(companyCode);
                if (!isValidWorkspace) {
                    return;
                }
            }
            setDefaultDates();
            await loadDocuments(0);
        } catch (error) {
            setEmptyMessage(error.message || "업체 주소를 확인할 수 없습니다.");
        }
    };

    void initialize();
})();
