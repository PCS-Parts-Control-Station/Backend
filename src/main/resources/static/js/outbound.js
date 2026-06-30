(() => {
    const PAGE_SIZE = 20;

    window.PcsUi?.consumeFlashToast();

    const filterForm = document.querySelector(".outbound-document-filter-form");
    const searchButton = filterForm?.querySelector("button[type='submit']");
    const partnerFilter = document.querySelector("[data-partner-filter]");
    const openPartnerModalButton = document.querySelector("[data-open-partner-modal]");
    const partnerModal = document.querySelector("[data-partner-modal]");
    const closePartnerModalButtons = document.querySelectorAll("[data-close-partner-modal]");
    const partnerSearchInput = document.querySelector("[data-partner-search]");
    const partnerList = document.querySelector("[data-partner-list]");
    const selectedPartnerName = document.querySelector("[data-selected-partner-name]");
    const selectedPartnerMeta = document.querySelector("[data-selected-partner-meta]");
    const outboundTable = document.querySelector(".document-data-table");
    const emptyRow = document.querySelector("[data-outbound-empty]");
    const pagination = document.querySelector("[data-outbound-pagination]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const notice = document.querySelector("[data-created-notice]");
    const summaryDocuments = document.querySelector("[data-summary-documents]");
    const summaryQuantity = document.querySelector("[data-summary-quantity]");
    const summaryCompleted = document.querySelector("[data-summary-completed]");
    const summaryCanceled = document.querySelector("[data-summary-canceled]");
    const detailDrawer = document.querySelector("[data-outbound-detail-drawer]");
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
    const createdOutboundKey = "pcsCreatedOutboundDocument";

    let createdOutbound = null;
    let currentDocuments = [];
    let currentPage = 0;
    let currentPageData = null;
    let selectedDocumentId = null;
    let currentDetail = null;
    let cancelTarget = null;
    let lastDetailTrigger = null;
    let partners = [];
    let selectedPartner = null;

    if (!filterForm || !outboundTable || !window.PcsApi) {
        return;
    }

    const getCompanyCode = () => {
        const segments = window.location.pathname.split("/").filter(Boolean);
        return segments[0] === "w" && segments[1] ? decodeURIComponent(segments[1]) : "";
    };

    const getCompanyApiBase = () => {
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

    const normalizeListData = (data) => {
        if (Array.isArray(data)) {
            return data;
        }
        return Array.isArray(data?.content) ? data.content : [];
    };

    const normalizePageData = (data) => {
        if (window.PcsPagination) {
            return window.PcsPagination.normalizePageData(data, PAGE_SIZE);
        }
        const content = normalizeListData(data);
        return {
            content,
            page: 0,
            size: PAGE_SIZE,
            totalElements: content.length,
            totalPages: content.length ? 1 : 0,
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

    const numberText = (value) => Number(value || 0).toLocaleString("ko-KR");

    const partnerRoleLabel = (role) => {
        if (role === "CUSTOMER") return "고객";
        if (role === "SUPPLIER") return "공급처";
        if (role === "BOTH") return "공급처/고객";
        return role || "-";
    };

    const partnerMeta = (partner) => {
        const code = partner.partnerCode || partner.code || "";
        const role = partnerRoleLabel(partner.partnerRole);
        return [code, role].filter(Boolean).join(" · ") || "거래처 정보 없음";
    };

    const partnerSearchText = (partner) => [
        partner.partnerName,
        partner.partnerCode,
        partner.code,
        partner.representativeName,
        partner.phoneNumber,
        partner.tel,
    ].filter(Boolean).join(" ").toLowerCase();

    const documentStatusLabel = (status) => status === "CANCELED" ? "취소" : "완료";

    const documentStatusClass = (status) => status === "CANCELED" ? "badge-inactive" : "badge-active";

    const unitStatusLabel = (status) => {
        if (status === "IN_STOCK") return "보관";
        if (status === "OUTBOUND") return "출고";
        if (status === "DISPOSED") return "폐기";
        if (status === "CANCELED") return "취소";
        return status || "-";
    };

    const gradeLabel = (grade) => {
        if (!grade || grade === "NONE") return "미정";
        if (grade === "DEFECTIVE") return "불량";
        return grade;
    };

    const gradeClass = (grade) => {
        if (grade === "A") return "grade-a";
        if (grade === "B") return "grade-b";
        if (grade === "C") return "grade-c";
        if (grade === "DEFECTIVE") return "grade-defective";
        return "";
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
        const restoreFocus = options.restoreFocus !== false;
        setDetailDrawerOpen(false);
        if (restoreFocus && lastDetailTrigger?.isConnected) {
            lastDetailTrigger.focus({ preventScroll: true });
        }
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

    const updateSelectedPartnerView = () => {
        if (!partnerFilter) {
            return;
        }
        const hasPartner = Boolean(selectedPartner);
        partnerFilter.value = hasPartner ? String(selectedPartner.partnerId) : "";
        if (selectedPartnerName) {
            selectedPartnerName.textContent = hasPartner ? selectedPartner.partnerName : "전체 거래처";
        }
        if (selectedPartnerMeta) {
            selectedPartnerMeta.textContent = hasPartner ? partnerMeta(selectedPartner) : "거래처를 검색해 선택해 주세요.";
        }
        openPartnerModalButton?.classList.toggle("is-selected", hasPartner);
    };

    const renderPartnerList = () => {
        if (!partnerList) {
            return;
        }
        const keyword = partnerSearchInput?.value.trim().toLowerCase() || "";
        const filteredPartners = keyword
                ? partners.filter((partner) => partnerSearchText(partner).includes(keyword))
                : partners;
        const allSelected = !selectedPartner;
        const allRow = `
            <button class="partner-modal-row${allSelected ? " is-selected" : ""}" type="button" data-partner-option="">
                <span>
                    <strong>전체 거래처</strong>
                    <small>거래처 조건 없이 조회합니다.</small>
                </span>
            </button>
        `;
        if (!filteredPartners.length) {
            partnerList.innerHTML = `${allRow}<p class="partner-modal-empty">${partners.length ? "검색 결과가 없습니다." : "선택 가능한 고객 거래처가 없습니다."}</p>`;
            return;
        }
        const partnerRows = filteredPartners.map((partner) => {
            const selected = String(selectedPartner?.partnerId || "") === String(partner.partnerId);
            return `
                <button class="partner-modal-row${selected ? " is-selected" : ""}" type="button" data-partner-option="${escapeHtml(String(partner.partnerId))}">
                    <span>
                        <strong>${escapeHtml(partner.partnerName || "-")}</strong>
                        <small>${escapeHtml(partnerMeta(partner))}</small>
                    </span>
                </button>
            `;
        }).join("");
        partnerList.innerHTML = `${allRow}${partnerRows}`;
    };

    const selectPartnerFilter = (partner) => {
        selectedPartner = partner;
        updateSelectedPartnerView();
        renderPartnerList();
        partnerModal?.close();
    };

    const renderPartnerOptions = (nextPartners) => {
        partners = nextPartners;
        if (openPartnerModalButton) {
            openPartnerModalButton.disabled = false;
        }
        updateSelectedPartnerView();
        renderPartnerList();
    };

    const loadPartnerFilter = async () => {
        if (!partnerFilter || !openPartnerModalButton) {
            return;
        }
        const apiBase = getCompanyApiBase();
        if (!apiBase) {
            openPartnerModalButton.disabled = true;
            if (selectedPartnerName) selectedPartnerName.textContent = "거래처 조회 실패";
            return;
        }

        openPartnerModalButton.disabled = true;
        try {
            const params = new URLSearchParams({
                active: "true",
                limit: "100",
            });
            const data = await window.PcsApi.getData(`${apiBase}/partners?${params.toString()}`, apiOptions());
            const partners = normalizeListData(data).filter((partner) => {
                const role = partner.partnerRole || "";
                return role === "CUSTOMER" || role === "BOTH";
            });
            renderPartnerOptions(partners);
        } catch (error) {
            openPartnerModalButton.disabled = true;
            if (selectedPartnerName) selectedPartnerName.textContent = "거래처 조회 실패";
        }
    };

    const consumeCreatedOutbound = () => {
        try {
            const rawCreatedOutbound = window.sessionStorage.getItem(createdOutboundKey);
            createdOutbound = rawCreatedOutbound ? JSON.parse(rawCreatedOutbound) : null;
            window.sessionStorage.removeItem(createdOutboundKey);
        } catch (error) {
            createdOutbound = null;
            try {
                window.sessionStorage.removeItem(createdOutboundKey);
            } catch (storageError) {
                // Ignore storage cleanup failures.
            }
        }

        if (!createdOutbound?.documentNo || !notice) {
            return;
        }
        notice.hidden = false;
        notice.textContent = `출고 전표 ${createdOutbound.documentNo} 가 등록되었습니다.`;
    };

    const clearDocumentRows = () => {
        outboundTable.querySelectorAll(".document-data-row:not(.table-head):not([data-outbound-empty])").forEach((row) => {
            row.remove();
        });
    };

    const setEmptyMessage = (message, options = {}) => {
        if (!emptyRow) {
            return;
        }
        emptyRow.hidden = false;
        emptyRow.classList.toggle("is-loading", options.loading === true);
        emptyRow.querySelector("[role='cell']").textContent = message;
    };

    const hideEmptyMessage = () => {
        if (emptyRow) {
            emptyRow.hidden = true;
            emptyRow.classList.remove("is-loading");
        }
    };

    const buildDocumentSubText = (stockDocument) => {
        const firstPartName = stockDocument.firstPartName || "-";
        const lineCount = Number(stockDocument.lineCount || 0);
        const extra = lineCount > 1 ? ` 외 ${lineCount - 1}종` : "";
        const processedByName = stockDocument.processedByName || "-";
        return `${firstPartName}${extra} · ${processedByName} 처리`;
    };

    const createOutboundRow = (stockDocument) => {
        const row = document.createElement("div");
        const isCreated = createdOutbound?.documentNo && createdOutbound.documentNo === stockDocument.documentNo;
        const isCanceled = stockDocument.documentStatus === "CANCELED";
        const isSelected = selectedDocumentId && String(selectedDocumentId) === String(stockDocument.documentId);

        row.className = `data-row document-data-row${isCreated ? " is-created" : ""}${isSelected ? " is-selected" : ""}`;
        row.setAttribute("role", "row");
        row.setAttribute("tabindex", "0");
        row.setAttribute("aria-selected", String(Boolean(isSelected)));
        row.dataset.documentId = String(stockDocument.documentId);
        row.innerHTML = `
            <strong role="cell" data-label="전표번호">${escapeHtml(stockDocument.documentNo)}</strong>
            <span role="cell" class="cell-stack" data-label="출고 내용">
                <b>${escapeHtml(stockDocument.partnerName || "-")}</b>
                <small>${escapeHtml(buildDocumentSubText(stockDocument))}</small>
            </span>
            <span role="cell" data-label="수량">${numberText(stockDocument.totalQuantity)}개</span>
            <span role="cell" data-label="상태"><em class="badge ${documentStatusClass(stockDocument.documentStatus)}">${documentStatusLabel(stockDocument.documentStatus)}</em></span>
            <span role="cell" data-label="출고일">${formatDate(stockDocument.createdAt)}</span>
            <span role="cell" class="row-actions" data-label="취소">
                <button type="button" data-document-cancel="${stockDocument.documentId}"${isCanceled ? " disabled" : ""}>${isCanceled ? "취소됨" : "취소"}</button>
            </span>
        `;
        return row;
    };

    const updateSummary = (data) => {
        const summary = data?.summary || {};
        const totalCount = Number(summary.totalCount || 0);
        const canceledCount = Number(summary.canceledCount || 0);
        if (summaryDocuments) summaryDocuments.textContent = numberText(totalCount);
        if (summaryQuantity) summaryQuantity.textContent = numberText(summary.totalQuantity);
        if (summaryCompleted) summaryCompleted.textContent = numberText(Math.max(0, totalCount - canceledCount));
        if (summaryCanceled) summaryCanceled.textContent = numberText(canceledCount);
    };

    const renderDocuments = (data) => {
        const documents = normalizeListData(data);
        currentDocuments = documents;
        clearDocumentRows();
        updateSummary(data);

        if (!documents.length) {
            selectedDocumentId = null;
            currentDetail = null;
            closeDetailDrawer({ restoreFocus: false });
            setEmptyMessage("조회된 출고 전표가 없습니다.");
            updatePagination(data);
            return;
        }

        hideEmptyMessage();
        documents.forEach((stockDocument) => {
            const row = createOutboundRow(stockDocument);
            if (emptyRow) {
                emptyRow.insertAdjacentElement("beforebegin", row);
            } else {
                outboundTable.append(row);
            }
        });
        updatePagination(data);
    };

    const updateSelectedRows = () => {
        outboundTable.querySelectorAll("[data-document-id]").forEach((row) => {
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

    const renderDetailLines = (lines) => {
        if (!detailFields.lines) {
            return;
        }

        if (!lines?.length) {
            detailFields.lines.innerHTML = '<p class="detail-empty-text">등록된 출고 품목이 없습니다.</p>';
            if (detailFields.lineSummary) {
                detailFields.lineSummary.textContent = "0개 품목 · 총 0개";
            }
            return;
        }

        const totalQuantity = lines.reduce((sum, line) => sum + Number(line.quantity || 0), 0);
        if (detailFields.lineSummary) {
            detailFields.lineSummary.textContent = `${numberText(lines.length)}개 품목 · 총 ${numberText(totalQuantity)}개`;
        }

        detailFields.lines.innerHTML = lines.map((line) => {
            const units = Array.isArray(line.units) ? line.units : [];
            return `
                <details class="document-line-item outbound-detail-line">
                    <summary>
                        <span>
                            <strong>${escapeHtml(line.partName || "-")}</strong>
                            ${line.modelName ? `<small>${escapeHtml(line.modelName)}</small>` : ""}
                        </span>
                        <b>${numberText(line.quantity)}개</b>
                    </summary>
                    ${line.reason ? `<p class="line-reason">${escapeHtml(line.reason)}</p>` : ""}
                    <div class="unit-chip-list">
                        ${units.length ? units.map((unit) => `
                            <span class="unit-chip">
                                <code>${escapeHtml(unit.internalSerialNo)}</code>
                                <em class="outbound-badge ${gradeClass(unit.grade)}">${escapeHtml(gradeLabel(unit.grade))}</em>
                                <small>${escapeHtml(unitStatusLabel(unit.unitStatus))}</small>
                            </span>
                        `).join("") : '<p class="detail-empty-text">관리번호가 없습니다.</p>'}
                    </div>
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
        if (openCancelModalButton) {
            openCancelModalButton.disabled = detail.cancelable !== true;
        }
        renderDetailLines(detail.lines || []);
        updateSelectedRows();
    };

    const setDetailLoading = (message, documentId = null) => {
        selectedDocumentId = documentId;
        currentDetail = null;
        openDetailDrawer();
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
        updateSelectedRows();
    };

    const loadDocumentDetail = async (documentId, options = {}) => {
        const apiBase = getCompanyApiBase();
        if (options.trigger instanceof HTMLElement) {
            lastDetailTrigger = options.trigger;
        }
        if (!apiBase) {
            setDetailLoading("출고 전표 상세를 불러오지 못했습니다.", documentId);
            return null;
        }

        setDetailLoading("출고 전표 상세를 불러오는 중입니다.", documentId);
        try {
            const detail = await window.PcsApi.getData(`${apiBase}/stock/documents/${encodeURIComponent(documentId)}`, apiOptions());
            renderDocumentDetail(detail);
            if (options.openCancelAfter === true) {
                openCancelModal(detail);
            }
            return detail;
        } catch (error) {
            setDetailLoading(error.message || "출고 전표 상세를 불러오지 못했습니다.", documentId);
            return null;
        }
    };

    const closeDetailPanel = (options = {}) => {
        selectedDocumentId = null;
        currentDetail = null;
        closeDetailDrawer(options);
        updateSelectedRows();
    };

    const shouldKeepDetailPanelOnClick = (target) => {
        if (!detailDrawer?.classList.contains("is-open") || !(target instanceof Element)) {
            return true;
        }
        if (cancelModal?.open) {
            return true;
        }
        return Boolean(
            target.closest("[data-outbound-detail-drawer]")
            || target.closest("[data-document-id]")
            || target.closest("[data-document-cancel]")
        );
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
        if (confirmCancelButton) {
            confirmCancelButton.disabled = false;
            confirmCancelButton.textContent = "전표 취소";
        }
        cancelModal?.showModal();
    };

    const closeCancelModal = () => {
        cancelModal?.close();
        setCancelMessage("");
    };

    const cancelDocument = async () => {
        const apiBase = getCompanyApiBase();
        if (!cancelTarget?.documentId || !apiBase) {
            setCancelMessage("취소할 전표를 찾을 수 없습니다.");
            return;
        }

        confirmCancelButton.disabled = true;
        confirmCancelButton.textContent = "취소 중";
        try {
            await window.PcsApi.request(`${apiBase}/stock/documents/${encodeURIComponent(cancelTarget.documentId)}/cancel`, {
                method: "POST",
                ...apiOptions(),
            });
            closeCancelModal();
            window.PcsUi?.toast({
                type: "success",
                message: `출고 전표 ${cancelTarget.documentNo} 가 취소되었습니다.`,
            });
            if (currentDetail?.documentId && String(currentDetail.documentId) === String(cancelTarget.documentId)) {
                await loadDocumentDetail(cancelTarget.documentId);
            }
            await loadDocuments(currentPage, { preserveDetail: Boolean(currentDetail) });
        } catch (error) {
            setCancelMessage(error.message || "출고 전표를 취소하지 못했습니다.");
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
                    documentType: "OUTBOUND",
                },
            });
        }

        const params = new URLSearchParams({
            documentType: "OUTBOUND",
            page: String(Math.max(0, page)),
            size: String(PAGE_SIZE),
        });
        const keyword = filterForm.elements.keyword?.value?.trim();
        const partnerId = filterForm.elements.partnerId?.value;
        const documentStatus = filterForm.elements.documentStatus?.value;
        if (keyword) params.set("keyword", keyword);
        if (partnerId) params.set("partnerId", partnerId);
        if (documentStatus) params.set("documentStatus", documentStatus);
        return params;
    };

    const setLoading = (isLoading) => {
        if (!searchButton) {
            return;
        }
        searchButton.disabled = isLoading;
        searchButton.textContent = isLoading ? "조회 중" : "검색";
    };

    const loadDocuments = async (page = 0, options = {}) => {
        const apiBase = getCompanyApiBase();
        if (!apiBase) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const preserveDetail = options.preserveDetail === true;
        setLoading(true);
        if (!preserveDetail) {
            selectedDocumentId = null;
            currentDetail = null;
            closeDetailDrawer({ restoreFocus: false });
        }
        setEmptyMessage("출고 전표 목록을 불러오는 중입니다.", { loading: true });

        try {
            const data = await window.PcsApi.getData(`${apiBase}/stock/documents?${buildDocumentParams(page).toString()}`, apiOptions());
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
            setEmptyMessage(error.message || "출고 전표 목록을 불러오지 못했습니다.");
        } finally {
            setLoading(false);
        }
    };

    filterForm.addEventListener("submit", (event) => {
        event.preventDefault();
        loadDocuments(0);
    });

    openPartnerModalButton?.addEventListener("click", () => {
        renderPartnerList();
        partnerModal?.showModal();
        requestAnimationFrame(() => partnerSearchInput?.focus());
    });

    closePartnerModalButtons.forEach((button) => {
        button.addEventListener("click", () => partnerModal?.close());
    });

    partnerSearchInput?.addEventListener("input", renderPartnerList);
    partnerSearchInput?.addEventListener("keydown", (event) => {
        if (event.key === "Escape") {
            partnerModal?.close();
        }
    });

    partnerList?.addEventListener("click", (event) => {
        const option = event.target.closest("[data-partner-option]");
        if (!option) {
            return;
        }
        if (!option.dataset.partnerOption) {
            selectPartnerFilter(null);
            return;
        }
        const partner = partners.find((candidate) => String(candidate.partnerId) === option.dataset.partnerOption);
        if (partner) {
            selectPartnerFilter(partner);
        }
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

    outboundTable.addEventListener("click", (event) => {
        const cancelButton = event.target.closest("[data-document-cancel]");
        if (cancelButton) {
            event.stopPropagation();
            loadDocumentDetail(cancelButton.dataset.documentCancel, { openCancelAfter: true });
            return;
        }

        const row = event.target.closest("[data-document-id]");
        if (row) {
            loadDocumentDetail(row.dataset.documentId, { trigger: row });
        }
    });

    outboundTable.addEventListener("keydown", (event) => {
        if (event.key !== "Enter" && event.key !== " ") {
            return;
        }
        const row = event.target.closest("[data-document-id]");
        if (!row) {
            return;
        }
        event.preventDefault();
        loadDocumentDetail(row.dataset.documentId, { trigger: row });
    });

    closeDetailButtons.forEach((button) => {
        button.addEventListener("click", closeDetailPanel);
    });

    window.PcsDrawer?.bindDismiss({
        drawer: detailDrawer,
        close: closeDetailPanel,
        keepOpenSelector: "[data-document-id], [data-document-cancel], dialog",
        shouldIgnoreEscape: () => Boolean(cancelModal?.open)
    });

    document.addEventListener("click", (event) => {
        if (shouldKeepDetailPanelOnClick(event.target)) {
            return;
        }
        closeDetailPanel();
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
            consumeCreatedOutbound();
            await loadPartnerFilter();
            await loadDocuments(0);
        } catch (error) {
            setEmptyMessage(error?.message || "화면을 초기화하지 못했습니다.");
        }
    };

    initialize();
})();
