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
    const nextFlowAction = document.querySelector("[data-next-flow-action]");
    const searchButton = filterForm?.querySelector("button[type='submit']");

    let currentPage = 0;
    let detailRequestId = 0;
    let documentSearchTimer = null;
    let selectedDocument = null;

    const escape = window.PcsHtml?.escape || ((value) => String(value ?? ""));
    const setText = window.PcsHtml?.setText || ((element, value, fallback = "-") => {
        if (element) {
            element.textContent = value === null || value === undefined || value === "" ? fallback : String(value);
        }
    });

    const LABELS = {
        unit: {
            IN_STOCK: "재고보유",
            OUTBOUND: "출고",
            CANCELED: "입고취소",
            DISPOSED: "비활성"
        },
        grade: {
            NONE: "-",
            A: "A등급",
            B: "B등급",
            C: "C등급",
            DEFECTIVE: "불량"
        },
        sales: {
            HOLD: "보류",
            AVAILABLE: "판매가능",
            UNAVAILABLE: "판매불가"
        },
        movement: {
            INBOUND: "입고",
            OUTBOUND: "출고",
            INBOUND_CANCEL: "입고취소",
            OUTBOUND_CANCEL: "출고취소"
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
    const movementLabel = (type) => LABELS.movement[type] || type || "-";
    const inspectionTypeLabel = (type) => LABELS.inspectionType[type] || type || "-";
    const inspectionResultLabel = (result) => LABELS.inspectionResult[result] || result || "-";

    const workspaceRoute = (route) => {
        const code = companyCode();
        return code ? `/w/${encodeURIComponent(code)}/${route}` : "#";
    };

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

    const setSelectedDocument = (document = null) => {
        selectedDocument = document;
        if (documentInput) {
            documentInput.value = document?.documentId ? String(document.documentId) : "";
        }
        if (documentLabel) {
            documentLabel.textContent = document?.documentNo || "전체";
        }
    };

    const workStatusLabel = (unit) => {
        if (!unit) {
            return "-";
        }
        if (unit.unitStatus === "CANCELED") return "입고취소";
        if (unit.unitStatus === "DISPOSED") return "비활성";
        if (unit.unitStatus === "OUTBOUND") {
            return unit.grade && unit.grade !== "NONE" ? gradeLabel(unit.grade) : "출고";
        }
        if (unit.inspectionStatus === "WAITING" || !unit.grade || unit.grade === "NONE") {
            return "검수대기";
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
        return `${workStatusLabel(unit)} / ${salesLabel(unit.salesStatus)} / ${recentLabel(unit)}`;
    };

    const statusBadgeClass = (label) => {
        const value = label || "";
        if (value.includes("판매불가") || value.includes("불량")) return "badge-danger";
        if (value.includes("출고") || value.includes("취소") || value.includes("비활성")) return "badge-inactive";
        if (value.includes("검수대기")) return "badge-pending";
        if (value.includes("보류") || value.includes("C등급")) return "badge-warning";
        if (value.includes("A등급") || value.includes("B등급") || value.includes("판매가능")) return "badge-available";
        return "badge-blue";
    };

    const salesBadgeClass = (label) => {
        const value = label || "";
        if (value === "판매가능") return "badge-available";
        if (value === "보류") return "badge-warning";
        if (value === "판매불가") return "badge-danger";
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
        const base = apiBase();
        if (!base || !window.PcsApi?.getData || !window.PcsPagination) {
            emptyTable("워크스페이스 정보를 확인할 수 없습니다.");
            updateSummary();
            return;
        }

        const execute = async () => {
            setLoading(true);
            try {
                const data = await window.PcsApi.getData(
                        `${base}/part-units?${buildParams(page).toString()}`,
                        apiOptions()
                );
                const pageData = window.PcsPagination.normalizePageData(data, PAGE_SIZE);
                currentPage = pageData.page;
                renderRows(pageData);
                updateSummary(pageData.summary || {});
                updatePagination(pageData);
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

        flowList.innerHTML = "";
        if (!events.length) {
            const empty = document.createElement("article");
            empty.innerHTML = "<strong>-</strong><span>표시할 이력이 없습니다.</span><small>-</small>";
            flowList.append(empty);
            return;
        }

        events.forEach((event) => {
            const item = document.createElement("article");
            item.innerHTML = `<strong>${escape(event.title)}</strong><span>${escape(event.status)}</span><small>${escape(event.meta)}</small>`;
            flowList.append(item);
        });
    };

    const hideNextFlowAction = () => {
        if (!nextFlowAction) {
            return;
        }
        nextFlowAction.hidden = true;
        nextFlowAction.removeAttribute("href");
        nextFlowAction.textContent = "";
    };

    const showNextFlowAction = (label, route) => {
        if (!nextFlowAction) {
            return;
        }
        nextFlowAction.textContent = label;
        nextFlowAction.href = workspaceRoute(route);
        nextFlowAction.hidden = false;
    };

    const updateNextFlowAction = (detail) => {
        const unit = detail?.unit;
        if (!unit) {
            hideNextFlowAction();
            return;
        }

        if (["OUTBOUND", "CANCELED", "DISPOSED"].includes(unit.unitStatus)) {
            hideNextFlowAction();
            return;
        }

        const inspectionCompleted = unit.inspectionStatus === "COMPLETED"
                || (detail.inspectionHistories || []).length > 0;
        if (!inspectionCompleted) {
            showNextFlowAction("검수하러 가기", "inspection");
            return;
        }

        if (unit.salesStatus === "AVAILABLE") {
            showNextFlowAction("출고하러 가기", "outbound/new");
            return;
        }

        hideNextFlowAction();
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
        updateNextFlowAction(detail);
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

    window.PcsDrawer?.bindDatasetDetailDrawer({
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
            hideNextFlowAction();
            detailRequestId += 1;
            loadDetail(row.dataset.unitId, detailRequestId);
        }
    });

    const categoryPicker = window.PcsCategoryPicker?.bind({
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
        loadFailureMessage: "분류를 불러오지 못했습니다."
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
        categoryPicker?.setValue("");
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

    categoryPicker?.load();
    setPartState(partStateInput?.value || DEFAULT_PART_STATE);
    syncStateCards();
    loadPartUnits(0);
})();
