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
    const listLoading = document.querySelector("[data-documents-list-loading]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const partnerFilter = document.querySelector("[data-partner-filter]");
    const openPartnerModalButton = document.querySelector("[data-open-partner-modal]");
    const partnerModal = document.querySelector("[data-partner-modal]");
    const closePartnerModalButtons = document.querySelectorAll("[data-close-partner-modal]");
    const partnerSearchInput = document.querySelector("[data-partner-search]");
    const partnerList = document.querySelector("[data-partner-list]");
    const selectedPartnerName = document.querySelector("[data-selected-partner-name]");
    const selectedPartnerMeta = document.querySelector("[data-selected-partner-meta]");
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
    const cancelModal = document.querySelector("[data-cancel-modal]");
    const closeCancelModalButtons = document.querySelectorAll("[data-close-cancel-modal]");
    const confirmCancelButton = document.querySelector("[data-confirm-cancel]");
    const cancelFields = {
        documentNo: document.querySelector("[data-cancel-document-no]"),
        documentType: document.querySelector("[data-cancel-document-type]"),
        partner: document.querySelector("[data-cancel-partner]"),
        quantity: document.querySelector("[data-cancel-quantity]"),
        message: document.querySelector("[data-cancel-message]"),
    };

    let currentPage = 0;
    let currentPageData = null;
    let selectedDocumentId = null;
    let currentDetail = null;
    let cancelTarget = null;
    let lastDetailTrigger = null;
    let paginationStatusTimer = null;
    let partnerPicker = null;
    let documentListRequestId = 0;
    let documentDetailRequestId = 0;

    if (!filterForm || !table || !window.PcsApi || !window.PcsPagination) {
        return;
    }

    const workspace = window.PcsWorkspace.createContext();
    const escapeHtml = window.PcsHtml.escape;
    const numberText = window.PcsFormat.number;
    const formatDate = window.PcsFormat.dateTime;

    const documentTypeLabel = (type) => window.PcsLabels?.documentType(type) || type || "-";

    const documentTypeClass = (type) => window.PcsLabels?.documentTypeClass(type) || "badge-gray";

    const documentStatusLabel = (status) => window.PcsLabels?.documentStatus(status) || "완료";

    const documentStatusClass = (status) => window.PcsLabels?.documentStatusClass(status) || "badge-active";

    const partnerMeta = (partner) => {
        const code = partner?.partnerCode || partner?.code || "";
        const role = window.PcsLabels.partnerRoleLong(partner?.partnerRole, "역할 미지정");
        return [code, role].filter(Boolean).join(" · ");
    };

    const buildDocumentSubText = (stockDocument) => {
        const firstPartName = stockDocument.firstPartName || "-";
        const lineCount = Number(stockDocument.lineCount || 0);
        const extra = lineCount > 1 ? ` 외 ${lineCount - 1}종` : "";
        const processedByName = stockDocument.processedByName || "-";
        return `${firstPartName}${extra} · ${processedByName} 처리`;
    };

    const buildRouteUrl = (route, documentNo) => {
        const companyCode = encodeURIComponent(workspace.companyCode);
        const keyword = encodeURIComponent(documentNo || "");
        return `/w/${companyCode}/${route}?documentNo=${keyword}&keyword=${keyword}`;
    };

    const partStateForDocument = (stockDocument) => {
        const isCanceledInbound = stockDocument?.documentStatus === "CANCELED" && stockDocument?.documentType === "INBOUND";
        const isActiveOutbound = stockDocument?.documentType === "OUTBOUND" && stockDocument?.documentStatus !== "CANCELED";
        if (isCanceledInbound) {
            return "CANCELED";
        }
        return isActiveOutbound ? "OUTBOUND" : "HELD";
    };

    const buildPartUnitsRouteUrl = (stockDocument) => {
        const companyCode = encodeURIComponent(workspace.companyCode);
        const params = new URLSearchParams();
        if (stockDocument?.documentId) {
            params.set("documentId", String(stockDocument.documentId));
        }
        if (stockDocument?.documentNo) {
            params.set("documentNo", stockDocument.documentNo);
        }
        params.set("partState", partStateForDocument(stockDocument));
        return `/w/${companyCode}/part-units?${params.toString()}`;
    };

    const renderActionLinks = (stockDocument, options = {}) => {
        const documentNo = stockDocument?.documentNo || "";
        const className = options.className || "document-action-link";
        const links = [];
        if (stockDocument?.documentType === "INBOUND" && stockDocument?.documentStatus !== "CANCELED") {
            links.push(`<a class="${className} document-action-link-primary" href="${buildRouteUrl("inspection", documentNo)}">검수</a>`);
        }
        if (stockDocument?.documentId) {
            links.push(`<a class="${className}" href="${escapeHtml(buildPartUnitsRouteUrl(stockDocument))}">부품 관리</a>`);
        }
        return links.join("");
    };

    const renderCancelAction = (stockDocument) => {
        if (!stockDocument || stockDocument.documentStatus === "CANCELED") {
            return "";
        }
        const isCancelable = stockDocument.cancelable === true;
        const disabled = isCancelable ? "" : " disabled";
        const reason = isCancelable ? "" : ` title="${escapeHtml(stockDocument.cancelBlockedReason || "취소할 수 없습니다.")}"`;
        const label = isCancelable ? `${documentTypeLabel(stockDocument.documentType)} 취소` : "취소 불가";
        return `<button class="btn btn-danger documents-detail-action documents-cancel-action" type="button" data-document-cancel-detail="${escapeHtml(stockDocument.documentId)}"${disabled}${reason}>${label}</button>`;
    };

    const openDetailDrawer = () => {
        window.PcsDrawer.setOpen(detailDrawer, true);
    };

    const closeDetailDrawer = (options = {}) => {
        if (!detailDrawer) {
            return;
        }
        documentDetailRequestId += 1;
        window.PcsDrawer.setOpen(detailDrawer, false);
        selectedDocumentId = null;
        currentDetail = null;
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
        currentDetail = null;
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
        currentDetail = detail;
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
            detailFields.actions.innerHTML = [
                renderCancelAction(detail),
                renderActionLinks(detail, { className: "btn btn-secondary documents-detail-action" }),
            ].filter(Boolean).join("");
        }
        renderDetailLines(detail.lines || []);
        updateSelectedRows();
    };

    const loadDocumentDetail = async (documentId, trigger = null) => {
        const base = workspace.apiBase;
        if (trigger instanceof HTMLElement) {
            lastDetailTrigger = trigger;
        }
        if (!base) {
            setDetailLoading("전표 상세를 불러올 수 없습니다.", documentId);
            return;
        }

        const requestId = ++documentDetailRequestId;
        setDetailLoading("전표 상세를 불러오는 중입니다.", documentId);
        try {
            const detail = await window.PcsApi.getData(workspace.apiUrl(`/stock/documents/${encodeURIComponent(documentId)}`), workspace.apiOptions());
            if (requestId !== documentDetailRequestId) {
                return;
            }
            renderDocumentDetail(detail);
        } catch (error) {
            if (requestId !== documentDetailRequestId) {
                return;
            }
            setDetailLoading(error?.message || "전표 상세를 불러오지 못했습니다.", documentId);
        }
    };

    const setCancelMessage = (message) => {
        if (!cancelFields.message) {
            return;
        }
        cancelFields.message.textContent = message || "";
        cancelFields.message.hidden = !message;
    };

    const openCancelModal = () => {
        cancelTarget = currentDetail;
        if (!cancelTarget || cancelTarget.documentStatus === "CANCELED") {
            return;
        }
        if (cancelTarget.cancelable !== true) {
            window.PcsFeedback.toast(cancelTarget.cancelBlockedReason || "취소할 수 없는 전표입니다.", "warning");
            return;
        }
        if (cancelFields.documentNo) cancelFields.documentNo.textContent = cancelTarget.documentNo || "-";
        if (cancelFields.documentType) cancelFields.documentType.textContent = documentTypeLabel(cancelTarget.documentType);
        if (cancelFields.partner) cancelFields.partner.textContent = cancelTarget.partnerName || "-";
        if (cancelFields.quantity) cancelFields.quantity.textContent = `${numberText(cancelTarget.totalQuantity)}개`;
        setCancelMessage("");
        if (confirmCancelButton) {
            confirmCancelButton.disabled = false;
            confirmCancelButton.textContent = "전표 취소";
        }
        cancelModal?.showModal();
    };

    const closeCancelModal = () => {
        cancelModal?.close();
        cancelTarget = null;
        setCancelMessage("");
    };

    const cancelDocument = async () => {
        const base = workspace.apiBase;
        if (!cancelTarget?.documentId || !base || !confirmCancelButton) {
            setCancelMessage("취소할 전표를 찾을 수 없습니다.");
            return;
        }

        const target = cancelTarget;
        confirmCancelButton.disabled = true;
        confirmCancelButton.textContent = "취소 중";
        try {
            await window.PcsApi.request(workspace.apiUrl(`/stock/documents/${encodeURIComponent(target.documentId)}/cancel`), {
                method: "POST",
                ...workspace.apiOptions(),
            });
            closeCancelModal();
            window.PcsFeedback.toast(`${documentTypeLabel(target.documentType)} 전표 ${target.documentNo} 가 취소되었습니다.`, "success");
            await loadDocumentDetail(target.documentId);
            await loadDocuments(currentPage, { keepRows: true });
        } catch (error) {
            setCancelMessage(error?.message || "전표를 취소하지 못했습니다.");
        } finally {
            confirmCancelButton.disabled = false;
            confirmCancelButton.textContent = "전표 취소";
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
                void window.PcsPagination.withPreservedScroll(execute);
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
        window.PcsPagination.setLoadingState({
            listContainer: listCard,
            target: table,
            overlay: listLoading,
            pagination,
            prevButton,
            nextButton,
            pageData: currentPageData,
            isLoading
        });

        if (!isLoading && !paginationStatus?.classList.contains("is-error")) {
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
        const base = workspace.apiBase;
        if (!base) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const requestId = ++documentListRequestId;
        setLoading(true);
        if (keepRows) {
            setPageLoading(true);
        } else {
            setEmptyMessage("전표 목록을 불러오는 중입니다.", { loading: true });
        }

        try {
            const params = buildParams(page);
            const data = await window.PcsApi.getData(workspace.apiUrl(`/stock/documents?${params.toString()}`), workspace.apiOptions());
            if (requestId !== documentListRequestId) {
                return;
            }
            const pageData = window.PcsPagination.normalizePageData(data, PAGE_SIZE);
            currentPage = pageData.page;
            renderDocuments(pageData);
        } catch (error) {
            if (requestId !== documentListRequestId) {
                return;
            }
            const message = error?.message || "전표 목록을 불러오지 못했습니다.";
            if (keepRows) {
                setPaginationStatus(message, "error");
                window.PcsFeedback.toast(message, "error");
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
            if (requestId === documentListRequestId) {
                if (keepRows) {
                    setPageLoading(false);
                }
                setLoading(false);
            }
        }
    };

    partnerPicker = window.PcsPartnerPicker.bind({
        input: partnerFilter,
        modal: partnerModal,
        search: partnerSearchInput,
        list: partnerList,
        nameTarget: selectedPartnerName,
        metaTarget: selectedPartnerMeta,
        openButtons: openPartnerModalButton,
        closeButtons: closePartnerModalButtons,
        companyCode: workspace.companyCode,
        allowEmpty: true,
        size: 100,
        emptyName: "전체 거래처",
        emptyMeta: "거래처를 검색해 선택해 주세요.",
        getMeta: partnerMeta,
        onChange: () => {
            closeDetailDrawer({ restoreFocus: false });
            void loadDocuments(0);
        },
    });

    const loadPartnerPicker = async () => {
        const selectedPartnerId = partnerFilter?.value;
        if (selectedPartnerId) {
            try {
                const selectedPartner = await window.PcsApi.getData(
                    workspace.apiUrl(`/partners/${encodeURIComponent(selectedPartnerId)}`),
                    workspace.apiOptions()
                );
                partnerPicker.setSelected(selectedPartner);
            } catch {
                // The list load below keeps the normal empty-filter fallback for an invalid deep link.
            }
        }
        await partnerPicker.load();
    };

    const applyUrlParams = () => {
        const params = new URLSearchParams(window.location.search);
        ["keyword", "partnerId", "documentType", "documentStatus", "dateFrom", "dateTo"].forEach((name) => {
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
        partnerPicker.setSelected(null);
        closeDetailDrawer({ restoreFocus: false });
        void loadDocuments(0);
    });

    prevButton?.addEventListener("click", () => {
        if (!currentPageData?.hasPrevious) {
            return;
        }
        closeDetailDrawer({ restoreFocus: false });
        const execute = () => loadDocuments(Math.max(0, currentPage - 1), { keepRows: true });
        void window.PcsPagination.withPreservedScroll(execute);
    });

    nextButton?.addEventListener("click", () => {
        if (!currentPageData?.hasNext) {
            return;
        }
        closeDetailDrawer({ restoreFocus: false });
        const execute = () => loadDocuments(currentPage + 1, { keepRows: true });
        void window.PcsPagination.withPreservedScroll(execute);
    });

    table.addEventListener("click", (event) => {
        const row = event.target.closest("[data-document-id]");
        if (!row) {
            return;
        }
        void loadDocumentDetail(row.dataset.documentId, row);
    });

    detailFields.actions?.addEventListener("click", (event) => {
        const cancelButton = event.target.closest("[data-document-cancel-detail]");
        if (!cancelButton || cancelButton.disabled) {
            return;
        }
        event.preventDefault();
        openCancelModal();
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

    closeCancelModalButtons.forEach((button) => {
        button.addEventListener("click", closeCancelModal);
    });

    cancelModal?.addEventListener("click", (event) => {
        if (event.target === cancelModal) {
            closeCancelModal();
        }
    });

    confirmCancelButton?.addEventListener("click", cancelDocument);

    window.PcsDrawer?.bindDismiss({
        drawer: detailDrawer,
        close: closeDetailDrawer,
        keepOpenSelector: "[data-document-id], [data-cancel-modal], [data-partner-modal]",
        shouldIgnoreEscape: () => Boolean(cancelModal?.open),
    });

    const initialize = async () => {
        const companyCode = workspace.companyCode;
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
            await loadPartnerPicker();
            await loadDocuments(0);
        } catch (error) {
            setEmptyMessage(error?.message || "화면을 초기화하지 못했습니다.");
        }
    };

    void initialize();
})();
