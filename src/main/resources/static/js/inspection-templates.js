(function () {
    const PAGE_SIZE = 10;
    const SORT_STEP = 10;

    const INPUT_TYPES = {
        CHECK: "통과/불합격",
        NUMBER: "숫자",
        TEXT: "텍스트",
        SELECT: "선택형"
    };

    const ACTIVE_LABELS = {
        true: "사용 중",
        false: "중지"
    };

    const GROUPS = {
        BASIC: "주요 검수 항목",
        DETAIL: "추가 검수 항목"
    };

    const GRADE_IMPACTS = {
        LOW: "낮음",
        MEDIUM: "중간",
        HIGH: "높음"
    };

    const FAIL_POLICIES = {
        NONE: "별도 조치 없음",
        GRADE_DOWN: "등급 낮춤",
        MARK_DEFECTIVE: "불량 처리",
        BLOCK_SALE: "판매 불가 처리"
    };

    const filterForm = document.querySelector("[data-template-filter-form]");
    const table = document.querySelector("[data-template-table]");
    const pagination = document.querySelector("[data-template-pagination]");
    const pageInfo = document.querySelector("[data-template-page-info]");
    const prevButton = document.querySelector("[data-template-page-prev]");
    const nextButton = document.querySelector("[data-template-page-next]");
    const panelViews = document.querySelectorAll("[data-template-panel]");
    const detailDrawer = document.querySelector("[data-template-detail-drawer]");
    const createDrawerButtons = document.querySelectorAll("[data-template-create-drawer]");
    const createDrawerButton = Array.from(createDrawerButtons)
            .find((button) => !button.closest("[data-workspace-quick-bar]"))
            || createDrawerButtons[0]
            || null;
    const createForm = document.querySelector("[data-template-create-form]");
    const editForm = document.querySelector("[data-template-edit-form]");
    const categoryPickerModal = document.querySelector("[data-template-category-picker-modal]");
    const categoryPickerSearch = document.querySelector("[data-template-category-picker-search]");
    const categoryPickerList = document.querySelector("[data-template-category-picker-list]");
    const categoryPickerMessage = document.querySelector("[data-template-category-picker-message]");
    const categoryPickerInputs = {
        filter: filterForm?.elements.categoryId,
        create: createForm?.elements.categoryId,
        edit: editForm?.elements.categoryId
    };
    const categoryPickerLabels = {
        filter: document.querySelector("[data-template-filter-category-label]"),
        create: document.querySelector("[data-template-create-category-label]"),
        edit: document.querySelector("[data-template-edit-category-label]")
    };
    const itemForm = document.querySelector("[data-template-item-form]");
    const itemFormTitle = document.querySelector("[data-template-item-form-title]");
    const itemFormDescription = document.querySelector("[data-template-item-form-description]");
    const itemFormSubmit = document.querySelector("[data-template-item-submit]");
    const itemFormReset = document.querySelector("[data-template-item-reset]");
    const itemActiveToggle = document.querySelector("[data-template-item-active-toggle]");
    const itemModal = document.querySelector("[data-template-item-modal]");
    const itemModalCloseButtons = document.querySelectorAll("[data-close-template-item-modal]");
    const advancedFields = document.querySelector("[data-template-advanced-fields]");
    const advancedSummary = document.querySelector("[data-template-advanced-summary]");
    const builderEmpty = document.querySelector("[data-template-builder-empty]");
    const builderBody = document.querySelector("[data-template-builder-body]");
    const builderDescription = document.querySelector("[data-template-builder-description]");
    const itemList = document.querySelector("[data-template-item-list]");
    const selectedItemDetail = document.querySelector("[data-selected-item-detail]");
    const selectedItemSummary = document.querySelector("[data-selected-item-summary]");
    const inputTypeModal = document.querySelector("[data-template-input-type-modal]");
    const inputTypeModalFields = {
        item: document.querySelector("[data-input-type-modal-item]"),
        optionCount: document.querySelector("[data-input-type-modal-option-count]"),
        nextType: document.querySelector("[data-input-type-modal-next-type]"),
        message: document.querySelector("[data-input-type-modal-message]"),
        confirm: document.querySelector("[data-confirm-input-type-change]"),
        closeButtons: document.querySelectorAll("[data-close-input-type-modal]")
    };
    const detailFields = {
        name: document.querySelector("[data-detail-template-name]"),
        category: document.querySelector("[data-detail-category]"),
        version: document.querySelector("[data-detail-version]"),
        active: document.querySelector("[data-detail-active]"),
        basicCount: document.querySelector("[data-detail-basic-count]"),
        detailCount: document.querySelector("[data-detail-detail-count]"),
        optionCount: document.querySelector("[data-detail-option-count]"),
        createdBy: document.querySelector("[data-detail-created-by]"),
        updatedAt: document.querySelector("[data-detail-updated-at]")
    };
    const summaryFields = {
        total: document.querySelector("[data-summary-total]"),
        active: document.querySelector("[data-summary-active]"),
        items: document.querySelector("[data-summary-items]"),
        options: document.querySelector("[data-summary-options]")
    };
    const counts = {
        item: document.querySelector("[data-template-item-count]")
    };

    let categories = [];
    let templates = [];
    let selectedTemplate = null;
    let selectedTemplateId = null;
    let selectedItemId = null;
    let editingItemId = null;
    let editingOptionId = null;
    let templatePageData = {
        content: [],
        page: 0,
        size: PAGE_SIZE,
        totalElements: 0,
        totalPages: 0,
        hasPrevious: false,
        hasNext: false,
        summary: null
    };
    let lastDrawerTrigger = null;
    let dragState = null;
    let isSorting = false;
    let inputTypeConfirmResolver = null;
    let activeCategoryPickerMode = "create";

    const numberText = (value) => Number(value || 0).toLocaleString("ko-KR");

    const normalizeTemplatePageData = (data) => {
        if (window.PcsPagination) {
            return window.PcsPagination.normalizePageData(data, PAGE_SIZE);
        }

        return {
            content: Array.isArray(data?.content) ? data.content : [],
            page: Math.max(0, Number(data?.page || 0)),
            size: Math.max(1, Number(data?.size || PAGE_SIZE)),
            totalElements: Math.max(0, Number(data?.totalElements || 0)),
            totalPages: Math.max(0, Number(data?.totalPages || 0)),
            hasPrevious: data?.hasPrevious === true,
            hasNext: data?.hasNext === true,
            summary: data?.summary || null
        };
    };

    const updateTemplatePagination = () => {
        if (window.PcsPagination) {
            window.PcsPagination.updateControls({
                pageData: templatePageData,
                container: pagination,
                info: pageInfo,
                prevButton,
                nextButton
            });
            return;
        }

        if (pagination) {
            pagination.hidden = templatePageData.totalPages <= 1;
        }
        if (pageInfo) {
            pageInfo.textContent = templatePageData.totalPages
                ? `${templatePageData.page + 1} / ${templatePageData.totalPages} 페이지 · 총 ${numberText(templatePageData.totalElements)}건`
                : "0건";
        }
        if (prevButton) {
            prevButton.disabled = !templatePageData.hasPrevious;
        }
        if (nextButton) {
            nextButton.disabled = !templatePageData.hasNext;
        }
    };

    const getCompanyCode = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : "";
    };

    const apiOptions = () => {
        const companyCode = getCompanyCode();
        return {
            authRedirect: true,
            loginCompanyCode: companyCode
        };
    };

    const apiBase = () => `/api/workspaces/${encodeURIComponent(getCompanyCode())}`;

    const requestData = async (url, options = {}) => {
        const result = await window.PcsApi.request(url, options);
        return result?.data;
    };

    const showToast = (message, type = "info") => {
        window.PcsUi?.toast({ message, type });
    };

    const normalizeString = (value) => (value === null || value === undefined ? "" : String(value));

    const getCategoryById = (categoryId) => categories.find((category) => String(category.categoryId) === String(categoryId));

    const getCategoryNameById = (categoryId) => {
        const category = getCategoryById(categoryId);
        return category ? category.categoryName : "-";
    };

    const syncCategoryLabel = (mode) => {
        const input = categoryPickerInputs[mode];
        const label = categoryPickerLabels[mode];
        if (!input || !label) {
            return;
        }
        label.textContent = input.value ? getCategoryNameById(input.value) : mode === "filter" ? "전체" : "선택";
    };

    const syncAllCategoryLabels = () => {
        ["filter", "create", "edit"].forEach(syncCategoryLabel);
    };

    const setCategoryValue = (mode, categoryId) => {
        const input = categoryPickerInputs[mode];
        if (!input) {
            return;
        }
        input.value = normalizeString(categoryId);
        syncCategoryLabel(mode);
    };

    const createCategoryPickerAllOption = (selectedCategoryId) => {
        const button = document.createElement("button");
        button.type = "button";
        button.className = "category-picker-option";
        if (!selectedCategoryId) {
            button.classList.add("is-selected");
        }

        const name = document.createElement("strong");
        name.textContent = "전체 분류";

        const description = document.createElement("small");
        description.textContent = "분류 조건 없이 전체 템플릿을 조회합니다.";

        button.append(name, description);
        button.addEventListener("click", () => {
            setCategoryValue("filter", "");
            closeCategoryPicker();
        });

        return button;
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
        const filteredCategories = categories.filter((category) => matchesCategoryKeyword(category, keyword));
        categoryPickerList.innerHTML = "";

        if (activeCategoryPickerMode === "filter" && !keyword) {
            categoryPickerList.append(createCategoryPickerAllOption(selectedCategoryId));
        }

        if (!filteredCategories.length) {
            const empty = document.createElement("p");
            empty.className = "spec-builder-empty";
            empty.textContent = keyword ? "검색된 분류가 없습니다." : "등록된 분류가 없습니다.";
            categoryPickerList.append(empty);
            return;
        }

        filteredCategories.forEach((category) => {
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

    const normalizeTemplateSummary = (template) => ({
        id: String(template.templateId),
        templateId: template.templateId,
        categoryId: template.categoryId,
        categoryName: template.categoryName || "-",
        templateName: template.templateName || "-",
        version: template.version || 1,
        active: Boolean(template.active),
        itemCount: Number(template.itemCount || 0),
        optionCount: Number(template.optionCount || 0),
        createdBy: template.createdByName || "-",
        updatedAt: formatDate(template.updatedAt),
        items: []
    });

    const normalizeTemplateDetail = (template) => ({
        id: String(template.templateId),
        templateId: template.templateId,
        categoryId: template.categoryId,
        categoryName: template.categoryName || "-",
        templateName: template.templateName || "-",
        version: template.version || 1,
        active: Boolean(template.active),
        basicItemCount: Number(template.basicItemCount || 0),
        detailItemCount: Number(template.detailItemCount || 0),
        optionCount: Number(template.optionCount || 0),
        createdBy: template.createdByName || "-",
        createdAt: formatDate(template.createdAt),
        updatedAt: formatDate(template.updatedAt),
        items: (template.items || []).map((item) => ({
            id: String(item.itemId),
            itemId: item.itemId,
            itemName: item.itemName || "-",
            itemGroup: item.itemGroup,
            inputType: item.inputType,
            required: Boolean(item.required),
            sortOrder: Number(item.sortOrder || 0),
            gradeImpact: item.gradeImpact || "LOW",
            failPolicy: item.failPolicy || "NONE",
            active: Boolean(item.active),
            options: (item.options || []).map((option) => ({
                id: String(option.optionId),
                optionId: option.optionId,
                itemId: option.itemId,
                optionLabel: option.optionLabel || "-",
                optionValue: option.optionValue || "",
                sortOrder: Number(option.sortOrder || 0),
                active: Boolean(option.active)
            }))
        }))
    });

    const countOptions = (template) => template?.items?.reduce((sum, item) => sum + item.options.length, 0) || 0;

    const mergeTemplateDetailIntoList = (detail) => {
        const index = templates.findIndex((template) => template.id === detail.id);
        if (index < 0) {
            return;
        }
        templates[index] = {
            ...templates[index],
            templateName: detail.templateName,
            categoryId: detail.categoryId,
            categoryName: detail.categoryName,
            version: detail.version,
            active: detail.active,
            itemCount: detail.basicItemCount + detail.detailItemCount,
            optionCount: detail.optionCount,
            createdBy: detail.createdBy,
            updatedAt: detail.updatedAt
        };
    };

    const applyTemplateDetail = (detailData) => {
        selectedTemplate = normalizeTemplateDetail(detailData);
        selectedTemplateId = selectedTemplate.id;
        mergeTemplateDetailIntoList(selectedTemplate);
        renderRows();
        renderDetail(selectedTemplate);
        renderBuilder();
        updateSelectedRow();
    };

    const getSelectedTemplate = () => selectedTemplate;

    const getSelectedItem = (template = selectedTemplate) => {
        if (!template) {
            return null;
        }
        return template.items.find((item) => item.id === String(selectedItemId)) || null;
    };

    const createCell = (label, content, tagName = "span") => {
        const cell = document.createElement(tagName);
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", label);
        if (content instanceof Node) {
            cell.append(content);
        } else {
            cell.textContent = content || "-";
        }
        return cell;
    };

    const createBadge = (text, className = "badge-info") => {
        const badge = document.createElement("em");
        badge.className = `badge ${className}`;
        badge.textContent = text;
        return badge;
    };

    const setPanelMode = (mode) => {
        panelViews.forEach((panel) => {
            const isActive = panel.dataset.templatePanel === mode;
            panel.hidden = !isActive;
            panel.classList.toggle("is-active", isActive);
        });
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
        selectedTemplate = null;
        selectedTemplateId = null;
        selectedItemId = null;
        setDrawerOpen(false);
        renderBuilder();
        updateSelectedRow();
        if (options.restoreFocus !== false && lastDrawerTrigger?.isConnected) {
            lastDrawerTrigger.focus({ preventScroll: true });
        }
    };

    const clearRows = () => {
        table?.querySelectorAll(".data-row:not(.table-head)").forEach((row) => row.remove());
    };

    const setEmptyMessage = (message) => {
        clearRows();
        const row = document.createElement("div");
        row.className = "data-row management-data-row inspection-template-row empty-data-row";
        row.setAttribute("role", "row");
        row.append(createCell("안내", message));
        table.append(row);
    };

    const setFormSaving = (targetForm, isSaving, savingText = "저장 중") => {
        if (!targetForm) {
            return;
        }
        targetForm.dataset.saving = String(isSaving);
        targetForm.querySelectorAll("button, input, select, textarea").forEach((field) => {
            field.disabled = isSaving;
        });
        const submitButton = targetForm.querySelector("button[type='submit']");
        if (!submitButton) {
            return;
        }
        if (!submitButton.dataset.defaultText) {
            submitButton.dataset.defaultText = submitButton.textContent;
        }
        submitButton.textContent = isSaving ? savingText : submitButton.dataset.defaultText;
    };

    const handleApiError = (error, fallbackMessage) => {
        showToast(error?.message || fallbackMessage, "warning");
    };

    const updateAdvancedSummary = () => {
        if (!itemForm || !advancedSummary) {
            return;
        }
        const gradeImpact = itemForm.elements.gradeImpact?.value || "LOW";
        const failPolicy = itemForm.elements.failPolicy?.value || "NONE";
        advancedSummary.textContent = `등급 영향 ${GRADE_IMPACTS[gradeImpact] || "낮음"} · ${FAIL_POLICIES[failPolicy] || "별도 조치 없음"}`;
    };

    const buildItemPayload = (item, overrides = {}) => ({
        itemName: item.itemName,
        itemGroup: item.itemGroup,
        inputType: item.inputType,
        required: item.required,
        sortOrder: item.sortOrder,
        gradeImpact: item.gradeImpact || "LOW",
        failPolicy: item.failPolicy || "NONE",
        ...overrides
    });

    const buildOptionPayload = (option, overrides = {}) => ({
        optionLabel: option.optionLabel,
        optionValue: option.optionValue || option.optionLabel,
        sortOrder: option.sortOrder,
        ...overrides
    });

    const clearDragMarkers = () => {
        document.querySelectorAll(".is-dragging, .is-drop-before, .is-drop-after").forEach((element) => {
            element.classList.remove("is-dragging", "is-drop-before", "is-drop-after");
        });
    };

    const getDropPosition = (event, target) => {
        const rect = target.getBoundingClientRect();
        return event.clientY < rect.top + (rect.height / 2) ? "before" : "after";
    };

    const orderedIdsFrom = (container, selector, datasetKey) => {
        return [...container.querySelectorAll(selector)]
            .map((element) => element.dataset[datasetKey])
            .filter(Boolean);
    };

    const moveDraggedElement = (container, target, position) => {
        if (!dragState?.element || dragState.element === target || !container.contains(dragState.element)) {
            return;
        }
        if (position === "before") {
            container.insertBefore(dragState.element, target);
            return;
        }
        container.insertBefore(dragState.element, target.nextSibling);
    };

    const completeInputTypeConfirm = (confirmed) => {
        if (inputTypeModal?.open) {
            inputTypeModal.close();
        }
        if (inputTypeConfirmResolver) {
            inputTypeConfirmResolver(confirmed);
            inputTypeConfirmResolver = null;
        }
    };

    const confirmInputTypeChange = (item, nextInputType) => {
        const activeOptionCount = item.options.filter((option) => option.active).length;
        if (!inputTypeModal || typeof inputTypeModal.showModal !== "function") {
            return Promise.resolve(window.confirm(`${item.itemName} 항목의 선택지 ${activeOptionCount}개가 비활성화됩니다. 저장할까요?`));
        }

        inputTypeModalFields.item.textContent = item.itemName;
        inputTypeModalFields.optionCount.textContent = `${numberText(item.options.length)}개 · 사용 중 ${numberText(activeOptionCount)}개`;
        inputTypeModalFields.nextType.textContent = INPUT_TYPES[nextInputType] || nextInputType;
        if (inputTypeModalFields.message) {
            inputTypeModalFields.message.hidden = true;
            inputTypeModalFields.message.textContent = "";
        }

        return new Promise((resolve) => {
            inputTypeConfirmResolver = resolve;
            inputTypeModal.showModal();
        });
    };

    const patchTemplateItem = (template, item, overrides = {}) => {
        return requestData(
            `${apiBase()}/inspection-templates/${template.templateId}/items/${item.itemId}`,
            {
                ...apiOptions(),
                method: "PATCH",
                body: buildItemPayload(item, overrides)
            }
        );
    };

    const patchTemplateOption = (template, item, option, overrides = {}) => {
        return requestData(
            `${apiBase()}/inspection-templates/${template.templateId}/items/${item.itemId}/options/${option.optionId}`,
            {
                ...apiOptions(),
                method: "PATCH",
                body: buildOptionPayload(option, overrides)
            }
        );
    };

    const saveItemOrder = async (template, groupKey, orderedIds) => {
        if (!template || isSorting) {
            return;
        }
        const groupItems = template.items.filter((item) => item.itemGroup === groupKey);
        const itemsById = new Map(groupItems.map((item) => [item.id, item]));
        const updates = orderedIds
            .map((id, index) => {
                const item = itemsById.get(String(id));
                const nextSortOrder = (index + 1) * SORT_STEP;
                if (!item || item.sortOrder === nextSortOrder) {
                    return null;
                }
                return { item, nextSortOrder };
            })
            .filter(Boolean);

        if (!updates.length) {
            return;
        }

        isSorting = true;
        try {
            const data = await requestData(
                `${apiBase()}/inspection-templates/${template.templateId}/items/sort-order`,
                {
                    ...apiOptions(),
                    method: "PATCH",
                    body: {
                        itemGroup: groupKey,
                        orderedItemIds: orderedIds.map((id) => Number(id))
                    }
                }
            );
            applyTemplateDetail(data);
            showToast("항목 순서를 저장했습니다.", "success");
        } catch (error) {
            handleApiError(error, "항목 순서 저장에 실패했습니다.");
            await reloadSelectedTemplate();
        } finally {
            isSorting = false;
        }
    };

    const saveOptionOrder = async (template, item, orderedIds) => {
        if (!template || !item || isSorting) {
            return;
        }
        const optionsById = new Map(item.options.map((option) => [option.id, option]));
        const updates = orderedIds
            .map((id, index) => {
                const option = optionsById.get(String(id));
                const nextSortOrder = (index + 1) * SORT_STEP;
                if (!option || option.sortOrder === nextSortOrder) {
                    return null;
                }
                return { option, nextSortOrder };
            })
            .filter(Boolean);

        if (!updates.length) {
            return;
        }

        isSorting = true;
        try {
            const data = await requestData(
                `${apiBase()}/inspection-templates/${template.templateId}/items/${item.itemId}/options/sort-order`,
                {
                    ...apiOptions(),
                    method: "PATCH",
                    body: {
                        orderedOptionIds: orderedIds.map((id) => Number(id))
                    }
                }
            );
            selectedItemId = item.id;
            editingItemId = item.id;
            editingOptionId = null;
            applyTemplateDetail(data);
            showToast("선택지 순서를 저장했습니다.", "success");
        } catch (error) {
            handleApiError(error, "선택지 순서 저장에 실패했습니다.");
            await reloadSelectedTemplate();
        } finally {
            isSorting = false;
        }
    };

    const updateSummary = (summary = null) => {
        const fallbackTotal = templates.length;
        const fallbackActive = templates.filter((template) => template.active).length;
        const fallbackItems = templates.reduce((sum, template) => sum + Number(template.itemCount || 0), 0);
        const fallbackOptions = templates.reduce((sum, template) => sum + Number(template.optionCount || 0), 0);

        summaryFields.total.textContent = numberText(summary?.totalCount ?? fallbackTotal);
        summaryFields.active.textContent = numberText(summary?.activeCount ?? fallbackActive);
        summaryFields.items.textContent = numberText(summary?.itemCount ?? fallbackItems);
        summaryFields.options.textContent = numberText(summary?.optionCount ?? fallbackOptions);
    };

    const updateSelectedRow = () => {
        table?.querySelectorAll("[data-template-id]").forEach((row) => {
            const isSelected = row.dataset.templateId === String(selectedTemplateId);
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
        });
    };

    const populateCategorySelects = () => {
        syncAllCategoryLabels();
    };

    const loadCategories = async () => {
        const data = await window.PcsApi.getData(`${apiBase()}/categories?size=100`, apiOptions());
        categories = data?.content || [];
        populateCategorySelects();
    };

    const renderDetail = (template) => {
        if (!template) {
            return;
        }

        detailFields.name.textContent = template.templateName;
        detailFields.category.textContent = template.categoryName;
        detailFields.version.textContent = `v${template.version}`;
        detailFields.active.textContent = template.active ? "사용 중" : "사용 안 함";
        detailFields.active.className = `badge ${template.active ? "badge-available" : "badge-inactive"}`;
        detailFields.basicCount.textContent = `${numberText(template.basicItemCount)}개`;
        detailFields.detailCount.textContent = `${numberText(template.detailItemCount)}개`;
        detailFields.optionCount.textContent = `${numberText(template.optionCount)}개`;
        detailFields.createdBy.textContent = template.createdBy;
        detailFields.updatedAt.textContent = template.updatedAt;
    };

    const fillEditForm = (template) => {
        if (!template || !editForm) {
            return;
        }

        editForm.elements.templateName.value = template.templateName;
        setCategoryValue("edit", template.categoryId);
        editForm.elements.version.value = template.version;
        editForm.elements.active.checked = template.active;
    };

    const renderRows = () => {
        clearRows();

        if (!templates.length) {
            setEmptyMessage("조회된 검수 템플릿이 없습니다.");
            selectedTemplate = null;
            selectedTemplateId = null;
            renderBuilder();
            setPanelMode("create");
            return;
        }

        templates.forEach((template) => {
            const row = document.createElement("div");
            row.className = "data-row management-data-row inspection-template-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.dataset.templateId = template.id;

            row.append(
                createCell("템플릿", template.templateName, "strong"),
                createCell("카테고리", template.categoryName),
                createCell("버전", `v${template.version}`),
                createCell("항목", `${numberText(template.itemCount)}개`),
                createCell("상태", createBadge(template.active ? "사용 중" : "사용 안 함", template.active ? "badge-available" : "badge-inactive")),
                createCell("수정일", template.updatedAt)
            );

            row.addEventListener("click", () => selectTemplate(template.id, row));
            row.addEventListener("keydown", (event) => {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    selectTemplate(template.id, row);
                }
            });

            table.append(row);
        });

        updateSelectedRow();
    };

    const loadTemplates = async ({ preferredTemplateId = selectedTemplateId, page = templatePageData.page } = {}) => {
        const nextPage = Math.max(0, Number(page || 0));
        const params = new URLSearchParams({
            page: String(nextPage),
            size: String(PAGE_SIZE)
        });
        const keyword = filterForm?.elements.keyword?.value.trim();
        const categoryId = filterForm?.elements.categoryId?.value;
        const active = filterForm?.elements.active?.value;
        if (keyword) params.set("keyword", keyword);
        if (categoryId) params.set("categoryId", categoryId);
        if (active !== "") params.set("active", active);

        setEmptyMessage("검수 템플릿 목록을 불러오는 중입니다.");
        const data = await window.PcsApi.getData(`${apiBase()}/inspection-templates?${params.toString()}`, apiOptions());
        templatePageData = normalizeTemplatePageData(data);
        templates = templatePageData.content.map(normalizeTemplateSummary);
        updateSummary(templatePageData.summary || null);
        renderRows();
        updateTemplatePagination();

        if (!templates.length) {
            return;
        }

        const preferred = preferredTemplateId ? String(preferredTemplateId) : null;
        const nextSelectedId = templates.some((template) => template.id === preferred)
            ? preferred
            : templates[0].id;
        await selectTemplate(nextSelectedId, null, { open: false });
    };

    const loadTemplateDetail = async (templateId) => {
        const data = await window.PcsApi.getData(`${apiBase()}/inspection-templates/${encodeURIComponent(templateId)}`, apiOptions());
        return normalizeTemplateDetail(data);
    };

    const clearTemplateFilters = () => {
        if (!filterForm) {
            return;
        }
        if (filterForm.elements.keyword) {
            filterForm.elements.keyword.value = "";
        }
        if (filterForm.elements.categoryId) {
            filterForm.elements.categoryId.value = "";
        }
        syncCategoryLabel("filter");
        if (filterForm.elements.active) {
            filterForm.elements.active.value = "";
        }
    };

    const reloadSelectedTemplate = async () => {
        if (!selectedTemplateId) {
            return;
        }
        selectedTemplate = await loadTemplateDetail(selectedTemplateId);
        renderDetail(selectedTemplate);
        renderBuilder();
        updateSelectedRow();
    };

    const addOptionToItem = async (template, item, form) => {
        const optionLabel = form.elements.optionLabel.value.trim();
        if (!optionLabel) {
            showToast("선택지명을 입력해 주세요.", "warning");
            return;
        }

        setFormSaving(form, true, "추가 중");
        try {
            await requestData(
                `${apiBase()}/inspection-templates/${template.templateId}/items/${item.itemId}/options`,
                {
                    ...apiOptions(),
                    method: "POST",
                    body: { optionLabel }
                }
            );
            selectedItemId = item.id;
            editingItemId = item.id;
            editingOptionId = null;
            form.reset();
            await loadTemplates({ preferredTemplateId: template.id });
            showToast("선택지를 추가했습니다.", "success");
        } catch (error) {
            handleApiError(error, "선택지 추가에 실패했습니다.");
        } finally {
            setFormSaving(form, false);
        }
    };

    const updateOptionLabel = async (template, item, optionId, form) => {
        const option = item.options.find((itemOption) => itemOption.id === String(optionId));
        const optionLabel = form.elements.optionLabel.value.trim();
        if (!option || !optionLabel) {
            showToast("선택지명을 입력해 주세요.", "warning");
            return;
        }

        setFormSaving(form, true);
        try {
            await patchTemplateOption(template, item, option, { optionLabel });
            selectedItemId = item.id;
            editingItemId = item.id;
            editingOptionId = null;
            await loadTemplates({ preferredTemplateId: template.id });
            showToast("선택지를 수정했습니다.", "success");
        } catch (error) {
            handleApiError(error, "선택지 수정에 실패했습니다.");
        } finally {
            setFormSaving(form, false);
        }
    };

    const toggleOptionActive = async (template, item, optionId) => {
        const option = item.options.find((itemOption) => itemOption.id === String(optionId));
        if (!option) {
            return;
        }
        try {
            await window.PcsApi.request(
                `${apiBase()}/inspection-templates/${template.templateId}/items/${item.itemId}/options/${option.optionId}/active`,
                {
                    ...apiOptions(),
                    method: "PATCH",
                    body: { active: !option.active }
                }
            );
            selectedItemId = item.id;
            editingItemId = item.id;
            editingOptionId = null;
            await loadTemplates({ preferredTemplateId: template.id });
            showToast(option.active ? "선택지를 중지했습니다." : "선택지를 사용 중으로 변경했습니다.", "success");
        } catch (error) {
            handleApiError(error, "선택지 상태 변경에 실패했습니다.");
        }
    };

    const updateItemFromForm = async (template, item, form) => {
        const itemName = form.elements.itemName.value.trim();
        if (!itemName) {
            showToast("항목명을 입력해 주세요.", "warning");
            return;
        }

        const nextInputType = form.elements.inputType.value;
        if (item.inputType === "SELECT" && nextInputType !== "SELECT" && item.options.length > 0) {
            const confirmed = await confirmInputTypeChange(item, nextInputType);
            if (!confirmed) {
                return;
            }
        }

        setFormSaving(form, true);
        try {
            await patchTemplateItem(template, item, {
                itemName,
                itemGroup: form.elements.itemGroup.value,
                inputType: nextInputType,
                required: form.elements.required.checked,
                gradeImpact: form.elements.gradeImpact.value || "LOW",
                failPolicy: form.elements.failPolicy.value || "NONE"
            });
            selectedItemId = item.id;
            editingItemId = null;
            editingOptionId = null;
            await loadTemplates({ preferredTemplateId: template.id });
            closeItemModal();
            showToast("검수 항목을 수정했습니다.", "success");
        } catch (error) {
            handleApiError(error, "검수 항목 수정에 실패했습니다.");
        } finally {
            setFormSaving(form, false);
        }
    };

    const setItemFormSubmitText = (text) => {
        if (!itemFormSubmit) {
            return;
        }
        itemFormSubmit.textContent = text;
        itemFormSubmit.dataset.defaultText = text;
    };

    const closeItemModal = () => {
        itemModal?.close();
    };

    const focusItemName = () => {
        window.setTimeout(() => {
            itemForm?.elements.itemName?.focus();
        }, 0);
    };

    const resetItemForm = () => {
        editingItemId = null;
        itemForm?.reset();
        if (advancedFields) {
            advancedFields.open = false;
        }
        if (itemForm?.elements.gradeImpact) {
            itemForm.elements.gradeImpact.value = "LOW";
        }
        if (itemForm?.elements.failPolicy) {
            itemForm.elements.failPolicy.value = "NONE";
        }
        updateAdvancedSummary();
        if (itemFormTitle) {
            itemFormTitle.textContent = "항목 추가";
        }
        if (itemFormDescription) {
            itemFormDescription.textContent = "새 검수 항목을 추가합니다.";
        }
        setItemFormSubmitText("항목 추가");
        if (itemActiveToggle) {
            itemActiveToggle.hidden = true;
        }
    };

    const fillItemForm = (item) => {
        if (!itemForm || !item) {
            resetItemForm();
            return;
        }
        editingItemId = item.id;
        itemForm.elements.itemName.value = item.itemName;
        itemForm.elements.itemGroup.value = item.itemGroup;
        itemForm.elements.inputType.value = item.inputType;
        itemForm.elements.gradeImpact.value = item.gradeImpact;
        itemForm.elements.failPolicy.value = item.failPolicy;
        itemForm.elements.required.checked = item.required;
        if (advancedFields) {
            advancedFields.open = false;
        }
        updateAdvancedSummary();
        if (itemFormTitle) {
            itemFormTitle.textContent = "항목 수정";
        }
        if (itemFormDescription) {
            itemFormDescription.textContent = `${item.itemName} 항목을 수정 중입니다.`;
        }
        setItemFormSubmitText("항목 수정");
        if (itemActiveToggle) {
            itemActiveToggle.hidden = false;
            itemActiveToggle.textContent = item.active ? "항목 중지" : "항목 사용";
        }
    };

    const openItemCreateModal = () => {
        const template = getSelectedTemplate();
        if (!template) {
            showToast("항목을 추가할 템플릿을 먼저 선택해 주세요.", "warning");
            return;
        }
        resetItemForm();
        itemModal?.showModal();
        focusItemName();
    };

    const openItemEditModal = (itemId) => {
        const template = getSelectedTemplate();
        const item = template?.items.find((candidate) => candidate.id === String(itemId));
        if (!template || !item) {
            showToast("수정할 항목을 먼저 선택해 주세요.", "warning");
            return;
        }
        selectedItemId = item.id;
        editingItemId = item.id;
        editingOptionId = null;
        fillItemForm(item);
        renderItems(template);
        itemModal?.showModal();
        focusItemName();
    };

    const toggleSelectedItemActive = async () => {
        const template = getSelectedTemplate();
        const item = getSelectedItem(template);
        if (!template || !item) {
            return;
        }

        if (itemActiveToggle) {
            itemActiveToggle.disabled = true;
        }
        try {
            await window.PcsApi.request(
                `${apiBase()}/inspection-templates/${template.templateId}/items/${item.itemId}/active`,
                {
                    ...apiOptions(),
                    method: "PATCH",
                    body: { active: !item.active }
                }
            );
            selectedItemId = item.id;
            editingItemId = null;
            editingOptionId = null;
            await loadTemplates({ preferredTemplateId: template.id });
            closeItemModal();
            showToast("항목 상태를 변경했습니다.", "success");
        } catch (error) {
            handleApiError(error, "항목 상태 변경에 실패했습니다.");
        } finally {
            if (itemActiveToggle) {
                itemActiveToggle.disabled = false;
            }
        }
    };

    const renderItemOptions = (template, item) => {
        const wrap = document.createElement("div");
        wrap.className = "management-editor-option-strip";

        const header = document.createElement("div");
        header.className = "management-editor-option-strip-header";
        const title = document.createElement("strong");
        title.textContent = "선택지";
        const count = document.createElement("span");
        const activeOptionCount = item.options.filter((itemOption) => itemOption.active).length;
        count.textContent = `${numberText(item.options.length)}개 · 사용 중 ${numberText(activeOptionCount)}개`;
        header.append(title, count);

        const values = document.createElement("div");
        values.className = "management-editor-option-list";
        values.dataset.optionValues = item.id;
        values.addEventListener("dragover", (event) => {
            if (dragState?.type !== "option" || dragState.itemId !== item.id || isSorting) {
                return;
            }
            event.preventDefault();
        });
        values.addEventListener("drop", (event) => {
            if (dragState?.type !== "option" || dragState.itemId !== item.id || isSorting) {
                return;
            }
            event.preventDefault();
            const targetValue = event.target.closest("[data-option-id]");
            if (!targetValue && dragState.element && values.contains(dragState.element)) {
                values.append(dragState.element);
                saveOptionOrder(template, item, orderedIdsFrom(values, "[data-option-id]", "optionId"));
            }
            clearDragMarkers();
        });
        if (!item.options.length) {
            const empty = document.createElement("span");
            empty.className = "management-editor-empty-note";
            empty.textContent = "등록된 선택지가 없습니다.";
            values.append(empty);
        } else {
            item.options.forEach((itemOption) => {
                if (editingOptionId === itemOption.id) {
                    const form = document.createElement("form");
                    form.className = "management-editor-option-edit-form";
                    form.setAttribute("action", "#");
                    form.setAttribute("method", "post");

                    const field = document.createElement("input");
                    field.name = "optionLabel";
                    field.value = itemOption.optionLabel;
                    field.required = true;
                    field.setAttribute("aria-label", "선택지명");

                    const saveButton = document.createElement("button");
                    saveButton.className = "btn btn-primary";
                    saveButton.type = "submit";
                    saveButton.textContent = "저장";

                    const cancelButton = document.createElement("button");
                    cancelButton.className = "btn btn-secondary";
                    cancelButton.type = "button";
                    cancelButton.textContent = "취소";
                    cancelButton.addEventListener("click", () => {
                        editingOptionId = null;
                        renderSelectedItemDetail(template);
                    });

                    form.append(field, saveButton, cancelButton);
                    form.addEventListener("submit", (event) => {
                        event.preventDefault();
                        updateOptionLabel(template, item, itemOption.id, form);
                    });
                    values.append(form);
                    setTimeout(() => field.focus(), 0);
                    return;
                }

                const value = document.createElement("div");
                value.className = `management-editor-option-value ${itemOption.active ? "" : "is-inactive"}`;
                value.draggable = true;
                value.dataset.optionId = itemOption.id;

                const dragHandle = document.createElement("span");
                dragHandle.className = "management-editor-drag-handle";
                dragHandle.textContent = "⋮⋮";
                dragHandle.title = "드래그해서 순서 변경";
                dragHandle.setAttribute("aria-hidden", "true");

                const label = document.createElement("strong");
                label.textContent = itemOption.optionLabel;

                const status = createBadge(itemOption.active ? "사용 중" : "중지", itemOption.active ? "badge-available" : "badge-inactive");

                const actions = document.createElement("div");
                actions.className = "management-editor-option-actions";

                const editButton = document.createElement("button");
                editButton.className = "btn btn-secondary";
                editButton.type = "button";
                editButton.textContent = "수정";
                editButton.addEventListener("click", () => {
                    editingOptionId = itemOption.id;
                    renderSelectedItemDetail(template);
                });

                const toggleButton = document.createElement("button");
                toggleButton.className = "btn btn-secondary";
                toggleButton.type = "button";
                toggleButton.textContent = itemOption.active ? "중지" : "사용";
                toggleButton.addEventListener("click", () => toggleOptionActive(template, item, itemOption.id));

                actions.append(editButton, toggleButton);
                value.append(dragHandle, label, status, actions);
                value.addEventListener("dragstart", (event) => {
                    if (isSorting) {
                        event.preventDefault();
                        return;
                    }
                    dragState = {
                        type: "option",
                        id: itemOption.id,
                        itemId: item.id,
                        element: value
                    };
                    value.classList.add("is-dragging");
                    event.dataTransfer.effectAllowed = "move";
                    event.dataTransfer.setData("text/plain", itemOption.id);
                });
                value.addEventListener("dragover", (event) => {
                    if (dragState?.type !== "option" || dragState.itemId !== item.id || dragState.id === itemOption.id || isSorting) {
                        return;
                    }
                    event.preventDefault();
                    clearDragMarkers();
                    value.classList.add(getDropPosition(event, value) === "before" ? "is-drop-before" : "is-drop-after");
                });
                value.addEventListener("drop", (event) => {
                    if (dragState?.type !== "option" || dragState.itemId !== item.id || dragState.id === itemOption.id || isSorting) {
                        return;
                    }
                    event.preventDefault();
                    const position = getDropPosition(event, value);
                    moveDraggedElement(values, value, position);
                    saveOptionOrder(template, item, orderedIdsFrom(values, "[data-option-id]", "optionId"));
                    clearDragMarkers();
                });
                value.addEventListener("dragend", () => {
                    dragState = null;
                    clearDragMarkers();
                });
                values.append(value);
            });
        }

        const editor = document.createElement("details");
        editor.className = "management-editor-option-create";
        const summary = document.createElement("summary");
        summary.textContent = "선택지 추가";

        const form = document.createElement("form");
        form.className = "management-editor-option-create-form";
        form.setAttribute("action", "#");
        form.setAttribute("method", "post");
        form.setAttribute("autocomplete", "off");

        const labelInput = document.createElement("label");
        const labelText = document.createElement("span");
        const labelField = document.createElement("input");
        labelText.textContent = "선택지명";
        labelField.name = "optionLabel";
        labelField.placeholder = "예: 팬 소음";
        labelField.required = true;
        labelInput.append(labelText, labelField);

        const submitButton = document.createElement("button");
        submitButton.className = "btn btn-primary";
        submitButton.type = "submit";
        submitButton.textContent = "추가";

        form.append(labelInput, submitButton);
        form.addEventListener("submit", (event) => {
            event.preventDefault();
            addOptionToItem(template, item, form);
        });

        editor.append(summary, form);
        wrap.append(header, values, editor);
        return wrap;
    };

    const renderItemCard = (template, item) => {
        const card = document.createElement("article");
        card.className = `management-editor-item-card ${item.active ? "" : "is-inactive"}`;
        card.classList.toggle("is-selected", item.id === String(selectedItemId));
        card.dataset.itemId = item.id;
        card.draggable = true;
        card.setAttribute("role", "button");
        card.setAttribute("tabindex", "0");
        card.setAttribute("aria-pressed", String(item.id === String(selectedItemId)));

        const summary = document.createElement("div");
        summary.className = "management-editor-item-summary";

        const dragHandle = document.createElement("span");
        dragHandle.className = "management-editor-drag-handle";
        dragHandle.textContent = "⋮⋮";
        dragHandle.title = "드래그해서 순서 변경";
        dragHandle.setAttribute("aria-hidden", "true");

        const name = document.createElement("div");
        name.className = "management-editor-item-name";
        const title = document.createElement("strong");
        title.textContent = item.itemName;
        name.append(title);
        if (item.required) {
            const requiredMark = document.createElement("span");
            requiredMark.className = "management-editor-required-mark";
            requiredMark.textContent = "*필수";
            name.append(requiredMark);
        }

        const typeBadge = createBadge(INPUT_TYPES[item.inputType], item.inputType === "SELECT" ? "badge-blue" : "badge-info");
        const activeBadge = createBadge(ACTIVE_LABELS[String(item.active)], item.active ? "badge-available" : "badge-inactive");
        const badges = document.createElement("div");
        badges.className = "management-editor-item-badges";
        badges.append(typeBadge, activeBadge);

        summary.append(dragHandle, name, badges);
        card.append(summary);
        card.addEventListener("click", () => selectItem(item.id));
        card.addEventListener("keydown", (event) => {
            if (event.key === "Enter" || event.key === " ") {
                event.preventDefault();
                selectItem(item.id);
            }
        });
        card.addEventListener("dragstart", (event) => {
            if (isSorting) {
                event.preventDefault();
                return;
            }
            dragState = {
                type: "item",
                id: item.id,
                groupKey: item.itemGroup,
                element: card
            };
            selectedItemId = item.id;
            card.classList.add("is-dragging");
            event.dataTransfer.effectAllowed = "move";
            event.dataTransfer.setData("text/plain", item.id);
        });
        card.addEventListener("dragover", (event) => {
            if (dragState?.type !== "item" || dragState.groupKey !== item.itemGroup || dragState.id === item.id || isSorting) {
                return;
            }
            event.preventDefault();
            clearDragMarkers();
            card.classList.add(getDropPosition(event, card) === "before" ? "is-drop-before" : "is-drop-after");
        });
        card.addEventListener("drop", (event) => {
            if (dragState?.type !== "item" || dragState.groupKey !== item.itemGroup || dragState.id === item.id || isSorting) {
                return;
            }
            event.preventDefault();
            const container = card.closest("[data-item-group-items]");
            if (!container) {
                return;
            }
            const position = getDropPosition(event, card);
            moveDraggedElement(container, card, position);
            saveItemOrder(template, item.itemGroup, orderedIdsFrom(container, "[data-item-id]", "itemId"));
            clearDragMarkers();
        });
        card.addEventListener("dragend", () => {
            dragState = null;
            clearDragMarkers();
        });
        return card;
    };

    const renderSelectedItemDetail = (template) => {
        const item = getSelectedItem(template);
        selectedItemDetail.innerHTML = "";

        if (!item) {
            selectedItemSummary.textContent = "항목 미선택";
            const empty = document.createElement("div");
            empty.className = "management-editor-empty-note";
            empty.textContent = "왼쪽 목록에서 항목을 선택해 주세요.";
            selectedItemDetail.append(empty);
            return;
        }

        selectedItemSummary.textContent = INPUT_TYPES[item.inputType];

        const head = document.createElement("div");
        head.className = "management-editor-selected-head";
        const title = document.createElement("strong");
        title.textContent = item.itemName;
        if (item.required) {
            const requiredMark = document.createElement("span");
            requiredMark.className = "management-editor-required-mark";
            requiredMark.textContent = "*필수";
            title.append(" ", requiredMark);
        }
        const badges = document.createElement("div");
        badges.className = "management-editor-selected-badges";
        badges.append(
            createBadge(INPUT_TYPES[item.inputType], item.inputType === "SELECT" ? "badge-blue" : "badge-info"),
            createBadge(ACTIVE_LABELS[String(item.active)], item.active ? "badge-available" : "badge-inactive")
        );
        const editButton = document.createElement("button");
        editButton.className = "btn btn-secondary management-editor-selected-edit-button";
        editButton.type = "button";
        editButton.textContent = "항목 수정";
        editButton.addEventListener("click", () => openItemEditModal(item.id));

        const actions = document.createElement("div");
        actions.className = "management-editor-selected-head-actions";
        actions.append(badges, editButton);
        head.append(title, actions);

        selectedItemDetail.append(head);
        if (item.inputType === "SELECT") {
            selectedItemDetail.append(renderItemOptions(template, item));
            return;
        }

        const note = document.createElement("div");
        note.className = "management-editor-empty-note";
        note.textContent = "선택지가 필요 없는 입력 방식입니다.";
        selectedItemDetail.append(note);
    };

    const renderItems = (template) => {
        itemList.innerHTML = "";
        if (!template.items.some((item) => item.id === String(selectedItemId))) {
            selectedItemId = template.items[0]?.id || null;
        }

        ["BASIC", "DETAIL"].forEach((groupKey) => {
            const groupItems = template.items.filter((item) => item.itemGroup === groupKey);
            const group = document.createElement("section");
            group.className = "management-editor-group";

            const title = document.createElement("div");
            title.className = "management-editor-group-title";
            const titleText = document.createElement("span");
            titleText.textContent = GROUPS[groupKey];
            const titleCount = document.createElement("em");
            titleCount.textContent = `${numberText(groupItems.length)}개`;
            title.append(titleText, titleCount);
            group.append(title);

            if (!groupItems.length) {
                const empty = document.createElement("div");
                empty.className = "management-editor-empty-note";
                empty.textContent = "등록된 항목이 없습니다.";
                group.append(empty);
            } else {
                const groupBody = document.createElement("div");
                groupBody.className = "management-editor-group-items";
                groupBody.dataset.itemGroupItems = groupKey;
                groupBody.addEventListener("dragover", (event) => {
                    if (dragState?.type !== "item" || dragState.groupKey !== groupKey || isSorting) {
                        return;
                    }
                    event.preventDefault();
                });
                groupBody.addEventListener("drop", (event) => {
                    if (dragState?.type !== "item" || dragState.groupKey !== groupKey || isSorting) {
                        return;
                    }
                    event.preventDefault();
                    const targetCard = event.target.closest("[data-item-id]");
                    if (!targetCard && dragState.element && groupBody.contains(dragState.element)) {
                        groupBody.append(dragState.element);
                        saveItemOrder(template, groupKey, orderedIdsFrom(groupBody, "[data-item-id]", "itemId"));
                    }
                    clearDragMarkers();
                });
                groupItems.forEach((item) => groupBody.append(renderItemCard(template, item)));
                group.append(groupBody);
            }

            itemList.append(group);
        });

        renderSelectedItemDetail(template);
    };

    function renderBuilder() {
        const template = getSelectedTemplate();
        if (!template) {
            builderEmpty.hidden = false;
            builderBody.hidden = true;
            builderDescription.textContent = "템플릿을 선택하면 항목과 선택지를 편집할 수 있습니다.";
            selectedItemId = null;
            editingItemId = null;
            editingOptionId = null;
            if (itemFormReset) {
                itemFormReset.hidden = true;
            }
            resetItemForm();
            return;
        }

        builderEmpty.hidden = true;
        builderBody.hidden = false;
        builderDescription.textContent = `${template.templateName}의 검수 입력 항목입니다.`;
        counts.item.textContent = `항목 ${numberText(template.items.length)} · 선택지 ${numberText(countOptions(template))}`;
        if (itemFormReset) {
            itemFormReset.hidden = false;
        }
        renderItems(template);
    }

    const selectTemplate = async (templateId, trigger = null, options = {}) => {
        selectedTemplateId = String(templateId);
        editingItemId = null;
        editingOptionId = null;
        if (options.open !== false) {
            openDrawer(trigger);
        }
        try {
            selectedTemplate = await loadTemplateDetail(templateId);
            if (!selectedTemplate.items.some((item) => item.id === String(selectedItemId))) {
                selectedItemId = selectedTemplate.items[0]?.id || null;
            }
            renderDetail(selectedTemplate);
            renderBuilder();
            setPanelMode("detail");
            updateSelectedRow();
        } catch (error) {
            handleApiError(error, "검수 템플릿 상세 조회에 실패했습니다.");
        }
    };

    const selectItem = (itemId) => {
        selectedItemId = String(itemId);
        editingItemId = null;
        editingOptionId = null;
        const template = getSelectedTemplate();
        if (!template) {
            return;
        }
        renderItems(template);
    };

    const showCreatePanel = (trigger = null, options = {}) => {
        selectedTemplate = null;
        selectedTemplateId = null;
        selectedItemId = null;
        editingItemId = null;
        editingOptionId = null;
        createForm?.reset();
        setCategoryValue("create", "");
        if (createForm?.elements.active) {
            createForm.elements.active.checked = true;
        }
        renderBuilder();
        updateSelectedRow();
        setPanelMode("create");
        if (options.open === true) {
            openDrawer(trigger);
        }
    };

    filterForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        try {
            await loadTemplates({ preferredTemplateId: null, page: 0 });
        } catch (error) {
            handleApiError(error, "검수 템플릿 목록 조회에 실패했습니다.");
        }
    });

    prevButton?.addEventListener("click", async () => {
        if (!templatePageData.hasPrevious) {
            return;
        }
        try {
            await loadTemplates({ page: templatePageData.page - 1 });
        } catch (error) {
            handleApiError(error, "이전 페이지 조회에 실패했습니다.");
        }
    });

    nextButton?.addEventListener("click", async () => {
        if (!templatePageData.hasNext) {
            return;
        }
        try {
            await loadTemplates({ page: templatePageData.page + 1 });
        } catch (error) {
            handleApiError(error, "다음 페이지 조회에 실패했습니다.");
        }
    });

    document.querySelectorAll("[data-template-create-mode]").forEach((button) => {
        button.addEventListener("click", (event) => showCreatePanel(event.currentTarget, { open: true }));
    });

    createDrawerButtons.forEach((button) => {
        button.addEventListener("click", (event) => {
            showCreatePanel(event.currentTarget, { open: true });
        });
    });

    document.querySelectorAll("[data-close-template-drawer]").forEach((button) => {
        button.addEventListener("click", () => closeDrawer());
    });

    document.querySelector("[data-template-edit-mode]")?.addEventListener("click", () => {
        const template = getSelectedTemplate();
        if (!template) {
            return;
        }
        fillEditForm(template);
        setPanelMode("edit");
    });

    document.querySelectorAll("[data-open-template-category-picker]").forEach((button) => {
        button.addEventListener("click", () => openCategoryPicker(button.dataset.openTemplateCategoryPicker));
    });

    document.querySelectorAll("[data-close-template-category-picker]").forEach((button) => {
        button.addEventListener("click", closeCategoryPicker);
    });

    categoryPickerModal?.addEventListener("click", (event) => {
        if (event.target === categoryPickerModal) {
            closeCategoryPicker();
        }
    });

    categoryPickerSearch?.addEventListener("input", renderCategoryPickerList);

    createForm?.addEventListener("reset", () => {
        window.setTimeout(() => setCategoryValue("create", ""), 0);
    });

    document.querySelector("[data-template-detail-mode]")?.addEventListener("click", () => {
        const template = getSelectedTemplate();
        if (!template) {
            showCreatePanel(null, { open: false });
            return;
        }
        renderDetail(template);
        setPanelMode("detail");
    });

    window.PcsDrawer?.bindDismiss({
        drawer: detailDrawer,
        close: closeDrawer,
        keepOpenSelector: "[data-template-create-drawer], [data-template-id], dialog"
    });

    document.querySelector("[data-template-active-toggle]")?.addEventListener("click", async () => {
        const template = getSelectedTemplate();
        if (!template) {
            return;
        }
        try {
            await window.PcsApi.request(
                `${apiBase()}/inspection-templates/${template.templateId}/active`,
                {
                    ...apiOptions(),
                    method: "PATCH",
                    body: { active: !template.active }
                }
            );
            await loadTemplates({ preferredTemplateId: template.id });
            showToast("템플릿 상태를 변경했습니다.", "success");
        } catch (error) {
            handleApiError(error, "템플릿 상태 변경에 실패했습니다.");
        }
    });

    createForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        if (createForm.dataset.saving === "true") {
            return;
        }
        const form = createForm.elements;
        const templateName = form.templateName.value.trim();
        if (!templateName) {
            showToast("템플릿명을 입력해 주세요.", "warning");
            return;
        }
        if (!form.categoryId.value) {
            showToast("카테고리를 선택해 주세요.", "warning");
            return;
        }

        setFormSaving(createForm, true);
        try {
            const data = await requestData(
                `${apiBase()}/inspection-templates`,
                {
                    ...apiOptions(),
                    method: "POST",
                    body: {
                        templateName,
                        categoryId: Number(form.categoryId.value),
                        version: Number(form.version.value || 1),
                        active: form.active.checked
                    }
                }
            );
            selectedTemplateId = String(data.templateId);
            clearTemplateFilters();
            createForm.reset();
            setCategoryValue("create", "");
            createForm.elements.active.checked = true;
            await loadTemplates({ preferredTemplateId: selectedTemplateId, page: 0 });
            showToast("템플릿을 등록했습니다.", "success");
        } catch (error) {
            handleApiError(error, "템플릿 등록에 실패했습니다.");
        } finally {
            setFormSaving(createForm, false);
        }
    });

    editForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const template = getSelectedTemplate();
        if (!template || editForm.dataset.saving === "true") {
            return;
        }

        const form = editForm.elements;
        const templateName = form.templateName.value.trim();
        if (!templateName) {
            showToast("템플릿명을 입력해 주세요.", "warning");
            return;
        }
        if (!form.categoryId.value) {
            showToast("카테고리를 선택해 주세요.", "warning");
            return;
        }

        setFormSaving(editForm, true);
        try {
            await requestData(
                `${apiBase()}/inspection-templates/${template.templateId}`,
                {
                    ...apiOptions(),
                    method: "PATCH",
                    body: {
                        templateName,
                        categoryId: Number(form.categoryId.value),
                        version: Number(form.version.value || 1),
                        active: form.active.checked
                    }
                }
            );
            await loadTemplates({ preferredTemplateId: template.id });
            showToast("템플릿 정보를 수정했습니다.", "success");
        } catch (error) {
            handleApiError(error, "템플릿 수정에 실패했습니다.");
        } finally {
            setFormSaving(editForm, false);
        }
    });

    itemFormReset?.addEventListener("click", openItemCreateModal);

    itemModalCloseButtons.forEach((button) => {
        button.addEventListener("click", closeItemModal);
    });

    itemModal?.addEventListener("cancel", (event) => {
        event.preventDefault();
        closeItemModal();
    });

    itemActiveToggle?.addEventListener("click", () => {
        toggleSelectedItemActive();
    });

    itemForm?.elements.gradeImpact?.addEventListener("change", updateAdvancedSummary);
    itemForm?.elements.failPolicy?.addEventListener("change", updateAdvancedSummary);

    inputTypeModalFields.closeButtons.forEach((button) => {
        button.addEventListener("click", () => completeInputTypeConfirm(false));
    });

    inputTypeModalFields.confirm?.addEventListener("click", () => completeInputTypeConfirm(true));

    inputTypeModal?.addEventListener("cancel", (event) => {
        event.preventDefault();
        completeInputTypeConfirm(false);
    });

    itemForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const template = getSelectedTemplate();
        if (!template) {
            showToast("항목을 추가할 템플릿을 먼저 선택해 주세요.", "warning");
            return;
        }
        if (itemForm.dataset.saving === "true") {
            return;
        }

        const form = itemForm.elements;
        const itemName = form.itemName.value.trim();
        if (!itemName) {
            showToast("항목명을 입력해 주세요.", "warning");
            return;
        }

        const editingItem = editingItemId
            ? template.items.find((item) => item.id === String(editingItemId))
            : null;
        if (editingItem) {
            await updateItemFromForm(template, editingItem, itemForm);
            return;
        }

        setFormSaving(itemForm, true, "추가 중");
        try {
            const data = await requestData(
                `${apiBase()}/inspection-templates/${template.templateId}/items`,
                {
                    ...apiOptions(),
                    method: "POST",
                    body: {
                        itemName,
                        itemGroup: form.itemGroup.value,
                        inputType: form.inputType.value,
                        required: form.required.checked,
                        gradeImpact: form.gradeImpact.value,
                        failPolicy: form.failPolicy.value
                    }
                }
            );
            const createdItem = [...(data.items || [])].sort((a, b) => Number(b.itemId) - Number(a.itemId))[0];
            selectedItemId = createdItem ? String(createdItem.itemId) : selectedItemId;
            editingItemId = null;
            editingOptionId = null;
            itemForm.reset();
            await loadTemplates({ preferredTemplateId: template.id });
            closeItemModal();
            showToast("검수 항목을 추가했습니다.", "success");
        } catch (error) {
            handleApiError(error, "검수 항목 추가에 실패했습니다.");
        } finally {
            setFormSaving(itemForm, false);
        }
    });

    const init = async () => {
        if (!filterForm || !table) {
            return;
        }
        const companyCode = getCompanyCode();
        if (!companyCode || !window.PcsApi) {
            setEmptyMessage("작업공간 정보가 없어 검수 템플릿을 불러올 수 없습니다.");
            return;
        }
        try {
            const isValidWorkspace = await window.PcsApi.validateWorkspacePublic(companyCode);
            if (!isValidWorkspace) {
                return;
            }
            await loadCategories();
            await loadTemplates();
        } catch (error) {
            setEmptyMessage("검수 템플릿 목록을 불러오지 못했습니다.");
            handleApiError(error, "검수 템플릿 초기화에 실패했습니다.");
        }
    };

    init();
})();
