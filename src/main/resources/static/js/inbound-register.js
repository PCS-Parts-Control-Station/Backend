(() => {
    const lineList = document.querySelector("[data-line-list]");
    const lineCount = document.querySelector("[data-line-count]");
    const inboundForm = document.querySelector("#inbound-register-form");
    const submitMessage = document.querySelector("[data-submit-message]");
    const partResults = document.querySelector(".part-search-results");
    let partOptions = [...document.querySelectorAll("[data-part-option]")];
    const partnerIdInput = document.querySelector("[data-partner-id]");
    const openPartnerModalButton = document.querySelector("[data-open-partner-modal]");
    const partnerModal = document.querySelector("[data-partner-modal]");
    const closePartnerModalButtons = document.querySelectorAll("[data-close-partner-modal]");
    const partnerSearchInput = document.querySelector("[data-partner-search]");
    const partnerList = document.querySelector("[data-partner-list]");
    const selectedPartnerName = document.querySelector("[data-selected-partner-name]");
    const selectedPartnerMeta = document.querySelector("[data-selected-partner-meta]");
    const partnerMessage = document.querySelector("[data-partner-message]");
    const lineEmpty = document.querySelector("[data-line-empty]");
    const keywordInput = document.querySelector("[data-part-keyword]");
    const categorySelect = document.querySelector("[data-part-category]");
    const categoryLabel = document.querySelector("[data-part-category-label]");
    const openCategoryPickerButton = document.querySelector("[data-open-category-picker]");
    const categoryPickerModal = document.querySelector("[data-category-picker-modal]");
    const closeCategoryPickerButtons = document.querySelectorAll("[data-close-category-picker]");
    const clearCategoryPickerButton = document.querySelector("[data-clear-category-picker]");
    const categoryPickerSearch = document.querySelector("[data-category-picker-search]");
    const categoryPickerList = document.querySelector("[data-category-picker-list]");
    const categoryPickerMessage = document.querySelector("[data-category-picker-message]");
    const searchButton = document.querySelector("[data-part-search]");
    const partSearchMessage = document.querySelector("[data-part-search-message]");
    const selectedName = document.querySelector("[data-selected-part-name]");
    const selectedMeta = document.querySelector("[data-selected-part-meta]");
    const quantityInput = document.querySelector("[data-add-quantity]");
    const reasonInput = document.querySelector("[data-add-reason]");
    const addButton = document.querySelector("[data-add-line]");
    const partModal = document.querySelector("[data-part-modal]");
    const partModalForm = document.querySelector("[data-part-modal-form]");
    const openPartModalButton = document.querySelector("[data-open-part-modal]");
    const closePartModalButtons = document.querySelectorAll("[data-close-part-modal]");
    const partModalMessage = document.querySelector("[data-part-modal-message]");
    const newPartCategorySelect = document.querySelector("[data-new-part-category]");
    const newPartManufacturerInput = document.querySelector("[data-new-part-manufacturer]");
    const newPartNameInput = document.querySelector("[data-new-part-name]");
    const newPartModelInput = document.querySelector("[data-new-part-model]");
    const newPartSafeQuantityInput = document.querySelector("[data-new-part-safe-quantity]");
    const registerStepSections = document.querySelectorAll("[data-inbound-register-step]");
    const sideStepItems = document.querySelectorAll("[data-inbound-register-side-step]");
    const categoryLabels = {
        graphics: "그래픽카드",
        memory: "RAM",
        storage: "SSD",
        cpu: "CPU",
    };
    const CREATED_INBOUND_KEY = "pcsCreatedInboundDocument";
    let selectedPart = null;
    let partSearchStarted = false;
    let submitting = false;
    let categoryPicker = null;
    let partnerPicker = null;
    let partSearchRequestId = 0;

    if (!inboundForm || !lineList || !lineCount || !partResults || !addButton) {
        return;
    }

    const workspace = window.PcsWorkspace.createContext();
    const escapeHtml = window.PcsHtml.escape;

    const setCurrentRegisterStep = (step) => {
        const nextStep = String(step || "1");

        registerStepSections.forEach((section) => {
            const isCurrent = section.dataset.inboundRegisterStep === nextStep;
            section.classList.toggle("is-active", isCurrent);
        });

        sideStepItems.forEach((item) => {
            const isCurrent = item.dataset.inboundRegisterSideStep === nextStep;
            item.classList.toggle("is-current", isCurrent);
            if (isCurrent) {
                item.setAttribute("aria-current", "step");
            } else {
                item.removeAttribute("aria-current");
            }
        });
    };

    const hasInboundLines = () => Boolean(lineList.querySelector("[data-line-entry]"));

    const resolveCurrentRegisterStep = () => {
        if (submitting) {
            return "4";
        }
        if (hasInboundLines()) {
            return "3";
        }
        if (partSearchStarted || keywordInput.value.trim() || categorySelect.value) {
            return "2";
        }
        return "1";
    };

    const updateCurrentRegisterStep = (preferredStep = null) => {
        setCurrentRegisterStep(preferredStep || resolveCurrentRegisterStep());
    };

    const bindRegisterStepTracking = () => {
        if (!sideStepItems.length) {
            return;
        }
        updateCurrentRegisterStep();
    };

    const readPart = (option) => ({
        id: option.dataset.partId,
        name: option.dataset.partName,
        meta: option.dataset.partMeta,
        prefix: option.dataset.partPrefix,
    });

    const setPartnerMessage = (message, type = "info") => {
        if (!partnerMessage) {
            return;
        }

        partnerMessage.textContent = message;
        partnerMessage.classList.toggle("is-error", type === "error");
    };

    const partnerMeta = (partner) => {
        const code = partner.partnerCode || partner.code || "";
        const role = window.PcsLabels.partnerRoleLong(partner.partnerRole, "");
        return [code, role].filter(Boolean).join(" · ") || "공급 거래처";
    };

    const validatePartnerSelection = () => {
        if (partnerIdInput?.value) {
            setPartnerMessage("");
            return true;
        }

        setPartnerMessage("거래처를 선택해 주세요.", "error");
        openPartnerModalButton?.focus();
        updateCurrentRegisterStep("1");
        return false;
    };

    const setPartSearchMessage = (message, type = "info") => {
        if (!partSearchMessage) {
            return;
        }

        partSearchMessage.hidden = !message;
        partSearchMessage.textContent = message;
        partSearchMessage.classList.toggle("is-error", type === "error");
    };

    const normalizeListData = (data) => {
        if (Array.isArray(data)) {
            return data;
        }
        return Array.isArray(data?.content) ? data.content : [];
    };

    const dateToken = () => {
        const now = new Date();
        const year = String(now.getFullYear());
        const month = String(now.getMonth() + 1).padStart(2, "0");
        const day = String(now.getDate()).padStart(2, "0");
        return `${year}${month}${day}`;
    };

    const partPrefix = (partCode) => {
        if (!partCode) {
            return "PCS-PART";
        }
        return partCode.startsWith("PCS-")
                ? partCode.split("-").slice(0, 2).join("-")
                : `PCS-${partCode.split("-")[0] || "PART"}`;
    };

    const partMeta = (part) => {
        const manufacturer = part.manufacturer || "";
        const modelName = part.modelName || "";
        const partCode = part.partCode || "";
        const model = `${manufacturer}${modelName ? ` ${modelName}` : ""}`.trim();
        return [model, partCode].filter(Boolean).join(" · ") || "-";
    };

    const selectPart = (option) => {
        selectedPart = readPart(option);
        partOptions.forEach((partOption) => {
            const active = partOption === option;
            partOption.classList.toggle("active", active);
            const label = partOption.querySelector("[data-select-label]");
            if (label) {
                label.textContent = active ? "선택됨" : "선택";
            }
        });
        selectedName.textContent = selectedPart.name;
        selectedMeta.textContent = selectedPart.meta;
        if (partSearchStarted) {
            updateCurrentRegisterStep("2");
        }
    };

    const clearSelectedPart = () => {
        selectedPart = null;
        partOptions.forEach((partOption) => {
            partOption.classList.remove("active");
            const label = partOption.querySelector("[data-select-label]");
            if (label) {
                label.textContent = "선택";
            }
        });
        selectedName.textContent = "품목을 검색해 주세요";
        selectedMeta.textContent = "검색 결과에서 품목을 선택하면 여기에 표시됩니다.";
        quantityInput.value = "1";
        reasonInput.value = "";
        updateCurrentRegisterStep();
    };

    const serialPreview = (prefix, quantity) => {
        const count = Number(quantity) || 1;
        const createdDate = dateToken();
        const more = count > 1 ? `<em>외 ${count - 1}개</em>` : "";
        return `
            <strong>관리번호 예시</strong>
            <span>${prefix}-${createdDate}-0001</span>
            ${more}
        `;
    };

    const createPartOption = ({ id, name, meta, prefix, category, categoryLabel }) => {
        const option = document.createElement("button");
        option.className = "part-result-row";
        option.type = "button";
        option.dataset.partOption = "";
        option.dataset.partId = id;
        option.dataset.partName = name;
        option.dataset.partMeta = meta;
        option.dataset.partPrefix = prefix;
        option.dataset.partCategoryValue = category;
        option.innerHTML = `
            <strong>${escapeHtml(name)}</strong>
            <span>${escapeHtml(meta)}</span>
            <em>${escapeHtml(categoryLabel || categoryLabels[category] || "기타")}</em>
            <b data-select-label>선택</b>
        `;
        option.addEventListener("click", () => {
            partSearchStarted = true;
            selectPart(option);
        });
        return option;
    };

    const refreshLineState = () => {
        const lines = [...lineList.querySelectorAll("[data-line-entry]")];
        lineCount.textContent = `${lines.length}개 품목`;
        if (lineEmpty) {
            lineEmpty.hidden = lines.length > 0;
        }

        lines.forEach((line, index) => {
            line.querySelector("legend").textContent = `품목 ${index + 1}`;
            line.querySelector("[data-line-part-id]").name = `lines[${index}].partId`;
            line.querySelector("[data-line-quantity]").name = `lines[${index}].quantity`;
            line.querySelector("[data-line-reason]").name = `lines[${index}].reason`;
        });
    };

    const createLine = ({ id, name, meta, prefix }, quantity, reason) => {
        const line = document.createElement("fieldset");
        line.className = "line-entry";
        line.dataset.lineEntry = "";
        line.dataset.partId = id;
        line.dataset.partName = name;
        line.dataset.partMeta = meta;
        line.dataset.partPrefix = prefix;
        line.innerHTML = `
            <legend>품목</legend>
            <input type="hidden" value="${id}" data-line-part-id>
            <div class="line-entry-grid line-review-grid">
                <div class="line-part-summary">
                    <span>품목</span>
                    <strong>${escapeHtml(name)}</strong>
                    <p>${escapeHtml(meta)}</p>
                </div>
                <label>
                    <span>수량</span>
                    <input type="number" min="1" value="${quantity}" required data-line-quantity>
                </label>
                <label class="field-wide">
                    <span>품목 사유</span>
                    <input type="text" value="${escapeHtml(reason)}" data-line-reason>
                </label>
                <button class="line-delete-button" type="button" data-delete-line>삭제</button>
            </div>
            <div class="serial-preview" aria-label="관리번호 발급 예시">
                ${serialPreview(prefix, quantity)}
            </div>
        `;
        return line;
    };

    const addLine = () => {
        if (!selectedPart) {
            setPartSearchMessage("먼저 품목을 검색하고 선택해 주세요.", "error");
            return;
        }

        const quantity = Math.max(1, Number(quantityInput.value) || 1);
        const reason = reasonInput.value.trim();
        const existingLine = lineList.querySelector(`[data-line-entry][data-part-id="${selectedPart.id}"]`);

        if (existingLine) {
            const existingQuantity = existingLine.querySelector("[data-line-quantity]");
            const existingReason = existingLine.querySelector("[data-line-reason]");
            existingQuantity.value = Number(existingQuantity.value || 0) + quantity;
            if (!existingReason.value && reason) {
                existingReason.value = reason;
            }
            existingLine.querySelector(".serial-preview").innerHTML = serialPreview(selectedPart.prefix, existingQuantity.value);
            refreshLineState();
            updateCurrentRegisterStep("3");
            clearSelectedPart();
            return;
        }

        lineList.append(createLine(selectedPart, quantity, reason));
        refreshLineState();
        updateCurrentRegisterStep("3");
        clearSelectedPart();
    };

    const filterParts = ({ keepMessage = false } = {}) => {
        const keyword = keywordInput.value.trim().toLowerCase();
        const category = categorySelect.value;
        let visibleCount = 0;

        partOptions.forEach((option) => {
            const text = option.textContent.toLowerCase();
            const keywordMatched = !keyword || text.includes(keyword);
            const categoryMatched = !category || option.dataset.partCategoryValue === category;
            const hidden = !keywordMatched || !categoryMatched;
            option.hidden = hidden;
            if (!hidden) {
                visibleCount += 1;
            }
        });

        const visibleOptions = partOptions.filter((option) => !option.hidden);
        const selectedOption = selectedPart
                ? visibleOptions.find((option) => option.dataset.partId === selectedPart.id)
                : null;

        if (visibleOptions.length && !selectedOption) {
            selectPart(visibleOptions[0]);
        }

        if (!visibleOptions.length) {
            selectedPart = null;
            selectedName.textContent = "검색 결과 없음";
            selectedMeta.textContent = "검색어를 바꾸거나 품목을 새로 등록해 주세요.";
        }

        if (!keepMessage) {
            setPartSearchMessage(visibleCount ? "" : "검색 결과가 없습니다.");
        }
    };

    categoryPicker = window.PcsCategoryPicker.bind({
        input: categorySelect,
        label: categoryLabel,
        modal: categoryPickerModal,
        search: categoryPickerSearch,
        list: categoryPickerList,
        message: categoryPickerMessage,
        openButtons: openCategoryPickerButton,
        closeButtons: closeCategoryPickerButtons,
        clearButtons: clearCategoryPickerButton,
        companyCode: workspace.companyCode,
        defaultLabel: "전체 분류",
        onChange: () => {
            partSearchStarted = true;
            updateCurrentRegisterStep("2");
            filterParts();
        }
    });

    partnerPicker = window.PcsPartnerPicker.bind({
        input: partnerIdInput,
        modal: partnerModal,
        search: partnerSearchInput,
        list: partnerList,
        message: partnerMessage,
        nameTarget: selectedPartnerName,
        metaTarget: selectedPartnerMeta,
        openButtons: openPartnerModalButton,
        closeButtons: closePartnerModalButtons,
        companyCode: workspace.companyCode,
        partnerRole: "SUPPLIER",
        size: 100,
        emptyName: "거래처 선택",
        unavailableMessage: "선택 가능한 공급 거래처가 없습니다.",
        getMeta: partnerMeta,
        onChange: () => updateCurrentRegisterStep("1")
    });

    const renderPartOptions = (parts) => {
        partOptions.forEach((option) => option.remove());
        partOptions = normalizeListData(parts).map((part) => createPartOption({
            id: String(part.partId),
            name: part.partName,
            meta: partMeta(part),
            prefix: partPrefix(part.partCode),
            category: String(part.categoryId || ""),
            categoryLabel: part.categoryName,
        }));
        partOptions.forEach((option) => partResults.append(option));

        if (partOptions.length) {
            setPartSearchMessage(`${partOptions.length}개 품목을 찾았습니다.`);
            selectPart(partOptions[0]);
            return;
        }

        setPartSearchMessage("검색 결과가 없습니다.");
        selectedPart = null;
        selectedName.textContent = "검색 결과 없음";
        selectedMeta.textContent = "검색어를 바꾸거나 품목을 새로 등록해 주세요.";
    };

    const searchParts = async () => {
        partSearchStarted = true;
        updateCurrentRegisterStep("2");
        const params = new URLSearchParams({
            active: "true",
            limit: "100",
        });
        const keyword = keywordInput.value.trim();
        const categoryId = categorySelect.value;

        if (keyword) params.set("keyword", keyword);
        if (/^\d+$/.test(categoryId)) params.set("categoryId", categoryId);

        if (!workspace.companyCode) {
            setPartSearchMessage("업체 코드를 확인할 수 없습니다.", "error");
            return;
        }

        const requestId = ++partSearchRequestId;
        searchButton.disabled = true;
        setPartSearchMessage("품목을 검색하는 중입니다.");
        try {
            const parts = await window.PcsApi.getData(
                workspace.apiUrl(`/parts?${params.toString()}`),
                workspace.apiOptions()
            );
            if (requestId !== partSearchRequestId) {
                return;
            }
            renderPartOptions(parts);
        } catch (error) {
            if (requestId !== partSearchRequestId) {
                return;
            }
            setPartSearchMessage(error.message || "품목 검색 요청을 처리할 수 없습니다.", "error");
        } finally {
            if (requestId === partSearchRequestId) {
                searchButton.disabled = false;
            }
        }
    };

    const renderCategories = (categories) => {
        const normalizedCategories = normalizeListData(categories);
        categoryPicker?.setValue("");
        if (openCategoryPickerButton) {
            openCategoryPickerButton.disabled = normalizedCategories.length === 0;
            openCategoryPickerButton.title = normalizedCategories.length === 0 ? "등록된 분류가 없습니다." : "";
        }
        if (newPartCategorySelect) {
            newPartCategorySelect.innerHTML = '<option value="">분류 선택</option>';
            normalizedCategories.forEach((category) => {
                newPartCategorySelect.append(new Option(category.categoryName || "-", String(category.categoryId)));
            });
            newPartCategorySelect.disabled = normalizedCategories.length === 0;
        }
        if (openPartModalButton) {
            openPartModalButton.disabled = normalizedCategories.length === 0;
            openPartModalButton.title = normalizedCategories.length === 0 ? "등록된 분류가 필요합니다." : "";
        }
    };

    const appendAndSelectPart = (part) => {
        if (keywordInput) {
            keywordInput.value = "";
        }
        if (categorySelect && part.categoryId) {
            categoryPicker?.setValue(String(part.categoryId));
        }
        const option = createPartOption({
            id: String(part.partId),
            name: part.partName,
            meta: partMeta(part),
            prefix: partPrefix(part.partCode),
            category: String(part.categoryId || ""),
            categoryLabel: part.categoryName,
        });
        partResults.append(option);
        partOptions.push(option);
        selectPart(option);
        filterParts({ keepMessage: true });
    };

    const setPartModalMessage = (message, isError = false) => {
        if (!partModalMessage) {
            return;
        }
        partModalMessage.hidden = !message;
        partModalMessage.textContent = message || "";
        partModalMessage.classList.toggle("is-error", isError);
    };

    const setPartModalDisabled = (disabled) => {
        partModalForm?.querySelectorAll("input, select, button").forEach((element) => {
            element.disabled = disabled;
        });
    };

    const createQuickPart = async () => {
        if (!partModalForm?.reportValidity()) {
            return;
        }
        if (!workspace.companyCode) {
            setPartModalMessage("업체 코드를 확인할 수 없습니다.", true);
            return;
        }

        const body = {
            categoryId: Number(newPartCategorySelect.value),
            partName: newPartNameInput.value.trim(),
            manufacturer: newPartManufacturerInput.value.trim(),
            modelName: newPartModelInput.value.trim(),
            safeQuantity: Math.max(0, Number(newPartSafeQuantityInput.value) || 0),
            specValues: []
        };

        setPartModalDisabled(true);
        setPartModalMessage("품목을 등록하는 중입니다.");
        try {
            const result = await window.PcsApi.request(
                workspace.apiUrl("/parts"),
                workspace.apiOptions({ method: "POST", body })
            );
            const part = result?.data;
            if (!part?.partId) {
                throw new Error("등록된 품목 정보를 확인할 수 없습니다.");
            }
            partSearchStarted = true;
            appendAndSelectPart(part);
            setPartSearchMessage("새 품목을 등록하고 선택했습니다.");
            updateCurrentRegisterStep("2");
            partModalForm.reset();
            setPartModalMessage("");
            partModal?.close();
        } catch (error) {
            setPartModalMessage(error.message || "품목을 등록하지 못했습니다.", true);
        } finally {
            setPartModalDisabled(false);
        }
    };

    const loadCategories = async () => {
        if (!categorySelect && !newPartCategorySelect) {
            return;
        }

        if (!workspace.companyCode) {
            if (openCategoryPickerButton) {
                openCategoryPickerButton.disabled = true;
                openCategoryPickerButton.title = "분류 목록을 불러올 수 없습니다.";
            }
            if (newPartCategorySelect) {
                newPartCategorySelect.innerHTML = '<option value="">분류 조회 불가</option>';
                newPartCategorySelect.disabled = true;
            }
            if (openPartModalButton) {
                openPartModalButton.disabled = true;
                openPartModalButton.title = "분류 목록을 불러올 수 없습니다.";
            }
            return;
        }

        if (openCategoryPickerButton) {
            openCategoryPickerButton.disabled = true;
            openCategoryPickerButton.title = "분류 목록을 불러오는 중입니다.";
        }
        if (newPartCategorySelect) {
            newPartCategorySelect.disabled = true;
            newPartCategorySelect.innerHTML = '<option value="">분류 불러오는 중</option>';
        }
        if (openPartModalButton) {
            openPartModalButton.disabled = true;
            openPartModalButton.title = "분류 목록을 불러오는 중입니다.";
        }

        const categories = await categoryPicker.load();
        const loadError = categoryPickerMessage?.textContent.trim() || "";
        renderCategories(categories);
        if (loadError) {
            if (openCategoryPickerButton) {
                openCategoryPickerButton.disabled = true;
                openCategoryPickerButton.title = "분류 목록을 불러올 수 없습니다.";
            }
            if (newPartCategorySelect) {
                newPartCategorySelect.innerHTML = '<option value="">분류 조회 실패</option>';
                newPartCategorySelect.disabled = true;
            }
            if (openPartModalButton) {
                openPartModalButton.disabled = true;
                openPartModalButton.title = "분류 목록을 불러올 수 없습니다.";
            }
            setPartSearchMessage(loadError, "error");
        }
    };

    partOptions.forEach((option) => {
        option.addEventListener("click", () => {
            partSearchStarted = true;
            selectPart(option);
        });
    });

    searchButton.addEventListener("click", searchParts);
    keywordInput.addEventListener("input", () => {
        partSearchStarted = true;
        updateCurrentRegisterStep("2");
        filterParts();
    });
    keywordInput.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
            searchParts();
        }
    });
    addButton.addEventListener("click", addLine);

    lineList.addEventListener("click", (event) => {
        const deleteButton = event.target.closest("[data-delete-line]");
        if (!deleteButton) {
            return;
        }
        deleteButton.closest("[data-line-entry]").remove();
        refreshLineState();
        updateCurrentRegisterStep();
    });

    lineList.addEventListener("input", (event) => {
        const quantity = event.target.closest("[data-line-quantity]");
        if (!quantity) {
            return;
        }
        const line = quantity.closest("[data-line-entry]");
        line.querySelector(".serial-preview").innerHTML = serialPreview(line.dataset.partPrefix, quantity.value);
        updateCurrentRegisterStep("3");
    });

    inboundForm.elements.reason?.addEventListener("input", () => updateCurrentRegisterStep());

    const setSubmitMessage = (message, isError = false) => {
        if (!submitMessage) {
            return;
        }
        submitMessage.textContent = message;
        submitMessage.classList.toggle("is-error", isError);
    };

    const setSubmitDisabled = (disabled) => {
        const submitButtons = [
            ...inboundForm.querySelectorAll('button[type="submit"]'),
            ...document.querySelectorAll('button[type="submit"][form="inbound-register-form"]'),
        ];
        submitButtons.forEach((button) => {
            button.disabled = disabled;
        });
    };

    const buildInboundPayload = () => {
        const lineEntries = [...lineList.querySelectorAll("[data-line-entry]")];
        return {
            partnerId: Number(inboundForm.elements.partnerId.value),
            reason: inboundForm.elements.reason.value.trim(),
            lines: lineEntries.map((line) => ({
                partId: Number(line.querySelector("[data-line-part-id]").value),
                quantity: Number(line.querySelector("[data-line-quantity]").value),
                reason: line.querySelector("[data-line-reason]").value.trim() || null,
            })),
        };
    };

    const inboundSummary = (payload) => {
        const totalQuantity = payload.lines.reduce((sum, line) => sum + line.quantity, 0);
        return {
            partnerName: partnerPicker.getSelected()?.partnerName || "-",
            totalQuantity,
        };
    };

    const submitInbound = async ({ companyCode, payload }) => {
        let redirecting = false;
        const summary = inboundSummary(payload);

        submitting = true;
        setSubmitDisabled(true);
        setSubmitMessage("입고를 저장하는 중입니다.");
        updateCurrentRegisterStep("4");

        try {
            const result = await window.PcsApi.request(
                `/api/workspaces/${encodeURIComponent(companyCode)}/stock/documents/inbounds`,
                workspace.apiOptions({ method: "POST", body: payload })
            );

            const documentNo = result?.data?.documentNo;
            const successMessage = documentNo
                    ? `입고 전표 ${documentNo} 가 등록되었습니다.`
                    : "입고 전표가 등록되었습니다.";

            if (documentNo) {
                try {
                    window.sessionStorage.setItem(CREATED_INBOUND_KEY, JSON.stringify({
                        documentNo,
                        partnerName: summary.partnerName,
                        quantity: summary.totalQuantity
                    }));
                } catch (error) {
                    // Storage can be blocked in private or restricted browser modes.
                }
            }

            window.PcsUi?.setFlashToast({
                message: successMessage,
                type: "success",
                duration: 3000
            });

            setSubmitMessage(documentNo ? `입고 저장 완료: ${documentNo}` : "입고 저장이 완료되었습니다.");
            redirecting = true;
            window.location.href = `/w/${encodeURIComponent(companyCode)}/inbound`;
        } catch (error) {
            setSubmitMessage(error.message || "입고 저장 요청을 처리할 수 없습니다.", true);
        } finally {
            submitting = false;
            if (!redirecting) {
                setSubmitDisabled(false);
                updateCurrentRegisterStep();
            }
        }
    };

    inboundForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        setSubmitMessage("");

        if (!validatePartnerSelection()) {
            return;
        }

        if (!inboundForm.reportValidity()) {
            return;
        }

        const companyCode = workspace.companyCode;
        const payload = buildInboundPayload();

        if (!companyCode) {
            setSubmitMessage("업체 코드를 확인할 수 없습니다.", true);
            return;
        }
        if (!payload.lines.length) {
            setSubmitMessage("입고 품목을 1개 이상 추가해 주세요.", true);
            return;
        }

        updateCurrentRegisterStep("4");
        void submitInbound({ companyCode, payload });
    });

    openPartModalButton?.addEventListener("click", () => {
        setPartModalMessage("");
        partModal?.showModal();
    });

    closePartModalButtons.forEach((button) => {
        button.addEventListener("click", () => {
            partModal?.close();
        });
    });

    partModal?.addEventListener("click", (event) => {
        if (event.target === partModal) {
            partModal.close();
        }
    });

    partModalForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        void createQuickPart();
    });

    if (partOptions.length) {
        selectPart(partOptions[0]);
    } else {
        setPartSearchMessage("검색 버튼을 눌러 품목을 조회하세요.");
    }
    void loadCategories();
    void partnerPicker.load();
    refreshLineState();
    bindRegisterStepTracking();
})();
