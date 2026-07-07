(function () {
    const PAGE_SIZE = 15;
    const DEFAULT_PART_STATE = "HELD";

    const filterForm = document.querySelector("[data-part-unit-filter-form]");
    const resetButton = document.querySelector("[data-part-unit-filter-reset]");
    const table = document.querySelector("[data-part-unit-table]");
    const pagination = document.querySelector("[data-part-unit-pagination]");
    const pageInfo = pagination?.querySelector("[data-page-info]");
    const prevButton = pagination?.querySelector("[data-page-prev]");
    const nextButton = pagination?.querySelector("[data-page-next]");
    const summaryHeld = document.querySelector("[data-summary-held]");
    const summaryWaiting = document.querySelector("[data-summary-waiting]");
    const summarySalesAvailable = document.querySelector("[data-summary-sales-available]");
    const summarySalesHold = document.querySelector("[data-summary-sales-hold]");
    const summarySalesUnavailable = document.querySelector("[data-summary-sales-unavailable]");
    const summaryGradeA = document.querySelector("[data-summary-grade-a]");
    const summaryGradeB = document.querySelector("[data-summary-grade-b]");
    const summaryGradeC = document.querySelector("[data-summary-grade-c]");
    const summaryDefective = document.querySelector("[data-summary-defective]");
    const summaryOutbound = document.querySelector("[data-summary-outbound]");
    const partStateInput = filterForm?.elements.partState;
    const stateFilterCards = Array.from(document.querySelectorAll("[data-part-state-filter]"));
    const documentInput = filterForm?.elements.documentId;
    const documentLabel = document.querySelector("[data-part-unit-document-label]");
    const documentPickerModal = document.querySelector("[data-part-unit-document-picker-modal]");
    const documentPickerSearch = document.querySelector("[data-part-unit-document-picker-search]");
    const documentPickerList = document.querySelector("[data-part-unit-document-picker-list]");
    const documentPickerMessage = document.querySelector("[data-part-unit-document-picker-message]");
    const flowList = document.querySelector("[data-detail-flow-list]");
    const stockHistoryAction = document.querySelector("[data-stock-history-action]");
    const inspectionHistoryAction = document.querySelector("[data-inspection-history-action]");
    const searchButton = filterForm?.querySelector("button[type='submit']");

    let currentPage = 0;
    let detailRequestId = 0;
    let documentSearchTimer = null;
    let selectedDocument = null;
    let categoryPicker = null;
    let detailDrawer = null;
    let isRestoringNavigationState = false;

    const escape = window.PcsHtml?.escape || ((value) => String(value ?? ""));
    const setText = window.PcsHtml?.setText || ((element, value, fallback = "-") => {
        if (element) {
            element.textContent = value === null || value === undefined || value === "" ? fallback : String(value);
        }
    });
    const navigationState = window.PcsNavigationState?.createUrlStateController({
        namespace: "part-units",
        managedKeys: ["keyword", "documentId", "documentNo", "categoryId", "partState", "page", "unitId"],
        defaults: {
            partState: DEFAULT_PART_STATE,
            page: "0"
        }
    });

    const LABELS = {
        unit: {
            IN_STOCK: "재고 보유",
            OUTBOUND: "출고",
            CANCELED: "입고 취소",
            DISPOSED: "비활성"
        },
        grade: {
            NONE: "-",
            A: "A 등급",
            B: "B 등급",
            C: "C 등급",
            DEFECTIVE: "불량"
        },
        sales: {
            HOLD: "판매 보류",
            AVAILABLE: "판매 가능",
            UNAVAILABLE: "판매 불가"
        },
        movement: {
            INBOUND: "입고",
            OUTBOUND: "출고",
            INBOUND_CANCEL: "입고 취소",
            OUTBOUND_CANCEL: "출고 취소"
        },
        inspectionType: {
            INITIAL: "최초 검수",
            CORRECTION: "검수 정정",
            REINSPECTION: "재검수"
        },
        inspectionResult: {
            PASS: "통과",
            FAIL: "불합격"
        }
    };

    const companyCode = () => window.PcsWorkspace?.getCompanyCode?.() || "";
    const apiBase = () => {
        const code = companyCode();
        return code ? `/api/workspaces/${encodeURIComponent(code)}` : "";
    };
    const workspaceRoute = (route, params = null) => {
        const code = companyCode();
        const query = params?.toString();
        const path = code ? `/w/${encodeURIComponent(code)}/${route}` : `/${route}`;
        return query ? `${path}?${query}` : path;
    };
    const apiOptions = () => ({
        authRedirect: true,
        loginCompanyCode: companyCode()
    });

    const formatNumber = (value) => window.PcsFormat?.number
            ? window.PcsFormat.number(value)
            : Number(value || 0).toLocaleString("ko-KR");

    const formatDateTime = (value) => {
        if (!value) {
            return "-";
        }
        if (Array.isArray(value)) {
            const [year, month, day, hour = 0, minute = 0] = value;
            if (year && month && day) {
                return `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")} ${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`;
            }
        }
        return String(value).replace("T", " ").slice(0, 16);
    };

    const dateValue = (value) => {
        if (!value) {
            return 0;
        }
        if (Array.isArray(value)) {
            const [year, month, day, hour = 0, minute = 0, second = 0] = value;
            return new Date(year, month - 1, day, hour, minute, second).getTime();
        }
        const parsed = new Date(value).getTime();
        return Number.isFinite(parsed) ? parsed : 0;
    };

    const gradeLabel = (grade) => LABELS.grade[grade] || grade || "-";
    const unitLabel = (status) => LABELS.unit[status] || status || "-";
    const salesLabel = (status) => LABELS.sales[status] || status || "-";
    const partSalesLabel = (unit) => unit?.unitStatus === "OUTBOUND" ? "판매 완료" : salesLabel(unit?.salesStatus);
    const movementLabel = (type) => LABELS.movement[type] || type || "-";
    const inspectionTypeLabel = (type) => LABELS.inspectionType[type] || type || "-";
    const inspectionResultLabel = (result) => LABELS.inspectionResult[result] || result || "-";

    const normalizeListData = (data) => {
        if (Array.isArray(data)) {
            return data;
        }
        if (Array.isArray(data?.content)) {
            return data.content;
        }
        if (Array.isArray(data?.items)) {
            return data.items;
        }
        return [];
    };

    const documentTypeLabel = (type) => {
        if (type === "INBOUND") return "입고";
        if (type === "OUTBOUND") return "출고";
        return type || "-";
    };

    const syncStateCards = () => {
        const selectedState = partStateInput?.value || "";
        stateFilterCards.forEach((card) => {
            const selected = card.dataset.partStateFilter === selectedState;
            card.classList.toggle("is-selected", selected);
            card.setAttribute("aria-pressed", String(selected));
        });
    };

    const setPartState = (partState) => {
        if (!partStateInput) {
            return;
        }
        partStateInput.value = partState || "";
        syncStateCards();
    };

    const currentFilterState = () => ({
        ...window.PcsNavigationState?.captureFormState?.(filterForm, {
            fields: ["keyword", "documentId", "categoryId", "partState"]
        }),
        documentNo: selectedDocument?.documentNo || "",
    });

    const syncNavigationState = (overrides = {}, options = {}) => {
        if (!navigationState || isRestoringNavigationState) {
            return;
        }

        const nextState = {
            ...currentFilterState(),
            page: String(currentPage),
            unitId: navigationState.read().unitId || "",
            ...overrides,
        };

        if (!nextState.documentId) {
            nextState.documentNo = "";
        }

        navigationState.write(nextState, {
            mode: options.mode || "replace",
            captureScroll: options.captureScroll !== false,
        });
    };

    const setSelectedDocument = (document = null, options = {}) => {
        selectedDocument = document;
        if (documentInput) {
            documentInput.value = document?.documentId ? String(document.documentId) : "";
        }
        if (documentLabel) {
            documentLabel.textContent = document?.documentNo || "전체";
        }
        if (options.sync !== false) {
            syncNavigationState({
                documentId: document?.documentId ? String(document.documentId) : "",
                documentNo: document?.documentNo || "",
                page: "0",
                unitId: ""
            });
        }
    };

    const setCategoryValue = (value, options = {}) => {
        const normalized = value ? String(value) : "";
        if (categoryPicker) {
            categoryPicker.setValue(normalized);
        } else if (filterForm?.elements.categoryId) {
            filterForm.elements.categoryId.value = normalized;
        }
        if (options.sync !== false) {
            syncNavigationState({
                categoryId: normalized,
                page: "0",
                unitId: ""
            });
        }
    };

    const readInitialNavigationState = () => navigationState?.read() || {};

    const applyNavigationStateToFilters = () => {
        const state = readInitialNavigationState();
        const page = window.PcsNavigationState?.numberParam?.(state.page, 0) || 0;

        isRestoringNavigationState = true;
        try {
            window.PcsNavigationState?.applyFormState?.(filterForm, state, {
                fields: ["keyword", "categoryId"]
            });
            setPartState(state.partState || DEFAULT_PART_STATE);
            setSelectedDocument(state.documentId ? {
                documentId: state.documentId,
                documentNo: state.documentNo || `전표 ${state.documentId}`
            } : null, { sync: false });
            setCategoryValue(state.categoryId || "", { sync: false });
        } finally {
            isRestoringNavigationState = false;
        }

        return {
            page,
            unitId: state.unitId || ""
        };
    };

    const workStatusLabel = (unit) => {
        if (!unit) {
            return "-";
        }
        if (unit.unitStatus === "CANCELED") return "입고 취소";
        if (unit.unitStatus === "DISPOSED") return "비활성";
        if (unit.unitStatus === "OUTBOUND") {
            return unit.grade && unit.grade !== "NONE" ? gradeLabel(unit.grade) : "출고";
        }
        if (unit.inspectionStatus === "WAITING" || !unit.grade || unit.grade === "NONE") {
            return "검수 대기";
        }
        return gradeLabel(unit.grade);
    };

    const recentLabel = (unit) => {
        if (!unit?.recentEventLabel) {
            return "이력 없음";
        }
        return `${unit.recentEventLabel} · ${formatDateTime(unit.recentEventAt)}`;
    };

    const partStatusLabel = (unit) => {
        if (!unit) {
            return "-";
        }
        return `${workStatusLabel(unit)} / ${partSalesLabel(unit)} / ${recentLabel(unit)}`;
    };

    const statusBadgeClass = (label) => {
        const value = label || "";
        if (value.includes("판매 완료")) return "badge-available";
        if (value.includes("판매 불가") || value.includes("불량")) return "badge-danger";
        if (value.includes("출고") || value.includes("취소") || value.includes("비활성")) return "badge-inactive";
        if (value.includes("검수 대기")) return "badge-pending";
        if (value.includes("보류") || value.includes("C 등급") || value.includes("C 등급")) return "badge-warning";
        if (value.includes("A 등급") || value.includes("B 등급") || value.includes("판매 가능")) return "badge-available";
        return "badge-blue";
    };

    const salesBadgeClass = (label) => {
        const value = label || "";
        if (value === "판매 가능") return "badge-available";
        if (value === "판매 보류" || value === "보류") return "badge-warning";
        if (value === "판매 불가") return "badge-danger";
        return "badge-inactive";
    };

    const setBadge = (selector, text, variantClass) => {
        const badge = document.querySelector(selector);
        if (!badge) {
            return;
        }
        badge.className = `badge ${variantClass}`;
        setText(badge, text);
    };

    const updateSummary = (summary = {}) => {
        setText(summaryHeld, formatNumber(summary.heldCount || 0), "0");
        setText(summaryWaiting, formatNumber(summary.waitingCount || 0), "0");
        setText(summarySalesAvailable, formatNumber(summary.salesAvailableCount || summary.outboundAvailableCount || 0), "0");
        setText(summarySalesHold, formatNumber(summary.salesHoldCount || 0), "0");
        setText(summarySalesUnavailable, formatNumber(summary.salesUnavailableCount || 0), "0");
        setText(summaryGradeA, formatNumber(summary.gradeACount || 0), "0");
        setText(summaryGradeB, formatNumber(summary.gradeBCount || 0), "0");
        setText(summaryGradeC, formatNumber(summary.gradeCCount || 0), "0");
        setText(summaryDefective, formatNumber(summary.defectiveCount || 0), "0");
        setText(summaryOutbound, formatNumber(summary.outboundCount || 0), "0");
        syncStateCards();
    };

    const setLoading = (loading) => {
        if (!searchButton) {
            return;
        }
        searchButton.disabled = loading;
        searchButton.textContent = loading ? "조회 중" : "검색";
    };

    const emptyTable = (message) => {
        window.PcsTable?.emptyRow(table, {
            rowClassName: "data-row management-data-row part-unit-data-row empty-data-row",
            message
        });
    };

    const cell = (label, html) => {
        const element = document.createElement("span");
        element.setAttribute("role", "cell");
        element.setAttribute("data-label", label);
        element.innerHTML = html;
        return element;
    };

    const renderRows = (pageData) => {
        window.PcsTable?.clearRows(table);
        if (!pageData.content.length) {
            emptyTable("조회 조건에 맞는 부품이 없습니다.");
            return;
        }

        pageData.content.forEach((unit) => {
            const stateText = partStatusLabel(unit);
            const recentText = recentLabel(unit);

            const row = document.createElement("div");
            row.className = "data-row management-data-row part-unit-data-row";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.dataset.partUnitRow = "true";
            row.dataset.unitId = unit.unitId || "";
            row.dataset.code = unit.internalSerialNo || "";
            row.dataset.part = unit.partName || "";
            row.dataset.category = unit.categoryName || "";
            row.dataset.model = unit.modelName || "";
            row.dataset.maker = unit.manufacturer || "";
            row.dataset.serial = unit.manufacturerSerialNo || "-";
            row.dataset.unitStatus = stateText;
            row.dataset.updated = recentText;

            row.append(
                    cell("관리번호", `<span class="part-unit-line"><strong>${escape(unit.internalSerialNo || "-")}</strong></span>`),
                    cell("품목", `<span class="part-unit-line"><strong>${escape(unit.partName || "-")}</strong><span class="part-unit-muted">${escape(unit.manufacturer || "-")} · ${escape(unit.modelName || "-")}</span></span>`),
                    cell("분류", `<span class="part-unit-line">${escape(unit.categoryName || "-")}</span>`),
                    cell("부품 상태", `<span class="part-unit-status-text">${escape(stateText)}</span>`)
            );
            table.append(row);
        });
    };

    const updatePagination = (pageData) => {
        window.PcsPagination?.updateControls({
            pageData,
            container: pagination,
            info: pageInfo,
            prevButton,
            nextButton
        });
    };

    const findPartUnitRow = (unitId) => {
        if (!unitId || !table) {
            return null;
        }
        return Array.from(table.querySelectorAll("[data-part-unit-row]"))
                .find((row) => String(row.dataset.unitId || "") === String(unitId)) || null;
    };

    const openPartUnitRow = (unitId, options = {}) => {
        const row = findPartUnitRow(unitId);
        if (!row || !detailDrawer?.update) {
            return false;
        }

        isRestoringNavigationState = options.restore === true;
        try {
            detailDrawer.update(row);
        } finally {
            isRestoringNavigationState = false;
        }

        if (options.scrollIntoView) {
            row.scrollIntoView({
                block: "center",
                behavior: options.behavior || "auto"
            });
        }

        return true;
    };

    const buildParams = (page) => {
        const params = window.PcsPagination.buildParams({
            page,
            size: PAGE_SIZE,
            form: filterForm
        });
        params.delete("salesStatus");
        return params;
    };

    const loadPartUnits = async (page = 0, options = {}) => {
        const requestedPage = Math.max(0, Number(page) || 0);
        const base = apiBase();
        if (!base || !window.PcsApi?.getData || !window.PcsPagination) {
            emptyTable("워크스페이스 정보를 확인할 수 없습니다.");
            updateSummary();
            return;
        }

        if (options.updateNavigation !== false) {
            syncNavigationState({
                page: String(requestedPage),
                unitId: options.unitId || ""
            });
        }

        const execute = async () => {
            setLoading(true);
            try {
                const data = await window.PcsApi.getData(
                        `${base}/part-units?${buildParams(requestedPage).toString()}`,
                        apiOptions()
                );
                const pageData = window.PcsPagination.normalizePageData(data, PAGE_SIZE);
                currentPage = pageData.page;
                renderRows(pageData);
                updateSummary(pageData.summary || {});
                updatePagination(pageData);

                if (options.restoreUnitId) {
                    const restored = openPartUnitRow(options.restoreUnitId, {
                        restore: true,
                        scrollIntoView: true
                    });
                    if (restored) {
                        navigationState?.restoreScroll();
                    }
                }
            } catch (error) {
                emptyTable(error?.message || "부품 목록을 불러오지 못했습니다.");
                updateSummary();
                window.PcsFeedback?.toast?.(error?.message || "부품 목록을 불러오지 못했습니다.", "error");
            } finally {
                setLoading(false);
            }
        };

        if (options.preserveScroll && window.PcsPagination?.withPreservedScroll) {
            await window.PcsPagination.withPreservedScroll(execute);
            return;
        }
        await execute();
    };

    const hasCompletedInspection = (detail) => {
        const unit = detail?.unit;
        return unit?.inspectionStatus === "COMPLETED"
                || Boolean(unit?.lastInspectionId)
                || (detail?.inspectionHistories || []).length > 0;
    };

    const hasOutboundHistory = (detail) => {
        const unit = detail?.unit;
        return unit?.unitStatus === "OUTBOUND"
                || (detail?.stockHistories || []).some((history) => String(history.movementType || "").startsWith("OUTBOUND"));
    };

    const findInboundStockContext = (detail) => {
        const histories = detail?.stockHistories || [];
        return histories.find((history) => history.documentId && history.movementId && history.movementType === "INBOUND")
                || histories.find((history) => history.documentId && history.movementId && String(history.movementType || "").startsWith("INBOUND"));
    };

    const inspectionRoute = (detail) => {
        const context = findInboundStockContext(detail);
        const unitId = detail?.unit?.unitId;
        if (!context || !unitId) {
            return "inspection";
        }
        const params = new URLSearchParams({
            documentId: String(context.documentId),
            movementId: String(context.movementId),
            unitId: String(unitId)
        });
        return `inspection?${params.toString()}`;
    };

    const outboundRoute = (detail) => {
        const unit = detail?.unit;
        if (!unit?.unitId) {
            return "outbound/new";
        }

        const params = new URLSearchParams({
            unitId: String(unit.unitId)
        });
        if (unit.partId) {
            params.set("partId", String(unit.partId));
        }
        if (unit.categoryId) {
            params.set("categoryId", String(unit.categoryId));
        }
        if (unit.internalSerialNo) {
            params.set("keyword", unit.internalSerialNo);
        }

        return `outbound/new?${params.toString()}`;
    };

    const stockHistoryRoute = (detail, options = {}) => {
        const unit = detail?.unit;
        const params = new URLSearchParams();
        const keyword = unit?.internalSerialNo || unit?.manufacturerSerialNo || "";
        if (keyword) {
            params.set("keyword", keyword);
        }
        if (options.inboundOnly) {
            params.set("documentType", "INBOUND");
        }
        return workspaceRoute("history/stock", params);
    };

    const latestInspectionId = (detail) => {
        return [...(detail?.inspectionHistories || [])]
                .sort((a, b) => dateValue(b.inspectedAt) - dateValue(a.inspectedAt))
                .find((history) => history.inspectionId)?.inspectionId || detail?.unit?.lastInspectionId || "";
    };

    const inspectionHistoryRoute = (detail) => {
        const unit = detail?.unit;
        const params = new URLSearchParams();
        const context = findInboundStockContext(detail);
        if (context?.documentId) {
            params.set("documentId", String(context.documentId));
        }
        if (unit?.partId) {
            params.set("partId", String(unit.partId));
        }
        if (unit?.unitId) {
            params.set("unitId", String(unit.unitId));
        }
        const inspectionId = latestInspectionId(detail);
        if (inspectionId) {
            params.set("inspectionId", String(inspectionId));
        }
        return workspaceRoute("history/inspection", params);
    };

    const createFlowArticle = ({ title, status, meta, actionLabel, route, note, variant }) => {
        const item = document.createElement("article");
        if (variant) {
            item.classList.add(variant);
        }

        const titleElement = document.createElement("strong");
        titleElement.textContent = title || "-";
        item.append(titleElement);

        if (status !== null && status !== undefined && status !== "") {
            const statusElement = document.createElement("span");
            statusElement.textContent = status;
            item.append(statusElement);
        }

        if (meta) {
            const metaElement = document.createElement("small");
            metaElement.textContent = meta;
            item.append(metaElement);
        }

        if (actionLabel || note) {
            const actionRow = document.createElement("div");
            actionRow.className = "process-flow-action-row";

            if (actionLabel && route) {
                const action = document.createElement("a");
                action.className = "btn btn-primary process-flow-action-button";
                action.href = workspaceRoute(route);
                action.textContent = actionLabel;
                actionRow.append(action);
            }

            if (note) {
                const noteElement = document.createElement("em");
                noteElement.className = "process-flow-status-note";
                noteElement.textContent = note;
                actionRow.append(noteElement);
            }

            item.append(actionRow);
        }

        return item;
    };

    const nextFlowStep = (detail) => {
        const unit = detail?.unit;
        if (!unit) {
            return null;
        }

        if (["OUTBOUND", "CANCELED", "DISPOSED"].includes(unit.unitStatus)) {
            return null;
        }

        if (!hasCompletedInspection(detail)) {
            return {
                title: "검수",
                status: "검수 전",
                actionLabel: "검수하러 가기",
                route: inspectionRoute(detail),
                variant: "is-next"
            };
        }

        if (unit.salesStatus === "AVAILABLE") {
            return {
                title: "출고",
                status: "판매 가능",
                actionLabel: "출고하러 가기",
                route: outboundRoute(detail),
                variant: "is-next"
            };
        }

        if (unit.salesStatus === "UNAVAILABLE") {
            return {
                title: "판매 불가 상태입니다.",
                variant: "is-blocked"
            };
        }

        if (unit.salesStatus === "HOLD") {
            return {
                title: "판매 보류 상태입니다.",
                variant: "is-blocked"
            };
        }

        return null;
    };

    const renderFlow = (detail) => {
        if (!flowList) {
            return;
        }

        const stockEvents = (detail.stockHistories || []).map((history) => ({
            at: history.createdAt,
            title: movementLabel(history.movementType),
            status: `${unitLabel(history.beforeUnitStatus)} → ${unitLabel(history.afterUnitStatus)}`,
            meta: `${history.documentNo || "-"} · ${formatDateTime(history.createdAt)} · ${history.processedByName || "-"}`
        }));
        const inspectionEvents = (detail.inspectionHistories || []).map((history) => ({
            at: history.inspectedAt,
            title: "검수",
            status: `${inspectionTypeLabel(history.inspectionType)} · ${inspectionResultLabel(history.result)} · ${gradeLabel(history.grade)} · ${salesLabel(history.salesStatus)}`,
            meta: `${formatDateTime(history.inspectedAt)} · ${history.inspectedByName || "-"}`
        }));

        const events = [...stockEvents, ...inspectionEvents]
                .sort((a, b) => dateValue(a.at) - dateValue(b.at));
        const nextStep = nextFlowStep(detail);

        flowList.innerHTML = "";
        if (!events.length && !nextStep) {
            flowList.append(createFlowArticle({
                title: "-",
                status: "표시할 이력이 없습니다.",
                meta: "-"
            }));
            return;
        }

        events.forEach((event) => {
            flowList.append(createFlowArticle(event));
        });

        if (nextStep) {
            flowList.append(createFlowArticle(nextStep));
        }
    };

    const resetDetailActions = () => {
        if (stockHistoryAction) {
            stockHistoryAction.textContent = "입고 이력";
            stockHistoryAction.href = workspaceRoute("history/stock");
        }
        if (inspectionHistoryAction) {
            inspectionHistoryAction.hidden = true;
        }
    };

    const updateDetailActions = (detail) => {
        if (stockHistoryAction) {
            const inboundOnly = !hasOutboundHistory(detail);
            stockHistoryAction.textContent = inboundOnly ? "입고 이력" : "입출고 이력";
            stockHistoryAction.href = stockHistoryRoute(detail, { inboundOnly });
        }
        if (inspectionHistoryAction) {
            const hasInspection = hasCompletedInspection(detail);
            inspectionHistoryAction.hidden = !hasInspection;
            if (hasInspection) {
                inspectionHistoryAction.href = inspectionHistoryRoute(detail);
            }
        }
    };

    const updateDetailFields = (detail) => {
        const unit = detail?.unit;
        if (!unit) {
            return;
        }

        const stateText = partStatusLabel(unit);
        setText(document.querySelector("[data-detail-code]"), unit.internalSerialNo);
        setText(document.querySelector("[data-detail-subtitle]"), `${unit.partName || "-"} · ${unit.categoryName || "-"}`);
        setText(document.querySelector("[data-detail-part]"), unit.partName);
        setText(document.querySelector("[data-detail-model]"), `${unit.manufacturer || "-"} · ${unit.modelName || "-"}`);
        setText(document.querySelector("[data-detail-serial]"), unit.manufacturerSerialNo);
        setBadge("[data-detail-unit-status]", stateText, statusBadgeClass(stateText));
        renderFlow(detail);
        updateDetailActions(detail);
    };

    const loadDetail = async (unitId, requestId) => {
        const base = apiBase();
        if (!unitId || !base || !window.PcsApi?.getData) {
            return;
        }

        try {
            const detail = await window.PcsApi.getData(
                    `${base}/part-units/${encodeURIComponent(unitId)}`,
                    apiOptions()
            );
            if (requestId !== detailRequestId) {
                return;
            }
            updateDetailFields(detail);
        } catch (error) {
            if (requestId !== detailRequestId) {
                return;
            }
            window.PcsFeedback?.toast?.(error?.message || "부품 상세를 불러오지 못했습니다.", "error");
        }
    };

    detailDrawer = window.PcsDrawer?.bindDatasetDetailDrawer({
        drawer: "[data-part-unit-detail-drawer]",
        container: "[data-part-unit-table]",
        rowSelector: "[data-part-unit-row]",
        closeButtons: "[data-close-part-unit-drawer]",
        keepOpenSelector: "[data-part-unit-row]",
        fields: {
            code: "[data-detail-code]",
            subtitle: {
                target: "[data-detail-subtitle]",
                value: (data) => `${data.part || "-"} · ${data.category || "-"}`
            },
            part: "[data-detail-part]",
            model: {
                target: "[data-detail-model]",
                value: (data) => `${data.maker || "-"} · ${data.model || "-"}`
            },
            serial: "[data-detail-serial]",
            unitStatus: "[data-detail-unit-status]"
        },
        onUpdate: (row, data) => {
            setBadge("[data-detail-unit-status]", data.unitStatus, statusBadgeClass(data.unitStatus));
            if (flowList) {
                flowList.innerHTML = "<article><strong>-</strong><span>상세 이력을 불러오는 중입니다.</span><small>-</small></article>";
            }
            resetDetailActions();
            detailRequestId += 1;
            loadDetail(row.dataset.unitId, detailRequestId);
            syncNavigationState({
                page: String(currentPage),
                unitId: row.dataset.unitId || ""
            });
        },
        onClose: () => {
            syncNavigationState({
                page: String(currentPage),
                unitId: ""
            });
        }
    });

    categoryPicker = window.PcsCategoryPicker?.bind({
        input: filterForm?.elements.categoryId,
        label: "[data-part-unit-category-label]",
        openButtons: "[data-open-part-unit-category-picker]",
        modal: "[data-part-unit-category-picker-modal]",
        search: "[data-part-unit-category-picker-search]",
        list: "[data-part-unit-category-picker-list]",
        message: "[data-part-unit-category-picker-message]",
        closeButtons: "[data-close-part-unit-category-picker]",
        clearButtons: "[data-clear-part-unit-category-picker]",
        defaultLabel: "전체",
        loadFailureMessage: "분류를 불러오지 못했습니다.",
        onChange: (categoryId) => {
            syncNavigationState({
                categoryId,
                page: "0",
                unitId: ""
            });
        }
    });

    const setDocumentMessage = (message = "") => {
        if (documentPickerMessage) {
            documentPickerMessage.textContent = message;
        }
    };

    const renderEmptyDocumentPicker = (message) => {
        if (!documentPickerList) {
            return;
        }
        documentPickerList.innerHTML = "";
        const empty = document.createElement("p");
        empty.className = "spec-builder-empty";
        empty.textContent = message;
        documentPickerList.append(empty);
    };

    const renderDocumentPicker = (documents) => {
        if (!documentPickerList) {
            return;
        }
        documentPickerList.innerHTML = "";
        if (!documents.length) {
            renderEmptyDocumentPicker("검색된 전표가 없습니다.");
            return;
        }

        documents.forEach((stockDocument) => {
            const button = document.createElement("button");
            button.type = "button";
            button.className = "category-picker-option";
            if (String(stockDocument.documentId) === String(documentInput?.value || "")) {
                button.classList.add("is-selected");
            }

            const name = document.createElement("strong");
            name.textContent = stockDocument.documentNo || "-";

            const count = document.createElement("span");
            count.className = "category-picker-count";
            count.textContent = `${documentTypeLabel(stockDocument.documentType)} · ${formatNumber(stockDocument.totalQuantity || 0)}개`;

            const description = document.createElement("small");
            description.textContent = [
                stockDocument.partnerName || "거래처 없음",
                stockDocument.firstPartName || "품목 없음",
                formatDateTime(stockDocument.createdAt)
            ].join(" · ");

            button.append(name, count, description);
            button.addEventListener("click", () => {
                setSelectedDocument(stockDocument);
                documentPickerModal?.close();
            });
            documentPickerList.append(button);
        });
    };

    const loadDocuments = async () => {
        const base = apiBase();
        if (!base || !window.PcsApi?.getData) {
            renderEmptyDocumentPicker("워크스페이스 정보를 확인할 수 없습니다.");
            return;
        }

        const params = new URLSearchParams({
            documentStatus: "COMPLETED",
            size: "20"
        });
        const keyword = documentPickerSearch?.value.trim();
        if (keyword) {
            params.set("keyword", keyword);
        }

        setDocumentMessage("");
        renderEmptyDocumentPicker("전표 목록을 불러오는 중입니다.");
        try {
            const data = await window.PcsApi.getData(
                    `${base}/stock/documents?${params.toString()}`,
                    apiOptions()
            );
            renderDocumentPicker(normalizeListData(data));
        } catch (error) {
            setDocumentMessage(error?.message || "전표를 불러오지 못했습니다.");
            renderEmptyDocumentPicker("전표를 불러오지 못했습니다.");
        }
    };

    const openDocumentPicker = () => {
        if (!documentPickerModal) {
            return;
        }
        if (documentPickerSearch) {
            documentPickerSearch.value = "";
        }
        setDocumentMessage("");
        if (typeof documentPickerModal.showModal === "function" && !documentPickerModal.open) {
            documentPickerModal.showModal();
        }
        loadDocuments();
        window.setTimeout(() => documentPickerSearch?.focus(), 0);
    };

    document.querySelectorAll("[data-open-part-unit-document-picker]").forEach((button) => {
        button.addEventListener("click", openDocumentPicker);
    });
    document.querySelectorAll("[data-close-part-unit-document-picker]").forEach((button) => {
        button.addEventListener("click", () => documentPickerModal?.close());
    });
    document.querySelectorAll("[data-clear-part-unit-document-picker]").forEach((button) => {
        button.addEventListener("click", () => {
            setSelectedDocument(null);
            documentPickerModal?.close();
        });
    });
    documentPickerModal?.addEventListener("click", (event) => {
        if (event.target === documentPickerModal) {
            documentPickerModal.close();
        }
    });
    documentPickerSearch?.addEventListener("input", () => {
        window.clearTimeout(documentSearchTimer);
        documentSearchTimer = window.setTimeout(loadDocuments, 220);
    });

    stateFilterCards.forEach((card) => {
        const apply = () => {
            const nextState = card.dataset.partStateFilter || "";
            setPartState(nextState);
            loadPartUnits(0);
        };
        card.addEventListener("click", apply);
        card.addEventListener("keydown", (event) => {
            if (event.key === "Enter" || event.key === " ") {
                event.preventDefault();
                apply();
            }
        });
    });

    filterForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        loadPartUnits(0);
    });

    resetButton?.addEventListener("click", () => {
        filterForm?.reset();
        setPartState(DEFAULT_PART_STATE);
        setSelectedDocument(null);
        setCategoryValue("");
        loadPartUnits(0);
    });

    prevButton?.addEventListener("click", () => {
        if (currentPage > 0) {
            loadPartUnits(currentPage - 1, { preserveScroll: true });
        }
    });

    nextButton?.addEventListener("click", () => {
        loadPartUnits(currentPage + 1, { preserveScroll: true });
    });

    window.addEventListener("popstate", () => {
        const restored = applyNavigationStateToFilters();
        loadPartUnits(restored.page, {
            updateNavigation: false,
            restoreUnitId: restored.unitId
        });
    });

    navigationState?.bindScrollCapture();

    const restored = applyNavigationStateToFilters();
    categoryPicker?.load();
    syncStateCards();
    loadPartUnits(restored.page, {
        updateNavigation: false,
        restoreUnitId: restored.unitId
    });
})();
