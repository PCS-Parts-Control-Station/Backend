(function () {
    const DOCUMENT_PAGE_SIZE = 10;
    const HISTORY_PAGE_SIZE = 10;
    const MAX_BULK_INSPECTION_UNITS = 300;
    const { companyCode, apiBase, apiOptions } = window.PcsWorkspace.createContext();
    const numberText = window.PcsFormat.number;
    const escapeHtml = window.PcsHtml.escape;
    const formatDate = window.PcsFormat.date;
    const formatLocalDate = window.PcsFormat.localDate;
    const showToast = window.PcsFeedback.toast;
    const {
        inspectionStatus: inspectionStatusText,
        inspectionResult: inspectionResultText,
        inspectionType: inspectionTypeText,
        inspectionItemGroup: inspectionItemGroupText,
        inspectionInputType: inspectionInputTypeText,
        grade: gradeText,
        salesStatus: salesStatusText
    } = window.PcsLabels;

    const filterForm = document.querySelector(".inspection-filter-form");
    const partnerFilter = filterForm?.elements.partnerId;
    const waitingTable = document.querySelector("[data-inspection-waiting-table]");
    const documentListFrame = document.querySelector("[data-inspection-document-list-frame]");
    const documentListLoading = document.querySelector("[data-inspection-document-list-loading]");
    const documentPagination = document.querySelector("[data-inspection-document-pagination]");
    const documentPageInfo = document.querySelector("[data-inspection-document-page-info]");
    const documentPrevButton = document.querySelector("[data-inspection-document-page-prev]");
    const documentNextButton = document.querySelector("[data-inspection-document-page-next]");
    const historyTable = document.querySelector("[data-inspection-history-table]");
    const historyListFrame = document.querySelector("[data-inspection-history-list-frame]");
    const historyListLoading = document.querySelector("[data-inspection-history-list-loading]");
    const historyScope = document.querySelector("[data-inspection-history-scope]");
    const historyPagination = document.querySelector("[data-inspection-history-pagination]");
    const historyPageInfo = document.querySelector("[data-inspection-history-page-info]");
    const historyPrevButton = document.querySelector("[data-inspection-history-page-prev]");
    const historyNextButton = document.querySelector("[data-inspection-history-page-next]");
    const inspectionForm = document.querySelector("[data-inspection-form]");
    const clearFormButton = document.querySelector("[data-inspection-form-clear]");
    const documentSummaryCard = document.querySelector("[data-inspection-document-summary-card]");
    const historyDetailPanel = document.querySelector("[data-inspection-history-detail]");
    const historyActionsPanel = document.querySelector("[data-inspection-history-actions]");
    const historyWorkflowPanel = document.querySelector("[data-inspection-history-workflow]");
    const historyWorkflowForm = document.querySelector("[data-inspection-workflow-form]");
    const targetStep = document.querySelector("[data-inspection-target-step]");
    const formStep = document.querySelector("[data-inspection-form-step]");
    const confirmModal = document.querySelector("[data-inspection-confirm-modal]");
    const sideStepItems = document.querySelectorAll("[data-inspection-side-step]");
    const routeFilter = document.querySelector("[data-inspection-route-filter]");
    const routeFilterText = document.querySelector("[data-inspection-route-filter-text]");
    const routeFilterClear = document.querySelector("[data-inspection-route-filter-clear]");

    const summaryFields = {
        documents: document.querySelector("[data-summary-total]"),
        totalUnits: document.querySelector("[data-summary-total-units]"),
        completed: document.querySelector("[data-summary-completed]"),
        waiting: document.querySelector("[data-summary-waiting]")
    };

    const documentFields = {
        subtitle: document.querySelector("[data-inspection-document-subtitle]"),
        documentNo: document.querySelector("[data-inspection-document-no]"),
        status: document.querySelector("[data-inspection-document-status]"),
        total: document.querySelector("[data-inspection-document-total]"),
        completed: document.querySelector("[data-inspection-document-completed]"),
        waiting: document.querySelector("[data-inspection-document-waiting]"),
        defective: document.querySelector("[data-inspection-document-defective]"),
        partner: document.querySelector("[data-inspection-document-partner]"),
        createdAt: document.querySelector("[data-inspection-document-created-at]"),
        summary: document.querySelector("[data-inspection-document-summary]"),
        lineCount: document.querySelector("[data-inspection-document-line-count]"),
        lines: document.querySelector("[data-inspection-document-lines]")
    };

    const formFields = {
        subtitle: document.querySelector("[data-inspection-form-subtitle]"),
        unit: document.querySelector("[data-inspection-form-unit]"),
        badges: document.querySelector("[data-inspection-form-badges]"),
        serials: document.querySelector("[data-inspection-form-serials]"),
        applyNote: document.querySelector("[data-inspection-form-apply-note]"),
        documentNo: document.querySelector("[data-inspection-form-document-no]"),
        part: document.querySelector("[data-inspection-form-part]"),
        model: document.querySelector("[data-inspection-form-model]"),
        templateItemSection: document.querySelector("[data-inspection-template-item-section]"),
        templateItemCount: document.querySelector("[data-inspection-template-item-count]"),
        templateItems: document.querySelector("[data-inspection-template-items]"),
        message: document.querySelector("[data-inspection-form-message]")
    };

    const confirmElements = {
        unit: document.querySelector("[data-confirm-unit]"),
        result: document.querySelector("[data-confirm-result]"),
        message: document.querySelector("[data-confirm-message]"),
        save: document.querySelector("[data-confirm-save]"),
        closeButtons: document.querySelectorAll("[data-close-confirm-modal]")
    };

    const historyFields = {
        unit: document.querySelector("[data-inspection-history-unit]"),
        type: document.querySelector("[data-inspection-history-type]"),
        grade: document.querySelector("[data-inspection-history-grade]"),
        result: document.querySelector("[data-inspection-history-result]"),
        documentNo: document.querySelector("[data-inspection-history-document-no]"),
        part: document.querySelector("[data-inspection-history-part]"),
        date: document.querySelector("[data-inspection-history-date]"),
        worker: document.querySelector("[data-inspection-history-worker]"),
        sales: document.querySelector("[data-inspection-history-sales]"),
        memo: document.querySelector("[data-inspection-history-memo]"),
        relation: document.querySelector("[data-inspection-history-relation]"),
        itemCount: document.querySelector("[data-inspection-history-item-count]"),
        items: document.querySelector("[data-inspection-history-items]")
    };

    const workflowFields = {
        title: document.querySelector("[data-inspection-workflow-title]"),
        base: document.querySelector("[data-inspection-workflow-base]"),
        memoLabel: document.querySelector("[data-inspection-workflow-memo-label]"),
        message: document.querySelector("[data-inspection-workflow-message]"),
        submit: document.querySelector("[data-inspection-workflow-submit]"),
        itemCount: document.querySelector("[data-inspection-workflow-item-count]"),
        items: document.querySelector("[data-inspection-workflow-template-items]")
    };

    let waitingDocuments = [];
    let currentDocumentPage = 0;
    let currentDocumentPageData = null;
    let currentHistoryPage = 0;
    let currentHistoryPageData = null;
    let currentDocumentDetail = null;
    let selectedDocumentId = null;
    let selectedMovementId = null;
    let selectedUnits = [];
    let templatesByCategory = new Map();
    let templateDetailsById = new Map();
    let selectedTemplateDetail = null;
    let selectedWorkflowTemplateDetail = null;
    let selectedHistoryId = null;
    let selectedHistoryDetail = null;
    let activeHistoryMode = null;
    let historyStepActive = false;
    let pendingSavePayload = null;
    let historyWorkflowSaving = false;
    let documentDetailRequestId = 0;
    let historyRequestId = 0;
    let historyDetailRequestId = 0;
    let targetStepHighlightTimer = null;
    let unitCheckAnchor = null;
    let initialPartIdFilter = null;
    let initialHasWaitingFilter = false;
    let initialPartNameFilter = "";
    let initialCategoryNameFilter = "";

    const readInspectionPrefill = () => {
        const params = new URLSearchParams(window.location.search);
        const documentId = params.get("documentId");
        const movementId = params.get("movementId");
        const unitId = params.get("unitId");
        if (!documentId) {
            return null;
        }
        return { documentId, movementId, unitId };
    };

    const statusBadgeClass = (status) => {
        if (status === "COMPLETED") return "badge-active";
        if (status === "IN_PROGRESS") return "badge-blue";
        return "badge-warning";
    };

    const resultBadgeClass = (result) => result === "FAIL" ? "badge-danger" : "badge-active";
    const gradeBadgeClass = (grade) => grade === "DEFECTIVE" ? "badge-danger" : (grade === "NONE" ? "badge-warning" : "badge-blue");
    const typeBadgeClass = (type) => {
        if (type === "CORRECTION") return "badge-warning";
        if (type === "REINSPECTION") return "badge-blue";
        return "badge-active";
    };

    const clearRows = (table) => {
        table?.querySelectorAll(".data-row:not(.table-head)").forEach((row) => row.remove());
    };

    const setTableMessage = (table, message, rowClass = "") => {
        if (!table) {
            return;
        }
        clearRows(table);
        const row = document.createElement("div");
        row.className = `data-row management-data-row empty-data-row inspection-empty-row ${rowClass}`.trim();
        row.setAttribute("role", "row");
        const cell = document.createElement("span");
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", "안내");
        cell.textContent = message;
        row.append(cell);
        table.append(row);
    };

    const setBadge = (element, text, className) => {
        if (!element) {
            return;
        }
        element.className = `badge ${className}`;
        element.textContent = text || "-";
    };

    const setFormMessage = (message, isError = false) => {
        if (!formFields.message) {
            return;
        }
        formFields.message.textContent = message || "";
        formFields.message.hidden = !message;
        formFields.message.classList.toggle("is-error", isError);
    };

    const setConfirmMessage = (message) => {
        if (!confirmElements.message) {
            return;
        }
        confirmElements.message.textContent = message || "";
        confirmElements.message.hidden = !message;
    };

    const setWorkflowMessage = (message, isError = false) => {
        if (!workflowFields.message) {
            return;
        }
        workflowFields.message.textContent = message || "";
        workflowFields.message.hidden = !message;
        workflowFields.message.classList.toggle("is-error", isError);
    };

    const renderRouteFilter = () => {
        if (!routeFilter || !routeFilterText) {
            return;
        }
        const hasRouteFilter = Boolean(initialPartIdFilter || initialHasWaitingFilter);
        routeFilter.hidden = !hasRouteFilter;
        if (!hasRouteFilter) {
            routeFilterText.textContent = "";
            return;
        }
        const targetText = [initialCategoryNameFilter, initialPartNameFilter].filter(Boolean).join(" · ");
        routeFilterText.textContent = targetText
                ? `운영현황에서 이동: ${targetText} 검수 대기`
                : "운영현황에서 이동한 검수 대기 항목";
    };

    const removeRouteFilterParams = () => {
        const url = new URL(window.location.href);
        ["partId", "hasWaiting", "partName", "categoryName"].forEach((key) => url.searchParams.delete(key));
        window.history.replaceState(window.history.state, "", `${url.pathname}${url.search}`);
    };

    const clearRouteFilter = () => {
        initialPartIdFilter = null;
        initialHasWaitingFilter = false;
        initialPartNameFilter = "";
        initialCategoryNameFilter = "";
        removeRouteFilterParams();
        renderRouteFilter();
        resetDocumentSelectionContext();
        loadWaitingDocuments(0);
    };

    function setCurrentSideStep(step) {
        sideStepItems.forEach((item) => {
            const isCurrent = item.dataset.inspectionSideStep === String(step);
            item.classList.toggle("is-current", isCurrent);
            if (isCurrent) {
                item.setAttribute("aria-current", "step");
            } else {
                item.removeAttribute("aria-current");
            }
        });
    }

    function updateCurrentSideStep() {
        if (historyStepActive || historyDetailPanel?.open || selectedHistoryId) {
            setCurrentSideStep(4);
            return;
        }
        if (selectedUnits.length || formStep?.classList.contains("is-active")) {
            setCurrentSideStep(3);
            return;
        }
        if (selectedDocumentId) {
            setCurrentSideStep(2);
            return;
        }
        setCurrentSideStep(1);
    }

    function highlightTargetStep() {
        if (!targetStep) {
            return;
        }
        window.clearTimeout(targetStepHighlightTimer);
        targetStep.classList.remove("is-attention");
        void targetStep.offsetWidth;
        targetStep.classList.add("is-attention");
        targetStepHighlightTimer = window.setTimeout(() => {
            targetStep.classList.remove("is-attention");
        }, 1200);
    }

    const setFormDisabled = (disabled) => {
        inspectionForm?.querySelectorAll("select, input, textarea, button[type='submit']").forEach((field) => {
            field.disabled = disabled;
        });
        if (clearFormButton) {
            clearFormButton.disabled = disabled;
        }
    };

    const resetInspectionFormValues = () => {
        inspectionForm?.reset();
        if (inspectionForm?.elements.result) inspectionForm.elements.result.value = "PASS";
        if (inspectionForm?.elements.grade) inspectionForm.elements.grade.value = "A";
        if (inspectionForm?.elements.salesStatus) inspectionForm.elements.salesStatus.value = "AVAILABLE";
    };

    const clearInspectionForm = (options = {}) => {
        selectedUnits = [];
        selectedTemplateDetail = null;
        pendingSavePayload = null;
        unitCheckAnchor = null;
        resetInspectionFormValues();
        setFormDisabled(true);
        formStep?.classList.remove("is-active");

        if (formFields.subtitle) formFields.subtitle.textContent = "관리번호 선택 후 입력합니다.";
        if (formFields.unit) formFields.unit.textContent = "검수 대상 없음";
        if (formFields.badges) {
            formFields.badges.innerHTML = `
                <em class="badge badge-warning">-</em>
                <em class="badge badge-blue">-</em>
                <em class="badge badge-warning">-</em>
            `;
        }
        if (formFields.serials) {
            formFields.serials.innerHTML = "";
            formFields.serials.hidden = true;
        }
        if (formFields.applyNote) {
            formFields.applyNote.textContent = "";
            formFields.applyNote.hidden = true;
        }
        if (formFields.documentNo) formFields.documentNo.textContent = "-";
        if (formFields.part) formFields.part.textContent = "-";
        if (formFields.model) formFields.model.textContent = "-";
        if (formFields.templateItemSection) formFields.templateItemSection.hidden = true;
        if (formFields.templateItemCount) formFields.templateItemCount.textContent = "항목 없음";
        if (formFields.templateItems) {
            formFields.templateItems.innerHTML = '<p class="detail-empty-text">검수 템플릿을 선택하면 항목이 표시됩니다.</p>';
        }
        if (inspectionForm?.elements.templateId) {
            inspectionForm.elements.templateId.innerHTML = '<option value="">관리번호를 선택해 주세요</option>';
        }
        setFormMessage("검수할 관리번호를 먼저 선택해 주세요.");
        syncSelectedUnitChecks();
        if (!options.skipSideStepUpdate) {
            updateCurrentSideStep();
        }
    };

    const buildPeriodParams = (params) => {
        const period = filterForm?.elements.period?.value;
        if (!period) {
            return;
        }
        const today = new Date();
        const toDateText = formatLocalDate(today);
        const from = new Date(today);
        if (period === "today") {
            params.set("dateFrom", toDateText);
            params.set("dateTo", toDateText);
            return;
        }
        if (period === "7d") {
            from.setDate(today.getDate() - 6);
        } else if (period === "30d") {
            from.setDate(today.getDate() - 29);
        } else {
            return;
        }
        params.set("dateFrom", formatLocalDate(from));
        params.set("dateTo", toDateText);
    };

    const updateSummary = (summary) => {
        if (summaryFields.documents) summaryFields.documents.textContent = numberText(summary?.documentCount);
        if (summaryFields.totalUnits) summaryFields.totalUnits.textContent = numberText(summary?.totalUnitCount);
        if (summaryFields.completed) summaryFields.completed.textContent = numberText(summary?.completedCount);
        if (summaryFields.waiting) summaryFields.waiting.textContent = numberText(summary?.waitingCount);
    };

    const renderWaitingDocuments = (documents) => {
        if (!waitingTable) {
            return;
        }
        clearRows(waitingTable);
        if (!documents.length) {
            setTableMessage(waitingTable, "조회된 검수 대상 전표가 없습니다.");
            return;
        }

        documents.forEach((item) => {
            const row = document.createElement("div");
            row.className = "data-row management-data-row inspection-document-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.dataset.inspectionDocumentId = String(item.documentId);
            row.innerHTML = `
                <strong role="cell" data-label="전표 번호">${escapeHtml(item.documentNo)}</strong>
                <span class="inspection-stack-cell" role="cell" data-label="거래처">
                    <strong>${escapeHtml(item.partnerName)}</strong>
                    <small>${escapeHtml(item.summary)}</small>
                </span>
                <span class="inspection-date-cell" role="cell" data-label="입고일">${escapeHtml(formatDate(item.createdAt))}</span>
                <span role="cell" data-label="검수 대상">${numberText(item.totalUnitCount)}</span>
                <span role="cell" data-label="대기">${numberText(item.waitingCount)}</span>
                <span role="cell" data-label="완료">${numberText(item.completedCount)}</span>
                <span class="inspection-progress" role="cell" data-label="진행률">
                    <strong>${numberText(item.progressRate)}%</strong>
                    <span class="inspection-progress-track" aria-hidden="true"><i style="--progress: ${Number(item.progressRate || 0)}%"></i></span>
                </span>
                <span class="row-actions" role="cell" data-label="선택">
                    <button type="button" data-inspection-document-action="${item.documentId}">선택</button>
                </span>
            `;
            row.addEventListener("click", (event) => {
                if (event.target.closest("button")) return;
                loadDocumentDetail(item.documentId);
            });
            row.addEventListener("keydown", (event) => {
                if (event.key !== "Enter" && event.key !== " ") return;
                event.preventDefault();
                loadDocumentDetail(item.documentId);
            });
            waitingTable.append(row);
        });
        updateSelectedDocumentRow();
    };

    const updateSelectedDocumentRow = () => {
        waitingTable?.querySelectorAll("[data-inspection-document-id]").forEach((row) => {
            const selected = String(row.dataset.inspectionDocumentId) === String(selectedDocumentId);
            row.classList.toggle("is-selected", selected);
            row.setAttribute("aria-selected", String(selected));
            const button = row.querySelector("[data-inspection-document-action]");
            if (button) {
                button.textContent = selected ? "선택됨" : "선택";
                button.classList.toggle("is-current", selected);
                button.setAttribute("aria-pressed", String(selected));
            }
        });
    };

    const updateSelectedHistoryRow = () => {
        historyTable?.querySelectorAll("[data-inspection-history-id]").forEach((row) => {
            const selected = String(row.dataset.inspectionHistoryId) === String(selectedHistoryId);
            row.classList.toggle("is-selected", selected);
            row.setAttribute("aria-selected", String(selected));
        });
    };

    const updateDocumentPagination = (pageData) => {
        currentDocumentPageData = pageData;
        if (!window.PcsPagination) {
            if (documentPagination) {
                documentPagination.hidden = true;
            }
            return;
        }
        window.PcsPagination.updateControls({
            pageData,
            container: documentPagination,
            info: documentPageInfo,
            prevButton: documentPrevButton,
            nextButton: documentNextButton,
            onPageClick: (page) => {
                const scrollPosition = window.PcsPagination?.captureScroll?.();
                loadWaitingDocuments(page, { preserveScroll: scrollPosition });
            }
        });
    };

    const setDocumentListLoading = (isLoading) => {
        window.PcsPagination?.setLoadingState({
            listContainer: documentListFrame,
            target: waitingTable,
            overlay: documentListLoading,
            pagination: documentPagination,
            prevButton: documentPrevButton,
            nextButton: documentNextButton,
            pageData: currentDocumentPageData,
            isLoading
        });
    };

    const setHistoryListLoading = (isLoading) => {
        window.PcsPagination?.setLoadingState({
            listContainer: historyListFrame,
            target: historyTable,
            overlay: historyListLoading,
            pagination: historyPagination,
            prevButton: historyPrevButton,
            nextButton: historyNextButton,
            pageData: currentHistoryPageData,
            isLoading
        });
    };

    const updateHistoryPagination = (pageData) => {
        currentHistoryPageData = pageData;
        if (!window.PcsPagination) {
            if (historyPagination) {
                historyPagination.hidden = true;
            }
            return;
        }
        window.PcsPagination.updateControls({
            pageData,
            container: historyPagination,
            info: historyPageInfo,
            prevButton: historyPrevButton,
            nextButton: historyNextButton,
            onPageClick: (page) => {
                historyStepActive = true;
                updateCurrentSideStep();
                const scrollPosition = window.PcsPagination?.captureScroll?.();
                loadHistories(page, { preserveScroll: scrollPosition });
            }
        });
    };

    const getHistoryScope = () => {
        if (selectedUnits.length === 1) {
            const context = selectedUnits[0];
            return {
                params: { unitId: context.unit.unitId },
                description: `${context.unit.internalSerialNo} 관리번호의 검수 이력입니다.`,
                emptyMessage: "이 관리번호의 검수 이력이 없습니다."
            };
        }
        if (selectedDocumentId) {
            return {
                params: { documentId: selectedDocumentId },
                description: `${currentDocumentDetail?.documentNo || "선택한 전표"} 기준 검수 이력입니다.`,
                emptyMessage: "이 전표의 검수 이력이 없습니다."
            };
        }
        return null;
    };

    const resetHistoryDetail = () => {
        selectedHistoryId = null;
        selectedHistoryDetail = null;
        selectedWorkflowTemplateDetail = null;
        activeHistoryMode = null;
        updateSelectedHistoryRow();
        if (historyDetailPanel?.open) {
            historyDetailPanel.close();
        }
        if (historyDetailPanel) {
            historyDetailPanel.hidden = true;
        }
        if (historyWorkflowPanel) historyWorkflowPanel.hidden = true;
        historyWorkflowForm?.reset();
        setWorkflowMessage("");
        if (historyFields.items) {
            historyFields.items.innerHTML = '<p class="detail-empty-text">검수 이력을 선택해 주세요.</p>';
        }
        if (workflowFields.items) {
            workflowFields.items.innerHTML = '<p class="detail-empty-text">이력 상세의 검수 항목을 불러오는 중입니다.</p>';
        }
        if (workflowFields.itemCount) {
            workflowFields.itemCount.textContent = "항목 없음";
        }
        updateCurrentSideStep();
    };

    const resetHistorySection = (message = "전표를 선택하면 해당 전표 또는 관리번호 기준 이력이 표시됩니다.") => {
        historyRequestId += 1;
        historyDetailRequestId += 1;
        currentHistoryPage = 0;
        currentHistoryPageData = null;
        resetHistoryDetail();
        setTableMessage(historyTable, message);
        if (historyPagination) {
            historyPagination.hidden = true;
        }
        if (historyScope) {
            historyScope.textContent = message;
        }
    };

    const resetDocumentSelectionContext = () => {
        documentDetailRequestId += 1;
        currentDocumentPage = 0;
        selectedDocumentId = null;
        currentDocumentDetail = null;
        selectedMovementId = null;
        historyStepActive = false;
        clearInspectionForm();
        resetHistorySection();
        targetStep?.classList.remove("is-active", "is-attention");
        if (documentSummaryCard) documentSummaryCard.hidden = true;
        if (documentFields.subtitle) {
            documentFields.subtitle.hidden = false;
            documentFields.subtitle.textContent = "전표 선택 후 표시됩니다.";
        }
        if (documentFields.lineCount) documentFields.lineCount.textContent = "전표 미선택";
        if (documentFields.lines) documentFields.lines.innerHTML = '<p class="detail-empty-text">전표를 선택해 주세요.</p>';
        updateCurrentSideStep();
    };

    const loadWaitingDocuments = async (page = currentDocumentPage, options = {}) => {
        if (!window.PcsApi || !companyCode) {
            setTableMessage(waitingTable, "검수 대상 전표를 불러올 수 없습니다.");
            return;
        }

        const keepCurrentList = options.preserveScroll && waitingDocuments.length > 0;
        if (!keepCurrentList) {
            setTableMessage(waitingTable, "검수 대상 전표를 불러오는 중입니다.");
        }
        setDocumentListLoading(true);
        const normalizedPage = Math.max(0, Number(page) || 0);
        const params = new URLSearchParams({ page: String(normalizedPage), size: String(DOCUMENT_PAGE_SIZE) });
        const keyword = filterForm?.elements.keyword?.value?.trim();
        const inspectionStatus = filterForm?.elements.inspectionStatus?.value;
        const partnerId = filterForm?.elements.partnerId?.value;
        if (keyword) params.set("keyword", keyword);
        if (initialPartIdFilter) params.set("partId", initialPartIdFilter);
        if (initialHasWaitingFilter) params.set("hasWaiting", "true");
        if (inspectionStatus) params.set("inspectionStatus", inspectionStatus);
        if (partnerId) params.set("partnerId", partnerId);
        buildPeriodParams(params);

        try {
            const data = await window.PcsApi.getData(`${apiBase}/inspections/waiting-documents?${params.toString()}`, apiOptions());
            const pageData = window.PcsPagination
                    ? window.PcsPagination.normalizePageData(data, DOCUMENT_PAGE_SIZE)
                    : {
                        content: Array.isArray(data?.content) ? data.content : [],
                        page: normalizedPage,
                        size: DOCUMENT_PAGE_SIZE,
                        totalElements: data?.totalElements || 0,
                        totalPages: data?.totalPages || 0,
                        hasPrevious: data?.hasPrevious === true,
                        hasNext: data?.hasNext === true,
                        summary: data?.summary || null
                    };
            currentDocumentPage = pageData.page;
            waitingDocuments = pageData.content;
            updateSummary(pageData.summary);
            renderWaitingDocuments(waitingDocuments);
            updateDocumentPagination(pageData);
        } catch (error) {
            if (keepCurrentList) {
                showToast(error.message || "검수 대상 전표를 불러오지 못했습니다.", "error");
            } else {
                setTableMessage(waitingTable, error.message || "검수 대상 전표를 불러오지 못했습니다.");
                if (documentPagination) {
                    documentPagination.hidden = true;
                }
            }
        } finally {
            setDocumentListLoading(false);
            if (options.preserveScroll && window.PcsPagination) {
                window.PcsPagination.restoreScrollPosition(options.preserveScroll);
            }
        }
    };

    const loadPartners = async () => {
        if (!partnerFilter || !window.PcsApi || !companyCode) {
            return;
        }
        partnerFilter.disabled = true;
        partnerFilter.innerHTML = '<option value="">전체</option>';
        try {
            const params = new URLSearchParams({
                active: "true",
                partnerRole: "SUPPLIER",
                page: "0",
                size: "100"
            });
            const data = await window.PcsApi.getData(`${apiBase}/partners?${params.toString()}`, apiOptions());
            const partners = Array.isArray(data?.content) ? data.content : [];
            partnerFilter.innerHTML = '<option value="">전체</option>';
            partners.forEach((partner) => {
                partnerFilter.append(new Option(partner.partnerName || "-", String(partner.partnerId)));
            });
            partnerFilter.disabled = false;
        } catch (error) {
            partnerFilter.innerHTML = '<option value="">거래처 조회 실패</option>';
        }
    };

    const renderDocumentLines = (lines) => {
        if (!documentFields.lines) {
            return;
        }
        unitCheckAnchor = null;
        if (!lines?.length) {
            selectedMovementId = null;
            documentFields.lines.innerHTML = '<p class="detail-empty-text">검수 대상 부품이 없습니다.</p>';
            return;
        }

        if (!selectedMovementId || !lines.some((line) => String(line.movementId) === String(selectedMovementId))) {
            selectedMovementId = lines[0].movementId;
        }
        const selectedLine = lines.find((line) => String(line.movementId) === String(selectedMovementId)) || lines[0];
        const formatLineMeta = (line) => [line.modelName, line.categoryName].filter(Boolean).join(" · ");
        const selectedLineMeta = formatLineMeta(selectedLine);
        const waitingUnits = (selectedLine.units || []).filter((unit) => unit.inspectionStatus !== "COMPLETED");
        const unitsHtml = (selectedLine.units || []).map((unit) => {
            const completed = unit.inspectionStatus === "COMPLETED";
            const gradeBadge = unit.grade && unit.grade !== "NONE"
                    ? `<em class="badge ${gradeBadgeClass(unit.grade)}">${escapeHtml(gradeText(unit.grade, unit.grade))}</em>`
                    : "";
            return `
                <li class="${completed ? "is-completed" : "is-waiting"}"${completed ? "" : ` data-inspection-unit-row="${escapeHtml(String(unit.unitId))}"`}>
                    <input type="checkbox" aria-label="${escapeHtml(unit.internalSerialNo)} 선택" value="${unit.unitId}" data-inspection-unit-check${completed ? " disabled" : ""}>
                    <span class="inspection-unit-main">
                        <code>${escapeHtml(unit.internalSerialNo)}</code>
                        <span class="inspection-unit-badges">
                            <em class="badge ${statusBadgeClass(unit.inspectionStatus)}">${escapeHtml(inspectionStatusText(unit.inspectionStatus, unit.inspectionStatus))}</em>
                            ${gradeBadge}
                        </span>
                    </span>
                    <button class="inspection-unit-action-button" type="button"
                        ${completed && unit.latestInspectionId ? `data-inspection-history-action="${unit.latestInspectionId}" data-inspection-history-unit-id="${unit.unitId}"` : `data-inspection-unit-action="${unit.unitId}"`}
                        ${completed && !unit.latestInspectionId ? " disabled" : ""}>
                        ${completed ? "이력 보기" : "검수 등록"}
                    </button>
                </li>
            `;
        }).join("");

        documentFields.lines.innerHTML = `
            <div class="inspection-line-picker" aria-label="부품 묶음 선택">
                ${lines.map((line) => {
                    const selected = String(line.movementId) === String(selectedLine.movementId);
                    return `
                        <button class="inspection-line-picker-button${selected ? " is-selected" : ""}" type="button" data-inspection-line-picker-action="${line.movementId}" aria-pressed="${selected}">
                            <span>
                                <strong>${escapeHtml(line.partName)}</strong>
                                <small>${escapeHtml(formatLineMeta(line))}</small>
                            </span>
                            <em>${numberText(line.quantity)}개</em>
                        </button>
                    `;
                }).join("")}
            </div>
            <div class="inspection-line-detail">
                <article class="inspection-target-item" data-inspection-line="${selectedLine.movementId}">
                    <header>
                        <span class="inspection-target-heading">
                            <span class="inspection-target-title">
                                <strong>${escapeHtml(selectedLine.partName)}</strong>
                                <small>${escapeHtml(selectedLineMeta)}</small>
                            </span>
                        </span>
                        <span class="inspection-target-summary">대기 ${numberText(selectedLine.waitingCount)}개 · 완료 ${numberText(selectedLine.completedCount)}개</span>
                    </header>
                    <div class="inspection-bulk-actions">
                        <span data-line-selected-count>선택 없음</span>
                        <div>
                            <button class="inspection-line-primary-action" type="button" data-inspection-line-selected-action disabled>선택 검수</button>
                            <button class="inspection-line-quiet-action" type="button" data-inspection-line-toggle-selection${waitingUnits.length ? "" : " disabled"}>전체 선택</button>
                        </div>
                    </div>
                    <ul class="inspection-unit-list">${unitsHtml || "<li><span>관리번호가 없습니다.</span></li>"}</ul>
                </article>
            </div>
        `;
    };

    const loadDocumentDetail = async (documentId) => {
        if (!window.PcsApi || !documentId) {
            return;
        }
        const requestId = ++documentDetailRequestId;
        const isDifferentDocument = String(selectedDocumentId || "") !== String(documentId);
        historyStepActive = false;
        selectedDocumentId = documentId;
        selectedMovementId = isDifferentDocument ? null : selectedMovementId;
        updateSelectedDocumentRow();
        updateCurrentSideStep();
        highlightTargetStep();
        clearInspectionForm({ skipSideStepUpdate: true });
        if (isDifferentDocument) {
            currentDocumentDetail = null;
            resetHistorySection();
        } else {
            resetHistoryDetail();
        }
        if (documentFields.lines) {
            documentFields.lines.innerHTML = '<p class="detail-empty-text">전표 정보를 불러오는 중입니다.</p>';
        }

        try {
            const detail = await window.PcsApi.getData(`${apiBase}/inspections/waiting-documents/${documentId}/units`, apiOptions());
            if (requestId !== documentDetailRequestId) {
                return;
            }
            currentDocumentDetail = detail;
            selectedDocumentId = detail.documentId;
            updateSelectedDocumentRow();

            if (documentSummaryCard) documentSummaryCard.hidden = false;
            if (documentFields.subtitle) documentFields.subtitle.hidden = true;
            if (documentFields.documentNo) documentFields.documentNo.textContent = detail.documentNo || "-";
            setBadge(
                    documentFields.status,
                    inspectionStatusText(detail.inspectionStatus, detail.inspectionStatus),
                    statusBadgeClass(detail.inspectionStatus)
            );
            if (documentFields.total) documentFields.total.textContent = `${numberText(detail.totalUnitCount)}개`;
            if (documentFields.completed) documentFields.completed.textContent = `${numberText(detail.completedCount)}개`;
            if (documentFields.waiting) documentFields.waiting.textContent = `${numberText(detail.waitingCount)}개`;
            if (documentFields.defective) documentFields.defective.textContent = `${numberText(detail.defectiveCount)}개`;
            if (documentFields.partner) documentFields.partner.textContent = detail.partnerName || "-";
            if (documentFields.createdAt) documentFields.createdAt.textContent = formatDate(detail.createdAt);
            if (documentFields.summary) documentFields.summary.textContent = detail.summary || "-";
            if (documentFields.lineCount) documentFields.lineCount.textContent = `${numberText(detail.lines?.length)}개 묶음`;
            renderDocumentLines(detail.lines || []);
            targetStep?.classList.add("is-active");
            updateCurrentSideStep();
            await loadHistories(0);
        } catch (error) {
            if (requestId !== documentDetailRequestId) {
                return;
            }
            if (documentFields.lines) {
                documentFields.lines.innerHTML = `<p class="detail-empty-text">${escapeHtml(error.message || "전표 정보를 불러오지 못했습니다.")}</p>`;
            }
            resetHistorySection("전표 정보를 불러오지 못해 검수 이력을 표시할 수 없습니다.");
        }
    };

    const applyInspectionPrefill = async (prefill) => {
        if (!prefill?.documentId) {
            return;
        }
        await loadDocumentDetail(prefill.documentId);
        if (!currentDocumentDetail) {
            return;
        }

        if (prefill.movementId && (currentDocumentDetail.lines || []).some((line) => String(line.movementId) === String(prefill.movementId))) {
            selectedMovementId = prefill.movementId;
        }

        if (prefill.unitId) {
            const context = findLineByUnitId(prefill.unitId);
            if (context) {
                selectedMovementId = context.line.movementId;
            }
        }

        renderDocumentLines(currentDocumentDetail.lines || []);

        if (!prefill.unitId) {
            requestAnimationFrame(() => targetStep?.scrollIntoView({ block: "start", behavior: "smooth" }));
            return;
        }

        const context = findLineByUnitId(prefill.unitId);
        if (!context) {
            setFormMessage("선택된 입고 전표에서 해당 관리번호를 찾지 못했습니다.", true);
            showToast("선택된 입고 전표에서 해당 관리번호를 찾지 못했습니다.", "warning");
            return;
        }
        if (context.unit.inspectionStatus === "COMPLETED") {
            setFormMessage("이미 검수 완료된 관리번호입니다.", true);
            showToast("이미 검수 완료된 관리번호입니다.", "warning");
            return;
        }

        await renderInspectionForm(context);
    };

    const findLineByUnitId = (unitId) => {
        for (const line of currentDocumentDetail?.lines || []) {
            const unit = (line.units || []).find((candidate) => String(candidate.unitId) === String(unitId));
            if (unit) {
                return { line, unit };
            }
        }
        return null;
    };

    const loadTemplatesForCategory = async (categoryId) => {
        if (!categoryId) {
            return [];
        }
        const key = String(categoryId);
        if (templatesByCategory.has(key)) {
            return templatesByCategory.get(key);
        }
        const params = new URLSearchParams({
            categoryId: key,
            active: "true",
            page: "0",
            size: "100"
        });
        const data = await window.PcsApi.getData(`${apiBase}/inspection-templates?${params.toString()}`, apiOptions());
        const templates = Array.isArray(data?.content) ? data.content : [];
        templatesByCategory.set(key, templates);
        return templates;
    };

    const getTemplateDetail = async (templateId) => {
        if (!templateId) {
            return null;
        }
        const key = String(templateId);
        if (templateDetailsById.has(key)) {
            return templateDetailsById.get(key);
        }
        const detail = await window.PcsApi.getData(`${apiBase}/inspection-templates/${encodeURIComponent(templateId)}`, apiOptions());
        templateDetailsById.set(key, detail);
        return detail;
    };

    const loadTemplateDetail = async (templateId) => {
        if (!templateId) {
            selectedTemplateDetail = null;
            return null;
        }
        const detail = await getTemplateDetail(templateId);
        selectedTemplateDetail = detail;
        return detail;
    };

    const renderTemplateOptions = async (categoryId) => {
        const select = inspectionForm?.elements.templateId;
        if (!select) {
            return;
        }
        select.innerHTML = '<option value="">템플릿을 불러오는 중입니다</option>';
        try {
            const templates = await loadTemplatesForCategory(categoryId);
            if (!templates.length) {
                select.innerHTML = '<option value="">사용 가능한 템플릿 없음</option>';
                selectedTemplateDetail = null;
                renderTemplateItems(null);
                setFormMessage("이 부품 카테고리에 사용 중인 검수 템플릿이 없습니다.", true);
                inspectionForm.querySelector("button[type='submit']").disabled = true;
                return;
            }
            select.innerHTML = templates.map((template, index) => `
                <option value="${template.templateId}"${index === 0 ? " selected" : ""}>
                    ${escapeHtml(template.templateName)} v${numberText(template.version)}
                </option>
            `).join("");
            const detail = await loadTemplateDetail(select.value);
            renderTemplateItems(detail);
            inspectionForm.querySelector("button[type='submit']").disabled = false;
        } catch (error) {
            select.innerHTML = '<option value="">템플릿 조회 실패</option>';
            selectedTemplateDetail = null;
            renderTemplateItems(null);
            setFormMessage(error.message || "검수 템플릿을 불러오지 못했습니다.", true);
            inspectionForm.querySelector("button[type='submit']").disabled = true;
        }
    };

    const TEMPLATE_RESULTS = ["PASS", "WARN", "FAIL", "NA"];

    const renderTemplateResultOptions = (selected = "PASS", includeWarn = true) => TEMPLATE_RESULTS
            .filter((value) => includeWarn || value !== "WARN")
            .map((value) => `
                <option value="${value}"${value === selected ? " selected" : ""}>${inspectionResultText(value, value)}</option>
            `).join("");

    const renderTemplateItemControl = (item, options = {}) => {
        const workflow = options.workflow === true;
        const previous = options.previous || null;
        const baseName = `${workflow ? "workflow_item" : "item"}_${item.itemId}`;
        const valueAttribute = workflow ? "data-inspection-workflow-template-value" : "data-inspection-template-value";
        const resultAttribute = workflow ? "data-inspection-workflow-template-result" : "data-inspection-template-result";
        const previousResult = previous?.result || "PASS";
        const resultControl = (includeWarn = true) => `
            <select name="${baseName}_result" ${resultAttribute}>
                ${renderTemplateResultOptions(previousResult, includeWarn)}
            </select>
        `;

        if (item.inputType === "CHECK") {
            return resultControl(workflow);
        }

        let valueControl = "";
        if (item.inputType === "NUMBER") {
            valueControl = `<input type="number" name="${baseName}_valueNumber" ${valueAttribute} value="${escapeHtml(previous?.valueNumber ?? "")}" placeholder="값">`;
        } else if (item.inputType === "TEXT") {
            valueControl = `<textarea name="${baseName}_valueText" ${valueAttribute} rows="2" placeholder="확인 내용을 입력해 주세요">${escapeHtml(previous?.valueText || "")}</textarea>`;
        } else if (item.inputType === "SELECT") {
            const selectedOptionId = previous?.selectedOptionId ? String(previous.selectedOptionId) : "";
            const optionList = (item.options || [])
                    .filter((option) => option.active !== false || (workflow && String(option.optionId) === selectedOptionId))
                    .map((option) => `
                        <option value="${option.optionId}"${String(option.optionId) === selectedOptionId ? " selected" : ""}>${escapeHtml(option.optionLabel)}</option>
                    `).join("");
            valueControl = `
                <select name="${baseName}_selectedOptionId" ${valueAttribute}>
                    <option value="">선택</option>
                    ${optionList}
                </select>
            `;
        }

        if (!workflow && item.inputType !== "NUMBER") {
            return valueControl;
        }
        return `<div class="inspection-template-control-grid">${valueControl}${resultControl()}</div>`;
    };

    const renderTemplateItems = (template) => {
        if (!formFields.templateItems) {
            return;
        }
        const items = (template?.items || []).filter((item) => item.active !== false);
        if (!items.length) {
            if (formFields.templateItemSection) formFields.templateItemSection.hidden = true;
            formFields.templateItems.innerHTML = "";
            if (formFields.templateItemCount) formFields.templateItemCount.textContent = "항목 없음";
            return;
        }
        if (formFields.templateItemSection) formFields.templateItemSection.hidden = false;

        const groups = ["BASIC", "DETAIL"].map((group) => ({
            group,
            items: items.filter((item) => item.itemGroup === group)
        })).filter((entry) => entry.items.length);

        formFields.templateItems.innerHTML = groups.map((entry) => `
            <section class="inspection-template-group" data-inspection-template-group="${entry.group}">
                <header>
                    <strong>${inspectionItemGroupText(entry.group, entry.group)}</strong>
                    <span>${numberText(entry.items.length)}개 항목</span>
                </header>
                <div class="inspection-template-items">
                    ${entry.items.map((item) => `
                        <label class="inspection-check-item inspection-template-item" data-template-item-id="${item.itemId}" data-template-input-type="${item.inputType}" data-template-required="${item.required}">
                            <span>
                                <strong>${escapeHtml(item.itemName)}${item.required ? '<em class="inspection-required-mark">*필수</em>' : ""}</strong>
                                <small>${inspectionInputTypeText(item.inputType, item.inputType)}</small>
                            </span>
                            ${renderTemplateItemControl(item)}
                        </label>
                    `).join("")}
                </div>
            </section>
        `).join("");
        if (formFields.templateItemCount) formFields.templateItemCount.textContent = `${numberText(items.length)}개 항목`;
    };

    const renderInspectionForm = async (unitContexts) => {
        const contexts = Array.isArray(unitContexts) ? unitContexts : [unitContexts];
        const validContexts = contexts.filter(Boolean);
        if (!validContexts.length || !currentDocumentDetail) {
            return;
        }
        const first = validContexts[0];
        const sameLine = validContexts.every((context) => String(context.line.movementId) === String(first.line.movementId));
        const sameCategory = validContexts.every((context) => String(context.line.categoryId) === String(first.line.categoryId));
        if (!sameCategory) {
            showToast("서로 다른 카테고리는 한 번에 검수할 수 없습니다.", "warning");
            return;
        }

        selectedUnits = validContexts;
        historyStepActive = false;
        syncSelectedUnitChecks();
        resetInspectionFormValues();
        setFormDisabled(false);
        const targetName = sameLine
                ? [first.line.partName, first.line.modelName].filter(Boolean).join(" ")
                : "여러 부품";
        const targetMeta = validContexts.length === 1
                ? `${first.unit.internalSerialNo} · ${currentDocumentDetail.documentNo || "-"}`
                : `선택 ${numberText(validContexts.length)}개 · ${currentDocumentDetail.documentNo || "-"}`;
        if (formFields.subtitle) {
            formFields.subtitle.textContent = targetMeta;
        }
        if (formFields.unit) {
            formFields.unit.textContent = targetName || "검수 대상";
        }
        if (formFields.badges) {
            const selectedCountBadge = `<em class="badge badge-blue inspection-selection-count">선택 ${numberText(validContexts.length)}개</em>`;
            const statusText = inspectionStatusText(first.unit.inspectionStatus, "검수 전");
            const statusClass = statusBadgeClass(first.unit.inspectionStatus || "WAITING");
            if (validContexts.length === 1) {
                formFields.badges.innerHTML = `
                    ${selectedCountBadge}
                    <em class="badge ${statusClass}">${escapeHtml(statusText)}</em>
                `;
            } else {
                formFields.badges.innerHTML = `
                    ${selectedCountBadge}
                    <em class="badge ${statusClass}">${escapeHtml(statusText)}</em>
                    <em class="badge badge-active">일괄 검수</em>
                `;
            }
        }
        if (formFields.serials) {
            formFields.serials.innerHTML = "";
            formFields.serials.hidden = true;
        }
        if (formFields.applyNote) {
            formFields.applyNote.textContent = "";
            formFields.applyNote.hidden = true;
        }
        if (formFields.documentNo) formFields.documentNo.textContent = currentDocumentDetail.documentNo || "-";
        if (formFields.part) formFields.part.textContent = sameLine ? first.line.partName : "여러 부품";
        if (formFields.model) formFields.model.textContent = sameLine ? first.line.modelName : "여러 모델";
        formStep?.classList.add("is-active");
        updateCurrentSideStep();
        setFormMessage("");
        await renderTemplateOptions(first.line.categoryId);
        await loadHistories(0);
        requestAnimationFrame(() => formStep?.scrollIntoView({ block: "start", behavior: "smooth" }));
    };

    const updateLineSelectionState = (lineElement) => {
        if (!lineElement) {
            return;
        }
        const selectedCount = lineElement.querySelectorAll("[data-inspection-unit-check]:checked").length;
        const selectableCount = lineElement.querySelectorAll("[data-inspection-unit-check]:not(:disabled)").length;
        const countText = lineElement.querySelector("[data-line-selected-count]");
        const selectedButton = lineElement.querySelector("[data-inspection-line-selected-action]");
        const toggleButton = lineElement.querySelector("[data-inspection-line-toggle-selection]");
        if (countText) countText.textContent = selectedCount ? `${numberText(selectedCount)}개 선택` : "선택 없음";
        if (selectedButton) selectedButton.disabled = selectedCount === 0;
        if (toggleButton) {
            const allSelected = selectableCount > 0 && selectedCount === selectableCount;
            toggleButton.textContent = allSelected ? "선택 취소" : "전체 선택";
            toggleButton.setAttribute("aria-pressed", String(allSelected));
            toggleButton.disabled = selectableCount === 0;
        }
    };

    const applyUnitCheckRangeSelection = (unitCheck, shiftKey) => {
        const lineElement = unitCheck?.closest("[data-inspection-line]");
        if (!lineElement || unitCheck.disabled) {
            return;
        }

        const lineId = String(lineElement.dataset.inspectionLine || "");
        const checks = Array.from(
                lineElement.querySelectorAll("[data-inspection-unit-check]:not(:disabled)")
        );
        const currentIndex = checks.indexOf(unitCheck);
        const anchorIndex = unitCheckAnchor?.lineId === lineId
                ? checks.findIndex((input) => String(input.value) === unitCheckAnchor.unitId)
                : -1;

        if (shiftKey && anchorIndex >= 0 && currentIndex >= 0) {
            const rangeStart = Math.min(anchorIndex, currentIndex);
            const rangeEnd = Math.max(anchorIndex, currentIndex);
            checks.slice(rangeStart, rangeEnd + 1).forEach((input) => {
                input.checked = unitCheck.checked;
            });
        } else {
            unitCheckAnchor = {
                lineId,
                unitId: String(unitCheck.value)
            };
        }
        updateLineSelectionState(lineElement);
    };

    function syncSelectedUnitChecks() {
        const selectedUnitIds = new Set(selectedUnits.map((context) => String(context.unit.unitId)));
        document.querySelectorAll("[data-inspection-unit-check]").forEach((input) => {
            input.checked = selectedUnitIds.has(String(input.value));
        });
        document.querySelectorAll("[data-inspection-line]").forEach(updateLineSelectionState);
    }

    const syncInspectionOutcomeRule = (form, changedField = null) => {
        const result = form?.elements.result;
        const grade = form?.elements.grade;
        const salesStatus = form?.elements.salesStatus;
        if (!result || !grade || !salesStatus) {
            return false;
        }

        if (changedField === "result") {
            if (result.value === "FAIL") {
                const adjusted = grade.value !== "DEFECTIVE" || salesStatus.value !== "UNAVAILABLE";
                grade.value = "DEFECTIVE";
                salesStatus.value = "UNAVAILABLE";
                return adjusted;
            }

            if (result.value === "PASS" && grade.value === "DEFECTIVE") {
                const adjusted = true;
                grade.value = "A";
                if (salesStatus.value === "UNAVAILABLE") {
                    salesStatus.value = "AVAILABLE";
                }
                return adjusted;
            }

            return false;
        }

        if (changedField === "grade") {
            if (grade.value === "DEFECTIVE") {
                const adjusted = result.value !== "FAIL" || salesStatus.value !== "UNAVAILABLE";
                result.value = "FAIL";
                salesStatus.value = "UNAVAILABLE";
                return adjusted;
            }

            if (result.value === "FAIL") {
                const adjusted = true;
                result.value = "PASS";
                if (salesStatus.value === "UNAVAILABLE") {
                    salesStatus.value = "AVAILABLE";
                }
                return adjusted;
            }

            return false;
        }

        if (result.value === "FAIL" || grade.value === "DEFECTIVE") {
            const adjusted = result.value !== "FAIL" || grade.value !== "DEFECTIVE" || salesStatus.value !== "UNAVAILABLE";
            result.value = "FAIL";
            grade.value = "DEFECTIVE";
            salesStatus.value = "UNAVAILABLE";
            return adjusted;
        }

        return false;
    };

    const syncInspectionFormRule = (changedField = null) => syncInspectionOutcomeRule(inspectionForm, changedField);

    const syncHistoryWorkflowRule = (changedField = null) => syncInspectionOutcomeRule(historyWorkflowForm, changedField);

    const applyFailedItemOutcome = (form, itemResults) => {
        if (!itemResults.some((item) => item.result === "FAIL")) {
            return false;
        }
        const result = form?.elements.result;
        const grade = form?.elements.grade;
        const salesStatus = form?.elements.salesStatus;
        if (!result || !grade || !salesStatus) {
            return false;
        }
        const adjusted = result.value !== "FAIL" || grade.value !== "DEFECTIVE" || salesStatus.value !== "UNAVAILABLE";
        result.value = "FAIL";
        grade.value = "DEFECTIVE";
        salesStatus.value = "UNAVAILABLE";
        return adjusted;
    };

    const isInvalidDefectiveSalesStatus = (form) => form?.elements.grade?.value === "DEFECTIVE"
            && form?.elements.salesStatus?.value !== "UNAVAILABLE";

    const collectTemplateItemResults = (items, container, selectors) => {
        const missingItems = [];
        const itemResults = [];
        items.forEach((item) => {
            const element = container?.querySelector(`[${selectors.itemId}="${item.itemId}"]`);
            const resultField = element?.querySelector(`[${selectors.result}]`);
            const valueField = element?.querySelector(`[${selectors.value}]`);
            const value = valueField?.value?.trim() || "";
            const result = resultField?.value || "PASS";

            if (item.required && ["SELECT", "TEXT", "NUMBER"].includes(item.inputType) && !value) {
                missingItems.push(item.itemName);
            }

            if (!item.required && item.inputType !== "CHECK" && !value && result !== "FAIL") {
                return;
            }

            itemResults.push({
                itemId: item.itemId,
                result,
                valueText: item.inputType === "TEXT" ? value || null : null,
                valueNumber: item.inputType === "NUMBER" && value ? Number(value) : null,
                selectedOptionId: item.inputType === "SELECT" && value ? Number(value) : null,
                memo: null
            });
        });
        return { itemResults, missingItems };
    };

    const collectInspectionItemResults = () => collectTemplateItemResults(
            (selectedTemplateDetail?.items || []).filter((item) => item.active !== false),
            formFields.templateItems,
            {
                itemId: "data-template-item-id",
                result: "data-inspection-template-result",
                value: "data-inspection-template-value"
            }
    );

    const saveInspection = async () => {
        if (!pendingSavePayload) {
            return;
        }
        const payload = pendingSavePayload;
        pendingSavePayload = null;
        if (confirmElements.save) confirmElements.save.disabled = true;

        try {
            const endpoint = payload.unitIds.length > 1
                    ? `${apiBase}/inspections/bulk`
                    : `${apiBase}/inspections`;
            const body = payload.unitIds.length > 1
                    ? {
                        unitIds: payload.unitIds,
                        templateId: payload.templateId,
                        result: payload.result,
                        grade: payload.grade,
                        salesStatus: payload.salesStatus,
                        memo: payload.memo,
                        itemResults: payload.itemResults
                    }
                    : {
                        unitId: payload.unitIds[0],
                        templateId: payload.templateId,
                        result: payload.result,
                        grade: payload.grade,
                        salesStatus: payload.salesStatus,
                        memo: payload.memo,
                        itemResults: payload.itemResults
                    };
            await window.PcsApi.request(endpoint, apiOptions({
                method: "POST",
                body
            }));
            confirmModal?.close();
            showToast("검수 결과를 저장했습니다.", "success");
            await Promise.all([
                loadWaitingDocuments(),
                selectedDocumentId ? loadDocumentDetail(selectedDocumentId) : loadHistories()
            ]);
            clearInspectionForm();
        } catch (error) {
            setFormMessage(error.message || "검수 결과를 저장하지 못했습니다.", true);
            showToast(error.message || "검수 결과 저장 실패", "error");
        } finally {
            if (confirmElements.save) confirmElements.save.disabled = false;
        }
    };

    const renderHistories = (histories, emptyMessage = "조회된 검수 이력이 없습니다.") => {
        if (!historyTable) {
            return;
        }
        clearRows(historyTable);
        if (!histories.length) {
            setTableMessage(historyTable, emptyMessage);
            return;
        }

        histories.forEach((history) => {
            const row = document.createElement("div");
            row.className = "data-row management-data-row inspection-history-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.dataset.inspectionHistoryId = String(history.inspectionId);
            row.innerHTML = `
                <strong class="inspection-history-date" role="cell" data-label="검수일">${escapeHtml(formatDate(history.inspectedAt))}</strong>
                <span class="inspection-stack-cell inspection-history-part" role="cell" data-label="부품">
                    <strong>${escapeHtml(history.internalSerialNo)}</strong>
                    <small>${escapeHtml(history.partName)} ${escapeHtml(history.modelName)}</small>
                </span>
                <span class="inspection-history-document" role="cell" data-label="전표 번호">${escapeHtml(history.documentNo || "-")}</span>
                <span class="inspection-history-type" role="cell" data-label="유형"><em class="badge ${typeBadgeClass(history.inspectionType)}">${escapeHtml(inspectionTypeText(history.inspectionType, history.inspectionType))}</em></span>
                <span class="inspection-history-grade" role="cell" data-label="등급"><em class="badge ${gradeBadgeClass(history.grade)}">${escapeHtml(gradeText(history.grade, history.grade))}</em></span>
                <span class="inspection-history-operator" role="cell" data-label="처리자">${escapeHtml(history.inspectedByName || "-")}</span>
                <span class="row-actions inspection-history-row-actions" role="cell" data-label="상세">
                    <button type="button" data-inspection-history-action="${history.inspectionId}">상세</button>
                </span>
            `;
            row.addEventListener("click", (event) => {
                if (event.target.closest("button")) return;
                historyStepActive = true;
                updateCurrentSideStep();
                loadHistoryDetail(history.inspectionId);
            });
            row.addEventListener("keydown", (event) => {
                if (event.key !== "Enter" && event.key !== " ") return;
                event.preventDefault();
                historyStepActive = true;
                updateCurrentSideStep();
                loadHistoryDetail(history.inspectionId);
            });
            historyTable.append(row);
        });
        updateSelectedHistoryRow();
    };

    const loadHistories = async (page = currentHistoryPage, options = {}) => {
        if (!window.PcsApi || !companyCode) {
            setTableMessage(historyTable, "검수 이력을 불러올 수 없습니다.");
            return;
        }
        const scope = getHistoryScope();
        if (!scope) {
            resetHistorySection();
            return;
        }
        const requestId = ++historyRequestId;
        currentHistoryPage = Math.max(0, page);
        resetHistoryDetail();
        const keepExistingRows = Boolean(options.preserveScroll && historyTable?.querySelector("[data-inspection-history-id]"));
        if (historyScope) {
            historyScope.textContent = scope.description;
        }
        if (!keepExistingRows) {
            clearRows(historyTable);
            if (historyPagination) {
                historyPagination.hidden = true;
            }
        }
        setHistoryListLoading(true);
        try {
            const params = window.PcsPagination
                    ? window.PcsPagination.buildParams({
                        page: currentHistoryPage,
                        size: HISTORY_PAGE_SIZE,
                        extraParams: scope.params
                    })
                    : new URLSearchParams({
                        page: String(currentHistoryPage),
                        size: String(HISTORY_PAGE_SIZE),
                        ...Object.fromEntries(Object.entries(scope.params).map(([key, value]) => [key, String(value)]))
                    });
            const data = await window.PcsApi.getData(`${apiBase}/inspections?${params.toString()}`, apiOptions());
            if (requestId !== historyRequestId) {
                return;
            }
            const pageData = window.PcsPagination
                    ? window.PcsPagination.normalizePageData(data, HISTORY_PAGE_SIZE)
                    : {
                        content: Array.isArray(data?.content) ? data.content : [],
                        page: currentHistoryPage,
                        totalPages: 0,
                        totalElements: 0,
                        hasPrevious: false,
                        hasNext: false
                    };
            currentHistoryPage = pageData.page;
            renderHistories(pageData.content, scope.emptyMessage);
            updateHistoryPagination(pageData);
            if (options.preserveScroll && window.PcsPagination) {
                window.PcsPagination.restoreScrollPosition(options.preserveScroll);
            }
        } catch (error) {
            if (requestId !== historyRequestId) {
                return;
            }
            const message = error.message || "검수 이력을 불러오지 못했습니다.";
            if (keepExistingRows) {
                showToast(message, "error");
            } else {
                setTableMessage(historyTable, message);
                if (historyPagination) {
                    historyPagination.hidden = true;
                }
            }
        } finally {
            if (requestId === historyRequestId) {
                setHistoryListLoading(false);
            }
        }
    };

    const renderHistoryItems = (items) => {
        if (!historyFields.items) {
            return;
        }
        if (!items?.length) {
            historyFields.items.innerHTML = '<p class="detail-empty-text">검수 항목 결과가 없습니다.</p>';
            return;
        }
        historyFields.items.innerHTML = items.map((item) => {
            const resultText = inspectionResultText(item.result, "-");
            const valueText = item.selectedOptionLabelSnapshot || item.valueText || item.valueNumber || item.memo || "-";
            return `
                <article class="inspection-result-item">
                    <header>
                        <strong>${escapeHtml(item.itemNameSnapshot)}</strong>
                        <em class="badge ${item.result === "FAIL" ? "badge-danger" : "badge-active"}">${escapeHtml(resultText)}</em>
                    </header>
                    <p>${escapeHtml(valueText)}</p>
                </article>
            `;
        }).join("");
    };

    const renderWorkflowTemplateItems = (template, priorItems = []) => {
        if (!workflowFields.items) {
            return;
        }
        const priorByItemId = new Map((priorItems || []).map((item) => [String(item.itemId), item]));
        const items = (template?.items || []).filter((item) => item.active !== false || priorByItemId.has(String(item.itemId)));
        selectedWorkflowTemplateDetail = template ? { ...template, items } : null;

        if (!items.length) {
            workflowFields.items.innerHTML = '<p class="detail-empty-text">저장할 검수 항목이 없습니다.</p>';
            if (workflowFields.itemCount) workflowFields.itemCount.textContent = "항목 없음";
            return;
        }

        const groups = ["BASIC", "DETAIL"].map((group) => ({
            group,
            items: items.filter((item) => item.itemGroup === group)
        })).filter((entry) => entry.items.length);

        workflowFields.items.innerHTML = groups.map((entry) => `
            <section class="inspection-template-group" data-inspection-workflow-template-group="${entry.group}">
                <header>
                    <strong>${inspectionItemGroupText(entry.group, entry.group)}</strong>
                    <span>${numberText(entry.items.length)}개 항목</span>
                </header>
                <div class="inspection-template-items">
                    ${entry.items.map((item) => {
                        const previous = priorByItemId.get(String(item.itemId));
                        return `
                            <label class="inspection-check-item inspection-template-item" data-workflow-template-item-id="${item.itemId}" data-workflow-template-input-type="${item.inputType}" data-workflow-template-required="${item.required}">
                                <span>
                                    <strong>${escapeHtml(item.itemName)}${item.required ? '<em class="inspection-required-mark">*필수</em>' : ""}</strong>
                                    <small>${inspectionInputTypeText(item.inputType, item.inputType)}</small>
                                </span>
                                ${renderTemplateItemControl(item, { workflow: true, previous })}
                            </label>
                        `;
                    }).join("")}
                </div>
            </section>
        `).join("");
        if (workflowFields.itemCount) workflowFields.itemCount.textContent = `${numberText(items.length)}개 항목`;
    };

    const collectWorkflowItemResults = () => collectTemplateItemResults(
            selectedWorkflowTemplateDetail?.items || [],
            workflowFields.items,
            {
                itemId: "data-workflow-template-item-id",
                result: "data-inspection-workflow-template-result",
                value: "data-inspection-workflow-template-value"
            }
    );

    const closeHistoryWorkflow = () => {
        activeHistoryMode = null;
        selectedWorkflowTemplateDetail = null;
        if (historyWorkflowPanel) historyWorkflowPanel.hidden = true;
        if (historyActionsPanel) historyActionsPanel.hidden = false;
        historyWorkflowForm?.reset();
        setWorkflowMessage("");
        if (workflowFields.items) {
            workflowFields.items.innerHTML = '<p class="detail-empty-text">이력 상세의 검수 항목을 불러오는 중입니다.</p>';
        }
        if (workflowFields.itemCount) {
            workflowFields.itemCount.textContent = "항목 없음";
        }
    };

    const loadHistoryDetail = async (inspectionId) => {
        if (!inspectionId) {
            return;
        }
        const requestId = ++historyDetailRequestId;
        closeHistoryWorkflow();
        try {
            const detail = await window.PcsApi.getData(`${apiBase}/inspections/${inspectionId}`, apiOptions());
            if (requestId !== historyDetailRequestId) {
                return;
            }
            selectedHistoryId = detail.inspectionId;
            selectedHistoryDetail = detail;
            updateSelectedHistoryRow();
            if (historyDetailPanel) {
                historyDetailPanel.hidden = false;
                if (typeof historyDetailPanel.showModal === "function" && !historyDetailPanel.open) {
                    historyDetailPanel.showModal();
                }
            }
            if (historyFields.unit) historyFields.unit.textContent = detail.internalSerialNo || "-";
            setBadge(historyFields.type, inspectionTypeText(detail.inspectionType, detail.inspectionType), typeBadgeClass(detail.inspectionType));
            setBadge(historyFields.grade, gradeText(detail.grade, detail.grade), gradeBadgeClass(detail.grade));
            setBadge(historyFields.result, inspectionResultText(detail.result, detail.result), resultBadgeClass(detail.result));
            if (historyFields.documentNo) historyFields.documentNo.textContent = detail.documentNo || "-";
            if (historyFields.part) historyFields.part.textContent = `${detail.partName || "-"} ${detail.modelName || ""}`.trim();
            if (historyFields.date) historyFields.date.textContent = formatDate(detail.inspectedAt);
            if (historyFields.worker) historyFields.worker.textContent = detail.inspectedByName || "-";
            if (historyFields.sales) historyFields.sales.textContent = salesStatusText(detail.salesStatus, "-");
            if (historyFields.memo) historyFields.memo.textContent = detail.memo || "-";
            if (historyFields.relation) {
                historyFields.relation.textContent = detail.originalInspectionId
                        ? `원본 검수 #${detail.originalInspectionId} 기준`
                        : "원본 검수";
            }
            if (historyFields.itemCount) historyFields.itemCount.textContent = `${numberText(detail.itemResults?.length)}개 항목`;
            renderHistoryItems(detail.itemResults || []);
            updateCurrentSideStep();
        } catch (error) {
            if (requestId !== historyDetailRequestId) {
                return;
            }
            showToast(error.message || "검수 이력 상세를 불러오지 못했습니다.", "error");
        }
    };

    const openUnitHistoryDetail = async (unitId, inspectionId) => {
        const context = findLineByUnitId(unitId);
        if (context) {
            clearInspectionForm();
            selectedUnits = [context];
            updateCurrentSideStep();
            await loadHistories(0);
        }
        await loadHistoryDetail(inspectionId);
    };

    const startHistoryWorkflow = async (mode) => {
        if (!selectedHistoryDetail || !historyWorkflowForm || !historyWorkflowPanel) {
            return;
        }
        activeHistoryMode = mode;
        historyWorkflowPanel.hidden = false;
        if (historyActionsPanel) historyActionsPanel.hidden = true;
        historyWorkflowForm.reset();
        historyWorkflowForm.elements.result.value = selectedHistoryDetail.result || "PASS";
        historyWorkflowForm.elements.grade.value = selectedHistoryDetail.grade || "A";
        historyWorkflowForm.elements.salesStatus.value = selectedHistoryDetail.salesStatus || "AVAILABLE";

        const isCorrection = mode === "correction";
        if (workflowFields.title) workflowFields.title.textContent = isCorrection ? "정정 등록" : "재검수 등록";
        if (workflowFields.base) workflowFields.base.textContent = `기준 #${selectedHistoryDetail.inspectionId}`;
        if (workflowFields.memoLabel) workflowFields.memoLabel.textContent = isCorrection ? "정정 사유" : "재검수 메모";
        if (workflowFields.submit) workflowFields.submit.textContent = isCorrection ? "정정 저장" : "재검수 저장";
        historyWorkflowForm.elements.memo.placeholder = isCorrection ? "정정 사유를 입력해 주세요" : "재검수 내용을 입력해 주세요";
        setWorkflowMessage("");

        if (workflowFields.items) {
            workflowFields.items.innerHTML = '<p class="detail-empty-text">검수 항목을 불러오는 중입니다.</p>';
        }
        if (workflowFields.itemCount) {
            workflowFields.itemCount.textContent = "확인 중";
        }
        selectedWorkflowTemplateDetail = null;
        if (selectedHistoryDetail.templateId) {
            try {
                const template = await getTemplateDetail(selectedHistoryDetail.templateId);
                renderWorkflowTemplateItems(template, selectedHistoryDetail.itemResults || []);
            } catch (error) {
                renderWorkflowTemplateItems(null, []);
                setWorkflowMessage(error.message || "검수 항목을 불러오지 못했습니다.", true);
            }
        } else {
            renderWorkflowTemplateItems(null, []);
        }
        requestAnimationFrame(() => historyWorkflowPanel.scrollIntoView({ block: "nearest", behavior: "smooth" }));
    };

    const saveHistoryWorkflow = async () => {
        if (!activeHistoryMode || !selectedHistoryDetail || !historyWorkflowForm) {
            return;
        }
        if (historyWorkflowSaving) {
            return;
        }
        const form = historyWorkflowForm.elements;
        const memo = form.memo.value.trim();
        if (!memo) {
            setWorkflowMessage(activeHistoryMode === "correction" ? "정정 사유를 입력해 주세요." : "재검수 메모를 입력해 주세요.", true);
            return;
        }
        if (selectedHistoryDetail.templateId && !selectedWorkflowTemplateDetail) {
            setWorkflowMessage("검수 항목을 불러온 뒤 저장해 주세요.", true);
            return;
        }
        const { itemResults, missingItems } = collectWorkflowItemResults();
        if (missingItems.length) {
            setWorkflowMessage(`필수 검수 항목을 입력해 주세요: ${missingItems.join(", ")}`, true);
            return;
        }
        const adjustedByItemFailure = applyFailedItemOutcome(historyWorkflowForm, itemResults);
        syncHistoryWorkflowRule();
        if (isInvalidDefectiveSalesStatus(historyWorkflowForm)) {
            setWorkflowMessage("불량 등급은 판매 불가로 저장해야 합니다.", true);
            return;
        }
        if (adjustedByItemFailure) {
            setWorkflowMessage("불합격 항목이 있어 검수 결과와 등급을 자동 조정했습니다.");
        }
        const path = activeHistoryMode === "correction" ? "corrections" : "reinspections";
        try {
            historyWorkflowSaving = true;
            if (workflowFields.submit) {
                workflowFields.submit.disabled = true;
            }
            const result = await window.PcsApi.request(`${apiBase}/inspections/${selectedHistoryDetail.inspectionId}/${path}`, apiOptions({
                method: "POST",
                body: {
                    templateId: selectedHistoryDetail.templateId,
                    result: form.result.value,
                    grade: form.grade.value,
                    salesStatus: form.salesStatus.value,
                    memo,
                    itemResults
                }
            }));
            const newInspectionId = result?.data?.inspectionIds?.[0];
            const fallbackInspectionId = selectedHistoryDetail.inspectionId;
            showToast(activeHistoryMode === "correction" ? "검수 정정을 저장했습니다." : "재검수를 저장했습니다.", "success");
            closeHistoryWorkflow();
            await loadHistories(0);
            await loadHistoryDetail(newInspectionId || fallbackInspectionId);
        } catch (error) {
            setWorkflowMessage(error.message || "저장하지 못했습니다.", true);
        } finally {
            historyWorkflowSaving = false;
            if (workflowFields.submit) {
                workflowFields.submit.disabled = false;
            }
        }
    };

    document.addEventListener("click", (event) => {
        const documentButton = event.target.closest("[data-inspection-document-action]");
        if (documentButton) {
            loadDocumentDetail(documentButton.dataset.inspectionDocumentAction);
            return;
        }

        const linePickerButton = event.target.closest("[data-inspection-line-picker-action]");
        if (linePickerButton) {
            selectedMovementId = linePickerButton.dataset.inspectionLinePickerAction;
            clearInspectionForm();
            renderDocumentLines(currentDocumentDetail?.lines || []);
            return;
        }

        const unitCheck = event.target.closest("[data-inspection-unit-check]");
        if (unitCheck) {
            applyUnitCheckRangeSelection(unitCheck, event.shiftKey);
            return;
        }

        const unitButton = event.target.closest("[data-inspection-unit-action]");
        if (unitButton) {
            renderInspectionForm(findLineByUnitId(unitButton.dataset.inspectionUnitAction));
            return;
        }

        const unitRow = event.target.closest("[data-inspection-unit-row]");
        if (unitRow && !event.target.closest("button, input, select, textarea, a")) {
            const unitCheck = unitRow.querySelector("[data-inspection-unit-check]");
            if (unitCheck && !unitCheck.disabled) {
                unitCheck.checked = !unitCheck.checked;
                applyUnitCheckRangeSelection(unitCheck, event.shiftKey);
            }
            return;
        }

        const selectedLineButton = event.target.closest("[data-inspection-line-selected-action]");
        if (selectedLineButton) {
            const lineElement = selectedLineButton.closest("[data-inspection-line]");
            const contexts = Array.from(lineElement?.querySelectorAll("[data-inspection-unit-check]:checked") || [])
                    .map((input) => findLineByUnitId(input.value));
            renderInspectionForm(contexts);
            return;
        }

        const toggleLineButton = event.target.closest("[data-inspection-line-toggle-selection]");
        if (toggleLineButton) {
            const lineElement = toggleLineButton.closest("[data-inspection-line]");
            const checks = Array.from(lineElement?.querySelectorAll("[data-inspection-unit-check]:not(:disabled)") || []);
            const shouldSelect = checks.some((input) => !input.checked);
            checks.forEach((input) => {
                input.checked = shouldSelect;
            });
            unitCheckAnchor = null;
            updateLineSelectionState(lineElement);
            return;
        }

        const historyButton = event.target.closest("[data-inspection-history-action]");
        if (historyButton) {
            historyStepActive = true;
            updateCurrentSideStep();
            const unitId = historyButton.dataset.inspectionHistoryUnitId;
            if (unitId) {
                void openUnitHistoryDetail(unitId, historyButton.dataset.inspectionHistoryAction);
            } else {
                void loadHistoryDetail(historyButton.dataset.inspectionHistoryAction);
            }
            return;
        }

        if (event.target.closest("[data-inspection-history-close]") || event.target === historyDetailPanel) {
            resetHistoryDetail();
            return;
        }

        if (event.target.closest("[data-inspection-correction-start]")) {
            void startHistoryWorkflow("correction");
            return;
        }

        if (event.target.closest("[data-inspection-reinspection-start]")) {
            void startHistoryWorkflow("reinspection");
            return;
        }

        if (event.target.closest("[data-inspection-workflow-cancel]")) {
            closeHistoryWorkflow();
        }
    });

    document.addEventListener("change", async (event) => {
        const unitCheck = event.target.closest("[data-inspection-unit-check]");
        if (unitCheck) {
            updateLineSelectionState(unitCheck.closest("[data-inspection-line]"));
            return;
        }
        if (inspectionForm?.contains(event.target) && event.target.matches("[name='templateId']")) {
            const detail = await loadTemplateDetail(event.target.value);
            renderTemplateItems(detail);
            return;
        }
        if (inspectionForm?.contains(event.target) && event.target.matches("[name='result'], [name='grade']")) {
            if (syncInspectionFormRule(event.target.name)) {
                setFormMessage("검수 결과와 등급에 맞춰 판매상태가 자동 조정됩니다.");
            }
            return;
        }
        if (historyWorkflowForm?.contains(event.target) && event.target.matches("[name='result'], [name='grade']")) {
            syncHistoryWorkflowRule(event.target.name);
        }
    });

    filterForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        resetDocumentSelectionContext();
        loadWaitingDocuments(0);
    });

    filterForm?.addEventListener("reset", () => {
        initialPartIdFilter = null;
        initialHasWaitingFilter = false;
        initialPartNameFilter = "";
        initialCategoryNameFilter = "";
        renderRouteFilter();
        removeRouteFilterParams();
        window.setTimeout(() => {
            resetDocumentSelectionContext();
            loadWaitingDocuments(0);
        }, 0);
    });

    routeFilterClear?.addEventListener("click", clearRouteFilter);

    documentPrevButton?.addEventListener("click", () => {
        if (!currentDocumentPageData?.hasPrevious) {
            return;
        }
        const scrollPosition = window.PcsPagination?.captureScroll?.();
        loadWaitingDocuments(currentDocumentPage - 1, { preserveScroll: scrollPosition });
    });

    documentNextButton?.addEventListener("click", () => {
        if (!currentDocumentPageData?.hasNext) {
            return;
        }
        const scrollPosition = window.PcsPagination?.captureScroll?.();
        loadWaitingDocuments(currentDocumentPage + 1, { preserveScroll: scrollPosition });
    });

    historyPrevButton?.addEventListener("click", () => {
        if (!currentHistoryPageData?.hasPrevious) {
            return;
        }
        historyStepActive = true;
        updateCurrentSideStep();
        const scrollPosition = window.PcsPagination?.captureScroll?.();
        loadHistories(currentHistoryPage - 1, { preserveScroll: scrollPosition });
    });

    historyNextButton?.addEventListener("click", () => {
        if (!currentHistoryPageData?.hasNext) {
            return;
        }
        historyStepActive = true;
        updateCurrentSideStep();
        const scrollPosition = window.PcsPagination?.captureScroll?.();
        loadHistories(currentHistoryPage + 1, { preserveScroll: scrollPosition });
    });

    historyTable?.addEventListener("focusin", () => {
        if (!selectedDocumentId) {
            return;
        }
        historyStepActive = true;
        updateCurrentSideStep();
    });

    historyTable?.addEventListener("click", () => {
        if (!selectedDocumentId) {
            return;
        }
        historyStepActive = true;
        updateCurrentSideStep();
    });

    clearFormButton?.addEventListener("click", () => {
        historyStepActive = false;
        clearInspectionForm();
        loadHistories(0);
    });

    historyDetailPanel?.addEventListener("cancel", (event) => {
        event.preventDefault();
        resetHistoryDetail();
    });

    confirmElements.closeButtons.forEach((button) => {
        button.addEventListener("click", () => {
            pendingSavePayload = null;
            setConfirmMessage("");
            if (confirmElements.save) confirmElements.save.disabled = false;
            confirmModal?.close();
        });
    });

    confirmElements.save?.addEventListener("click", saveInspection);

    inspectionForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        if (!selectedUnits.length) {
            setFormMessage("검수할 관리번호를 먼저 선택해 주세요.", true);
            return;
        }
        if (selectedUnits.length > MAX_BULK_INSPECTION_UNITS) {
            pendingSavePayload = null;
            if (confirmElements.unit) {
                confirmElements.unit.textContent = `${numberText(selectedUnits.length)}개 관리번호`;
            }
            if (confirmElements.result) {
                confirmElements.result.textContent = "저장할 수 없음";
            }
            setConfirmMessage(`한 번에 최대 ${numberText(MAX_BULK_INSPECTION_UNITS)}개까지 검수할 수 있습니다.`);
            if (confirmElements.save) confirmElements.save.disabled = true;
            confirmModal?.showModal();
            return;
        }
        syncInspectionFormRule();
        const templateId = Number(inspectionForm.elements.templateId?.value);
        if (!templateId) {
            setFormMessage("검수 템플릿을 선택해 주세요.", true);
            return;
        }
        const { itemResults, missingItems } = collectInspectionItemResults();
        if (missingItems.length) {
            setFormMessage(`필수 검수 항목을 입력해 주세요: ${missingItems.join(", ")}`, true);
            return;
        }
        const adjustedByItemFailure = applyFailedItemOutcome(inspectionForm, itemResults);
        syncInspectionFormRule();
        if (isInvalidDefectiveSalesStatus(inspectionForm)) {
            setFormMessage("불량 등급은 판매 불가로 저장해야 합니다.", true);
            return;
        }
        if (adjustedByItemFailure) {
            setFormMessage("불합격 항목이 있어 검수 결과와 등급을 자동 조정했습니다.");
        }

        pendingSavePayload = {
            unitIds: selectedUnits.map((context) => context.unit.unitId),
            templateId,
            result: inspectionForm.elements.result.value,
            grade: inspectionForm.elements.grade.value,
            salesStatus: inspectionForm.elements.salesStatus.value,
            memo: inspectionForm.elements.memo.value.trim() || null,
            itemResults
        };
        setConfirmMessage("");
        if (confirmElements.save) confirmElements.save.disabled = false;

        if (confirmElements.unit) {
            confirmElements.unit.textContent = selectedUnits.length === 1
                    ? selectedUnits[0].unit.internalSerialNo
                    : `${numberText(selectedUnits.length)}개 관리번호`;
        }
        if (confirmElements.result) {
            const resultText = inspectionForm.elements.result.selectedOptions[0]?.textContent || "-";
            const gradeText = inspectionForm.elements.grade.selectedOptions[0]?.textContent || "-";
            confirmElements.result.textContent = `${resultText} · ${gradeText} 등급 · ${numberText(itemResults.length)}개 항목`;
        }
        confirmModal?.showModal();
    });

    historyWorkflowForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        saveHistoryWorkflow();
    });

    const applyInitialSearchParams = () => {
        const params = new URLSearchParams(window.location.search);
        const keyword = params.get("documentNo") || params.get("keyword");
        const partId = params.get("partId");
        initialHasWaitingFilter = params.get("hasWaiting") === "true";
        initialPartNameFilter = params.get("partName") || "";
        initialCategoryNameFilter = params.get("categoryName") || "";
        if (keyword && filterForm?.elements.keyword) {
            filterForm.elements.keyword.value = keyword;
        }
        if (partId && /^\d+$/.test(partId)) {
            initialPartIdFilter = partId;
        }
        if (params.get("inspectionStatus") && filterForm?.elements.inspectionStatus) {
            filterForm.elements.inspectionStatus.value = params.get("inspectionStatus");
        }
        renderRouteFilter();
    };

    const init = async () => {
        window.PcsUi?.consumeFlashToast?.();
        const prefill = readInspectionPrefill();
        clearInspectionForm();
        applyInitialSearchParams();
        await Promise.all([
            loadPartners(),
            loadWaitingDocuments(),
            loadHistories()
        ]);
        await applyInspectionPrefill(prefill);
    };

    init();
})();
