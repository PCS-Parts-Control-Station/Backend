(function () {
    const SOURCE_PAGE_SIZE = 100;
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
    const detailOverlay = document.querySelector("[data-history-detail-overlay]");
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

    const typeBadgeClass = (type) => {
        if (type === "CORRECTION") return "badge-warning";
        if (type === "REINSPECTION") return "badge-info";
        return "badge-blue";
    };

    const resultBadgeClass = (result) => result === "FAIL" ? "badge-danger" : "badge-active";

    const gradeBadgeClass = (grade) => {
        if (grade === "DEFECTIVE") return "badge-danger";
        if (grade === "NONE") return "badge-warning";
        return "badge-blue";
    };

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

    const createDocumentGroups = (items) => {
        const groups = new Map();

        items.forEach((item) => {
            const key = getDocumentKey(item);
            if (!groups.has(key)) {
                groups.set(key, {
                    key,
                    documentId: item.documentId,
                    documentNo: item.documentNo || "-",
                    latestAt: item.inspectedAt,
                    inspections: 0,
                    failCount: 0,
                    unitIds: new Set(),
                    parts: new Map()
                });
            }

            const group = groups.get(key);
            group.inspections += 1;
            if (isProblemInspection(item)) {
                group.failCount += 1;
            }
            if (item.unitId != null) {
                group.unitIds.add(item.unitId);
            }
            if (String(item.inspectedAt || "") > String(group.latestAt || "")) {
                group.latestAt = item.inspectedAt;
            }

            const partName = [item.partName, item.modelName].filter(Boolean).join(" ") || "품목 미확인";
            group.parts.set(partName, (group.parts.get(partName) || 0) + 1);
        });

        return Array.from(groups.values());
    };

    const summarizeParts = (group) => {
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

    const summarizeRowsParts = (items) => {
        const parts = new Map();
        items.forEach((item) => {
            const partName = [item.partName, item.modelName].filter(Boolean).join(" ") || "품목 미확인";
            parts.set(partName, (parts.get(partName) || 0) + 1);
        });
        const sorted = Array.from(parts.entries()).sort((a, b) => b[1] - a[1]);
        if (!sorted.length) {
            return "-";
        }
        const names = sorted.map(([name]) => name);
        if (names.length <= 2) {
            return names.join(" · ");
        }
        return `${names.slice(0, 2).join(" · ")} 외 ${numberText(names.length - 2)}개 품목`;
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
        if (activeHistoryFilter === "ALL") {
            return true;
        }
        if (activeHistoryFilter === "FAIL") {
            return isProblemInspection(item);
        }
        return item.inspectionType === activeHistoryFilter;
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

    const closeDetailPanel = ({ restoreFocus = true } = {}) => {
        if (!detailPanel || !detailOverlay || !detailPanelOpen) {
            return;
        }
        detailPanelOpen = false;
        detailPanel.hidden = true;
        detailOverlay.hidden = true;
        document.body.classList.remove("history-detail-open");
        if (restoreFocus && lastDetailTrigger) {
            lastDetailTrigger.focus();
        }
    };

    const openDetailPanel = (triggerElement) => {
        if (!detailPanel || !detailOverlay) {
            return;
        }
        lastDetailTrigger = triggerElement || lastDetailTrigger;
        detailPanelOpen = true;
        detailPanel.hidden = false;
        detailOverlay.hidden = false;
        document.body.classList.add("history-detail-open");
        resetDetailPanelContent();
        window.requestAnimationFrame(() => {
            detailCloseButton?.focus();
        });
    };

    const resetUnitSection = () => {
        selectedDocumentRows = [];
        selectedManagementNumber = null;
        selectedPartGroup = "ALL";
        activeHistoryFilter = "ALL";
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
        if (partGroupList) {
            partGroupList.innerHTML = "";
        }
        if (partCountText) {
            partCountText.textContent = "0개";
        }
        if (unitCountText) {
            unitCountText.textContent = "0개";
        }
        clearRows(unitTable);
        closeDetailPanel({ restoreFocus: false });
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
                    partName: item.partName || "-",
                    modelName: item.modelName || "",
                    rows: []
                });
            }
            const group = groups.get(key);
            group.rows.push(item);
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
                <code role="cell" data-label="전표번호">${escapeHtml(group.documentNo)}</code>
                <span class="history-stack-cell" role="cell" data-label="품목 요약">
                    <strong>${escapeHtml(summarizeParts(group))}</strong>
                    <small>관리번호 ${numberText(group.unitIds.size)}개</small>
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
            setTableMessage(unitTable, activeHistoryFilter === "ALL" ? "표시할 관리번호가 없습니다." : "선택한 조건의 관리번호가 없습니다.");
            return;
        }

        groups.forEach((group) => {
            const latest = group.latest || {};
            const row = document.createElement("div");
            row.className = "data-row document-data-row history-unit-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.setAttribute("aria-selected", "false");
            row.dataset.historyUnitKey = group.key;
            row.dataset.historyInspectionId = String(latest.inspectionId || "");
            row.innerHTML = `
                <code role="cell" data-label="관리번호">${escapeHtml(group.internalSerialNo || "-")}</code>
                <span class="history-stack-cell" role="cell" data-label="품목">
                    <strong>${escapeHtml(group.partName || "-")}</strong>
                    <small>${escapeHtml(group.modelName || "")}</small>
                </span>
                <span class="history-result-cell" role="cell" data-label="최근 결과">
                    <em class="badge ${resultBadgeClass(latest.result)}">${escapeHtml(LABELS.result[latest.result] || latest.result || "-")}</em>
                    <em class="badge ${gradeBadgeClass(latest.grade)}">${escapeHtml(LABELS.grade[latest.grade] || latest.grade || "-")}</em>
                </span>
                <span role="cell" data-label="이력 건수">${numberText(group.rows.length)}건</span>
                <span role="cell" data-label="최근 처리일">${escapeHtml(formatDate(latest.inspectedAt))}</span>
            `;
            unitTable.append(row);
        });

        updateSelectedManagementRow();
    };

    const renderTimeline = (detail) => {
        const unitKey = getUnitKey(detail);
        const rows = selectedDocumentRows.filter((item) => {
            return getUnitKey(item) === unitKey;
        }).sort((a, b) => String(b.inspectedAt || "").localeCompare(String(a.inspectedAt || "")));

        const sourceRows = rows.length ? rows : [detail];
        return sourceRows.map((item) => `
            <article class="history-timeline-item ${isProblemInspection(item) ? "is-problem" : ""}">
                <span class="history-timeline-dot" aria-hidden="true"></span>
                <div class="history-timeline-copy">
                    <strong>${escapeHtml(LABELS.inspectionType[item.inspectionType] || item.inspectionType || "-")} · ${escapeHtml(LABELS.result[item.result] || item.result || "-")} · ${escapeHtml(LABELS.grade[item.grade] || item.grade || "-")}</strong>
                    <span>${escapeHtml(formatDate(item.inspectedAt))} · ${escapeHtml(item.inspectedByName || "-")}</span>
                </div>
            </article>
        `).join("");
    };

    const renderHistoryDetail = (detail) => {
        const itemResults = Array.isArray(detail.itemResults) ? detail.itemResults : [];
        const partText = [detail.partName, detail.modelName].filter(Boolean).join(" ") || "-";
        const latestResultText = `${LABELS.result[detail.result] || detail.result || "-"} · ${LABELS.grade[detail.grade] || detail.grade || "-"}`;

        if (detailPanelTitle) {
            detailPanelTitle.textContent = detail.internalSerialNo || "관리번호 상세";
        }
        if (detailScope) {
            detailScope.textContent = `${partText} · ${latestResultText} · ${formatDate(detail.inspectedAt)} · ${detail.inspectedByName || "-"}`;
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

        detailBody.innerHTML = `
            <section class="history-detail-section">
                <div class="history-detail-summary">
                    <div class="history-detail-summary-title">
                        <strong>${escapeHtml(partText)}</strong>
                        <span class="history-result-cell">
                            <em class="badge ${resultBadgeClass(detail.result)}">${escapeHtml(LABELS.result[detail.result] || detail.result || "-")}</em>
                            <em class="badge ${gradeBadgeClass(detail.grade)}">${escapeHtml(LABELS.grade[detail.grade] || detail.grade || "-")}</em>
                        </span>
                    </div>
                    <dl class="history-detail-meta">
                        <div>
                            <dt>전표번호</dt>
                            <dd>${escapeHtml(detail.documentNo || "-")}</dd>
                        </div>
                        <div>
                            <dt>처리일</dt>
                            <dd>${escapeHtml(formatDate(detail.inspectedAt))}</dd>
                        </div>
                        <div>
                            <dt>담당자</dt>
                            <dd>${escapeHtml(detail.inspectedByName || "-")}</dd>
                        </div>
                        <div>
                            <dt>판매상태</dt>
                            <dd>${escapeHtml(LABELS.salesStatus[detail.salesStatus] || detail.salesStatus || "-")}</dd>
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
            <section class="history-detail-section">
                <h3>메모</h3>
                <p class="history-empty-detail">${escapeHtml(detail.memo || "등록된 메모가 없습니다.")}</p>
            </section>
            <section class="history-detail-section">
                <h3>첨부 이미지 또는 파일</h3>
                <p class="history-empty-detail">첨부 파일이 없습니다.</p>
            </section>
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
            nextButton
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

    const loadDocumentGroups = async (page = 0, options = {}) => {
        if (!getCompanyCode()) {
            setTableMessage(documentTable, "업체 주소가 올바르지 않습니다.");
            return;
        }

        const preserveScroll = options.preserveScroll === true;
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

            let pageData = await fetchHistoryPage(page, SOURCE_PAGE_SIZE);
            if (pageData.content.length === 0 && pageData.totalElements > 0 && pageData.page > 0) {
                pageData = await fetchHistoryPage(pageData.page - 1, SOURCE_PAGE_SIZE);
            }
            currentPage = pageData.page;

            const groups = createDocumentGroups(pageData.content);
            currentDocumentGroups = groups;
            renderDocumentRows(groups, pageData);
            updatePagination(pageData);
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

    const loadDocumentHistories = async (group) => {
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
        selectedDocumentRows = [];
        closeDetailPanel({ restoreFocus: false });
        updateSelectedDocumentRow();
        updateUnitFilterControls();

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
        setTableMessage(unitTable, "관리번호를 불러오는 중입니다.");

        try {
            const rows = [];
            let page = 0;
            let pageData;
            do {
                pageData = await fetchHistoryPage(page, DETAIL_PAGE_SIZE, { documentId: group.documentId }, { includeFilter: false });
                rows.push(...pageData.content);
                page += 1;
            } while (pageData.hasNext && page < MAX_DETAIL_PAGES);

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
            renderUnitRows(rows);
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
        filterForm.elements.result.value = "";
        filterForm.elements.grade.value = "";
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

            await loadDocumentGroups(0);
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
        activeHistoryFilter = "ALL";
        closeDetailPanel({ restoreFocus: false });
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
        closeDetailPanel({ restoreFocus: false });
        updateUnitFilterControls();
        renderUnitRows(selectedDocumentRows);
    });

    detailCloseButton?.addEventListener("click", () => closeDetailPanel());
    detailOverlay?.addEventListener("click", () => closeDetailPanel());

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && detailPanelOpen) {
            closeDetailPanel();
        }
    });

    prevButton.addEventListener("click", () => {
        if (currentPage > 0) {
            loadDocumentGroups(currentPage - 1, { preserveScroll: true });
        }
    });

    nextButton.addEventListener("click", () => {
        loadDocumentGroups(currentPage + 1, { preserveScroll: true });
    });

    initializePage();
})();
