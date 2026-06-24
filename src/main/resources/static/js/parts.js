(function () {
    const PAGE_SIZE = 10;

    const filterForm = document.querySelector("[data-part-filter-form]");
    const table = document.querySelector("[data-part-table]");
    const pagination = document.querySelector("[data-part-pagination]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const searchButton = filterForm?.querySelector("button[type='submit']");
    const panelViews = document.querySelectorAll("[data-part-panel]");
    const detailDrawer = document.querySelector("[data-part-detail-drawer]");
    const createDrawerButtons = document.querySelectorAll("[data-part-create-drawer]");
    const createDrawerButton = createDrawerButtons[0] || null;
    const closeDrawerButtons = document.querySelectorAll("[data-close-part-drawer]");
    const createForm = document.querySelector("[data-part-create-form]");
    const editForm = document.querySelector("[data-part-edit-form]");
    const specModal = document.querySelector("[data-part-spec-modal]");
    const specModalForm = document.querySelector("[data-part-spec-modal-form]");
    const specModalMessage = document.querySelector("[data-part-spec-modal-message]");
    const specModalCategory = document.querySelector("[data-spec-modal-category]");
    const specFieldsContainer = document.querySelector("[data-part-spec-fields]");
    const createSpecSummary = document.querySelector("[data-create-spec-summary]");
    const editSpecSummary = document.querySelector("[data-edit-spec-summary]");
    const categoryPickerModal = document.querySelector("[data-category-picker-modal]");
    const categoryPickerSearch = document.querySelector("[data-category-picker-search]");
    const categoryPickerList = document.querySelector("[data-category-picker-list]");
    const categoryPickerMessage = document.querySelector("[data-category-picker-message]");
    const clearCategoryPickerButton = document.querySelector("[data-clear-category-picker]");
    const categoryPickerInputs = {
        filter: filterForm?.elements.categoryId,
        create: createForm?.elements.categoryId,
        edit: editForm?.elements.categoryId
    };
    const categoryPickerLabels = {
        filter: document.querySelector("[data-filter-category-label]"),
        create: document.querySelector("[data-create-category-label]"),
        edit: document.querySelector("[data-edit-category-label]")
    };
    const detailFields = {
        name: document.querySelector("[data-detail-name]"),
        category: document.querySelector("[data-detail-category]"),
        code: document.querySelector("[data-detail-code]"),
        manufacturer: document.querySelector("[data-detail-manufacturer]"),
        model: document.querySelector("[data-detail-model]"),
        stock: document.querySelector("[data-detail-stock]"),
        safeQuantity: document.querySelector("[data-detail-safe-quantity]"),
        specs: document.querySelector("[data-detail-specs]")
    };
    const summaryFields = {
        total: document.querySelector("[data-summary-total]"),
        stock: document.querySelector("[data-summary-stock]"),
        lowStock: document.querySelector("[data-summary-low-stock]")
    };

    const createEmptyDetailState = () => ({
        categoryId: "",
        safeQuantity: 0,
        specValues: []
    });

    let currentPage = 0;
    let currentParts = [];
    let selectedPartId = null;
    let lastDrawerTrigger = null;
    let categoryOptions = [];
    const categoryDetails = new Map();
    const detailStateByMode = {
        create: createEmptyDetailState(),
        edit: createEmptyDetailState()
    };
    let activeSpecModalMode = "create";
    let activeCategoryPickerMode = "filter";

    const getCompanyCode = window.PcsWorkspace.getCompanyCode;
    const numberText = window.PcsFormat.number;

    const getCurrentStock = (part) => Number(part?.currentStockQuantity ?? part?.stockQuantity ?? 0);

    const getSafeQuantity = (part) => Number(part?.safeQuantity ?? 0);

    const isLowStock = (part) => {
        const safeQuantity = getSafeQuantity(part);
        return safeQuantity > 0 && getCurrentStock(part) < safeQuantity;
    };

    const normalizeString = (value) => (value === null || value === undefined ? "" : String(value));

    const normalizeSpecValue = (value) => ({
        specDefinitionId: Number(value?.specDefinitionId),
        specName: value?.specName || "",
        inputType: value?.inputType || "",
        unit: value?.unit || "",
        valueText: value?.valueText ?? "",
        valueNumber: value?.valueNumber ?? null,
        valueBoolean: value?.valueBoolean ?? null,
        selectedOptionId: value?.selectedOptionId ?? null,
        selectedOptionLabel: value?.selectedOptionLabel ?? value?.selectedOptionLabelSnapshot ?? "",
        selectedOptionValue: value?.selectedOptionValue ?? value?.selectedOptionValueSnapshot ?? ""
    });

    const getCategoryById = (categoryId) => categoryOptions.find((item) => String(item.categoryId) === String(categoryId));

    const getCategoryNameById = (categoryId) => {
        const category = getCategoryById(categoryId);
        return category ? category.categoryName : "-";
    };

    const getPartCategoryName = (part) => part?.categoryName || getCategoryNameById(part?.categoryId);

    const getModeForm = (mode) => (mode === "edit" ? editForm : createForm);

    const getDetailState = (mode) => detailStateByMode[mode] || detailStateByMode.create;

    const syncCategoryLabel = (mode) => {
        const input = categoryPickerInputs[mode];
        const label = categoryPickerLabels[mode];
        if (!input || !label) {
            return;
        }

        if (!input.value) {
            label.textContent = mode === "filter" ? "전체" : "선택";
            return;
        }

        label.textContent = getCategoryNameById(input.value);
    };

    const syncAllCategoryLabels = () => {
        ["filter", "create", "edit"].forEach(syncCategoryLabel);
    };

    const setCategoryValue = (mode, categoryId, options = {}) => {
        const input = categoryPickerInputs[mode];
        if (!input) {
            return;
        }

        const nextValue = normalizeString(categoryId);
        const previousValue = input.value;
        input.value = nextValue;
        syncCategoryLabel(mode);

        if (options.resetDetail !== false && (mode === "create" || mode === "edit") && previousValue !== nextValue) {
            resetDetailStateForCategory(mode, nextValue);
        }
    };

    const matchesCategoryKeyword = (category, keyword) => {
        if (!keyword) {
            return true;
        }

        const target = `${category.categoryName || ""} ${category.description || ""}`.toLowerCase();
        return target.includes(keyword.toLowerCase());
    };

    const createCategoryPickerOption = (category, selectedCategoryId) => {
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
            setCategoryValue(activeCategoryPickerMode, category.categoryId);
            closeCategoryPicker();
        });

        return button;
    };

    const renderCategoryPickerList = () => {
        if (!categoryPickerList) {
            return;
        }

        const keyword = categoryPickerSearch?.value.trim() || "";
        const selectedCategoryId = categoryPickerInputs[activeCategoryPickerMode]?.value || "";
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
            categoryPickerList.append(createCategoryPickerOption(category, selectedCategoryId));
        });
    };

    const openCategoryPicker = (mode) => {
        if (!categoryPickerModal) {
            return;
        }

        activeCategoryPickerMode = mode;
        if (categoryPickerSearch) {
            categoryPickerSearch.value = "";
        }
        if (categoryPickerMessage) {
            categoryPickerMessage.textContent = "";
        }
        if (clearCategoryPickerButton) {
            clearCategoryPickerButton.hidden = mode !== "filter";
        }
        renderCategoryPickerList();
        categoryPickerModal.showModal();
        window.setTimeout(() => categoryPickerSearch?.focus(), 0);
    };

    const closeCategoryPicker = () => {
        if (categoryPickerMessage) {
            categoryPickerMessage.textContent = "";
        }
        categoryPickerModal?.close();
    };

    const validateCategorySelection = (mode) => {
        if (categoryPickerInputs[mode]?.value) {
            return true;
        }

        showToast("분류를 선택해 주세요.", "error");
        openCategoryPicker(mode);
        return false;
    };

    const clearRows = () => window.PcsTable.clearRows(table);
    const setEmptyMessage = (message) => window.PcsTable.emptyRow(table, {
        rowClassName: "data-row management-data-row part-management-data-row empty-data-row",
        message
    });

    const createStackedCell = (label, primary, secondary, className = "part-meta-cell") => {
        const cell = document.createElement("span");
        const primaryText = primary || "-";
        const secondaryText = secondary || "";
        cell.className = className;
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", label);
        cell.title = secondaryText ? `${primaryText} / ${secondaryText}` : primaryText;

        const primaryElement = document.createElement("strong");
        primaryElement.textContent = primaryText;
        cell.append(primaryElement);

        if (secondaryText) {
            const secondaryElement = document.createElement("small");
            secondaryElement.textContent = secondaryText;
            cell.append(secondaryElement);
        }

        return cell;
    };

    const createTextCell = window.PcsTable.textCell;

    const createQuantityCell = (label, value, secondary = "", low = false) => {
        const cell = document.createElement("span");
        cell.className = "quantity-cell";
        cell.classList.toggle("is-low", low);
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", label);

        const valueElement = document.createElement("strong");
        valueElement.textContent = `${numberText(value)}개`;
        cell.append(valueElement);

        if (secondary) {
            const secondaryElement = document.createElement("small");
            secondaryElement.textContent = secondary;
            cell.append(secondaryElement);
        }

        return cell;
    };

    const setDrawerOpen = (isOpen) => {
        detailDrawer?.classList.toggle("is-open", isOpen);
        detailDrawer?.setAttribute("aria-hidden", String(!isOpen));
        createDrawerButtons.forEach((button) => {
            button.setAttribute("aria-expanded", String(isOpen));
        });
    };

    const openDrawer = (trigger = null) => {
        if (trigger instanceof HTMLElement) {
            lastDrawerTrigger = detailDrawer?.contains(trigger) ? createDrawerButton : trigger;
        }
        setDrawerOpen(true);
    };

    const closeDrawer = (options = {}) => {
        selectedPartId = null;
        setDrawerOpen(false);
        updateSelectedRow();
        if (options.restoreFocus !== false && lastDrawerTrigger?.isConnected) {
            lastDrawerTrigger.focus({ preventScroll: true });
        }
    };

    const setPanelMode = (mode) => {
        panelViews.forEach((panel) => {
            const isActive = panel.dataset.partPanel === mode;
            panel.hidden = !isActive;
            panel.classList.toggle("is-active", isActive);
        });
        const titleIds = {
            create: "part-form-title",
            detail: "part-detail-title",
            edit: "part-edit-title"
        };
        detailDrawer?.setAttribute("aria-labelledby", titleIds[mode] || titleIds.create);
    };

    const getSelectedPart = () => {
        return currentParts.find((part) => String(part.partId) === String(selectedPartId)) || null;
    };

    const replaceCurrentPart = (part) => {
        if (!part?.partId) {
            return;
        }

        const index = currentParts.findIndex((item) => String(item.partId) === String(part.partId));
        if (index >= 0) {
            currentParts[index] = {
                ...currentParts[index],
                ...part
            };
        }
    };

    const updateSelectedRow = () => {
        table?.querySelectorAll("[data-part-id]").forEach((row) => {
            const isSelected = String(row.dataset.partId) === String(selectedPartId);
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
        });
    };

    const formatSpecValue = (value) => {
        const normalized = normalizeSpecValue(value);
        if (normalized.selectedOptionLabel) {
            return normalized.selectedOptionLabel;
        }
        if (normalized.valueBoolean !== null && normalized.valueBoolean !== undefined) {
            return normalized.valueBoolean ? "예" : "아니오";
        }
        if (normalized.valueNumber !== null && normalized.valueNumber !== undefined) {
            return `${numberText(normalized.valueNumber)}${normalized.unit || ""}`;
        }
        if (normalized.valueText) {
            return `${normalized.valueText}${normalized.unit || ""}`;
        }
        return "";
    };

    const summarizeSpecValues = (specValues = []) => {
        const summaries = specValues
                .map(normalizeSpecValue)
                .map((value) => {
                    const text = formatSpecValue(value);
                    return text ? `${value.specName || "사양"} ${text}` : "";
                })
                .filter(Boolean);

        if (!summaries.length) {
            return "-";
        }
        return summaries.slice(0, 3).join(" · ") + (summaries.length > 3 ? ` 외 ${summaries.length - 3}개` : "");
    };

    const updateDetailSummary = (mode) => {
        const state = getDetailState(mode);
        const target = mode === "edit" ? editSpecSummary : createSpecSummary;
        if (!target) {
            return;
        }

        const parts = [];
        if (Number(state.safeQuantity) > 0) {
            parts.push(`안전 재고 ${numberText(state.safeQuantity)}개`);
        }
        const specCount = (state.specValues || []).filter((value) => formatSpecValue(value)).length;
        if (specCount > 0) {
            parts.push(`사양 ${specCount}개`);
        }

        target.textContent = parts.length ? parts.join(", ") : "안전 재고, 사양 항목";
    };

    const renderDetail = (part) => {
        if (!part) {
            return;
        }

        detailFields.name.textContent = part.partName || "-";
        detailFields.category.textContent = getPartCategoryName(part);
        if (detailFields.code) {
            detailFields.code.textContent = part.partCode || "자동 생성";
        }
        detailFields.manufacturer.textContent = part.manufacturer || "-";
        detailFields.model.textContent = part.modelName || "-";
        detailFields.stock.textContent = `${numberText(getCurrentStock(part))}개`;
        detailFields.safeQuantity.textContent = `${numberText(getSafeQuantity(part))}개`;
        if (detailFields.specs) {
            detailFields.specs.textContent = summarizeSpecValues(part.specValues || []);
        }
    };

    const resetDetailStateForCategory = (mode, categoryId) => {
        const previous = getDetailState(mode);
        detailStateByMode[mode] = {
            categoryId: normalizeString(categoryId),
            safeQuantity: previous.safeQuantity || 0,
            specValues: []
        };
        updateDetailSummary(mode);
    };

    const fillEditForm = (part) => {
        if (!editForm || !part) {
            return;
        }
        setCategoryValue("edit", part.categoryId || "", { resetDetail: false });
        editForm.elements.partName.value = part.partName || "";
        editForm.elements.manufacturer.value = part.manufacturer || "";
        editForm.elements.modelName.value = part.modelName || "";
        detailStateByMode.edit = {
            categoryId: normalizeString(part.categoryId),
            safeQuantity: Number(part.safeQuantity ?? 0),
            specValues: (part.specValues || []).map(normalizeSpecValue)
        };
        updateDetailSummary("edit");
    };

    const showToast = window.PcsFeedback.toast;

    const fetchPartDetail = async (partId) => {
        const companyCode = getCompanyCode();
        return window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/parts/${partId}`,
                {
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
        );
    };

    const selectPart = async (partId, trigger = null) => {
        selectedPartId = partId;
        openDrawer(trigger);
        const part = getSelectedPart();
        updateSelectedRow();
        if (part) {
            renderDetail(part);
            setPanelMode("detail");
        }

        try {
            const detail = await fetchPartDetail(partId);
            replaceCurrentPart(detail);
            if (String(selectedPartId) === String(partId)) {
                renderDetail(detail);
                setPanelMode("detail");
            }
        } catch (error) {
            showToast(error?.message || "품목 상세 정보를 불러오지 못했습니다.", "error");
        }
    };

    const showCreatePanel = (trigger = null, options = {}) => {
        selectedPartId = null;
        updateSelectedRow();
        createForm?.reset();
        setCategoryValue("create", "", { resetDetail: false });
        detailStateByMode.create = createEmptyDetailState();
        updateDetailSummary("create");
        setPanelMode("create");
        if (options.open !== false) {
            openDrawer(trigger);
        }
    };

    const renderSummary = (pageData) => {
        if (!summaryFields.total || !pageData) {
            return;
        }

        const summary = pageData.summary || {};
        const totalStock = summary.totalStock ?? 0;
        const lowStockCount = summary.lowStockCount ?? 0;

        summaryFields.total.textContent = numberText(summary.totalCount ?? pageData.totalElements ?? 0);
        summaryFields.stock.textContent = numberText(totalStock);
        summaryFields.lowStock.textContent = numberText(lowStockCount);
    };

    const renderRows = (items) => {
        clearRows();
        currentParts = items;

        if (!items.length) {
            setEmptyMessage("조회된 품목이 없습니다.");
            showCreatePanel(null, { open: false });
            return;
        }

        items.forEach((part) => {
            const row = document.createElement("div");
            const currentStock = getCurrentStock(part);
            const safeQuantity = getSafeQuantity(part);
            const lowStock = isLowStock(part);

            row.className = "data-row management-data-row part-management-data-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.dataset.partId = String(part.partId);

            row.append(
                    createStackedCell("품목명", part.partName, part.partCode || "", "part-primary-cell"),
                    createStackedCell("제조사 / 제조사 모델명", part.manufacturer, part.modelName),
                    createTextCell("분류", getPartCategoryName(part)),
                    createQuantityCell("현재 재고", currentStock, lowStock ? "재고 부족" : ""),
                    createQuantityCell("안전 재고", safeQuantity, "", lowStock)
            );

            row.addEventListener("click", () => selectPart(part.partId, row));
            row.addEventListener("keydown", (event) => {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    selectPart(part.partId, row);
                }
            });

            table.append(row);
        });

        if (getSelectedPart()) {
            renderDetail(getSelectedPart());
            updateSelectedRow();
        } else {
            showCreatePanel(null, { open: false });
        }
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

    const buildParams = (page) => {
        return window.PcsPagination.buildParams({
            page,
            size: PAGE_SIZE,
            form: filterForm
        });
    };

    const setLoading = (isLoading) => {
        if (!searchButton) {
            return;
        }
        searchButton.disabled = isLoading;
        searchButton.textContent = isLoading ? "조회 중" : "검색";
    };

    const setFormSaving = window.PcsForm.setSaving;

    const readNumberValue = (value) => {
        if (value === undefined || value === null || value === "") {
            return 0;
        }
        const number = Number(value);
        return Number.isFinite(number) ? number : 0;
    };

    const getCategoryDetail = async (categoryId) => {
        const normalizedCategoryId = normalizeString(categoryId);
        if (!normalizedCategoryId) {
            return null;
        }
        if (categoryDetails.has(normalizedCategoryId)) {
            return categoryDetails.get(normalizedCategoryId);
        }

        const companyCode = getCompanyCode();
        const detail = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/categories/${encodeURIComponent(normalizedCategoryId)}`,
                {
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
        );
        categoryDetails.set(normalizedCategoryId, detail);
        return detail;
    };

    const findStoredSpecValue = (state, specDefinitionId) => {
        return (state.specValues || []).find((value) => {
            return String(value.specDefinitionId) === String(specDefinitionId);
        }) || null;
    };

    const createSpecInput = (definition, storedValue) => {
        const label = document.createElement("label");
        label.dataset.specDefinitionId = String(definition.specDefinitionId);
        label.dataset.inputType = definition.inputType;

        const title = document.createElement("span");
        title.textContent = definition.specName || "사양 항목";
        if (!definition.required) {
            const optional = document.createElement("em");
            optional.className = "field-optional";
            optional.textContent = "선택";
            title.append(" ", optional);
        }
        label.append(title);

        if (definition.inputType === "SELECT") {
            const select = document.createElement("select");
            select.name = `spec_${definition.specDefinitionId}`;
            select.required = Boolean(definition.required);
            select.innerHTML = '<option value="">선택</option>';
            (definition.options || []).forEach((option) => {
                const optionElement = document.createElement("option");
                optionElement.value = option.optionId;
                optionElement.textContent = option.optionLabel;
                select.append(optionElement);
            });
            select.value = normalizeString(storedValue?.selectedOptionId);
            label.append(select);
            return label;
        }

        if (definition.inputType === "NUMBER") {
            const input = document.createElement("input");
            input.type = "number";
            input.name = `spec_${definition.specDefinitionId}`;
            input.step = "any";
            input.required = Boolean(definition.required);
            input.placeholder = definition.unit ? `${definition.unit} 단위 입력` : "숫자 입력";
            input.value = storedValue?.valueNumber ?? "";
            label.append(input);
            return label;
        }

        if (definition.inputType === "BOOLEAN") {
            const row = document.createElement("label");
            row.className = "switch-row spec-switch-row";
            row.dataset.specDefinitionId = String(definition.specDefinitionId);
            row.dataset.inputType = definition.inputType;

            const checkbox = document.createElement("input");
            checkbox.type = "checkbox";
            checkbox.name = `spec_${definition.specDefinitionId}`;
            checkbox.checked = Boolean(storedValue?.valueBoolean);
            const text = document.createElement("span");
            text.textContent = definition.specName || "사양 항목";
            row.append(checkbox, text);
            return row;
        }

        const input = document.createElement("input");
        input.type = "text";
        input.name = `spec_${definition.specDefinitionId}`;
        input.required = Boolean(definition.required);
        input.placeholder = definition.unit ? `${definition.unit} 단위 입력` : "값 입력";
        input.value = storedValue?.valueText || "";
        label.append(input);
        return label;
    };

    const renderSpecFields = async (mode, categoryId) => {
        const state = getDetailState(mode);
        const detail = await getCategoryDetail(categoryId);
        const definitions = detail?.specDefinitions || [];

        if (specModalCategory) {
            specModalCategory.textContent = detail?.categoryName
                    ? `${detail.categoryName} 사양 항목`
                    : "분류 사양 항목";
        }

        specFieldsContainer.innerHTML = "";
        if (!definitions.length) {
            const empty = document.createElement("p");
            empty.className = "spec-builder-empty";
            empty.textContent = "이 분류에는 입력할 사양 항목이 없습니다.";
            specFieldsContainer.append(empty);
            return;
        }

        definitions.forEach((definition) => {
            specFieldsContainer.append(createSpecInput(
                    definition,
                    findStoredSpecValue(state, definition.specDefinitionId)
            ));
        });
    };

    const openSpecModal = async (mode) => {
        const form = getModeForm(mode);
        const categoryId = form?.elements.categoryId.value;
        if (!categoryId) {
            showToast("분류를 먼저 선택해 주세요.", "error");
            openCategoryPicker(mode);
            return;
        }

        activeSpecModalMode = mode;
        const state = getDetailState(mode);
        if (state.categoryId !== normalizeString(categoryId)) {
            resetDetailStateForCategory(mode, categoryId);
        }

        specModalMessage.textContent = "";
        specModalForm.elements.safeQuantity.value = state.safeQuantity || "";

        try {
            await renderSpecFields(mode, categoryId);
            specModal.showModal();
        } catch (error) {
            showToast(error?.message || "분류 사양 항목을 불러오지 못했습니다.", "error");
        }
    };

    const closeSpecModal = () => {
        specModalMessage.textContent = "";
        specModal.close();
    };

    const readRenderedSpecValues = () => {
        const values = [];
        const definitions = specFieldsContainer.querySelectorAll("[data-spec-definition-id]");

        for (const field of definitions) {
            const specDefinitionId = Number(field.dataset.specDefinitionId);
            const inputType = field.dataset.inputType;
            const definitionName = field.querySelector("span")?.childNodes?.[0]?.textContent?.trim() || "사양 항목";
            const control = field.querySelector("input, select");
            const required = Boolean(control?.required);

            if (inputType === "BOOLEAN") {
                values.push({
                    specDefinitionId,
                    valueBoolean: Boolean(control?.checked)
                });
                continue;
            }

            const rawValue = control?.value?.trim() || "";
            if (!rawValue) {
                if (required) {
                    throw new Error(`${definitionName} 값을 입력해 주세요.`);
                }
                continue;
            }

            if (inputType === "SELECT") {
                values.push({
                    specDefinitionId,
                    selectedOptionId: Number(rawValue)
                });
                continue;
            }

            if (inputType === "NUMBER") {
                const number = Number(rawValue);
                if (!Number.isFinite(number)) {
                    throw new Error(`${definitionName} 값은 숫자로 입력해 주세요.`);
                }
                values.push({
                    specDefinitionId,
                    valueNumber: number
                });
                continue;
            }

            values.push({
                specDefinitionId,
                valueText: rawValue
            });
        }

        return values;
    };

    const readPartForm = (targetForm, mode) => {
        const categoryId = targetForm.elements.categoryId.value || null;
        const state = getDetailState(mode);

        return {
            partName: targetForm.elements.partName.value.trim(),
            manufacturer: targetForm.elements.manufacturer.value.trim(),
            modelName: targetForm.elements.modelName.value.trim(),
            categoryId,
            safeQuantity: readNumberValue(state.categoryId === normalizeString(categoryId) ? state.safeQuantity : 0),
            specValues: state.categoryId === normalizeString(categoryId) ? state.specValues : []
        };
    };

    const loadCategoryOptions = async (companyCode) => {
        try {
            const data = await window.PcsApi.getData(
                    `/api/workspaces/${encodeURIComponent(companyCode)}/categories?size=100`,
                    {
                        authRedirect: true,
                        loginCompanyCode: companyCode
                    }
            );
            categoryOptions = Array.isArray(data) ? data : data.content || [];
            syncAllCategoryLabels();
        } catch (error) {
            console.error("분류 목록을 불러오지 못했습니다.", error);
        }
    };

    const loadParts = async (page = 0, options = {}) => {
        const companyCode = getCompanyCode();
        if (!companyCode) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const preserveScroll = options.preserveScroll === true;
        if (options.keepSelection !== true) {
            selectedPartId = null;
            closeDrawer({ restoreFocus: false });
        }
        const fetchPage = async (targetPage) => {
            const params = buildParams(targetPage);
            const data = await window.PcsApi.getData(
                    `/api/workspaces/${encodeURIComponent(companyCode)}/parts?${params.toString()}`,
                    {
                        authRedirect: true,
                        loginCompanyCode: companyCode
                    }
            );
            return window.PcsPagination.normalizePageData(data, PAGE_SIZE);
        };

        const requestPage = async () => {
            currentPage = page;
            setLoading(true);
            if (!preserveScroll) {
                setEmptyMessage("품목 목록을 불러오는 중입니다.");
            }

            let pageData = await fetchPage(page);
            if (pageData.content.length === 0 && pageData.totalElements > 0 && pageData.page > 0) {
                pageData = await fetchPage(pageData.page - 1);
            }
            currentPage = pageData.page;

            renderRows(pageData.content);
            updatePagination(pageData);
            renderSummary(pageData);
        };

        const execute = async () => {
            try {
                await requestPage();
            } catch (error) {
                setEmptyMessage(error?.message || "품목 목록을 불러오지 못했습니다.");
                updatePagination({
                    totalElements: 0,
                    totalPages: 0,
                    page: 0,
                    hasPrevious: false,
                    hasNext: false
                });
                renderSummary({
                    content: [],
                    totalElements: 0
                });
                showCreatePanel(null, { open: false });
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

    if (!filterForm || !table || !pagination || !window.PcsApi || !window.PcsPagination) {
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
            await loadCategoryOptions(companyCode);
            await loadParts(0);
            updateDetailSummary("create");
            updateDetailSummary("edit");
        } catch (error) {
            setEmptyMessage(error?.message || "업체 주소를 확인할 수 없습니다.");
        }
    };

    filterForm.addEventListener("submit", (event) => {
        event.preventDefault();
        loadParts(0);
    });

    document.querySelectorAll("[data-open-category-picker]").forEach((button) => {
        button.addEventListener("click", () => openCategoryPicker(button.dataset.openCategoryPicker));
    });

    document.querySelectorAll("[data-close-category-picker]").forEach((button) => {
        button.addEventListener("click", closeCategoryPicker);
    });

    categoryPickerModal?.addEventListener("click", (event) => {
        if (event.target === categoryPickerModal) {
            closeCategoryPicker();
        }
    });

    categoryPickerSearch?.addEventListener("input", renderCategoryPickerList);

    clearCategoryPickerButton?.addEventListener("click", () => {
        setCategoryValue("filter", "");
        closeCategoryPicker();
    });

    createDrawerButtons.forEach((button) => button.addEventListener("click", (event) => {
        showCreatePanel(event.currentTarget);
    }));

    document.querySelectorAll("[data-part-create-mode]").forEach((button) => {
        button.addEventListener("click", (event) => showCreatePanel(event.currentTarget));
    });

    closeDrawerButtons.forEach((button) => {
        button.addEventListener("click", () => closeDrawer());
    });

    window.PcsDrawer?.bindOutsideClose({
        drawer: detailDrawer,
        close: closeDrawer,
        keepOpenSelector: "[data-part-create-drawer], [data-part-id], [data-part-spec-modal], [data-category-picker-modal]"
    });

    document.querySelectorAll("[data-open-part-spec-modal]").forEach((button) => {
        button.addEventListener("click", () => openSpecModal(button.dataset.openPartSpecModal));
    });

    document.querySelectorAll("[data-close-part-spec-modal]").forEach((button) => {
        button.addEventListener("click", closeSpecModal);
    });

    specModal?.addEventListener("click", (event) => {
        if (event.target === specModal) {
            closeSpecModal();
        }
    });

    document.addEventListener("keydown", (event) => {
        if (
            event.key === "Escape" &&
            detailDrawer?.classList.contains("is-open") &&
            !specModal?.open &&
            !categoryPickerModal?.open
        ) {
            closeDrawer();
        }
    });

    specModalForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        try {
            const state = getDetailState(activeSpecModalMode);
            detailStateByMode[activeSpecModalMode] = {
                ...state,
                safeQuantity: readNumberValue(specModalForm.elements.safeQuantity.value),
                specValues: readRenderedSpecValues()
            };
            updateDetailSummary(activeSpecModalMode);
            closeSpecModal();
        } catch (error) {
            specModalMessage.textContent = error.message || "상세입력 값을 확인해 주세요.";
        }
    });

    document.querySelector("[data-part-edit-mode]")?.addEventListener("click", async () => {
        const part = getSelectedPart();
        if (!part) {
            return;
        }
        try {
            const detail = part.specValues ? part : await fetchPartDetail(part.partId);
            replaceCurrentPart(detail);
            fillEditForm(detail);
            setPanelMode("edit");
        } catch (error) {
            showToast(error?.message || "품목 수정 정보를 불러오지 못했습니다.", "error");
        }
    });

    document.querySelector("[data-part-detail-mode]")?.addEventListener("click", () => {
        const part = getSelectedPart();
        if (!part) {
            showCreatePanel();
            return;
        }
        renderDetail(part);
        setPanelMode("detail");
    });

    createForm?.addEventListener("reset", () => {
        detailStateByMode.create = createEmptyDetailState();
        window.setTimeout(() => {
            setCategoryValue("create", "", { resetDetail: false });
            updateDetailSummary("create");
        }, 0);
    });

    createForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        if (!companyCode || createForm.dataset.saving === "true") {
            return;
        }
        if (!createForm.reportValidity() || !validateCategorySelection("create")) {
            return;
        }

        try {
            setFormSaving(createForm, true);
            const data = await window.PcsApi.getData(
                    `/api/workspaces/${encodeURIComponent(companyCode)}/parts`,
                    {
                        method: "POST",
                        body: readPartForm(createForm, "create"),
                        authRedirect: true,
                        loginCompanyCode: companyCode
                    }
            );

            selectedPartId = data?.partId || null;
            await loadParts(0, { keepSelection: true });
            const createdPart = getSelectedPart();
            if (createdPart) {
                const createdDetail = await fetchPartDetail(createdPart.partId);
                replaceCurrentPart(createdDetail);
                renderDetail(createdDetail);
                setPanelMode("detail");
            }
            showToast("품목을 등록했습니다.", "success");
            createForm.reset();
        } catch (error) {
            showToast(error?.message || "품목을 등록하지 못했습니다.", "error");
        } finally {
            setFormSaving(createForm, false);
        }
    });

    editForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        const part = getSelectedPart();
        if (!companyCode || !part || editForm.dataset.saving === "true") {
            return;
        }
        if (!editForm.reportValidity() || !validateCategorySelection("edit")) {
            return;
        }

        try {
            setFormSaving(editForm, true);

            const data = await window.PcsApi.getData(
                    `/api/workspaces/${encodeURIComponent(companyCode)}/parts/${part.partId}`,
                    {
                        method: "PATCH",
                        body: readPartForm(editForm, "edit"),
                        authRedirect: true,
                        loginCompanyCode: companyCode
                    }
            );

            selectedPartId = data?.partId || part.partId;
            replaceCurrentPart(data);
            await loadParts(currentPage, { keepSelection: true, preserveScroll: true });
            const refreshedPart = await fetchPartDetail(selectedPartId);
            replaceCurrentPart(refreshedPart);
            renderDetail(refreshedPart);
            setPanelMode("detail");
            showToast("품목 정보를 수정했습니다.", "success");
        } catch (error) {
            showToast(error?.message || "품목을 수정하지 못했습니다.", "error");
        } finally {
            setFormSaving(editForm, false);
        }
    });

    prevButton.addEventListener("click", () => {
        if (currentPage > 0) {
            loadParts(currentPage - 1, { preserveScroll: true });
        }
    });

    nextButton.addEventListener("click", () => {
        loadParts(currentPage + 1, { preserveScroll: true });
    });

    initializePage();
})();
