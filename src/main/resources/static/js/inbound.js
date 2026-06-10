(() => {
    const PAGE_SIZE = 20;

    window.PcsUi?.consumeFlashToast();

    const filterForm = document.querySelector(".document-filter-form");
    const searchButton = filterForm?.querySelector("button[type='submit']");
    const partnerFilter = document.querySelector("[data-partner-filter]");
    const inboundTable = document.querySelector(".document-data-table");
    const tableHead = inboundTable?.querySelector(".table-head");
    const emptyRow = document.querySelector("[data-inbound-empty]");
    const pagination = document.querySelector("[data-inbound-pagination]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const notice = document.querySelector("[data-created-notice]");
    const summaryDocuments = document.querySelector("[data-summary-documents]");
    const summaryQuantity = document.querySelector("[data-summary-quantity]");
    const summaryWaiting = document.querySelector("[data-summary-waiting]");
    const summaryCanceled = document.querySelector("[data-summary-canceled]");
    const panelViews = document.querySelectorAll("[data-inbound-panel]");
    const detailFields = {
        subtitle: document.querySelector("[data-detail-subtitle]"),
        documentNo: document.querySelector("[data-detail-document-no]"),
        status: document.querySelector("[data-detail-status]"),
        partner: document.querySelector("[data-detail-partner]"),
        createdAt: document.querySelector("[data-detail-created-at]"),
        processedBy: document.querySelector("[data-detail-processed-by]"),
        reason: document.querySelector("[data-detail-reason]"),
        cancelState: document.querySelector("[data-detail-cancel-state]"),
        lineSummary: document.querySelector("[data-detail-line-summary]"),
        lines: document.querySelector("[data-detail-lines]"),
    };
    const closeDetailButtons = document.querySelectorAll("[data-close-detail-panel]");
    const cancelModal = document.querySelector("[data-cancel-modal]");
    const closeCancelModalButtons = document.querySelectorAll("[data-close-cancel-modal]");
    const openCancelModalButton = document.querySelector("[data-open-cancel-modal]");
    const confirmCancelButton = document.querySelector("[data-confirm-cancel]");
    const cancelFields = {
        documentNo: document.querySelector("[data-cancel-document-no]"),
        partner: document.querySelector("[data-cancel-partner]"),
        quantity: document.querySelector("[data-cancel-quantity]"),
        message: document.querySelector("[data-cancel-message]"),
    };
    const createdInboundKey = "pcsCreatedInboundDocument";
    let createdInbound = null;
    let currentDocuments = [];
    let currentPage = 0;
    let currentPageData = null;
    let selectedDocumentId = null;
    let currentDetail = null;
    let cancelTarget = null;

    const getCompanyCode = () => {
        const segments = window.location.pathname.split("/").filter(Boolean);
        return segments[0] === "w" && segments[1] ? decodeURIComponent(segments[1]) : "";
    };

    const escapeHtml = (value) => String(value || "").replace(/[&<>"']/g, (letter) => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#039;",
    }[letter]));

    const normalizeListData = (data) => Array.isArray(data?.content) ? data.content : [];

    const normalizePageData = (data) => {
        if (window.PcsPagination) {
            return window.PcsPagination.normalizePageData(data, PAGE_SIZE);
        }
        return {
            content: normalizeListData(data),
            page: 0,
            size: PAGE_SIZE,
            totalElements: normalizeListData(data).length,
            totalPages: normalizeListData(data).length ? 1 : 0,
            hasPrevious: false,
            hasNext: false,
            summary: data?.summary || null,
        };
    };

    const formatDate = (value) => {
        if (!value) {
            return "-";
        }
        const text = String(value);
        if (/^\d{4}-\d{2}-\d{2}/.test(text)) {
            return text.slice(0, 10);
        }
        const date = new Date(value);
        if (Number.isNaN(date.getTime())) {
            return text.slice(0, 10) || "-";
        }
        const year = String(date.getFullYear());
        const month = String(date.getMonth() + 1).padStart(2, "0");
        const day = String(date.getDate()).padStart(2, "0");
        return `${year}-${month}-${day}`;
    };

    const documentStatusLabel = (status) => {
        if (status === "CANCELED") {
            return "취소";
        }
        return "완료";
    };

    const documentStatusClass = (status) => {
        if (status === "CANCELED") {
            return "badge-inactive";
        }
        return "badge-active";
    };

    const numberText = (value) => Number(value || 0).toLocaleString("ko-KR");

    const statusText = (status) => {
        const labels = {
            WAITING: "검수 대기",
            COMPLETED: "검수 완료",
            HOLD: "판매 보류",
            AVAILABLE: "판매 가능",
            UNAVAILABLE: "판매 불가",
            IN_STOCK: "재고",
            OUTBOUND: "출고",
            DISPOSED: "폐기",
            CANCELED: "취소",
        };
        return labels[status] || status || "-";
    };

    const setPanelMode = (mode) => {
        panelViews.forEach((panel) => {
            const isActive = panel.dataset.inboundPanel === mode;
            panel.hidden = !isActive;
            panel.classList.toggle("is-active", isActive);
        });
    };

    const getCompanyApiBase = () => {
        const companyCode = getCompanyCode();
        if (!companyCode) {
            return "";
        }
        return `/api/workspaces/${encodeURIComponent(companyCode)}`;
    };

    const updatePagination = (pageData) => {
        currentPageData = pageData;
        if (window.PcsPagination) {
            window.PcsPagination.updateControls({
                pageData,
                container: pagination,
                info: pageInfo,
                prevButton,
                nextButton,
            });
            return;
        }
        if (pagination) {
            pagination.hidden = pageData.totalPages <= 1;
        }
        if (pageInfo) {
            pageInfo.textContent = pageData.totalElements ? `${pageData.page + 1} / ${pageData.totalPages} 페이지` : "0건";
        }
    };

    const renderPartnerOptions = (partners) => {
        if (!partnerFilter) {
            return;
        }

        partnerFilter.innerHTML = "";
        partnerFilter.append(new Option("전체 거래처", ""));

        partners.forEach((partner) => {
            partnerFilter.append(new Option(partner.partnerName, String(partner.partnerId)));
        });
    };

    const loadPartnerFilter = async () => {
        if (!partnerFilter) {
            return;
        }

        const companyCode = getCompanyCode();
        const api = window.PcsApi;

        if (!companyCode || !api) {
            partnerFilter.innerHTML = '<option value="">거래처를 불러오지 못했습니다</option>';
            partnerFilter.disabled = true;
            return;
        }

        partnerFilter.disabled = true;

        try {
            const params = new URLSearchParams({
                partnerRole: "SUPPLIER",
                active: "true",
                limit: "100",
            });
            const data = await api.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/partners?${params.toString()}`, {
                authRedirect: true,
                loginCompanyCode: companyCode,
            });
            renderPartnerOptions(Array.isArray(data) ? data : data?.content || []);
            partnerFilter.disabled = false;
        } catch (error) {
            partnerFilter.innerHTML = '<option value="">거래처를 불러오지 못했습니다</option>';
            partnerFilter.disabled = true;
        }
    };

    const consumeCreatedInbound = () => {
        try {
            const rawCreatedInbound = window.sessionStorage.getItem(createdInboundKey);
            createdInbound = rawCreatedInbound ? JSON.parse(rawCreatedInbound) : null;
            window.sessionStorage.removeItem(createdInboundKey);
        } catch (error) {
            createdInbound = null;
            try {
                window.sessionStorage.removeItem(createdInboundKey);
            } catch (storageError) {
                // Ignore storage cleanup failures.
            }
        }

        if (!createdInbound?.documentNo) {
            return;
        }

        const documentNo = String(createdInbound.documentNo);

        if (notice) {
            notice.hidden = false;
            notice.textContent = `입고 전표 ${documentNo} 가 등록되었습니다.`;
        }
    };

    const clearDocumentRows = () => {
        inboundTable?.querySelectorAll(".document-data-row:not(.table-head):not([data-inbound-empty])").forEach((row) => {
            row.remove();
        });
    };

    const setEmptyMessage = (message) => {
        if (!emptyRow) {
            return;
        }
        emptyRow.hidden = false;
        emptyRow.querySelector("[role='cell']").textContent = message;
    };

    const hideEmptyMessage = () => {
        if (emptyRow) {
            emptyRow.hidden = true;
        }
    };

    const buildDocumentSubText = (stockDocument) => {
        const firstPartName = stockDocument.firstPartName || "-";
        const lineCount = Number(stockDocument.lineCount) || 0;
        const extra = lineCount > 1 ? ` 외 ${lineCount - 1}종` : "";
        const processedByName = stockDocument.processedByName || "-";
        return `${firstPartName}${extra} · ${processedByName} 처리`;
    };

    const createInboundRow = (stockDocument) => {
        const row = document.createElement("div");
        const isCreated = createdInbound?.documentNo && createdInbound.documentNo === stockDocument.documentNo;
        const isCanceled = stockDocument.documentStatus === "CANCELED";
        const isSelected = selectedDocumentId && String(selectedDocumentId) === String(stockDocument.documentId);
        row.className = `data-row document-data-row${isCreated ? " is-created" : ""}${isSelected ? " is-selected" : ""}`;
        row.setAttribute("role", "row");
        row.setAttribute("tabindex", "0");
        row.dataset.documentId = String(stockDocument.documentId);
        row.innerHTML = `
            <strong role="cell" data-label="전표번호">${escapeHtml(stockDocument.documentNo)}</strong>
            <span role="cell" class="cell-stack" data-label="입고 내용">
                <b>${escapeHtml(stockDocument.partnerName || "-")}</b>
                <small>${escapeHtml(buildDocumentSubText(stockDocument))}</small>
            </span>
            <span role="cell" data-label="수량">${Number(stockDocument.totalQuantity || 0)}개</span>
            <span role="cell" data-label="상태"><em class="badge ${documentStatusClass(stockDocument.documentStatus)}">${documentStatusLabel(stockDocument.documentStatus)}</em></span>
            <span role="cell" data-label="입고일">${formatDate(stockDocument.createdAt)}</span>
            <span role="cell" class="row-actions" data-label="관리">
                <button type="button" data-document-detail="${stockDocument.documentId}">상세</button>
                <button type="button" data-document-cancel="${stockDocument.documentId}"${isCanceled ? " disabled" : ""}>${isCanceled ? "취소됨" : "취소"}</button>
            </span>
        `;
        return row;
    };

    const updateSummary = (data) => {
        const summary = data?.summary || {};
        if (summaryDocuments) summaryDocuments.textContent = String(summary.totalCount || 0);
        if (summaryQuantity) summaryQuantity.textContent = String(summary.totalQuantity || 0);
        if (summaryWaiting) summaryWaiting.textContent = String(summary.waitingQuantity || 0);
        if (summaryCanceled) summaryCanceled.textContent = String(summary.canceledCount || 0);
    };

    const renderDocuments = (data) => {
        const documents = Array.isArray(data?.content) ? data.content : normalizeListData(data);
        currentDocuments = documents;
        clearDocumentRows();
        updateSummary(data);

        if (!documents.length) {
            selectedDocumentId = null;
            currentDetail = null;
            setPanelMode("guide");
            setEmptyMessage("조회된 입고 전표가 없습니다.");
            updatePagination(data);
            return;
        }

        hideEmptyMessage();
        documents.forEach((stockDocument) => {
            const row = createInboundRow(stockDocument);
            if (emptyRow) {
                emptyRow.insertAdjacentElement("beforebegin", row);
            } else {
                inboundTable.append(row);
            }
        });
        updatePagination(data);
    };

    const findDocumentSummary = (documentId) => {
        return currentDocuments.find((stockDocument) => String(stockDocument.documentId) === String(documentId)) || null;
    };

    const updateSelectedRows = () => {
        inboundTable?.querySelectorAll("[data-document-id]").forEach((row) => {
            const isSelected = selectedDocumentId && String(row.dataset.documentId) === String(selectedDocumentId);
            row.classList.toggle("is-selected", Boolean(isSelected));
            row.setAttribute("aria-selected", String(Boolean(isSelected)));
        });
    };

    const setDetailStatus = (status) => {
        if (!detailFields.status) {
            return;
        }
        detailFields.status.className = `badge ${documentStatusClass(status)}`;
        detailFields.status.textContent = documentStatusLabel(status);
    };

    const copyText = async (text) => {
        if (!text) {
            return false;
        }
        if (navigator.clipboard?.writeText) {
            await navigator.clipboard.writeText(text);
            return true;
        }
        const input = document.createElement("textarea");
        input.value = text;
        input.setAttribute("readonly", "");
        input.style.position = "fixed";
        input.style.left = "-9999px";
        document.body.append(input);
        input.select();
        const copied = document.execCommand("copy");
        input.remove();
        return copied;
    };

    const renderDetailLines = (lines) => {
        if (!detailFields.lines) {
            return;
        }
        if (!lines?.length) {
            detailFields.lines.innerHTML = '<p class="detail-empty-text">등록된 부품 라인이 없습니다.</p>';
            return;
        }

        detailFields.lines.innerHTML = lines.map((line) => {
            const units = Array.isArray(line.units) ? line.units : [];
            const unitList = units.length
                    ? units.map((unit) => `
                        <li>
                            <code>${escapeHtml(unit.internalSerialNo || "-")}</code>
                            <span>${escapeHtml(statusText(unit.inspectionStatus))}</span>
                            <button type="button" data-copy-serial="${escapeHtml(unit.internalSerialNo || "")}">복사</button>
                        </li>
                    `).join("")
                    : '<li><span>관리번호 없음</span></li>';
            return `
                <details class="document-line-item" open>
                    <summary>
                        <span>
                            <strong>${escapeHtml(line.partName || "-")}</strong>
                            <small>${escapeHtml(line.modelName || line.partCode || "-")}</small>
                        </span>
                        <b>${numberText(line.quantity)}개</b>
                    </summary>
                    <ul>${unitList}</ul>
                </details>
            `;
        }).join("");
    };

    const renderDocumentDetail = (detail) => {
        currentDetail = detail;
        selectedDocumentId = detail.documentId;
        if (detailFields.subtitle) detailFields.subtitle.textContent = `${detail.partnerName || "-"} · ${formatDate(detail.createdAt)}`;
        if (detailFields.documentNo) detailFields.documentNo.textContent = detail.documentNo || "-";
        setDetailStatus(detail.documentStatus);
        if (detailFields.partner) detailFields.partner.textContent = detail.partnerName || "-";
        if (detailFields.createdAt) detailFields.createdAt.textContent = formatDate(detail.createdAt);
        if (detailFields.processedBy) detailFields.processedBy.textContent = detail.processedByName || "-";
        if (detailFields.reason) detailFields.reason.textContent = detail.reason || "-";
        if (detailFields.cancelState) {
            detailFields.cancelState.textContent = detail.cancelable === true
                    ? "취소 가능"
                    : detail.cancelBlockedReason || "취소할 수 없습니다.";
        }
        if (detailFields.lineSummary) {
            detailFields.lineSummary.textContent = `${numberText(detail.lineCount)}개 라인 · ${numberText(detail.totalQuantity)}개`;
        }
        if (openCancelModalButton) {
            openCancelModalButton.disabled = detail.cancelable !== true;
        }
        renderDetailLines(detail.lines || []);
        updateSelectedRows();
    };

    const setDetailLoading = (message) => {
        selectedDocumentId = null;
        currentDetail = null;
        setPanelMode("detail");
        if (detailFields.subtitle) detailFields.subtitle.textContent = message;
        if (detailFields.documentNo) detailFields.documentNo.textContent = "-";
        setDetailStatus("COMPLETED");
        if (detailFields.partner) detailFields.partner.textContent = "-";
        if (detailFields.createdAt) detailFields.createdAt.textContent = "-";
        if (detailFields.processedBy) detailFields.processedBy.textContent = "-";
        if (detailFields.reason) detailFields.reason.textContent = "-";
        if (detailFields.cancelState) detailFields.cancelState.textContent = "-";
        if (detailFields.lineSummary) detailFields.lineSummary.textContent = "-";
        if (detailFields.lines) detailFields.lines.innerHTML = `<p class="detail-empty-text">${escapeHtml(message)}</p>`;
        if (openCancelModalButton) openCancelModalButton.disabled = true;
    };

    const loadDocumentDetail = async (documentId) => {
        const companyCode = getCompanyCode();
        const apiBase = getCompanyApiBase();
        if (!apiBase || !window.PcsApi) {
            setDetailLoading("입고 전표 상세를 불러오지 못했습니다.");
            return;
        }

        setDetailLoading("입고 전표 상세를 불러오는 중입니다.");
        selectedDocumentId = documentId;
        try {
            const detail = await window.PcsApi.getData(`${apiBase}/stock/documents/${encodeURIComponent(documentId)}`, {
                authRedirect: true,
                loginCompanyCode: companyCode,
            });
            renderDocumentDetail(detail);
        } catch (error) {
            setDetailLoading(error.message || "입고 전표 상세를 불러오지 못했습니다.");
        }
    };

    const closeDetailPanel = () => {
        selectedDocumentId = null;
        currentDetail = null;
        setPanelMode("guide");
        updateSelectedRows();
    };

    const setCancelMessage = (message) => {
        if (!cancelFields.message) {
            return;
        }
        cancelFields.message.textContent = message || "";
        cancelFields.message.hidden = !message;
    };

    const openCancelModal = (stockDocument) => {
        cancelTarget = stockDocument || currentDetail;
        if (!cancelTarget || cancelTarget.documentStatus === "CANCELED") {
            return;
        }
        if (cancelTarget.cancelable === false) {
            window.PcsUi?.toast({
                type: "warning",
                message: cancelTarget.cancelBlockedReason || "취소할 수 없는 전표입니다.",
            });
            return;
        }
        if (cancelFields.documentNo) cancelFields.documentNo.textContent = cancelTarget.documentNo || "-";
        if (cancelFields.partner) cancelFields.partner.textContent = cancelTarget.partnerName || "-";
        if (cancelFields.quantity) cancelFields.quantity.textContent = `${numberText(cancelTarget.totalQuantity)}개`;
        setCancelMessage("");
        confirmCancelButton.disabled = false;
        confirmCancelButton.textContent = "전표 취소";
        cancelModal?.showModal();
    };

    const closeCancelModal = () => {
        cancelModal?.close();
        setCancelMessage("");
    };

    const cancelDocument = async () => {
        const companyCode = getCompanyCode();
        const apiBase = getCompanyApiBase();
        if (!cancelTarget?.documentId || !apiBase || !window.PcsApi) {
            setCancelMessage("취소할 전표를 찾을 수 없습니다.");
            return;
        }

        confirmCancelButton.disabled = true;
        confirmCancelButton.textContent = "취소 중";
        try {
            await window.PcsApi.request(`${apiBase}/stock/documents/${encodeURIComponent(cancelTarget.documentId)}/cancel`, {
                method: "POST",
                authRedirect: true,
                loginCompanyCode: companyCode,
            });
            closeCancelModal();
            window.PcsUi?.toast({
                type: "success",
                message: `입고 전표 ${cancelTarget.documentNo} 가 취소되었습니다.`,
            });
            if (currentDetail?.documentId && String(currentDetail.documentId) === String(cancelTarget.documentId)) {
                await loadDocumentDetail(cancelTarget.documentId);
            }
            await loadDocuments(currentPage, { preserveDetail: Boolean(currentDetail) });
        } catch (error) {
            setCancelMessage(error.message || "입고 전표를 취소하지 못했습니다.");
        } finally {
            confirmCancelButton.disabled = false;
            confirmCancelButton.textContent = "전표 취소";
        }
    };

    const buildDocumentParams = (page = 0) => {
        if (window.PcsPagination) {
            return window.PcsPagination.buildParams({
                page,
                size: PAGE_SIZE,
                form: filterForm,
                extraParams: {
                    documentType: "INBOUND",
                },
            });
        }
        const params = new URLSearchParams({
            documentType: "INBOUND",
            page: String(Math.max(0, page)),
            size: String(PAGE_SIZE),
        });
        const keyword = filterForm?.elements.keyword?.value?.trim();
        const partnerId = filterForm?.elements.partnerId?.value;
        const documentStatus = filterForm?.elements.documentStatus?.value;

        if (keyword) params.set("keyword", keyword);
        if (partnerId) params.set("partnerId", partnerId);
        if (documentStatus) params.set("documentStatus", documentStatus);

        return params;
    };

    const setLoading = (isLoading) => {
        if (searchButton) {
            searchButton.disabled = isLoading;
            searchButton.textContent = isLoading ? "조회 중" : "검색";
        }
    };

    const loadDocuments = async (page = 0, options = {}) => {
        const companyCode = getCompanyCode();
        const api = window.PcsApi;

        if (!inboundTable || !tableHead) {
            return;
        }
        if (!companyCode || !api) {
            setEmptyMessage("입고 전표 목록을 불러오지 못했습니다.");
            return;
        }

        const preserveDetail = options.preserveDetail === true;
        setLoading(true);
        if (!preserveDetail) {
            selectedDocumentId = null;
            currentDetail = null;
            setPanelMode("guide");
        }
        setEmptyMessage("입고 전표 목록을 불러오는 중입니다.");

        try {
            const data = await api.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/stock/documents?${buildDocumentParams(page).toString()}`, {
                authRedirect: true,
                loginCompanyCode: companyCode,
            });
            const pageData = normalizePageData(data);
            currentPage = pageData.page;
            renderDocuments(pageData);
        } catch (error) {
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
            setEmptyMessage(error.message || "입고 전표 목록을 불러오지 못했습니다.");
        } finally {
            setLoading(false);
        }
    };

    filterForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        loadDocuments(0);
    });

    prevButton?.addEventListener("click", () => {
        if (!currentPageData?.hasPrevious) {
            return;
        }
        loadDocuments(Math.max(0, currentPage - 1));
    });

    nextButton?.addEventListener("click", () => {
        if (!currentPageData?.hasNext) {
            return;
        }
        loadDocuments(currentPage + 1);
    });

    inboundTable?.addEventListener("click", (event) => {
        const detailButton = event.target.closest("[data-document-detail]");
        if (detailButton) {
            loadDocumentDetail(detailButton.dataset.documentDetail);
            return;
        }

        const cancelButton = event.target.closest("[data-document-cancel]");
        if (cancelButton) {
            openCancelModal(findDocumentSummary(cancelButton.dataset.documentCancel));
            return;
        }

        const row = event.target.closest("[data-document-id]");
        if (row) {
            loadDocumentDetail(row.dataset.documentId);
        }
    });

    inboundTable?.addEventListener("keydown", (event) => {
        if (event.key !== "Enter" && event.key !== " ") {
            return;
        }
        const row = event.target.closest("[data-document-id]");
        if (!row) {
            return;
        }
        event.preventDefault();
        loadDocumentDetail(row.dataset.documentId);
    });

    closeDetailButtons.forEach((button) => {
        button.addEventListener("click", closeDetailPanel);
    });

    detailFields.lines?.addEventListener("click", async (event) => {
        const copyButton = event.target.closest("[data-copy-serial]");
        if (!copyButton) {
            return;
        }
        event.preventDefault();
        const serialNo = copyButton.dataset.copySerial;
        try {
            const copied = await copyText(serialNo);
            window.PcsUi?.toast({
                type: copied ? "success" : "warning",
                message: copied ? "관리번호를 복사했습니다." : "관리번호를 복사하지 못했습니다.",
            });
        } catch (error) {
            window.PcsUi?.toast({
                type: "error",
                message: "관리번호를 복사하지 못했습니다.",
            });
        }
    });

    openCancelModalButton?.addEventListener("click", () => {
        openCancelModal(currentDetail);
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

    consumeCreatedInbound();
    loadPartnerFilter();
    loadDocuments(0);
})();
