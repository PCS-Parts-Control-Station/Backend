(function () {
    const PAGE_SIZE = 20;

    const filterForm = document.querySelector("[data-part-unit-filter-form]");
    const resetButton = document.querySelector("[data-part-unit-filter-reset]");
    const table = document.querySelector("[data-part-unit-table]");
    const pagination = document.querySelector("[data-part-unit-pagination]");
    const pageInfo = pagination?.querySelector("[data-page-info]");
    const prevButton = pagination?.querySelector("[data-page-prev]");
    const nextButton = pagination?.querySelector("[data-page-next]");
    const summaryTotal = document.querySelector("[data-summary-total]");
    const summaryWaiting = document.querySelector("[data-summary-waiting]");
    const summaryAvailable = document.querySelector("[data-summary-available]");
    const flowList = document.querySelector("[data-detail-flow-list]");
    const searchButton = filterForm?.querySelector("button[type='submit']");

    let currentPage = 0;
    let detailRequestId = 0;

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

    const partStatusLabel = (unit) => {
        if (!unit) {
            return "-";
        }
        if (unit.unitStatus === "CANCELED") return "입고취소";
        if (unit.unitStatus === "DISPOSED") return "비활성";
        if (unit.unitStatus === "OUTBOUND") {
            return "출고";
        }
        if (unit.inspectionStatus === "WAITING") {
            return "검수대기";
        }
        if (unit.salesStatus === "UNAVAILABLE") {
            return "판매불가";
        }
        if (unit.salesStatus === "HOLD") {
            return "보류";
        }
        return gradeLabel(unit.grade);
    };

    const statusBadgeClass = (label) => {
        const value = label || "";
        if (value === "검수대기") return "badge-pending";
        if (value === "불량" || value === "판매불가") return "badge-danger";
        if (value === "출고" || value.includes("취소")) return "badge-inactive";
        if (value === "C등급" || value === "보류") return "badge-warning";
        if (value === "A등급" || value === "B등급") return "badge-available";
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
        setText(summaryTotal, formatNumber(summary.totalCount || 0), "0");
        setText(summaryWaiting, formatNumber(summary.waitingCount || 0), "0");
        setText(summaryAvailable, formatNumber(summary.outboundAvailableCount || 0), "0");
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
            const recentText = unit.recentEventLabel
                    ? `${unit.recentEventLabel} · ${formatDateTime(unit.recentEventAt)}`
                    : "이력 없음";

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
                    cell("관리번호", `<strong>${escape(unit.internalSerialNo || "-")}</strong>`),
                    cell("품목", `<strong>${escape(unit.partName || "-")}</strong><small>${escape(unit.manufacturer || "-")} · ${escape(unit.modelName || "-")}</small>`),
                    cell("분류", escape(unit.categoryName || "-")),
                    cell("부품 상태", `<em class="badge ${statusBadgeClass(stateText)}">${escape(stateText)}</em>`),
                    cell("최근 처리", `<strong>${escape(recentText)}</strong>`)
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
                .sort((a, b) => dateValue(b.at) - dateValue(a.at))
                .slice(0, 6);

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

    const updateDetailFields = (detail) => {
        const unit = detail?.unit;
        if (!unit) {
            return;
        }

        const stateText = partStatusLabel(unit);
        setText(document.querySelector("[data-detail-code]"), unit.internalSerialNo);
        setText(document.querySelector("[data-detail-code-inline]"), unit.internalSerialNo);
        setText(document.querySelector("[data-detail-subtitle]"), `${unit.partName || "-"} · ${unit.categoryName || "-"}`);
        setText(document.querySelector("[data-detail-part]"), unit.partName);
        setText(document.querySelector("[data-detail-model]"), `${unit.manufacturer || "-"} · ${unit.modelName || "-"}`);
        setText(document.querySelector("[data-detail-serial]"), unit.manufacturerSerialNo);
        setText(document.querySelector("[data-detail-category]"), unit.categoryName);
        setText(document.querySelector("[data-detail-updated]"), unit.recentEventLabel ? `${unit.recentEventLabel} · ${formatDateTime(unit.recentEventAt)}` : "-");
        setBadge("[data-detail-unit-status]", stateText, statusBadgeClass(stateText));
        renderFlow(detail);
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
            codeInline: {
                target: "[data-detail-code-inline]",
                source: "code"
            },
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
            category: "[data-detail-category]",
            updated: "[data-detail-updated]",
            unitStatus: "[data-detail-unit-status]"
        },
        onUpdate: (row, data) => {
            setBadge("[data-detail-unit-status]", data.unitStatus, statusBadgeClass(data.unitStatus));
            if (flowList) {
                flowList.innerHTML = "<article><strong>-</strong><span>상세 이력을 불러오는 중입니다.</span><small>-</small></article>";
            }
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

    filterForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        loadPartUnits(0);
    });

    resetButton?.addEventListener("click", () => {
        filterForm?.reset();
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
    loadPartUnits(0);
})();
