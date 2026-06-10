(function () {
    const PAGE_SIZE = 20;

    const filterForm = document.querySelector(".inspection-filter-form");
    const partnerFilter = filterForm?.elements.partnerId;
    const waitingTable = document.querySelector("[data-inspection-waiting-table]");
    const documentPagination = document.querySelector("[data-inspection-document-pagination]");
    const documentPageInfo = document.querySelector("[data-inspection-document-page-info]");
    const documentPrevButton = document.querySelector("[data-inspection-document-page-prev]");
    const documentNextButton = document.querySelector("[data-inspection-document-page-next]");
    const historyTable = document.querySelector("[data-inspection-history-table]");
    const inspectionForm = document.querySelector("[data-inspection-form]");
    const clearFormButton = document.querySelector("[data-inspection-form-clear]");
    const documentSummaryCard = document.querySelector("[data-inspection-document-summary-card]");
    const historyDetailPanel = document.querySelector("[data-inspection-history-detail]");
    const historyWorkflowPanel = document.querySelector("[data-inspection-history-workflow]");
    const historyWorkflowForm = document.querySelector("[data-inspection-workflow-form]");
    const targetStep = document.querySelector("[data-inspection-target-step]");
    const formStep = document.querySelector("[data-inspection-form-step]");
    const confirmModal = document.querySelector("[data-inspection-confirm-modal]");

    const summaryFields = {
        documents: document.querySelector("[data-summary-total]"),
        totalUnits: document.querySelector("[data-summary-waiting]"),
        completed: document.querySelector("[data-summary-recheck]"),
        waiting: document.querySelector("[data-summary-defective]")
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
        templateItemCount: document.querySelector("[data-inspection-template-item-count]"),
        templateItems: document.querySelector("[data-inspection-template-items]"),
        message: document.querySelector("[data-inspection-form-message]")
    };

    const confirmElements = {
        unit: document.querySelector("[data-confirm-unit]"),
        result: document.querySelector("[data-confirm-result]"),
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
        submit: document.querySelector("[data-inspection-workflow-submit]")
    };

    let waitingDocuments = [];
    let currentDocumentPage = 0;
    let currentDocumentPageData = null;
    let currentDocumentDetail = null;
    let selectedDocumentId = null;
    let selectedUnits = [];
    let templatesByCategory = new Map();
    let templateDetailsById = new Map();
    let selectedTemplateDetail = null;
    let selectedHistoryId = null;
    let selectedHistoryDetail = null;
    let activeHistoryMode = null;
    let pendingSavePayload = null;

    const LABELS = {
        inspectionStatus: {
            WAITING: "대기",
            IN_PROGRESS: "진행 중",
            COMPLETED: "완료"
        },
        result: {
            PASS: "통과",
            FAIL: "불합격",
            WARN: "주의",
            NA: "해당 없음"
        },
        grade: {
            NONE: "미정",
            A: "A",
            B: "B",
            C: "C",
            DEFECTIVE: "불량"
        },
        salesStatus: {
            AVAILABLE: "판매 가능",
            HOLD: "판매 보류",
            UNAVAILABLE: "판매 불가"
        },
        inspectionType: {
            INITIAL: "최초",
            CORRECTION: "정정",
            REINSPECTION: "재검수"
        },
        itemGroup: {
            BASIC: "주요 검수 항목",
            DETAIL: "추가 검수 항목"
        },
        inputType: {
            CHECK: "통과/불합격",
            NUMBER: "숫자",
            TEXT: "텍스트",
            SELECT: "선택"
        }
    };

    const getCompanyCode = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : "";
    };

    const apiBase = () => `/api/workspaces/${encodeURIComponent(getCompanyCode())}`;

    const apiOptions = (options = {}) => ({
        authRedirect: true,
        loginCompanyCode: getCompanyCode(),
        ...options
    });

    const showToast = (message, type = "info") => {
        window.PcsUi?.toast({ message, type });
    };

    const numberText = (value) => Number(value || 0).toLocaleString("ko-KR");

    const escapeHtml = (value) => String(value ?? "").replace(/[&<>"']/g, (letter) => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#039;"
    }[letter]));

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

    const statusBadgeClass = (status) => {
        if (status === "COMPLETED") return "badge-active";
        if (status === "IN_PROGRESS") return "badge-blue";
        return "badge-warning";
    };

    const resultBadgeClass = (result) => result === "FAIL" ? "badge-danger" : "badge-active";
    const gradeBadgeClass = (grade) => grade === "DEFECTIVE" ? "badge-danger" : (grade === "NONE" ? "badge-warning" : "badge-blue");
    const salesBadgeClass = (salesStatus) => {
        if (salesStatus === "AVAILABLE") return "badge-active";
        if (salesStatus === "UNAVAILABLE") return "badge-danger";
        return "badge-warning";
    };
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

    const setWorkflowMessage = (message, isError = false) => {
        if (!workflowFields.message) {
            return;
        }
        workflowFields.message.textContent = message || "";
        workflowFields.message.hidden = !message;
        workflowFields.message.classList.toggle("is-error", isError);
    };

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

    const clearInspectionForm = () => {
        selectedUnits = [];
        selectedTemplateDetail = null;
        pendingSavePayload = null;
        resetInspectionFormValues();
        setFormDisabled(true);
        formStep?.classList.remove("is-active");

        if (formFields.subtitle) formFields.subtitle.textContent = "2번에서 관리번호를 선택하면 검수 결과를 입력할 수 있습니다.";
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
        if (formFields.applyNote) formFields.applyNote.textContent = "관리번호를 선택하면 저장 적용 범위가 표시됩니다.";
        if (formFields.documentNo) formFields.documentNo.textContent = "-";
        if (formFields.part) formFields.part.textContent = "-";
        if (formFields.model) formFields.model.textContent = "-";
        if (formFields.templateItemCount) formFields.templateItemCount.textContent = "항목 없음";
        if (formFields.templateItems) {
            formFields.templateItems.innerHTML = '<p class="detail-empty-text">검수 템플릿을 선택하면 항목이 표시됩니다.</p>';
        }
        if (inspectionForm?.elements.templateId) {
            inspectionForm.elements.templateId.innerHTML = '<option value="">관리번호를 선택해 주세요</option>';
        }
        setFormMessage("검수할 관리번호를 먼저 선택해 주세요.");
    };

    const buildPeriodParams = (params) => {
        const period = filterForm?.elements.period?.value;
        if (!period) {
            return;
        }
        const today = new Date();
        const toDateText = today.toISOString().slice(0, 10);
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
        params.set("dateFrom", from.toISOString().slice(0, 10));
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
                <strong role="cell" data-label="전표번호">${escapeHtml(item.documentNo)}</strong>
                <span class="inspection-stack-cell" role="cell" data-label="입고 내용">
                    <strong>${escapeHtml(item.partnerName)} / ${escapeHtml(item.summary)}</strong>
                    <small>입고일 ${escapeHtml(formatDate(item.createdAt))} · 검수 대기 ${numberText(item.waitingCount)}개</small>
                </span>
                <span role="cell" data-label="총수량">${numberText(item.totalUnitCount)}</span>
                <span role="cell" data-label="완료">${numberText(item.completedCount)}</span>
                <span class="inspection-progress" role="cell" data-label="진행률">
                    <strong>${numberText(item.progressRate)}%</strong>
                    <span class="inspection-progress-track" aria-hidden="true"><i style="--progress: ${Number(item.progressRate || 0)}%"></i></span>
                </span>
                <span class="row-actions" role="cell" data-label="선택">
                    <button type="button" data-inspection-document-action="${item.documentId}">전표 선택</button>
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
            nextButton: documentNextButton
        });
    };

    const loadWaitingDocuments = async (page = currentDocumentPage, options = {}) => {
        if (!window.PcsApi || !getCompanyCode()) {
            setTableMessage(waitingTable, "검수 대상 전표를 불러올 수 없습니다.");
            return;
        }

        setTableMessage(waitingTable, "검수 대상 전표를 불러오는 중입니다.");
        const normalizedPage = Math.max(0, Number(page) || 0);
        const params = new URLSearchParams({ page: String(normalizedPage), size: String(PAGE_SIZE) });
        const keyword = filterForm?.elements.keyword?.value?.trim();
        const inspectionStatus = filterForm?.elements.inspectionStatus?.value;
        const partnerId = filterForm?.elements.partnerId?.value;
        if (keyword) params.set("keyword", keyword);
        if (inspectionStatus) params.set("inspectionStatus", inspectionStatus);
        if (partnerId) params.set("partnerId", partnerId);
        buildPeriodParams(params);

        try {
            const data = await window.PcsApi.getData(`${apiBase()}/inspections/waiting-documents?${params.toString()}`, apiOptions());
            const pageData = window.PcsPagination
                    ? window.PcsPagination.normalizePageData(data, PAGE_SIZE)
                    : {
                        content: Array.isArray(data?.content) ? data.content : [],
                        page: normalizedPage,
                        size: PAGE_SIZE,
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
            setTableMessage(waitingTable, error.message || "검수 대상 전표를 불러오지 못했습니다.");
            if (documentPagination) {
                documentPagination.hidden = true;
            }
        } finally {
            if (options.preserveScroll && window.PcsPagination) {
                window.PcsPagination.restoreScrollPosition(options.preserveScroll);
            }
        }
    };

    const loadPartners = async () => {
        if (!partnerFilter || !window.PcsApi || !getCompanyCode()) {
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
            const data = await window.PcsApi.getData(`${apiBase()}/partners?${params.toString()}`, apiOptions());
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
        if (!lines?.length) {
            documentFields.lines.innerHTML = '<p class="detail-empty-text">검수 대상 부품이 없습니다.</p>';
            return;
        }

        documentFields.lines.innerHTML = lines.map((line) => {
            const waitingUnits = (line.units || []).filter((unit) => unit.inspectionStatus !== "COMPLETED");
            const unitsHtml = (line.units || []).map((unit) => {
                const completed = unit.inspectionStatus === "COMPLETED";
                return `
                    <li class="${completed ? "is-completed" : "is-waiting"}">
                        <input type="checkbox" aria-label="${escapeHtml(unit.internalSerialNo)} 선택" value="${unit.unitId}" data-inspection-unit-check${completed ? " disabled" : ""}>
                        <span class="inspection-unit-main">
                            <code>${escapeHtml(unit.internalSerialNo)}</code>
                            <span class="inspection-unit-badges">
                                <em class="badge ${statusBadgeClass(unit.inspectionStatus)}">${escapeHtml(LABELS.inspectionStatus[unit.inspectionStatus] || unit.inspectionStatus)}</em>
                                <em class="badge ${gradeBadgeClass(unit.grade)}">${escapeHtml(LABELS.grade[unit.grade] || unit.grade)}</em>
                            </span>
                        </span>
                        <button class="inspection-unit-action-button" type="button"
                            ${completed && unit.latestInspectionId ? `data-inspection-history-action="${unit.latestInspectionId}"` : `data-inspection-unit-action="${unit.unitId}"`}
                            ${completed && !unit.latestInspectionId ? " disabled" : ""}>
                            ${completed ? "이력 보기" : "검수 등록"}
                        </button>
                    </li>
                `;
            }).join("");

            return `
                <article class="inspection-target-item" data-inspection-line="${line.movementId}">
                    <header>
                        <span class="inspection-target-heading">
                            <span class="inspection-target-title">
                                <strong>${escapeHtml(line.partName)}</strong>
                                <small>${escapeHtml(line.modelName)}</small>
                                <em class="badge badge-blue">${numberText(line.quantity)}개</em>
                            </span>
                        </span>
                        <span class="inspection-target-summary">대기 ${numberText(line.waitingCount)}개 · 완료 ${numberText(line.completedCount)}개</span>
                    </header>
                    <div class="inspection-bulk-actions">
                        <span data-line-selected-count>선택 없음</span>
                        <div>
                            <button class="inspection-line-primary-action" type="button" data-inspection-line-selected-action disabled>선택 검수</button>
                            <button class="inspection-line-quiet-action" type="button" data-inspection-line-waiting-action="${line.movementId}"${waitingUnits.length ? "" : " disabled"}>대기만 선택</button>
                        </div>
                    </div>
                    <ul class="inspection-unit-list">${unitsHtml || "<li><span>관리번호가 없습니다.</span></li>"}</ul>
                </article>
            `;
        }).join("");
    };

    const loadDocumentDetail = async (documentId) => {
        if (!window.PcsApi || !documentId) {
            return;
        }
        clearInspectionForm();
        if (documentFields.lines) {
            documentFields.lines.innerHTML = '<p class="detail-empty-text">전표 정보를 불러오는 중입니다.</p>';
        }

        try {
            const detail = await window.PcsApi.getData(`${apiBase()}/inspections/waiting-documents/${documentId}/units`, apiOptions());
            currentDocumentDetail = detail;
            selectedDocumentId = detail.documentId;
            updateSelectedDocumentRow();

            if (documentSummaryCard) documentSummaryCard.hidden = false;
            if (documentFields.subtitle) documentFields.subtitle.hidden = true;
            if (documentFields.documentNo) documentFields.documentNo.textContent = detail.documentNo || "-";
            setBadge(
                    documentFields.status,
                    LABELS.inspectionStatus[detail.inspectionStatus] || detail.inspectionStatus,
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
        } catch (error) {
            if (documentFields.lines) {
                documentFields.lines.innerHTML = `<p class="detail-empty-text">${escapeHtml(error.message || "전표 정보를 불러오지 못했습니다.")}</p>`;
            }
        }
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

    const findLineByMovementId = (movementId) => {
        return (currentDocumentDetail?.lines || []).find((line) => String(line.movementId) === String(movementId)) || null;
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
        const data = await window.PcsApi.getData(`${apiBase()}/inspection-templates?${params.toString()}`, apiOptions());
        const templates = Array.isArray(data?.content) ? data.content : [];
        templatesByCategory.set(key, templates);
        return templates;
    };

    const loadTemplateDetail = async (templateId) => {
        if (!templateId) {
            selectedTemplateDetail = null;
            return null;
        }
        const key = String(templateId);
        if (templateDetailsById.has(key)) {
            selectedTemplateDetail = templateDetailsById.get(key);
            return selectedTemplateDetail;
        }
        const detail = await window.PcsApi.getData(`${apiBase()}/inspection-templates/${encodeURIComponent(templateId)}`, apiOptions());
        templateDetailsById.set(key, detail);
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

    const renderTemplateItemControl = (item) => {
        const baseName = `item_${item.itemId}`;
        if (item.inputType === "NUMBER") {
            return `
                <div class="inspection-template-control-grid">
                    <input type="number" name="${baseName}_valueNumber" data-inspection-template-value placeholder="값">
                    <select name="${baseName}_result" data-inspection-template-result>
                        <option value="PASS">통과</option>
                        <option value="WARN">주의</option>
                        <option value="FAIL">불합격</option>
                        <option value="NA">해당 없음</option>
                    </select>
                </div>
            `;
        }
        if (item.inputType === "TEXT") {
            return `<textarea name="${baseName}_valueText" data-inspection-template-value rows="2" placeholder="확인 내용을 입력해 주세요"></textarea>`;
        }
        if (item.inputType === "SELECT") {
            const options = (item.options || []).filter((option) => option.active !== false).map((option) => `
                <option value="${option.optionId}">${escapeHtml(option.optionLabel)}</option>
            `).join("");
            return `
                <select name="${baseName}_selectedOptionId" data-inspection-template-value>
                    <option value="">선택</option>
                    ${options}
                </select>
            `;
        }
        return `
            <select name="${baseName}_result" data-inspection-template-result>
                <option value="PASS">통과</option>
                <option value="FAIL">불합격</option>
                <option value="NA">해당 없음</option>
            </select>
        `;
    };

    const renderTemplateItems = (template) => {
        if (!formFields.templateItems) {
            return;
        }
        const items = (template?.items || []).filter((item) => item.active !== false);
        if (!items.length) {
            formFields.templateItems.innerHTML = '<p class="detail-empty-text">검수 템플릿을 선택하면 항목이 표시됩니다.</p>';
            if (formFields.templateItemCount) formFields.templateItemCount.textContent = "항목 없음";
            return;
        }

        const groups = ["BASIC", "DETAIL"].map((group) => ({
            group,
            items: items.filter((item) => item.itemGroup === group)
        })).filter((entry) => entry.items.length);

        formFields.templateItems.innerHTML = groups.map((entry) => `
            <section class="inspection-template-group" data-inspection-template-group="${entry.group}">
                <header>
                    <strong>${LABELS.itemGroup[entry.group] || entry.group}</strong>
                    <span>${numberText(entry.items.length)}개 항목</span>
                </header>
                <div class="inspection-template-items">
                    ${entry.items.map((item) => `
                        <label class="inspection-check-item inspection-template-item" data-template-item-id="${item.itemId}" data-template-input-type="${item.inputType}" data-template-required="${item.required}">
                            <span>
                                <strong>${escapeHtml(item.itemName)}${item.required ? '<em class="inspection-required-mark">*필수</em>' : ""}</strong>
                                <small>${LABELS.inputType[item.inputType] || item.inputType}</small>
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
        resetInspectionFormValues();
        setFormDisabled(false);
        if (formFields.subtitle) {
            formFields.subtitle.textContent = validContexts.length === 1
                    ? `${currentDocumentDetail.documentNo} · ${first.line.partName}`
                    : `${currentDocumentDetail.documentNo} · ${numberText(validContexts.length)}개 일괄 검수`;
        }
        if (formFields.unit) {
            formFields.unit.textContent = validContexts.length === 1
                    ? first.unit.internalSerialNo
                    : `선택 ${numberText(validContexts.length)}개 관리번호`;
        }
        if (formFields.badges) {
            if (validContexts.length === 1) {
                formFields.badges.innerHTML = `
                    <em class="badge ${statusBadgeClass(first.unit.inspectionStatus)}">${escapeHtml(LABELS.inspectionStatus[first.unit.inspectionStatus] || first.unit.inspectionStatus)}</em>
                    <em class="badge ${gradeBadgeClass(first.unit.grade)}">${escapeHtml(LABELS.grade[first.unit.grade] || first.unit.grade)}</em>
                    <em class="badge ${salesBadgeClass(first.unit.salesStatus)}">${escapeHtml(LABELS.salesStatus[first.unit.salesStatus] || first.unit.salesStatus)}</em>
                `;
            } else {
                formFields.badges.innerHTML = `
                    <em class="badge badge-active">일괄 검수</em>
                    <em class="badge badge-blue">${numberText(validContexts.length)}개 적용</em>
                `;
            }
        }
        if (formFields.serials) {
            if (validContexts.length > 1) {
                formFields.serials.innerHTML = validContexts.map((context) => `<span>${escapeHtml(context.unit.internalSerialNo)}</span>`).join("");
                formFields.serials.hidden = false;
            } else {
                formFields.serials.innerHTML = "";
                formFields.serials.hidden = true;
            }
        }
        if (formFields.applyNote) {
            formFields.applyNote.textContent = validContexts.length === 1
                    ? "저장 시 이 관리번호 1개에만 검수 결과가 반영됩니다."
                    : `저장 시 선택한 ${numberText(validContexts.length)}개 관리번호에 동일한 결과가 반영됩니다.`;
        }
        if (formFields.documentNo) formFields.documentNo.textContent = currentDocumentDetail.documentNo || "-";
        if (formFields.part) formFields.part.textContent = sameLine ? first.line.partName : "여러 부품";
        if (formFields.model) formFields.model.textContent = sameLine ? first.line.modelName : "여러 모델";
        formStep?.classList.add("is-active");
        setFormMessage("");
        await renderTemplateOptions(first.line.categoryId);
        requestAnimationFrame(() => formStep?.scrollIntoView({ block: "start", behavior: "smooth" }));
    };

    const updateLineSelectionState = (lineElement) => {
        if (!lineElement) {
            return;
        }
        const selectedCount = lineElement.querySelectorAll("[data-inspection-unit-check]:checked").length;
        const countText = lineElement.querySelector("[data-line-selected-count]");
        const selectedButton = lineElement.querySelector("[data-inspection-line-selected-action]");
        if (countText) countText.textContent = selectedCount ? `${numberText(selectedCount)}개 선택` : "선택 없음";
        if (selectedButton) selectedButton.disabled = selectedCount === 0;
    };

    const syncInspectionFormRule = () => {
        const result = inspectionForm?.elements.result;
        const grade = inspectionForm?.elements.grade;
        const salesStatus = inspectionForm?.elements.salesStatus;
        if (!result || !grade || !salesStatus) {
            return false;
        }
        let adjusted = false;
        if (result.value === "FAIL") {
            adjusted = grade.value !== "DEFECTIVE" || salesStatus.value !== "UNAVAILABLE";
            grade.value = "DEFECTIVE";
            salesStatus.value = "UNAVAILABLE";
            return adjusted;
        }
        if (grade.value === "DEFECTIVE") {
            adjusted = result.value !== "FAIL" || salesStatus.value !== "UNAVAILABLE";
            result.value = "FAIL";
            salesStatus.value = "UNAVAILABLE";
        }
        return adjusted;
    };

    const collectInspectionItemResults = () => {
        const items = (selectedTemplateDetail?.items || []).filter((item) => item.active !== false);
        const missingItems = [];
        const itemResults = [];
        items.forEach((item) => {
            const element = formFields.templateItems?.querySelector(`[data-template-item-id="${item.itemId}"]`);
            const resultField = element?.querySelector("[data-inspection-template-result]");
            const valueField = element?.querySelector("[data-inspection-template-value]");
            const value = valueField?.value?.trim() || "";
            const result = resultField?.value || "PASS";

            if (item.required) {
                if ((item.inputType === "SELECT" || item.inputType === "TEXT" || item.inputType === "NUMBER") && !value) {
                    missingItems.push(item.itemName);
                }
            }

            if (!item.required && item.inputType !== "CHECK" && !value) {
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

    const saveInspection = async () => {
        if (!pendingSavePayload) {
            return;
        }
        const payload = pendingSavePayload;
        pendingSavePayload = null;
        if (confirmElements.save) confirmElements.save.disabled = true;

        try {
            const endpoint = payload.unitIds.length > 1
                    ? `${apiBase()}/inspections/bulk`
                    : `${apiBase()}/inspections`;
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
                selectedDocumentId ? loadDocumentDetail(selectedDocumentId) : Promise.resolve(),
                loadHistories()
            ]);
            clearInspectionForm();
        } catch (error) {
            setFormMessage(error.message || "검수 결과를 저장하지 못했습니다.", true);
            showToast(error.message || "검수 결과 저장 실패", "error");
        } finally {
            if (confirmElements.save) confirmElements.save.disabled = false;
        }
    };

    const renderHistories = (histories) => {
        if (!historyTable) {
            return;
        }
        clearRows(historyTable);
        if (!histories.length) {
            setTableMessage(historyTable, "조회된 검수 이력이 없습니다.");
            return;
        }

        histories.forEach((history) => {
            const row = document.createElement("div");
            row.className = "data-row management-data-row inspection-history-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.dataset.inspectionHistoryId = String(history.inspectionId);
            row.innerHTML = `
                <strong role="cell" data-label="검수일">${escapeHtml(formatDate(history.inspectedAt))}</strong>
                <span class="inspection-stack-cell" role="cell" data-label="부품">
                    <strong>${escapeHtml(history.internalSerialNo)}</strong>
                    <small>${escapeHtml(history.partName)} ${escapeHtml(history.modelName)}</small>
                </span>
                <span role="cell" data-label="전표번호">${escapeHtml(history.documentNo || "-")}</span>
                <span role="cell" data-label="유형"><em class="badge ${typeBadgeClass(history.inspectionType)}">${escapeHtml(LABELS.inspectionType[history.inspectionType] || history.inspectionType)}</em></span>
                <span role="cell" data-label="등급"><em class="badge ${gradeBadgeClass(history.grade)}">${escapeHtml(LABELS.grade[history.grade] || history.grade)}</em></span>
                <span role="cell" data-label="처리자">${escapeHtml(history.inspectedByName || "-")}</span>
                <span class="row-actions" role="cell" data-label="상세">
                    <button type="button" data-inspection-history-action="${history.inspectionId}">상세</button>
                </span>
            `;
            row.addEventListener("click", (event) => {
                if (event.target.closest("button")) return;
                loadHistoryDetail(history.inspectionId);
            });
            row.addEventListener("keydown", (event) => {
                if (event.key !== "Enter" && event.key !== " ") return;
                event.preventDefault();
                loadHistoryDetail(history.inspectionId);
            });
            historyTable.append(row);
        });
        updateSelectedHistoryRow();
    };

    const loadHistories = async () => {
        if (!window.PcsApi || !getCompanyCode()) {
            setTableMessage(historyTable, "검수 이력을 불러올 수 없습니다.");
            return;
        }
        setTableMessage(historyTable, "검수 이력을 불러오는 중입니다.");
        try {
            const params = new URLSearchParams({ page: "0", size: String(PAGE_SIZE) });
            const data = await window.PcsApi.getData(`${apiBase()}/inspections?${params.toString()}`, apiOptions());
            renderHistories(Array.isArray(data?.content) ? data.content : []);
        } catch (error) {
            setTableMessage(historyTable, error.message || "검수 이력을 불러오지 못했습니다.");
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
            const resultText = LABELS.result[item.result] || item.result || "-";
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

    const closeHistoryWorkflow = () => {
        activeHistoryMode = null;
        if (historyWorkflowPanel) historyWorkflowPanel.hidden = true;
        historyWorkflowForm?.reset();
        setWorkflowMessage("");
    };

    const loadHistoryDetail = async (inspectionId) => {
        if (!inspectionId) {
            return;
        }
        closeHistoryWorkflow();
        try {
            const detail = await window.PcsApi.getData(`${apiBase()}/inspections/${inspectionId}`, apiOptions());
            selectedHistoryId = detail.inspectionId;
            selectedHistoryDetail = detail;
            updateSelectedHistoryRow();
            if (historyDetailPanel) historyDetailPanel.hidden = false;
            if (historyFields.unit) historyFields.unit.textContent = detail.internalSerialNo || "-";
            setBadge(historyFields.type, LABELS.inspectionType[detail.inspectionType] || detail.inspectionType, typeBadgeClass(detail.inspectionType));
            setBadge(historyFields.grade, LABELS.grade[detail.grade] || detail.grade, gradeBadgeClass(detail.grade));
            setBadge(historyFields.result, LABELS.result[detail.result] || detail.result, resultBadgeClass(detail.result));
            if (historyFields.documentNo) historyFields.documentNo.textContent = detail.documentNo || "-";
            if (historyFields.part) historyFields.part.textContent = `${detail.partName || "-"} ${detail.modelName || ""}`.trim();
            if (historyFields.date) historyFields.date.textContent = formatDate(detail.inspectedAt);
            if (historyFields.worker) historyFields.worker.textContent = detail.inspectedByName || "-";
            if (historyFields.sales) historyFields.sales.textContent = LABELS.salesStatus[detail.salesStatus] || detail.salesStatus || "-";
            if (historyFields.memo) historyFields.memo.textContent = detail.memo || "-";
            if (historyFields.relation) {
                historyFields.relation.textContent = detail.originalInspectionId
                        ? `원본 검수 #${detail.originalInspectionId} 기준`
                        : "원본 검수";
            }
            if (historyFields.itemCount) historyFields.itemCount.textContent = `${numberText(detail.itemResults?.length)}개 항목`;
            renderHistoryItems(detail.itemResults || []);
        } catch (error) {
            showToast(error.message || "검수 이력 상세를 불러오지 못했습니다.", "error");
        }
    };

    const syncHistoryWorkflowRule = () => {
        const result = historyWorkflowForm?.elements.result;
        const grade = historyWorkflowForm?.elements.grade;
        const salesStatus = historyWorkflowForm?.elements.salesStatus;
        if (!result || !grade || !salesStatus) {
            return;
        }
        if (result.value === "FAIL" || grade.value === "DEFECTIVE") {
            result.value = "FAIL";
            grade.value = "DEFECTIVE";
            salesStatus.value = "UNAVAILABLE";
        }
    };

    const startHistoryWorkflow = (mode) => {
        if (!selectedHistoryDetail || !historyWorkflowForm || !historyWorkflowPanel) {
            return;
        }
        activeHistoryMode = mode;
        historyWorkflowPanel.hidden = false;
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
        requestAnimationFrame(() => historyWorkflowPanel.scrollIntoView({ block: "nearest", behavior: "smooth" }));
    };

    const saveHistoryWorkflow = async () => {
        if (!activeHistoryMode || !selectedHistoryDetail || !historyWorkflowForm) {
            return;
        }
        syncHistoryWorkflowRule();
        const form = historyWorkflowForm.elements;
        const memo = form.memo.value.trim();
        if (!memo) {
            setWorkflowMessage(activeHistoryMode === "correction" ? "정정 사유를 입력해 주세요." : "재검수 메모를 입력해 주세요.", true);
            return;
        }
        const path = activeHistoryMode === "correction" ? "corrections" : "reinspections";
        try {
            const result = await window.PcsApi.request(`${apiBase()}/inspections/${selectedHistoryDetail.inspectionId}/${path}`, apiOptions({
                method: "POST",
                body: {
                    result: form.result.value,
                    grade: form.grade.value,
                    salesStatus: form.salesStatus.value,
                    memo,
                    itemResults: []
                }
            }));
            const newInspectionId = result?.data?.inspectionIds?.[0];
            showToast(activeHistoryMode === "correction" ? "검수 정정을 저장했습니다." : "재검수를 저장했습니다.", "success");
            closeHistoryWorkflow();
            await loadHistories();
            await loadHistoryDetail(newInspectionId || selectedHistoryDetail.inspectionId);
        } catch (error) {
            setWorkflowMessage(error.message || "저장하지 못했습니다.", true);
        }
    };

    document.addEventListener("click", (event) => {
        const documentButton = event.target.closest("[data-inspection-document-action]");
        if (documentButton) {
            loadDocumentDetail(documentButton.dataset.inspectionDocumentAction);
            return;
        }

        const unitButton = event.target.closest("[data-inspection-unit-action]");
        if (unitButton) {
            renderInspectionForm(findLineByUnitId(unitButton.dataset.inspectionUnitAction));
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

        const waitingLineButton = event.target.closest("[data-inspection-line-waiting-action]");
        if (waitingLineButton) {
            const line = findLineByMovementId(waitingLineButton.dataset.inspectionLineWaitingAction);
            const contexts = (line?.units || [])
                    .filter((unit) => unit.inspectionStatus !== "COMPLETED")
                    .map((unit) => ({ line, unit }));
            renderInspectionForm(contexts);
            return;
        }

        const historyButton = event.target.closest("[data-inspection-history-action]");
        if (historyButton) {
            loadHistoryDetail(historyButton.dataset.inspectionHistoryAction);
            return;
        }

        if (event.target.closest("[data-inspection-correction-start]")) {
            startHistoryWorkflow("correction");
            return;
        }

        if (event.target.closest("[data-inspection-reinspection-start]")) {
            startHistoryWorkflow("reinspection");
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
            if (syncInspectionFormRule()) {
                setFormMessage("불합격 또는 불량은 판매 불가 상태로 자동 반영됩니다.");
            }
            return;
        }
        if (historyWorkflowForm?.contains(event.target) && event.target.matches("[name='result'], [name='grade']")) {
            syncHistoryWorkflowRule();
        }
    });

    filterForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        currentDocumentPage = 0;
        selectedDocumentId = null;
        currentDocumentDetail = null;
        clearInspectionForm();
        if (documentSummaryCard) documentSummaryCard.hidden = true;
        if (documentFields.subtitle) {
            documentFields.subtitle.hidden = false;
            documentFields.subtitle.textContent = "1번에서 전표를 선택하면 부품 묶음과 관리번호가 표시됩니다.";
        }
        if (documentFields.lineCount) documentFields.lineCount.textContent = "전표 미선택";
        if (documentFields.lines) documentFields.lines.innerHTML = '<p class="detail-empty-text">검수할 전표를 먼저 선택해 주세요.</p>';
        loadWaitingDocuments(0);
    });

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

    clearFormButton?.addEventListener("click", clearInspectionForm);

    confirmElements.closeButtons.forEach((button) => {
        button.addEventListener("click", () => {
            pendingSavePayload = null;
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
        syncInspectionFormRule();
        if (inspectionForm.elements.grade?.value === "DEFECTIVE"
                && inspectionForm.elements.salesStatus?.value !== "UNAVAILABLE") {
            setFormMessage("불량 등급은 판매 불가로 저장해야 합니다.", true);
            return;
        }
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

        pendingSavePayload = {
            unitIds: selectedUnits.map((context) => context.unit.unitId),
            templateId,
            result: inspectionForm.elements.result.value,
            grade: inspectionForm.elements.grade.value,
            salesStatus: inspectionForm.elements.salesStatus.value,
            memo: inspectionForm.elements.memo.value.trim() || null,
            itemResults
        };

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

    const init = async () => {
        window.PcsUi?.consumeFlashToast?.();
        clearInspectionForm();
        await Promise.all([
            loadPartners(),
            loadWaitingDocuments(),
            loadHistories()
        ]);
    };

    init();
})();
