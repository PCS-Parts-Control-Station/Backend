(() => {
    const PAGE_SIZE = 20;
    const SELECT_ALL_PAGE_SIZE = 100;

    const form = document.querySelector("#outbound-form");
    const partnerSelect = document.querySelector("[data-partner-select]");
    const openPartnerModalButton = document.querySelector("[data-open-partner-modal]");
    const partnerModal = document.querySelector("[data-partner-modal]");
    const closePartnerModalButtons = document.querySelectorAll("[data-close-partner-modal]");
    const partnerSearchInput = document.querySelector("[data-partner-search]");
    const partnerList = document.querySelector("[data-partner-list]");
    const selectedPartnerName = document.querySelector("[data-selected-partner-name]");
    const selectedPartnerMeta = document.querySelector("[data-selected-partner-meta]");
    const partnerMessage = document.querySelector("[data-partner-message]");
    const keywordInput = document.querySelector("[data-candidate-keyword]");
    const categoryFilter = document.querySelector("[data-category-filter]");
    const categoryFilterLabel = document.querySelector("[data-category-filter-label]");
    const categoryPickerModal = document.querySelector("[data-category-picker-modal]");
    const categoryPickerSearch = document.querySelector("[data-category-picker-search]");
    const categoryPickerList = document.querySelector("[data-category-picker-list]");
    const categoryPickerMessage = document.querySelector("[data-category-picker-message]");
    const gradeFilter = document.querySelector("[data-grade-filter]");
    const searchButton = document.querySelector("[data-candidate-search]");
    const resetSearchButton = document.querySelector("[data-candidate-reset]");
    const selectAllCandidatesButton = document.querySelector("[data-select-all-candidates]");
    const candidateTable = document.querySelector("[data-candidate-table]");
    const candidateSummary = document.querySelector("[data-candidate-summary]");
    const pagination = document.querySelector("[data-candidate-pagination]");
    const pageInfo = pagination?.querySelector("[data-page-info]");
    const prevButton = pagination?.querySelector("[data-page-prev]");
    const nextButton = pagination?.querySelector("[data-page-next]");
    const selectedList = document.querySelector("[data-selected-list]");
    const selectedEmpty = document.querySelector("[data-selected-empty]");
    const selectedCount = document.querySelector("[data-selected-count]");
    const clearSelectionButton = document.querySelector("[data-clear-selection]");
    const submitMessage = document.querySelector("[data-submit-message]");
    const resetFormButton = document.querySelector("[data-reset-form]");
    const registerStepSections = document.querySelectorAll("[data-outbound-register-step]");
    const sideStepItems = document.querySelectorAll("[data-outbound-register-side-step]");
    const CREATED_OUTBOUND_KEY = "pcsCreatedOutboundDocument";

    if (!form || !candidateTable || !selectedList || !window.PcsApi || !window.PcsPagination) {
        return;
    }

    let currentPage = 0;
    let selectedUnits = new Map();
    let latestCandidates = [];
    let categoryOptions = [];
    let partners = [];
    let selectedPartner = null;
    let candidateSearchStarted = false;
    let currentRegisterStep = "1";

    const getCompanyCode = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : "";
    };

    const apiBase = () => `/api/workspaces/${encodeURIComponent(getCompanyCode())}`;

    const apiOptions = () => ({
        authRedirect: true,
        loginCompanyCode: getCompanyCode(),
    });

    const setCurrentRegisterStep = (step) => {
        const nextStep = String(step || "1");
        currentRegisterStep = nextStep;

        registerStepSections.forEach((section) => {
            const isCurrent = section.dataset.outboundRegisterStep === nextStep;
            section.classList.toggle("is-active", isCurrent);
        });

        sideStepItems.forEach((item) => {
            const isCurrent = item.dataset.outboundRegisterSideStep === nextStep;
            item.classList.toggle("is-current", isCurrent);
            if (isCurrent) {
                item.setAttribute("aria-current", "step");
            } else {
                item.removeAttribute("aria-current");
            }
        });
    };

    const resolveCurrentRegisterStep = () => {
        if (submitMessage?.textContent.includes("저장")) {
            return "4";
        }
        if (selectedUnits.size > 0) {
            return "3";
        }
        if (candidateSearchStarted || keywordInput?.value.trim() || categoryFilter?.value || gradeFilter?.value) {
            return "2";
        }
        return "1";
    };

    const updateCurrentRegisterStep = (preferredStep = null) => {
        setCurrentRegisterStep(preferredStep || resolveCurrentRegisterStep());
    };

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

    const partnerRoleLabel = (role) => {
        const normalizedRole = String(role || "").trim().toUpperCase();
        const labels = {
            CUSTOMER: "출고 거래처",
            CLIENT: "출고 거래처",
            BUYER: "출고 거래처",
            BOTH: "공급/출고 거래처",
        };
        return labels[normalizedRole] || "";
    };

    const partnerMeta = (partner) => {
        const code = partner.partnerCode || partner.code || "";
        const role = partnerRoleLabel(partner.partnerRole);
        return [code, role].filter(Boolean).join(" · ") || "출고 거래처";
    };

    const partnerSearchText = (partner) => [
        partner.partnerName,
        partner.partnerCode,
        partner.code,
        partner.representativeName,
        partner.phoneNumber,
        partner.tel,
    ].filter(Boolean).join(" ").toLowerCase();

    const updateSelectedPartnerView = () => {
        const hasPartner = Boolean(selectedPartner);
        if (partnerSelect) {
            partnerSelect.value = hasPartner ? String(selectedPartner.partnerId) : "";
        }
        if (selectedPartnerName) {
            selectedPartnerName.textContent = hasPartner ? selectedPartner.partnerName : "거래처 선택";
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

        if (!filteredPartners.length) {
            partnerList.innerHTML = `
                <p class="partner-modal-empty">
                    ${partners.length ? "검색 결과가 없습니다." : "선택 가능한 출고 거래처가 없습니다."}
                </p>
            `;
            return;
        }

        partnerList.innerHTML = filteredPartners.map((partner) => {
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
    };

    const selectPartner = (partner) => {
        selectedPartner = partner;
        updateSelectedPartnerView();
        setPartnerMessage("");
        updateCurrentRegisterStep("1");
        partnerModal?.close();
    };

    const syncCategoryFilterLabel = () => {
        if (!categoryFilterLabel) {
            return;
        }

        const selected = categoryOptions.find((category) => String(category.categoryId) === String(categoryFilter?.value || ""));
        categoryFilterLabel.textContent = selected?.categoryName || "전체 분류";
    };

    const matchesCategoryKeyword = (category, keyword) => {
        if (!keyword) {
            return true;
        }

        const target = `${category.categoryName || ""} ${category.description || ""}`.toLowerCase();
        return target.includes(keyword.toLowerCase());
    };

    const renderCategoryPickerList = () => {
        if (!categoryPickerList) {
            return;
        }

        const keyword = categoryPickerSearch?.value.trim() || "";
        const selectedCategoryId = categoryFilter?.value || "";
        const categories = categoryOptions.filter((category) => matchesCategoryKeyword(category, keyword));
        categoryPickerList.innerHTML = "";

        if (categories.length === 0) {
            const empty = document.createElement("p");
            empty.className = "spec-builder-empty";
            empty.textContent = keyword ? "검색된 분류가 없습니다." : "등록된 분류가 없습니다.";
            categoryPickerList.append(empty);
            return;
        }

        categories.forEach((category) => {
            const button = document.createElement("button");
            button.type = "button";
            button.className = "category-picker-option";
            if (String(category.categoryId) === String(selectedCategoryId)) {
                button.classList.add("is-selected");
            }

            const name = document.createElement("strong");
            name.textContent = category.categoryName || "이름 없음";

            const description = document.createElement("small");
            description.textContent = category.description || "설명 없음";

            button.append(name, description);
            button.addEventListener("click", () => {
                if (categoryFilter) {
                    categoryFilter.value = String(category.categoryId);
                }
                syncCategoryFilterLabel();
                categoryPickerModal?.close();
                loadCandidates(0);
            });

            categoryPickerList.append(button);
        });
    };

    const openCategoryPicker = () => {
        if (!categoryPickerModal) {
            return;
        }

        if (categoryPickerSearch) {
            categoryPickerSearch.value = "";
        }
        if (categoryPickerMessage) {
            categoryPickerMessage.textContent = "";
        }
        renderCategoryPickerList();
        categoryPickerModal.showModal();
        window.setTimeout(() => categoryPickerSearch?.focus(), 0);
    };

    const clearCategoryFilter = () => {
        if (categoryFilter) {
            categoryFilter.value = "";
        }
        syncCategoryFilterLabel();
    };

    const partTitle = (item) => item?.partName || "-";

    const partMeta = (item) => {
        const values = [
            item?.modelName,
            item?.manufacturer,
        ].filter((value) => value && value !== item?.partName);
        return values.length ? values.join(" / ") : "-";
    };

    const gradeLabel = (grade) => {
        if (!grade || grade === "NONE") {
            return "미정";
        }
        if (grade === "DEFECTIVE") {
            return "불량";
        }
        return grade;
    };

    const gradeClass = (grade) => {
        if (grade === "A") return "grade-a";
        if (grade === "B") return "grade-b";
        if (grade === "C") return "grade-c";
        return "";
    };

    const setPartnerMessage = (message, type = "info") => {
        if (!partnerMessage) {
            return;
        }
        partnerMessage.textContent = message;
        partnerMessage.classList.toggle("is-error", type === "error");
    };

    const setSubmitMessage = (message, isError = false) => {
        if (!submitMessage) {
            return;
        }
        submitMessage.textContent = message;
        submitMessage.classList.toggle("is-error", isError);
    };

    const setLoading = (isLoading) => {
        if (searchButton) {
            searchButton.disabled = isLoading;
            searchButton.textContent = isLoading ? "조회 중" : "검색";
        }
    };

    const setSelectAllLoading = (isLoading) => {
        if (!selectAllCandidatesButton) {
            return;
        }
        selectAllCandidatesButton.disabled = isLoading;
        selectAllCandidatesButton.textContent = isLoading ? "전체 선택 중" : "전체 선택";
    };

    const setSubmitDisabled = (disabled) => {
        form.querySelectorAll('button[type="submit"]').forEach((button) => {
            button.disabled = disabled;
        });
    };

    const clearCandidateRows = () => {
        candidateTable.querySelectorAll(".outbound-candidate-row:not(.table-head)").forEach((row) => row.remove());
    };

    const setCandidateMessage = (message) => {
        clearCandidateRows();
        const row = document.createElement("div");
        row.className = "outbound-candidate-row empty-data-row";
        row.setAttribute("role", "row");
        row.innerHTML = `<span role="cell" data-label="안내">${escapeHtml(message)}</span>`;
        candidateTable.append(row);
    };

    const updateSelectedCount = () => {
        const count = selectedUnits.size;
        if (selectedCount) {
            selectedCount.textContent = `${count.toLocaleString("ko-KR")}개 선택`;
        }
        if (selectedEmpty) {
            selectedEmpty.hidden = count > 0;
        }
        updateCurrentRegisterStep();
    };

    const selectedGroups = () => {
        const groups = new Map();
        selectedUnits.forEach((unit) => {
            const key = String(unit.partId);
            if (!groups.has(key)) {
                groups.set(key, {
                    partId: unit.partId,
                    partName: unit.partName,
                    meta: partMeta(unit),
                    categoryName: unit.categoryName || "-",
                    units: [],
                    reason: "",
                });
            }
            groups.get(key).units.push(unit);
        });
        return [...groups.values()];
    };

    const renderSelectedList = () => {
        selectedList.querySelectorAll("[data-selected-group]").forEach((element) => element.remove());
        const groups = selectedGroups();

        groups.forEach((group) => {
            const groupElement = document.createElement("details");
            groupElement.className = "outbound-selected-group is-collapsible";
            groupElement.dataset.selectedGroup = "";
            groupElement.dataset.partId = group.partId;
            const metaHtml = group.meta && group.meta !== "-"
                ? `<small>${escapeHtml(group.meta)}</small>`
                : "";
            const groupHeader = `
                <div class="outbound-selected-group-header">
                    <div>
                        <strong>${escapeHtml(group.partName)}</strong>
                        ${metaHtml}
                    </div>
                    <div class="outbound-selected-group-actions">
                        <b>${group.units.length.toLocaleString("ko-KR")}개</b>
                        <button type="button" data-remove-group="${group.partId}">묶음 취소</button>
                        <span class="outbound-selected-toggle-label" aria-hidden="true"></span>
                    </div>
                </div>
            `;
            const groupBody = `
                <div class="outbound-selected-group-body">
                <div class="outbound-selected-units" aria-label="${escapeHtml(group.partName)} 선택 관리번호">
                    ${group.units.map((unit) => `
                        <span class="outbound-selected-unit">
                            <code>${escapeHtml(unit.internalSerialNo)}</code>
                            <button type="button" data-remove-unit="${unit.unitId}" aria-label="${escapeHtml(unit.internalSerialNo)} 제거">×</button>
                        </span>
                    `).join("")}
                </div>
                <label class="outbound-line-reason">
                    <span>품목 사유</span>
                    <input type="text" data-line-reason="${group.partId}" placeholder="품목별 출고 사유">
                </label>
                </div>
            `;
            groupElement.innerHTML = `<summary>${groupHeader}</summary>${groupBody}`;
            selectedList.append(groupElement);
        });

        updateSelectedCount();
    };

    const syncCandidateSelectionState = () => {
        candidateTable.querySelectorAll("[data-unit-id]").forEach((row) => {
            const selected = selectedUnits.has(Number(row.dataset.unitId));
            row.classList.toggle("is-selected", selected);
            row.setAttribute("aria-selected", String(selected));
            const label = row.querySelector("[data-select-label]");
            if (label) {
                label.textContent = selected ? "선택됨" : "선택";
            }
        });
    };

    const toggleUnit = (unit) => {
        const unitId = Number(unit.unitId);
        if (selectedUnits.has(unitId)) {
            selectedUnits.delete(unitId);
        } else {
            selectedUnits.set(unitId, unit);
        }
        renderSelectedList();
        syncCandidateSelectionState();
    };

    const createCandidateRow = (item) => {
        const row = document.createElement("div");
        const meta = partMeta(item);
        const metaHtml = meta && meta !== "-" ? `<small>${escapeHtml(meta)}</small>` : "";
        row.className = "outbound-candidate-row";
        row.dataset.unitId = item.unitId;
        row.setAttribute("role", "row");
        row.setAttribute("tabindex", "0");
        row.setAttribute("aria-selected", selectedUnits.has(Number(item.unitId)) ? "true" : "false");
        row.innerHTML = `
            <code role="cell" data-label="관리번호">${escapeHtml(item.internalSerialNo)}</code>
            <span role="cell" data-label="품목">
                <strong>${escapeHtml(partTitle(item))}</strong>
                ${metaHtml}
            </span>
            <span role="cell" data-label="분류">${escapeHtml(item.categoryName || "-")}</span>
            <span role="cell" data-label="등급">
                <i class="outbound-badge ${gradeClass(item.grade)}">${escapeHtml(gradeLabel(item.grade))}</i>
            </span>
            <button class="outbound-candidate-select" type="button" data-select-label>선택</button>
        `;

        row.addEventListener("click", (event) => {
            event.preventDefault();
            toggleUnit(item);
        });
        row.addEventListener("keydown", (event) => {
            if (event.key !== "Enter" && event.key !== " ") {
                return;
            }
            event.preventDefault();
            toggleUnit(item);
        });
        return row;
    };

    const renderCandidates = (items, pageData) => {
        clearCandidateRows();
        latestCandidates = items;

        if (candidateSummary) {
            candidateSummary.textContent = `${pageData.totalElements.toLocaleString("ko-KR")}개`;
        }

        if (!items.length) {
            setCandidateMessage("출고 가능한 관리번호가 없습니다.");
            return;
        }

        items.forEach((item) => candidateTable.append(createCandidateRow(item)));
        syncCandidateSelectionState();
    };

    const updatePagination = (pageData) => {
        window.PcsPagination.updateControls({
            pageData,
            container: pagination,
            info: pageInfo,
            prevButton,
            nextButton,
            onPageClick: (page) => loadCandidates(page, { preserveScroll: true })
        });
    };

    const buildCandidateParams = (page = 0, size = PAGE_SIZE) => {
        return window.PcsPagination.buildParams({
            page,
            size,
            extraParams: {
                keyword: keywordInput?.value.trim(),
                categoryId: categoryFilter?.value,
                grade: gradeFilter?.value,
            },
        });
    };

    const loadCandidates = async (page = 0, options = {}) => {
        const initialLoad = options.initial === true;
        if (!initialLoad) {
            candidateSearchStarted = true;
            updateCurrentRegisterStep("2");
        }
        const companyCode = getCompanyCode();
        if (!companyCode) {
            setCandidateMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const params = buildCandidateParams(page);

        const preserveScroll = options.preserveScroll === true;

        const execute = async () => {
            try {
                setLoading(true);
                if (!preserveScroll) {
                    setCandidateMessage("출고 부품을 불러오는 중입니다.");
                }
                const data = await window.PcsApi.getData(`${apiBase()}/stock/outbound-candidates?${params.toString()}`, apiOptions());
                const pageData = window.PcsPagination.normalizePageData(data, PAGE_SIZE);
                currentPage = pageData.page;
                renderCandidates(pageData.content, pageData);
                updatePagination(pageData);
            } catch (error) {
                setCandidateMessage(error?.message || "출고 부품을 불러오지 못했습니다.");
                updatePagination({
                    totalElements: 0,
                    totalPages: 0,
                    page: 0,
                    hasPrevious: false,
                    hasNext: false,
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

    const selectAllCandidates = async () => {
        const companyCode = getCompanyCode();
        if (!companyCode) {
            setCandidateMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        let page = 0;
        let addedCount = 0;
        let totalCount = 0;

        try {
            setLoading(true);
            setSelectAllLoading(true);
            setSubmitMessage("조회 조건에 맞는 출고 부품을 전체 선택하는 중입니다.");
            updateCurrentRegisterStep("2");

            while (true) {
                const params = buildCandidateParams(page, SELECT_ALL_PAGE_SIZE);
                const data = await window.PcsApi.getData(`${apiBase()}/stock/outbound-candidates?${params.toString()}`, apiOptions());
                const pageData = window.PcsPagination.normalizePageData(data, SELECT_ALL_PAGE_SIZE);
                const items = Array.isArray(pageData.content) ? pageData.content : [];
                totalCount = Number(pageData.totalElements || totalCount || items.length);

                items.forEach((item) => {
                    const unitId = Number(item.unitId);
                    if (!selectedUnits.has(unitId)) {
                        selectedUnits.set(unitId, item);
                        addedCount += 1;
                    }
                });

                const hasNext = pageData.hasNext === true || (Number(pageData.totalPages || 0) > page + 1);
                if (!hasNext || !items.length) {
                    break;
                }
                page += 1;
            }

            renderSelectedList();
            syncCandidateSelectionState();
            updateCurrentRegisterStep(addedCount || selectedUnits.size ? "3" : null);

            if (totalCount === 0) {
                setSubmitMessage("선택할 수 있는 출고 부품이 없습니다.", true);
                return;
            }

            const message = addedCount
                ? `${addedCount.toLocaleString("ko-KR")}개를 선택 목록에 추가했습니다.`
                : "이미 모든 조회 결과가 선택되어 있습니다.";
            setSubmitMessage("");
            window.PcsUi?.toast({
                type: addedCount ? "success" : "info",
                message,
            });
        } catch (error) {
            setSubmitMessage(error?.message || "출고 부품을 전체 선택하지 못했습니다.", true);
        } finally {
            setLoading(false);
            setSelectAllLoading(false);
        }
    };

    const loadCategories = async () => {
        if (!categoryFilter) {
            return;
        }
        try {
            const data = await window.PcsApi.getData(`${apiBase()}/categories?size=100`, apiOptions());
            categoryOptions = normalizeListData(data);
            syncCategoryFilterLabel();
            renderCategoryPickerList();
        } catch (error) {
            categoryOptions = [];
            if (categoryPickerMessage) {
                categoryPickerMessage.textContent = error?.message || "분류를 불러오지 못했습니다.";
            }
            syncCategoryFilterLabel();
            renderCategoryPickerList();
        }
    };

    const loadPartners = async () => {
        if (!partnerSelect) {
            return;
        }
        if (openPartnerModalButton) {
            openPartnerModalButton.disabled = true;
        }
        setPartnerMessage("거래처를 불러오는 중입니다.");

        try {
            const params = new URLSearchParams({
                active: "true",
                limit: "100",
            });
            const data = await window.PcsApi.getData(`${apiBase()}/partners?${params.toString()}`, apiOptions());
            partners = normalizeListData(data).filter((partner) => {
                const role = partner.partnerRole || "";
                return role === "CUSTOMER" || role === "BOTH";
            });

            selectedPartner = partners.find((partner) => String(partner.partnerId) === String(partnerSelect.value || "")) || null;
            updateSelectedPartnerView();
            renderPartnerList();
            if (openPartnerModalButton) {
                openPartnerModalButton.disabled = partners.length === 0;
            }
            setPartnerMessage(partners.length ? "" : "선택 가능한 출고 거래처가 없습니다.", partners.length ? "info" : "error");
        } catch (error) {
            partners = [];
            selectedPartner = null;
            updateSelectedPartnerView();
            renderPartnerList();
            if (openPartnerModalButton) {
                openPartnerModalButton.disabled = true;
            }
            setPartnerMessage(error?.message || "거래처를 불러오지 못했습니다.", "error");
        }
    };

    const buildPayload = () => {
        const groups = selectedGroups();
        return {
            partnerId: Number(partnerSelect?.value),
            reason: form.elements.reason.value.trim() || null,
            lines: groups.map((group) => ({
                partId: Number(group.partId),
                unitIds: group.units.map((unit) => Number(unit.unitId)),
                reason: selectedList.querySelector(`[data-line-reason="${group.partId}"]`)?.value.trim() || null,
            })),
        };
    };

    const validatePayload = (payload) => {
        if (!payload.partnerId) {
            return "출고 거래처를 선택해 주세요.";
        }
        if (!payload.lines.length) {
            return "출고할 관리번호를 선택해 주세요.";
        }
        return "";
    };

    const resetAll = () => {
        selectedUnits = new Map();
        form.reset();
        selectedPartner = null;
        updateSelectedPartnerView();
        clearCategoryFilter();
        setSubmitMessage("");
        renderSelectedList();
        syncCandidateSelectionState();
        candidateSearchStarted = false;
        updateCurrentRegisterStep("1");
    };

    searchButton?.addEventListener("click", () => loadCandidates(0));
    selectAllCandidatesButton?.addEventListener("click", selectAllCandidates);
    resetSearchButton?.addEventListener("click", () => {
        if (keywordInput) keywordInput.value = "";
        clearCategoryFilter();
        if (gradeFilter) gradeFilter.value = "";
        loadCandidates(0);
    });
    keywordInput?.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
            loadCandidates(0);
        }
    });
    document.querySelector("[data-open-category-picker]")?.addEventListener("click", openCategoryPicker);
    document.querySelectorAll("[data-close-category-picker]").forEach((button) => {
        button.addEventListener("click", () => categoryPickerModal?.close());
    });
    categoryPickerModal?.addEventListener("click", (event) => {
        if (event.target === categoryPickerModal) {
            categoryPickerModal.close();
        }
    });
    categoryPickerSearch?.addEventListener("input", renderCategoryPickerList);
    document.querySelector("[data-clear-category-picker]")?.addEventListener("click", () => {
        clearCategoryFilter();
        categoryPickerModal?.close();
        loadCandidates(0);
    });
    gradeFilter?.addEventListener("change", () => loadCandidates(0));
    prevButton?.addEventListener("click", () => loadCandidates(Math.max(0, currentPage - 1), { preserveScroll: true }));
    nextButton?.addEventListener("click", () => loadCandidates(currentPage + 1, { preserveScroll: true }));
    clearSelectionButton?.addEventListener("click", () => {
        selectedUnits = new Map();
        renderSelectedList();
        syncCandidateSelectionState();
        updateCurrentRegisterStep();
    });
    resetFormButton?.addEventListener("click", resetAll);

    openPartnerModalButton?.addEventListener("click", () => {
        renderPartnerList();
        partnerModal?.showModal();
        requestAnimationFrame(() => partnerSearchInput?.focus());
    });

    closePartnerModalButtons.forEach((button) => {
        button.addEventListener("click", () => partnerModal?.close());
    });

    partnerModal?.addEventListener("click", (event) => {
        if (event.target === partnerModal) {
            partnerModal.close();
        }
    });

    partnerSearchInput?.addEventListener("input", renderPartnerList);
    partnerSearchInput?.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
            renderPartnerList();
        }
    });

    partnerList?.addEventListener("click", (event) => {
        const option = event.target.closest("[data-partner-option]");
        if (!option) {
            return;
        }
        const partner = partners.find((candidate) => String(candidate.partnerId) === option.dataset.partnerOption);
        if (partner) {
            selectPartner(partner);
        }
    });

    selectedList.addEventListener("click", (event) => {
        const removeGroupButton = event.target.closest("[data-remove-group]");
        if (removeGroupButton) {
            event.preventDefault();
            event.stopPropagation();
            const partId = String(removeGroupButton.dataset.removeGroup);
            selectedUnits.forEach((unit, unitId) => {
                if (String(unit.partId) === partId) {
                    selectedUnits.delete(unitId);
                }
            });
            renderSelectedList();
            syncCandidateSelectionState();
            updateCurrentRegisterStep();
            return;
        }

        const removeButton = event.target.closest("[data-remove-unit]");
        if (!removeButton) {
            return;
        }
        selectedUnits.delete(Number(removeButton.dataset.removeUnit));
        renderSelectedList();
        syncCandidateSelectionState();
        updateCurrentRegisterStep();
    });

    form.addEventListener("submit", async (event) => {
        event.preventDefault();

        const payload = buildPayload();
        const validationMessage = validatePayload(payload);
        if (validationMessage) {
            setSubmitMessage(validationMessage, true);
            return;
        }

        let redirecting = false;

        try {
            setSubmitDisabled(true);
            setSubmitMessage("출고 전표를 저장하는 중입니다.");
            updateCurrentRegisterStep("4");
            const result = await window.PcsApi.request(`${apiBase()}/stock/documents/outbounds`, {
                method: "POST",
                body: payload,
                ...apiOptions(),
            });
            const data = result?.data;
            const documentNo = data?.documentNo;
            const outboundUnitCount = data?.outboundUnitCount || payload.lines.reduce((sum, line) => sum + line.unitIds.length, 0);
            const successMessage = documentNo
                ? `출고 전표 ${documentNo} 가 등록되었습니다.`
                : "출고 전표가 등록되었습니다.";

            if (documentNo) {
                try {
                    window.sessionStorage.setItem(CREATED_OUTBOUND_KEY, JSON.stringify({
                        documentNo,
                        quantity: outboundUnitCount,
                    }));
                } catch (storageError) {
                    // Storage can be blocked in private or restricted browser modes.
                }
            }

            window.PcsUi?.setFlashToast({
                message: successMessage,
                type: "success",
                duration: 3000,
            });

            setSubmitMessage(documentNo ? `출고 저장 완료: ${documentNo}` : "출고 저장이 완료되었습니다.");
            redirecting = true;
            window.location.href = `/w/${encodeURIComponent(getCompanyCode())}/outbound`;
        } catch (error) {
            setSubmitMessage(error?.message || "출고 전표를 저장하지 못했습니다.", true);
        } finally {
            if (!redirecting) {
                setSubmitDisabled(false);
                updateCurrentRegisterStep();
            }
        }
    });

    const initialize = async () => {
        const companyCode = getCompanyCode();
        if (!companyCode) {
            setCandidateMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        try {
            if (window.PcsApi.validateWorkspacePublic) {
                const valid = await window.PcsApi.validateWorkspacePublic(companyCode);
                if (!valid) {
                    return;
                }
            }
            await Promise.all([loadPartners(), loadCategories()]);
            renderSelectedList();
            await loadCandidates(0, { initial: true });
            candidateSearchStarted = false;
            updateCurrentRegisterStep("1");
        } catch (error) {
            setCandidateMessage(error?.message || "화면을 초기화하지 못했습니다.");
        }
    };

    initialize();
})();
