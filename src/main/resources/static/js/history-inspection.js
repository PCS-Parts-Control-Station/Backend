(function () {
    const SOURCE_PAGE_SIZE = 10;
    const UNIT_PAGE_SIZE = 10;
    const DETAIL_PAGE_SIZE = 100;
    const MAX_DETAIL_PAGES = 5;

    const filterForm = document.querySelector("[data-history-filter-form]");
    const filterResetButton = document.querySelector("[data-history-filter-reset]");
    const documentTable = document.querySelector("[data-history-document-table]");
    const unitSection = document.querySelector("[data-history-unit-section]");
    const unitTable = document.querySelector("[data-history-unit-table]");
    const pagination = document.querySelector("[data-history-pagination]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const searchButton = filterForm?.querySelector("button[type='submit']");
    const documentScope = document.querySelector("[data-history-document-scope]");
    const clearDocumentButton = document.querySelector("[data-history-clear-document]");
    const partGroupList = document.querySelector("[data-history-part-groups]");
    const partCountText = document.querySelector("[data-history-part-count]");
    const unitCountText = document.querySelector("[data-history-unit-count]");
    const unitFilter = document.querySelector("[data-history-unit-filter]");
    const unitRefine = document.querySelector("[data-history-unit-refine]");
    const unitPagination = document.querySelector("[data-history-unit-pagination]");
    const unitPageInfo = document.querySelector("[data-history-unit-page-info]");
    const unitPrevButton = document.querySelector("[data-history-unit-page-prev]");
    const unitNextButton = document.querySelector("[data-history-unit-page-next]");
    const resultFilterSelect = document.querySelector("[data-history-result-filter]");
    const gradeFilterSelect = document.querySelector("[data-history-grade-filter]");
    const detailPanel = document.querySelector("[data-history-detail-panel]");
    const detailCloseButton = document.querySelector("[data-history-detail-close]");
    const detailPanelTitle = document.querySelector("#history-detail-panel-title");
    const detailScope = document.querySelector("[data-history-detail-scope]");
    const detailBody = document.querySelector("[data-history-detail-body]");

    let currentPage = 0;
    let currentDocumentGroups = [];
    let selectedDocumentRows = [];
    let selectedDocument = null;
    let selectedManagementNumber = null;
    let selectedPartGroup = "ALL";
    let activeHistoryFilter = "ALL";
    let activeResultFilter = "";
    let activeGradeFilter = "";
    let unitCurrentPage = 0;
    let detailPanelOpen = false;
    let lastDetailTrigger = null;

    const LABELS = {
        inspectionType: {
            INITIAL: "최초 검수",
            CORRECTION: "정정",
            REINSPECTION: "재검수"
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
        unitStatus: {
            IN_STOCK: "재고",
            OUTBOUND: "출고 완료",
            DISPOSED: "폐기됨",
            CANCELED: "취소됨"
        }
    };

    const FILTER_LABELS = {
        ALL: "전체",
        INITIAL: "최초 검수",
        CORRECTION: "정정",
        REINSPECTION: "재검수",
        FAIL: "불합격"
    };

    const getCompanyCode = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : "";
    };

    const apiBase = () => `/api/workspaces/${encodeURIComponent(getCompanyCode())}`;

    const readDeepLinkTarget = () => {
        const params = new URLSearchParams(window.location.search);
        return {
            documentId: params.get("documentId") || "",
            partId: params.get("partId") || "",
            unitId: params.get("unitId") || "",
            inspectionId: params.get("inspectionId") || ""
        };
    };

    const hasDeepLinkTarget = (target) => {
        return Boolean(target?.documentId || target?.partId || target?.unitId || target?.inspectionId);
    };

    const sameId = (left, right) => {
        return left !== null && left !== undefined && right !== null && right !== undefined
                && String(left) === String(right);
    };

    const escapeHtml = (value) => String(value ?? "").replace(/[&<>"']/g, (letter) => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#039;"
    }[letter]));

    const numberText = (value) => Number(value || 0).toLocaleString("ko-KR");

    const formatDate = (value) => {
        if (!value) {
            return "-";
        }
        if (Array.isArray(value)) {
            const [year, month, day, hour, minute] = value;
            if (year && month && day) {
                const datePart = `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
                if (hour != null && minute != null) {
                    return `${datePart} ${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`;
                }
                return datePart;
            }
        }
        return String(value).slice(0, 16).replace("T", " ");
    };

    const formatLocalDate = (date) => {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, "0");
        const day = String(date.getDate()).padStart(2, "0");
        return `${year}-${month}-${day}`;
    };

    const isProblemInspection = (item) => item?.result === "FAIL" || item?.grade === "DEFECTIVE";

    const resultBadgeClass = (result) => result === "FAIL" ? "badge-danger" : "badge-active";

    const gradeBadgeClass = (grade) => window.PcsLabels?.gradeBadgeClass(grade) || "badge-blue";

    const unitStatusBadgeClass = (status) => window.PcsLabels?.unitStatusBadgeClass(status) || "badge-active";

    const renderUnitStatusBadge = (status, options = {}) => {
        if (!status || (options.hideInStock && status === "IN_STOCK")) {
            return "";
        }
        return `<em class="badge ${unitStatusBadgeClass(status)} history-unit-status-badge">${escapeHtml(LABELS.unitStatus[status] || status)}</em>`;
    };

    const resolveCurrentSalesStatus = (unitStatus, salesStatus) => window.PcsLabels?.currentSalesStatus(unitStatus, salesStatus)
        || LABELS.salesStatus[salesStatus]
        || salesStatus
        || "-";

    const clearRows = (targetTable) => {
        targetTable?.querySelectorAll(".data-row:not(.table-head)").forEach((row) => row.remove());
    };

    const setTableMessage = (targetTable, message) => {
        clearRows(targetTable);
        const row = document.createElement("div");
        row.className = "data-row document-data-row empty-data-row";
        row.setAttribute("role", "row");
        row.innerHTML = `<span role="cell" data-label="안내">${escapeHtml(message)}</span>`;
        targetTable?.append(row);
    };

    const getDocumentKey = (item) => {
        if (item.documentId != null) {
            return `id:${item.documentId}`;
        }
        return `no:${item.documentNo || "UNKNOWN"}`;
    };

    const summarizeParts = (group) => {
        if (group.partSummary) {
            return group.partSummary;
        }
        const parts = Array.from(group.parts.entries())
            .sort((a, b) => b[1] - a[1])
            .map(([name]) => name);
        if (!parts.length) {
            return "-";
        }
        if (parts.length <= 2) {
            return parts.join(" · ");
        }
        return `${parts.slice(0, 2).join(" · ")} 외 ${numberText(parts.length - 2)}개 품목`;
    };

    const normalizeDocumentGroups = (items) => {
        return items.map((item) => ({
            key: getDocumentKey(item),
            documentId: item.documentId,
            documentNo: item.documentNo || "-",
            partSummary: item.partSummary || "-",
            latestAt: item.latestInspectedAt,
            inspections: item.inspectionCount || 0,
            failCount: item.failCount || 0,
            unitCount: item.unitCount || 0,
            unitIds: new Set(),
            parts: new Map()
        }));
    };

    const findDocumentGroupById = (groups, documentId) => {
        return groups.find((group) => sameId(group.documentId, documentId)) || null;
    };

    const getLatestInspection = (items) => {
        return [...items].sort((a, b) => String(b.inspectedAt || "").localeCompare(String(a.inspectedAt || "")))[0] || null;
    };

    const getPartGroupKey = (item) => {
        if (item?.partId != null) {
            return `id:${item.partId}`;
        }
        const partName = item?.partName || "품목 미확인";
        const modelName = item?.modelName || "";
        return `${partName}__${modelName}`;
    };

    const getPartCategoryText = (item) => {
        return item?.partCategoryName
            || item?.categoryName
            || item?.partCategory
            || item?.category
            || "분류 미지정";
    };

    const getUnitKey = (item) => {
        return item?.unitId != null ? `id:${item.unitId}` : `serial:${item?.internalSerialNo || item?.inspectionId}`;
    };

    const matchesPartGroup = (item) => {
        return selectedPartGroup === "ALL" || getPartGroupKey(item) === selectedPartGroup;
    };

    const matchesUnitFilter = (item) => {
        let matchesType = true;
        if (activeHistoryFilter === "FAIL") {
            matchesType = isProblemInspection(item);
        } else if (activeHistoryFilter !== "ALL") {
            matchesType = item.inspectionType === activeHistoryFilter;
        }
        if (!matchesType) {
            return false;
        }
        if (activeResultFilter && item.result !== activeResultFilter) {
            return false;
        }
        if (activeGradeFilter && item.grade !== activeGradeFilter) {
            return false;
        }
        return true;
    };

    const getRowsForSelectedPart = () => selectedDocumentRows.filter(matchesPartGroup);

    const resetDetailPanelContent = (message = "상세 이력을 불러오는 중입니다.") => {
        if (detailPanelTitle) {
            detailPanelTitle.textContent = "관리번호 상세";
        }
        if (detailScope) {
            detailScope.textContent = "";
        }
        if (detailBody) {
            detailBody.innerHTML = `<p class="detail-empty-text">${escapeHtml(message)}</p>`;
        }
    };

    const closeDetailPanel = ({restoreFocus = true} = {}) => {
        if (!detailPanel || !detailPanelOpen) {
            return;
        }
        detailPanelOpen = false;
        if (window.PcsDrawer?.close) {
            window.PcsDrawer.close(detailPanel, {restoreFocus: false});
        } else {
            detailPanel.hidden = true;
        }
        if (restoreFocus && lastDetailTrigger) {
            lastDetailTrigger.focus();
        }
    };

    const openDetailPanel = (triggerElement) => {
        if (!detailPanel) {
            return;
        }
        lastDetailTrigger = triggerElement || lastDetailTrigger;
        detailPanelOpen = true;
        if (window.PcsDrawer?.open) {
            window.PcsDrawer.open(detailPanel, {focus: false});
        } else {
            detailPanel.hidden = false;
        }
        resetDetailPanelContent();
    };

    const resetUnitSection = () => {
        selectedDocumentRows = [];
        selectedManagementNumber = null;
        selectedPartGroup = "ALL";
        activeHistoryFilter = "ALL";
        activeResultFilter = "";
        activeGradeFilter = "";
        unitCurrentPage = 0;
        if (unitSection) {
            unitSection.hidden = true;
        }
        if (documentScope) {
            documentScope.textContent = "";
        }
        if (clearDocumentButton) {
            clearDocumentButton.hidden = true;
        }
        if (unitFilter) {
            unitFilter.hidden = true;
        }
        if (unitRefine) {
            unitRefine.hidden = true;
        }
        if (resultFilterSelect) {
            resultFilterSelect.value = "";
        }
        if (gradeFilterSelect) {
            gradeFilterSelect.value = "";
        }
        if (partGroupList) {
            partGroupList.innerHTML = "";
        }
        if (partCountText) {
            partCountText.textContent = "0개";
        }
        if (unitCountText) {
            unitCountText.textContent = "0개";
        }
        if (unitPagination) {
            unitPagination.hidden = true;
        }
        if (unitPageInfo) {
            unitPageInfo.textContent = "1 / 1 페이지";
        }
        clearRows(unitTable);
        closeDetailPanel({restoreFocus: false});
    };

    const updateUnitFilterControls = () => {
        unitFilter?.querySelectorAll("[data-history-filter]").forEach((button) => {
            button.classList.toggle("is-active", button.dataset.historyFilter === activeHistoryFilter);
            button.setAttribute("aria-pressed", String(button.dataset.historyFilter === activeHistoryFilter));
        });
    };

    const updateUnitFilterCounts = (items) => {
        const counts = {
            ALL: items.length,
            INITIAL: 0,
            CORRECTION: 0,
            REINSPECTION: 0,
            FAIL: 0
        };
        items.forEach((item) => {
            if (counts[item.inspectionType] != null) {
                counts[item.inspectionType] += 1;
            }
            if (isProblemInspection(item)) {
                counts.FAIL += 1;
            }
        });
        unitFilter?.querySelectorAll("[data-history-filter]").forEach((button) => {
            const filter = button.dataset.historyFilter;
            button.textContent = `${FILTER_LABELS[filter] || filter} ${numberText(counts[filter] || 0)}`;
            button.classList.toggle("has-fail", filter === "FAIL" && counts.FAIL > 0);
        });
        updateUnitFilterControls();
    };

    const createPartGroups = (items) => {
        const groups = new Map();
        items.forEach((item) => {
            const key = getPartGroupKey(item);
            if (!groups.has(key)) {
                groups.set(key, {
                    key,
                    partName: item.partName || "품목 미확인",
                    modelName: item.modelName || "",
                    category: getPartCategoryText(item),
                    rows: [],
                    unitKeys: new Set(),
                    failCount: 0,
                    latestAt: item.inspectedAt
                });
            }

            const group = groups.get(key);
            group.rows.push(item);
            group.unitKeys.add(getUnitKey(item));
            if (isProblemInspection(item)) {
                group.failCount += 1;
            }
            if (String(item.inspectedAt || "") > String(group.latestAt || "")) {
                group.latestAt = item.inspectedAt;
            }
        });

        return Array.from(groups.values()).sort((a, b) => {
            if (b.unitKeys.size !== a.unitKeys.size) {
                return b.unitKeys.size - a.unitKeys.size;
            }
            return a.partName.localeCompare(b.partName, "ko");
        });
    };

    const renderPartGroups = (items) => {
        if (!partGroupList) {
            return;
        }

        const groups = createPartGroups(items);
        const totalUnitCount = new Set(items.map(getUnitKey)).size;
        const totalFailCount = items.filter(isProblemInspection).length;

        partGroupList.innerHTML = "";
        if (partCountText) {
            partCountText.textContent = `${numberText(groups.length)}개`;
        }

        const allButton = document.createElement("button");
        allButton.type = "button";
        allButton.className = "history-part-group-button";
        allButton.dataset.historyPartGroup = "ALL";
        allButton.setAttribute("aria-pressed", String(selectedPartGroup === "ALL"));
        allButton.innerHTML = `
            <span>
                <strong>전체</strong>
                <small>전체 관리번호</small>
            </span>
            <em>${numberText(totalUnitCount)}개${totalFailCount ? ` · 불합격 ${numberText(totalFailCount)}` : ""}</em>
        `;
        allButton.classList.toggle("is-active", selectedPartGroup === "ALL");
        allButton.classList.toggle("has-fail", totalFailCount > 0);
        partGroupList.append(allButton);

        groups.forEach((group) => {
            const button = document.createElement("button");
            button.type = "button";
            button.className = "history-part-group-button";
            button.dataset.historyPartGroup = group.key;
            button.setAttribute("aria-pressed", String(selectedPartGroup === group.key));
            button.innerHTML = `
                <span>
                    <strong>${escapeHtml(group.partName)}</strong>
                    <small>${escapeHtml([group.modelName, group.category].filter(Boolean).join(" / "))}</small>
                </span>
                <em>${numberText(group.unitKeys.size)}개${group.failCount ? ` · 불합격 ${numberText(group.failCount)}` : ""}</em>
            `;
            button.classList.toggle("is-active", selectedPartGroup === group.key);
            button.classList.toggle("has-fail", group.failCount > 0);
            partGroupList.append(button);
        });
    };

    const createUnitHistoryGroups = (items) => {
        const groups = new Map();
        items.filter(matchesPartGroup).filter(matchesUnitFilter).forEach((item) => {
            const key = getUnitKey(item);
            if (!groups.has(key)) {
                groups.set(key, {
                    key,
                    unitId: item.unitId,
                    internalSerialNo: item.internalSerialNo || "-",
                    unitStatus: item.unitStatus || "",
                    partName: item.partName || "-",
                    modelName: item.modelName || "",
                    rows: []
                });
            }
            const group = groups.get(key);
            group.rows.push(item);
            if (!group.unitStatus) {
                group.unitStatus = item.unitStatus || "";
            }
            if (!group.partName || group.partName === "-") {
                group.partName = item.partName || "-";
            }
            if (!group.modelName) {
                group.modelName = item.modelName || "";
            }
        });

        return Array.from(groups.values())
            .map((group) => ({
                ...group,
                latest: getLatestInspection(group.rows)
            }))
            .sort((a, b) => String(b.latest?.inspectedAt || "").localeCompare(String(a.latest?.inspectedAt || "")));
    };

    const updateSelectedDocumentRow = () => {
        documentTable?.querySelectorAll("[data-history-document-key]").forEach((row) => {
            const isSelected = row.dataset.historyDocumentKey === selectedDocument?.key;
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
        });
    };

    const updateSelectedManagementRow = () => {
        unitTable?.querySelectorAll("[data-history-unit-key]").forEach((row) => {
            const isSelected = row.dataset.historyUnitKey === selectedManagementNumber?.key;
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
        });
    };

    const updateUnitPagination = (totalElements) => {
        const totalPages = Math.ceil(totalElements / UNIT_PAGE_SIZE);
        const pageData = {
            totalElements,
            totalPages,
            page: unitCurrentPage,
            hasPrevious: unitCurrentPage > 0,
            hasNext: unitCurrentPage < totalPages - 1
        };

        if (window.PcsPagination) {
            window.PcsPagination.updateControls({
                pageData,
                container: unitPagination,
                info: unitPageInfo,
                prevButton: unitPrevButton,
                nextButton: unitNextButton,
                onPageClick: (page) => {
                    unitCurrentPage = page;
                    selectedManagementNumber = null;
                    closeDetailPanel({restoreFocus: false});
                    renderUnitRows(selectedDocumentRows);
                }
            });
            return;
        }

        if (unitPagination) {
            unitPagination.hidden = totalElements <= UNIT_PAGE_SIZE;
        }
        if (unitPageInfo) {
            unitPageInfo.textContent = `${numberText(unitCurrentPage + 1)} / ${numberText(Math.max(1, totalPages))} 페이지 · 총 ${numberText(totalElements)}개`;
        }
    };

    const renderDocumentRows = (groups, sourcePageData) => {
        clearRows(documentTable);

        if (!groups.length) {
            setTableMessage(documentTable, "조회된 검수 이력 전표가 없습니다.");
            selectedDocument = null;
            resetUnitSection();
            return;
        }

        groups.forEach((group) => {
            const row = document.createElement("div");
            row.className = "data-row document-data-row history-document-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.setAttribute("aria-selected", "false");
            row.dataset.historyDocumentKey = group.key;
            row.innerHTML = `
                <code role="cell" data-label="전표 번호">${escapeHtml(group.documentNo)}</code>
                <span class="history-stack-cell" role="cell" data-label="품목 요약">
                    <strong>${escapeHtml(summarizeParts(group))}</strong>
                    <small>관리번호 ${numberText(group.unitCount ?? group.unitIds.size)}개</small>
                </span>
                <span role="cell" data-label="검수 건수">${numberText(group.inspections)}건</span>
                <span role="cell" data-label="불합격 건수">${numberText(group.failCount)}건</span>
                <span role="cell" data-label="최근 검수일">${escapeHtml(formatDate(group.latestAt))}</span>
            `;
            documentTable.append(row);
        });

        updateSelectedDocumentRow();
    };

    const renderUnitRows = (items) => {
        clearRows(unitTable);

        const groups = createUnitHistoryGroups(items);
        if (unitCountText) {
            unitCountText.textContent = `${numberText(groups.length)}개`;
        }
        if (!groups.length) {
            const hasDetailFilter = activeHistoryFilter !== "ALL" || activeResultFilter || activeGradeFilter;
            setTableMessage(unitTable, hasDetailFilter ? "선택한 조건의 관리번호가 없습니다." : "표시할 관리번호가 없습니다.");
            updateUnitPagination(0);
            return;
        }

        const totalPages = Math.max(1, Math.ceil(groups.length / UNIT_PAGE_SIZE));
        if (unitCurrentPage >= totalPages) {
            unitCurrentPage = totalPages - 1;
        }
        if (unitCurrentPage < 0) {
            unitCurrentPage = 0;
        }

        const pageGroups = groups.slice(unitCurrentPage * UNIT_PAGE_SIZE, (unitCurrentPage + 1) * UNIT_PAGE_SIZE);
        pageGroups.forEach((group) => {
            const latest = group.latest || {};
            const unitStatusBadge = renderUnitStatusBadge(group.unitStatus || latest.unitStatus, {hideInStock: true});
            const row = document.createElement("div");
            row.className = "data-row document-data-row history-unit-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.setAttribute("aria-selected", "false");
            row.dataset.historyUnitKey = group.key;
            row.dataset.historyInspectionId = String(latest.inspectionId || "");
            row.innerHTML = `
                <span class="history-unit-code-cell" role="cell" data-label="관리번호">
                    <code>${escapeHtml(group.internalSerialNo || "-")}</code>
                    ${unitStatusBadge ? `<span class="history-unit-status-line">${unitStatusBadge}</span>` : ""}
                </span>
                <span class="history-stack-cell" role="cell" data-label="품목">
                    <strong>${escapeHtml(group.partName || "-")}</strong>
                    <small>${escapeHtml(group.modelName || "")}</small>
                </span>
                <span class="history-result-cell" role="cell" data-label="최근 결과">
                    <em class="badge ${resultBadgeClass(latest.result)}">${escapeHtml(LABELS.result[latest.result] || latest.result || "-")}</em>
                    <span class="history-result-separator" aria-hidden="true">/</span>
                    <em class="badge ${gradeBadgeClass(latest.grade)}">${escapeHtml(LABELS.grade[latest.grade] || latest.grade || "-")}</em>
                </span>
                <span role="cell" data-label="이력 건수">${numberText(group.rows.length)}건</span>
                <span role="cell" data-label="최근 처리일">${escapeHtml(formatDate(latest.inspectedAt))}</span>
            `;
            unitTable.append(row);
        });

        updateUnitPagination(groups.length);
        updateSelectedManagementRow();
    };

    const renderTimeline = (detail) => {
        const unitKey = getUnitKey(detail);
        const rows = selectedDocumentRows.filter((item) => {
            return getUnitKey(item) === unitKey;
        }).sort((a, b) => String(a.inspectedAt || "").localeCompare(String(b.inspectedAt || "")));

        const sourceRows = rows.length ? rows : [detail];
        return sourceRows.map((item, index) => {
            const typeText = LABELS.inspectionType[item.inspectionType] || item.inspectionType || "-";
            const resultText = LABELS.result[item.result] || item.result || "-";
            const gradeText = LABELS.grade[item.grade] || item.grade || "-";
            return `
            <article class="history-timeline-item ${isProblemInspection(item) ? "is-problem" : ""}">
                <div class="history-timeline-marker" aria-hidden="true">
                    <span class="history-timeline-dot">${numberText(index + 1)}</span>
                </div>
                <div class="history-timeline-copy">
                    <strong>${escapeHtml(typeText)} / ${escapeHtml(resultText)} / ${escapeHtml(gradeText)}</strong>
                    <span>${escapeHtml(item.inspectedByName || "-")}</span>
                    <small>${escapeHtml(formatDate(item.inspectedAt))}</small>
                </div>
            </article>
        `;
        }).join("");
    };

    const renderHistoryDetail = (detail) => {
        const itemResults = Array.isArray(detail.itemResults) ? detail.itemResults : [];
        const partText = [detail.partName, detail.modelName].filter(Boolean).join(" ") || "-";

        if (detailPanelTitle) {
            detailPanelTitle.textContent = detail.internalSerialNo || "관리번호 상세";
        }
        if (detailScope) {
            detailScope.textContent = partText;
        }
        if (!detailBody) {
            return;
        }

        const itemsMarkup = itemResults.length
            ? itemResults.map((item) => {
                const value = item.selectedOptionLabelSnapshot
                    || item.valueText
                    || (item.valueNumber != null ? String(item.valueNumber) : "-");
                const resultText = LABELS.result[item.result] || item.result || "-";
                return `
                        <article class="history-result-item ${isProblemInspection(item) ? "is-problem" : ""}">
                            <header>
                                <strong>${escapeHtml(item.itemNameSnapshot || "-")}</strong>
                                <em class="badge ${resultBadgeClass(item.result)}">${escapeHtml(resultText)}</em>
                            </header>
                            <p>${escapeHtml(value)}</p>
                        </article>
                    `;
            }).join("")
            : '<p class="history-empty-detail">항목별 결과가 없습니다.</p>';

        const memoMarkup = detail.memo ? `
            <section class="history-detail-section">
                <h3>메모</h3>
                <p class="history-empty-detail">${escapeHtml(detail.memo)}</p>
            </section>
        ` : "";

        detailBody.innerHTML = `
            <section class="history-detail-section">
                <h3>최근 검수 정보</h3>
                <div class="history-detail-summary">
                    <div class="history-detail-summary-title">
                        <strong>${escapeHtml(LABELS.inspectionType[detail.inspectionType] || detail.inspectionType || "-")}</strong>
                        <span class="history-result-cell">
                            <em class="badge ${resultBadgeClass(detail.result)}">${escapeHtml(LABELS.result[detail.result] || detail.result || "-")}</em>
                            <span class="history-result-separator" aria-hidden="true">/</span>
                            <em class="badge ${gradeBadgeClass(detail.grade)}">${escapeHtml(LABELS.grade[detail.grade] || detail.grade || "-")}</em>
                        </span>
                    </div>
                    <dl class="history-detail-meta">
                        <div>
                            <dt>검수 템플릿</dt>
                            <dd>${escapeHtml(detail.templateName || "-")}</dd>
                        </div>
                        <div>
                            <dt>현재 상태</dt>
                            <dd>${renderUnitStatusBadge(detail.unitStatus) || "-"}</dd>
                        </div>
                        <div>
                            <dt>처리자</dt>
                            <dd>${escapeHtml(detail.inspectedByName || "-")}</dd>
                        </div>
                        <div>
                            <dt>검수일</dt>
                            <dd>${escapeHtml(formatDate(detail.inspectedAt))}</dd>
                        </div>
                        <div>
                            <dt>현재 판매 상태</dt>
                            <dd>${escapeHtml(resolveCurrentSalesStatus(detail.unitStatus, detail.salesStatus))}</dd>
                        </div>
                    </dl>
                </div>
            </section>
            <section class="history-detail-section">
                <h3>검수 이력 타임라인</h3>
                <div class="history-timeline">${renderTimeline(detail)}</div>
            </section>
            <section class="history-detail-section">
                <h3>항목별 검수 결과</h3>
                <div class="history-result-list">${itemsMarkup}</div>
            </section>
            ${memoMarkup}
        `;
    };

    const buildParams = (page, size, extraParams = {}, options = {}) => {
        return window.PcsPagination.buildParams({
            page,
            size,
            form: options.includeFilter === false ? null : filterForm,
            extraParams
        });
    };

    const setLoading = (isLoading) => {
        if (!searchButton) {
            return;
        }
        searchButton.disabled = isLoading;
        searchButton.textContent = isLoading ? "조회 중" : "검색";
    };

    const updatePagination = (pageData) => {
        window.PcsPagination.updateControls({
            pageData,
            container: pagination,
            info: pageInfo,
            prevButton,
            nextButton,
            onPageClick: (page) => loadDocumentGroups(page, { preserveScroll: true })
        });
    };

    const fetchHistoryPage = async (page, size, extraParams = {}, options = {}) => {
        const params = buildParams(page, size, extraParams, options);
        const data = await window.PcsApi.getData(`${apiBase()}/inspections?${params.toString()}`, {
            authRedirect: true,
            loginCompanyCode: getCompanyCode()
        });
        return window.PcsPagination.normalizePageData(data, size);
    };

    const fetchHistoryDocumentPage = async (page, size, extraParams = {}, options = {}) => {
        const params = buildParams(page, size, extraParams, options);
        const data = await window.PcsApi.getData(`${apiBase()}/inspections/history-documents?${params.toString()}`, {
            authRedirect: true,
            loginCompanyCode: getCompanyCode()
        });
        return window.PcsPagination.normalizePageData(data, size);
    };

    const loadDocumentGroups = async (page = 0, options = {}) => {
        if (!getCompanyCode()) {
            setTableMessage(documentTable, "업체 주소가 올바르지 않습니다.");
            return;
        }

        const preserveScroll = options.preserveScroll === true;
        const restoreTarget = options.restoreTarget || null;
        const restoreDocumentId = restoreTarget?.documentId || "";
        const task = async () => {
            currentPage = page;
            setLoading(true);
            selectedDocument = null;
            selectedManagementNumber = null;
            currentDocumentGroups = [];
            resetUnitSection();
            if (!preserveScroll) {
                setTableMessage(documentTable, "이력을 불러오는 중입니다.");
            }

            const documentExtraParams = restoreDocumentId ? {documentId: restoreDocumentId} : {};
            const documentFetchOptions = restoreDocumentId ? {includeFilter: false} : {};
            let pageData = await fetchHistoryDocumentPage(page, SOURCE_PAGE_SIZE, documentExtraParams, documentFetchOptions);
            if (pageData.content.length === 0 && pageData.totalElements > 0 && pageData.page > 0) {
                pageData = await fetchHistoryDocumentPage(pageData.page - 1, SOURCE_PAGE_SIZE, documentExtraParams, documentFetchOptions);
            }
            currentPage = pageData.page;

            const groups = normalizeDocumentGroups(pageData.content);
            currentDocumentGroups = groups;
            renderDocumentRows(groups, pageData);
            updatePagination(pageData);

            if (restoreDocumentId) {
                const targetGroup = findDocumentGroupById(groups, restoreDocumentId);
                if (targetGroup) {
                    await loadDocumentHistories(targetGroup, {restoreTarget});
                }
            }
        };

        const execute = async () => {
            try {
                await task();
            } catch (error) {
                currentDocumentGroups = [];
                setTableMessage(documentTable, error?.message || "검수 이력을 불러오지 못했습니다.");
                resetUnitSection();
                updatePagination({
                    totalElements: 0,
                    totalPages: 0,
                    page: 0,
                    hasPrevious: false,
                    hasNext: false
                });
            } finally {
                setLoading(false);
            }
        };

        if (preserveScroll) {
            await window.PcsPagination.withPreservedScroll(execute);
            return;
        }
        await execute();
    };

    const loadDocumentHistories = async (group, options = {}) => {
        if (!group?.documentId) {
            selectedDocument = group || null;
            updateSelectedDocumentRow();
            if (unitSection) {
                unitSection.hidden = false;
            }
            setTableMessage(unitTable, "전표 정보를 확인할 수 없습니다.");
            return;
        }

        selectedDocument = group;
        selectedManagementNumber = null;
        selectedPartGroup = "ALL";
        activeHistoryFilter = "ALL";
        activeResultFilter = "";
        activeGradeFilter = "";
        unitCurrentPage = 0;
        selectedDocumentRows = [];
        closeDetailPanel({restoreFocus: false});
        updateSelectedDocumentRow();
        updateUnitFilterControls();
        if (resultFilterSelect) {
            resultFilterSelect.value = "";
        }
        if (gradeFilterSelect) {
            gradeFilterSelect.value = "";
        }

        if (unitSection) {
            unitSection.hidden = false;
        }
        if (documentScope) {
            documentScope.textContent = "관리번호를 불러오는 중입니다.";
        }
        if (clearDocumentButton) {
            clearDocumentButton.hidden = true;
        }
        if (unitFilter) {
            unitFilter.hidden = true;
        }
        if (unitRefine) {
            unitRefine.hidden = true;
        }
        setTableMessage(unitTable, "관리번호를 불러오는 중입니다.");

        try {
            const rows = [];
            const restoreTarget = options.restoreTarget || null;
            let page = 0;
            let pageData;
            do {
                pageData = await fetchHistoryPage(page, DETAIL_PAGE_SIZE, {documentId: group.documentId}, {includeFilter: false});
                rows.push(...pageData.content);
                page += 1;
            } while (pageData.hasNext && page < MAX_DETAIL_PAGES);

            if (restoreTarget?.unitId && !rows.some((item) => sameId(item.unitId, restoreTarget.unitId))) {
                const unitPageData = await fetchHistoryPage(0, DETAIL_PAGE_SIZE, {
                    documentId: group.documentId,
                    unitId: restoreTarget.unitId
                }, {includeFilter: false});
                const knownInspectionIds = new Set(rows.map((item) => String(item.inspectionId || "")));
                unitPageData.content.forEach((item) => {
                    const inspectionKey = String(item.inspectionId || "");
                    if (!inspectionKey || !knownInspectionIds.has(inspectionKey)) {
                        rows.push(item);
                        if (inspectionKey) {
                            knownInspectionIds.add(inspectionKey);
                        }
                    }
                });
            }

            selectedDocumentRows = rows;
            if (documentScope) {
                const unitCount = new Set(rows.map((item) => item.unitId ?? item.internalSerialNo).filter((value) => value != null)).size;
                const suffix = pageData?.hasNext ? " · 일부만 표시" : "";
                documentScope.textContent = `${group.documentNo} · 관리번호 ${numberText(unitCount)}개 · 검수 ${numberText(rows.length)}건${suffix}`;
            }
            if (clearDocumentButton) {
                clearDocumentButton.hidden = false;
            }
            renderPartGroups(rows);
            updateUnitFilterCounts(getRowsForSelectedPart());
            if (unitFilter) {
                unitFilter.hidden = false;
            }
            if (unitRefine) {
                unitRefine.hidden = false;
            }
            renderUnitRows(rows);
            if (hasDeepLinkTarget(restoreTarget)) {
                await restoreDeepLinkedSelection(restoreTarget);
            }
        } catch (error) {
            if (documentScope) {
                documentScope.textContent = "";
            }
            setTableMessage(unitTable, error?.message || "관리번호를 불러오지 못했습니다.");
        }
    };

    const loadHistoryDetail = async (inspectionId, triggerElement) => {
        if (!inspectionId) {
            return;
        }
        openDetailPanel(triggerElement);

        try {
            const detail = await window.PcsApi.getData(`${apiBase()}/inspections/${encodeURIComponent(inspectionId)}`, {
                authRedirect: true,
                loginCompanyCode: getCompanyCode()
            });
            renderHistoryDetail(detail);
        } catch (error) {
            resetDetailPanelContent(error?.message || "상세 이력을 불러오지 못했습니다.");
        }
    };

    const restoreDeepLinkedSelection = async (target) => {
        if (!hasDeepLinkTarget(target) || !selectedDocumentRows.length) {
            return;
        }

        let unitKey = "";
        if (target.partId) {
            const partGroupKey = `id:${target.partId}`;
            if (selectedDocumentRows.some((item) => getPartGroupKey(item) === partGroupKey)) {
                selectedPartGroup = partGroupKey;
            }
        }

        if (target.unitId) {
            const unitRow = selectedDocumentRows.find((item) => sameId(item.unitId, target.unitId));
            if (unitRow) {
                selectedPartGroup = getPartGroupKey(unitRow);
                unitKey = getUnitKey(unitRow);
            } else {
                unitKey = `id:${target.unitId}`;
            }
        }

        if (!unitKey && target.inspectionId) {
            const inspectionRow = selectedDocumentRows.find((item) => sameId(item.inspectionId, target.inspectionId));
            if (inspectionRow) {
                selectedPartGroup = getPartGroupKey(inspectionRow);
                unitKey = getUnitKey(inspectionRow);
            }
        }

        selectedManagementNumber = null;
        unitCurrentPage = 0;
        activeHistoryFilter = "ALL";
        activeResultFilter = "";
        activeGradeFilter = "";
        if (resultFilterSelect) {
            resultFilterSelect.value = "";
        }
        if (gradeFilterSelect) {
            gradeFilterSelect.value = "";
        }
        updateUnitFilterControls();
        renderPartGroups(selectedDocumentRows);
        updateUnitFilterCounts(getRowsForSelectedPart());

        if (unitKey) {
            const groups = createUnitHistoryGroups(selectedDocumentRows);
            const targetIndex = groups.findIndex((group) => group.key === unitKey);
            if (targetIndex >= 0) {
                unitCurrentPage = Math.floor(targetIndex / UNIT_PAGE_SIZE);
            }
        }

        renderUnitRows(selectedDocumentRows);

        if (!unitKey) {
            return;
        }

        const unitRows = selectedDocumentRows.filter((item) => getUnitKey(item) === unitKey);
        const inspectionId = target.inspectionId || getLatestInspection(unitRows)?.inspectionId || "";
        if (!inspectionId) {
            return;
        }

        const row = Array.from(unitTable?.querySelectorAll("[data-history-unit-key]") || [])
                .find((candidate) => candidate.dataset.historyUnitKey === unitKey) || null;
        selectedManagementNumber = {
            key: unitKey,
            inspectionId: String(inspectionId)
        };
        updateSelectedManagementRow();
        if (row) {
            row.scrollIntoView({block: "center", behavior: "auto"});
        }
        await loadHistoryDetail(inspectionId, row);
    };

    const clearSelectedDocument = () => {
        selectedDocument = null;
        selectedManagementNumber = null;
        selectedDocumentRows = [];
        selectedPartGroup = "ALL";
        activeHistoryFilter = "ALL";
        resetUnitSection();
        updateSelectedDocumentRow();
    };

    const resetFilterForm = () => {
        filterForm.elements.keyword.value = "";
        filterForm.elements.inspectionType.value = "";
        const end = new Date();
        const start = new Date();
        start.setDate(start.getDate() - 30);
        filterForm.elements.dateFrom.value = formatLocalDate(start);
        filterForm.elements.dateTo.value = formatLocalDate(end);
        loadDocumentGroups(0);
    };

    if (!filterForm || !documentTable || !unitTable || !pagination || !window.PcsApi || !window.PcsPagination) {
        return;
    }

    const initializePage = async () => {
        const companyCode = getCompanyCode();

        try {
            if (window.PcsApi.validateWorkspacePublic) {
                const isValidWorkspace = await window.PcsApi.validateWorkspacePublic(companyCode);
                if (!isValidWorkspace) {
                    return;
                }
            }

            const end = new Date();
            const start = new Date();
            start.setDate(start.getDate() - 30);

            filterForm.elements.dateFrom.value = formatLocalDate(start);
            filterForm.elements.dateTo.value = formatLocalDate(end);

            const deepLinkTarget = readDeepLinkTarget();
            await loadDocumentGroups(0, hasDeepLinkTarget(deepLinkTarget) ? {restoreTarget: deepLinkTarget} : {});
        } catch (error) {
            setTableMessage(documentTable, error?.message || "업체 주소를 확인할 수 없습니다.");
        }
    };

    filterForm.addEventListener("submit", (event) => {
        event.preventDefault();
        loadDocumentGroups(0);
    });

    filterResetButton?.addEventListener("click", () => {
        resetFilterForm();
    });

    documentTable.addEventListener("click", (event) => {
        const row = event.target.closest("[data-history-document-key]");
        if (!row || !documentTable.contains(row)) {
            return;
        }
        const group = currentDocumentGroups.find((item) => item.key === row.dataset.historyDocumentKey);
        if (group) {
            loadDocumentHistories(group);
        }
    });

    documentTable.addEventListener("keydown", (event) => {
        if (event.key !== "Enter" && event.key !== " ") {
            return;
        }
        const row = event.target.closest("[data-history-document-key]");
        if (!row) {
            return;
        }
        event.preventDefault();
        const group = currentDocumentGroups.find((item) => item.key === row.dataset.historyDocumentKey);
        if (group) {
            loadDocumentHistories(group);
        }
    });

    clearDocumentButton?.addEventListener("click", () => {
        clearSelectedDocument();
    });

    partGroupList?.addEventListener("click", (event) => {
        const button = event.target.closest("[data-history-part-group]");
        if (!button) {
            return;
        }
        selectedPartGroup = button.dataset.historyPartGroup || "ALL";
        selectedManagementNumber = null;
        unitCurrentPage = 0;
        activeHistoryFilter = "ALL";
        activeResultFilter = "";
        activeGradeFilter = "";
        if (resultFilterSelect) {
            resultFilterSelect.value = "";
        }
        if (gradeFilterSelect) {
            gradeFilterSelect.value = "";
        }
        closeDetailPanel({restoreFocus: false});
        renderPartGroups(selectedDocumentRows);
        updateUnitFilterCounts(getRowsForSelectedPart());
        renderUnitRows(selectedDocumentRows);
    });

    unitTable.addEventListener("click", (event) => {
        const row = event.target.closest("[data-history-unit-key]");
        if (!row || !unitTable.contains(row)) {
            return;
        }
        selectedManagementNumber = {
            key: row.dataset.historyUnitKey,
            inspectionId: row.dataset.historyInspectionId
        };
        updateSelectedManagementRow();
        loadHistoryDetail(row.dataset.historyInspectionId, row);
    });

    unitTable.addEventListener("keydown", (event) => {
        if (event.key !== "Enter" && event.key !== " ") {
            return;
        }
        const row = event.target.closest("[data-history-unit-key]");
        if (!row) {
            return;
        }
        event.preventDefault();
        selectedManagementNumber = {
            key: row.dataset.historyUnitKey,
            inspectionId: row.dataset.historyInspectionId
        };
        updateSelectedManagementRow();
        loadHistoryDetail(row.dataset.historyInspectionId, row);
    });

    unitFilter?.addEventListener("click", (event) => {
        const button = event.target.closest("[data-history-filter]");
        if (!button) {
            return;
        }
        activeHistoryFilter = button.dataset.historyFilter || "ALL";
        selectedManagementNumber = null;
        unitCurrentPage = 0;
        closeDetailPanel({restoreFocus: false});
        updateUnitFilterControls();
        renderUnitRows(selectedDocumentRows);
    });

    resultFilterSelect?.addEventListener("change", () => {
        activeResultFilter = resultFilterSelect.value;
        selectedManagementNumber = null;
        unitCurrentPage = 0;
        closeDetailPanel({restoreFocus: false});
        renderUnitRows(selectedDocumentRows);
    });

    gradeFilterSelect?.addEventListener("change", () => {
        activeGradeFilter = gradeFilterSelect.value;
        selectedManagementNumber = null;
        unitCurrentPage = 0;
        closeDetailPanel({restoreFocus: false});
        renderUnitRows(selectedDocumentRows);
    });

    unitPrevButton?.addEventListener("click", () => {
        if (unitCurrentPage <= 0) {
            return;
        }
        unitCurrentPage -= 1;
        selectedManagementNumber = null;
        closeDetailPanel({restoreFocus: false});
        renderUnitRows(selectedDocumentRows);
    });

    unitNextButton?.addEventListener("click", () => {
        unitCurrentPage += 1;
        selectedManagementNumber = null;
        closeDetailPanel({restoreFocus: false});
        renderUnitRows(selectedDocumentRows);
    });

    detailCloseButton?.addEventListener("click", () => closeDetailPanel());

    window.PcsDrawer?.bindDismiss({
        drawer: detailPanel,
        close: closeDetailPanel,
        isOpen: () => detailPanelOpen,
        keepOpenSelector: "[data-history-unit-key]"
    });

    prevButton.addEventListener("click", () => {
        if (currentPage > 0) {
            loadDocumentGroups(currentPage - 1, {preserveScroll: true});
        }
    });

    nextButton.addEventListener("click", () => {
        loadDocumentGroups(currentPage + 1, {preserveScroll: true});
    });

    initializePage();
})();
