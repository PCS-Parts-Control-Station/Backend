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
    const candidateListFrame = document.querySelector("[data-candidate-list-frame]");
    const candidateListLoading = document.querySelector("[data-candidate-list-loading]");
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
    let currentPageData = null;
    let selectedUnits = new Map();
    const selectedReasons = new Map();
    let latestCandidates = [];
    let candidateSearchStarted = false;
    let submitting = false;
    let categoryPicker = null;
    let partnerPicker = null;
    let candidateRequestId = 0;

    const workspace = window.PcsWorkspace.createContext();
    const escapeHtml = window.PcsHtml.escape;

    const readOutboundPrefill = () => {
        const params = new URLSearchParams(window.location.search);
        const unitId = params.get("unitId");
        if (!unitId) {
            return null;
        }

        return {
            unitId,
            partId: params.get("partId"),
            categoryId: params.get("categoryId"),
            keyword: params.get("keyword"),
        };
    };

    const setCurrentRegisterStep = (step) => {
        const nextStep = String(step || "1");

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
        if (submitting) {
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

    const focusPartnerSelection = () => {
        updateCurrentRegisterStep("1");

        window.requestAnimationFrame(() => {
            const scrollTarget = openPartnerModalButton?.closest(".partner-picker-field") || openPartnerModalButton;
            scrollTarget?.scrollIntoView({
                block: "center",
                behavior: "smooth",
            });
            if (openPartnerModalButton && !openPartnerModalButton.disabled) {
                openPartnerModalButton.focus({ preventScroll: true });
            }
        });
    };

    const partnerMeta = (partner) => {
        const code = partner.partnerCode || partner.code || "";
        const role = window.PcsLabels.partnerRoleLong(partner.partnerRole, "");
        return [code, role].filter(Boolean).join(" · ") || "출고 거래처";
    };

    const partTitle = (item) => item?.partName || "-";

    const partMeta = (item) => {
        const values = [
            item?.modelName,
            item?.manufacturer,
        ].filter((value) => value && value !== item?.partName);
        return values.length ? values.join(" / ") : "-";
    };

    const gradeLabel = (grade) => window.PcsLabels?.grade(grade) || grade || "미정";

    const gradeClass = (grade) => window.PcsLabels?.gradeClass(grade) || "";

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
        window.PcsPagination?.setLoadingState({
            listContainer: candidateListFrame,
            target: candidateTable,
            overlay: candidateListLoading,
            pagination,
            prevButton,
            nextButton,
            pageData: currentPageData,
            isLoading,
        });
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
                    units: [],
                });
            }
            groups.get(key).units.push(unit);
        });
        return [...groups.values()];
    };

    const renderSelectedList = () => {
        selectedList.querySelectorAll("[data-line-reason]").forEach((input) => {
            selectedReasons.set(String(input.dataset.lineReason), input.value);
        });
        selectedList.querySelectorAll("[data-selected-group]").forEach((element) => element.remove());
        const groups = selectedGroups();
        const activePartIds = new Set(groups.map((group) => String(group.partId)));
        selectedReasons.forEach((_, partId) => {
            if (!activePartIds.has(partId)) {
                selectedReasons.delete(partId);
            }
        });

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
                    <input type="text" data-line-reason="${group.partId}" value="${escapeHtml(selectedReasons.get(String(group.partId)) || "")}" placeholder="품목별 출고 사유">
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
        currentPageData = pageData;
        window.PcsPagination.updateControls({
            pageData,
            container: pagination,
            info: pageInfo,
            prevButton,
            nextButton,
            onPageClick: (page) => loadCandidates(page, { preserveScroll: true })
        });
    };

    const buildCandidateParams = (page = 0, size = PAGE_SIZE, extraParams = {}) => {
        return window.PcsPagination.buildParams({
            page,
            size,
            extraParams: {
                keyword: keywordInput?.value.trim(),
                categoryId: categoryFilter?.value,
                grade: gradeFilter?.value,
                ...extraParams,
            },
        });
    };

    const loadCandidates = async (page = 0, options = {}) => {
        const initialLoad = options.initial === true;
        if (!initialLoad) {
            candidateSearchStarted = true;
            updateCurrentRegisterStep("2");
        }
        const companyCode = workspace.companyCode;
        if (!companyCode) {
            setCandidateMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const params = buildCandidateParams(page, PAGE_SIZE, options.extraParams || {});
        const requestId = ++candidateRequestId;

        const preserveScroll = options.preserveScroll === true;

        const execute = async () => {
            try {
                setLoading(true);
                if (!preserveScroll) {
                    setCandidateMessage("출고 부품을 불러오는 중입니다.");
                }
                const data = await window.PcsApi.getData(workspace.apiUrl(`/stock/outbound-candidates?${params.toString()}`), workspace.apiOptions());
                if (requestId !== candidateRequestId) {
                    return;
                }
                const pageData = window.PcsPagination.normalizePageData(data, PAGE_SIZE);
                currentPage = pageData.page;
                renderCandidates(pageData.content, pageData);
                updatePagination(pageData);
            } catch (error) {
                if (requestId !== candidateRequestId) {
                    return;
                }
                if (preserveScroll && latestCandidates.length) {
                    window.PcsFeedback.toast(error?.message || "출고 부품을 불러오지 못했습니다.", "error");
                    return;
                }
                setCandidateMessage(error?.message || "출고 부품을 불러오지 못했습니다.");
                updatePagination({
                    totalElements: 0,
                    totalPages: 0,
                    page: 0,
                    hasPrevious: false,
                    hasNext: false,
                });
            } finally {
                if (requestId === candidateRequestId) {
                    setLoading(false);
                }
            }
        };

        if (preserveScroll) {
            await window.PcsPagination.withPreservedScroll(execute);
            return;
        }

        await execute();
    };

    categoryPicker = window.PcsCategoryPicker.bind({
        input: categoryFilter,
        label: categoryFilterLabel,
        modal: categoryPickerModal,
        search: categoryPickerSearch,
        list: categoryPickerList,
        message: categoryPickerMessage,
        openButtons: document.querySelector("[data-open-category-picker]"),
        closeButtons: document.querySelectorAll("[data-close-category-picker]"),
        clearButtons: document.querySelector("[data-clear-category-picker]"),
        companyCode: workspace.companyCode,
        defaultLabel: "전체 분류",
        onChange: () => void loadCandidates(0),
    });

    partnerPicker = window.PcsPartnerPicker.bind({
        input: partnerSelect,
        modal: partnerModal,
        search: partnerSearchInput,
        list: partnerList,
        message: partnerMessage,
        nameTarget: selectedPartnerName,
        metaTarget: selectedPartnerMeta,
        openButtons: openPartnerModalButton,
        closeButtons: closePartnerModalButtons,
        companyCode: workspace.companyCode,
        partnerRole: "CUSTOMER",
        size: 100,
        emptyName: "거래처 선택",
        emptyMeta: "출고 거래처를 검색해 선택해 주세요.",
        unavailableMessage: "선택 가능한 출고 거래처가 없습니다.",
        getMeta: partnerMeta,
        onChange: () => updateCurrentRegisterStep("1"),
    });

    const applyOutboundPrefill = async (prefill) => {
        if (!prefill?.unitId) {
            return false;
        }

        if (keywordInput) {
            keywordInput.value = prefill.keyword || "";
        }
        if (categoryFilter && prefill.categoryId) {
            categoryPicker.setValue(prefill.categoryId);
        }

        const extraParams = {};
        if (prefill.partId) {
            extraParams.partId = prefill.partId;
        }

        await loadCandidates(0, { extraParams });

        const target = latestCandidates.find((candidate) => String(candidate.unitId) === String(prefill.unitId));
        if (!target) {
            setSubmitMessage("해당 관리번호를 출고 대상에서 찾지 못했습니다.", true);
            updateCurrentRegisterStep("2");
            return true;
        }

        selectedUnits.set(Number(target.unitId), target);
        renderSelectedList();
        syncCandidateSelectionState();
        setSubmitMessage("출고할 관리번호가 선택되었습니다. 출고 거래처를 선택해 주세요.");
        focusPartnerSelection();
        return true;
    };

    const selectAllCandidates = async () => {
        const companyCode = workspace.companyCode;
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
                const data = await window.PcsApi.getData(workspace.apiUrl(`/stock/outbound-candidates?${params.toString()}`), workspace.apiOptions());
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
            window.PcsFeedback.toast(message, addedCount ? "success" : "info");
        } catch (error) {
            setSubmitMessage(error?.message || "출고 부품을 전체 선택하지 못했습니다.", true);
        } finally {
            setLoading(false);
            setSelectAllLoading(false);
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
        selectedReasons.clear();
        form.reset();
        partnerPicker.setSelected(null);
        categoryPicker.setValue("");
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
        categoryPicker.setValue("");
        if (gradeFilter) gradeFilter.value = "";
        loadCandidates(0);
    });
    keywordInput?.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
            loadCandidates(0);
        }
    });
    gradeFilter?.addEventListener("change", () => loadCandidates(0));
    prevButton?.addEventListener("click", () => loadCandidates(Math.max(0, currentPage - 1), { preserveScroll: true }));
    nextButton?.addEventListener("click", () => loadCandidates(currentPage + 1, { preserveScroll: true }));
    clearSelectionButton?.addEventListener("click", () => {
        selectedUnits = new Map();
        selectedReasons.clear();
        renderSelectedList();
        syncCandidateSelectionState();
        updateCurrentRegisterStep();
    });
    resetFormButton?.addEventListener("click", resetAll);

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
            selectedReasons.delete(partId);
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
            submitting = true;
            setSubmitDisabled(true);
            setSubmitMessage("출고 전표를 저장하는 중입니다.");
            updateCurrentRegisterStep("4");
            const result = await window.PcsApi.request(workspace.apiUrl("/stock/documents/outbounds"), {
                method: "POST",
                body: payload,
                ...workspace.apiOptions(),
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
            window.location.href = `/w/${encodeURIComponent(workspace.companyCode)}/outbound`;
        } catch (error) {
            setSubmitMessage(error?.message || "출고 전표를 저장하지 못했습니다.", true);
        } finally {
            if (!redirecting) {
                submitting = false;
                setSubmitDisabled(false);
                updateCurrentRegisterStep();
            }
        }
    });

    const initialize = async () => {
        const companyCode = workspace.companyCode;
        if (!companyCode) {
            setCandidateMessage("업체 주소가 올바르지 않습니다.");
            return;
        }
        const prefill = readOutboundPrefill();

        try {
            if (window.PcsApi.validateWorkspacePublic) {
                const valid = await window.PcsApi.validateWorkspacePublic(companyCode);
                if (!valid) {
                    return;
                }
            }
            await Promise.all([partnerPicker.load(), categoryPicker.load()]);
            renderSelectedList();
            if (prefill) {
                await applyOutboundPrefill(prefill);
                return;
            }
            await loadCandidates(0, { initial: true });
            candidateSearchStarted = false;
            updateCurrentRegisterStep("1");
        } catch (error) {
            setCandidateMessage(error?.message || "화면을 초기화하지 못했습니다.");
        }
    };

    initialize();
})();
