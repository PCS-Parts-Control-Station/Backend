(function () {
    const PAGE_SIZE = 10;
    const SPEC_TYPE_LABELS = {
        TEXT: "텍스트",
        NUMBER: "숫자",
        SELECT: "선택",
        BOOLEAN: "체크"
    };

    const filterForm = document.querySelector("[data-category-filter-form]");
    const table = document.querySelector("[data-category-table]");
    const pagination = document.querySelector("[data-category-pagination]");
    const pageInfo = document.querySelector("[data-page-info]");
    const prevButton = document.querySelector("[data-page-prev]");
    const nextButton = document.querySelector("[data-page-next]");
    const searchButton = filterForm?.querySelector("button[type='submit']");
    const panelViews = document.querySelectorAll("[data-category-panel]");
    const createForm = document.querySelector("[data-category-create-form]");
    const editForm = document.querySelector("[data-category-edit-form]");
    const createMessage = document.querySelector("[data-category-create-message]");
    const editMessage = document.querySelector("[data-category-edit-message]");
    const createSpecList = document.querySelector("[data-create-spec-list]");
    const createSpecEmpty = document.querySelector("[data-create-spec-empty]");
    const editSpecList = document.querySelector("[data-edit-spec-list]");
    const editSpecEmpty = document.querySelector("[data-edit-spec-empty]");
    const editSpecLockedMessage = document.querySelector("[data-spec-edit-locked]");
    const editSpecAddButton = document.querySelector("[data-open-spec-modal][data-spec-owner='edit']");
    const deleteModal = document.querySelector("[data-category-delete-modal]");
    const openDeleteModalButton = document.querySelector("[data-open-category-delete-modal]");
    const closeDeleteModalButtons = document.querySelectorAll("[data-close-category-delete-modal]");
    const confirmDeleteButton = document.querySelector("[data-confirm-category-delete]");
    const specModal = document.querySelector("[data-spec-modal]");
    const specModalForm = document.querySelector("[data-spec-modal-form]");
    const specModalTitle = document.querySelector("[data-spec-modal-title]");
    const specModalDescription = document.querySelector("[data-spec-modal-description]");
    const specModalSubmit = document.querySelector("[data-spec-modal-submit]");
    const specModalMessage = document.querySelector("[data-spec-modal-message]");
    const specInputType = specModalForm?.elements.inputType;
    const specOptionsWrap = document.querySelector("[data-spec-options-wrap]");
    const closeSpecModalButtons = document.querySelectorAll("[data-close-spec-modal]");
    const detailSpecList = document.querySelector("[data-detail-spec-list]");
    const detailFields = {
        name: document.querySelector("[data-detail-name]"),
        description: document.querySelector("[data-detail-description]"),
        partCount: document.querySelector("[data-detail-part-count]"),
        updatedAt: document.querySelector("[data-detail-updated-at]")
    };
    const deleteModalFields = {
        name: document.querySelector("[data-delete-category-name]"),
        partCount: document.querySelector("[data-delete-category-part-count]"),
        message: document.querySelector("[data-category-delete-message]")
    };

    let currentPage = 0;
    let currentCategories = [];
    let selectedCategoryId = null;
    let createSpecs = [];
    let editSpecs = [];
    let editSpecsEditable = true;
    let specOwner = "create";
    let editingSpecIndex = null;

    const getCompanyCode = window.PcsWorkspace.getCompanyCode;
    const formatDate = window.PcsFormat.date;
    const numberText = window.PcsFormat.number;

    const cloneSpecs = (items = []) => items.map((spec, index) => ({
        specKey: spec.specKey || null,
        specName: spec.specName || "",
        inputType: spec.inputType || "TEXT",
        unit: spec.unit || null,
        required: spec.required === true,
        searchable: spec.searchable === true,
        sortOrder: Number.isInteger(spec.sortOrder) ? spec.sortOrder : index,
        options: Array.isArray(spec.options)
            ? spec.options.map((option, optionIndex) => ({
                optionLabel: option.optionLabel || option.optionValue || "",
                optionValue: option.optionValue || option.optionLabel || "",
                sortOrder: Number.isInteger(option.sortOrder) ? option.sortOrder : optionIndex
            }))
            : []
    }));

    const showToast = window.PcsFeedback.toast;

    const setPanelMode = (mode) => {
        panelViews.forEach((panel) => {
            const isActive = panel.dataset.categoryPanel === mode;
            panel.hidden = !isActive;
            panel.classList.toggle("is-active", isActive);
        });
    };

    const setFormMessage = (element, message = "") => {
        if (!element) {
            return;
        }
        element.textContent = message;
    };

    const setSpecModalMessage = (message = "") => {
        if (!specModalMessage) {
            return;
        }
        specModalMessage.textContent = message;
        specModalMessage.hidden = !message;
    };

    const clearRows = () => window.PcsTable.clearRows(table);
    const setEmptyMessage = (message) => window.PcsTable.emptyRow(table, {
        rowClassName: "data-row simple-management-data-row empty-data-row",
        message
    });
    const createTextCell = window.PcsTable.textCell;

    const getSelectedCategory = () => (
        currentCategories.find((category) => String(category.categoryId) === String(selectedCategoryId)) || null
    );

    const updateSelectedRow = () => {
        table?.querySelectorAll("[data-category-id]").forEach((row) => {
            const isSelected = String(row.dataset.categoryId) === String(selectedCategoryId);
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
        });
    };

    const mergeCategory = (category) => {
        const exists = currentCategories.some((item) => String(item.categoryId) === String(category.categoryId));
        if (!exists) {
            return;
        }
        currentCategories = currentCategories.map((item) => (
            String(item.categoryId) === String(category.categoryId) ? { ...item, ...category } : item
        ));
    };

    const updateSpecOptionsVisibility = () => {
        if (specOptionsWrap && specInputType) {
            specOptionsWrap.hidden = specInputType.value !== "SELECT";
        }
    };

    const specMetaText = (spec) => {
        const metaParts = [
            SPEC_TYPE_LABELS[spec.inputType] || spec.inputType || "텍스트",
            spec.required ? "필수" : "선택",
            spec.searchable ? "검색 기준" : "",
            spec.unit ? `단위: ${spec.unit}` : ""
        ].filter(Boolean);
        return metaParts.join(" · ");
    };

    const renderSpecDetail = (specDefinitions = []) => {
        if (!detailSpecList) {
            return;
        }

        detailSpecList.innerHTML = "";
        if (!specDefinitions.length) {
            const empty = document.createElement("p");
            empty.textContent = "등록된 사양 항목이 없습니다.";
            detailSpecList.append(empty);
            return;
        }

        specDefinitions.forEach((spec) => {
            const item = document.createElement("article");
            item.className = "spec-detail-item";

            const title = document.createElement("strong");
            title.textContent = spec.specName || "-";

            const meta = document.createElement("small");
            meta.textContent = specMetaText(spec);

            item.append(title, meta);

            if (Array.isArray(spec.options) && spec.options.length > 0) {
                const options = document.createElement("small");
                options.textContent = `선택지: ${spec.options.map((option) => option.optionLabel).join(", ")}`;
                item.append(options);
            }

            detailSpecList.append(item);
        });
    };

    const renderDetail = (category) => {
        if (!category) {
            return;
        }

        detailFields.name.textContent = category.categoryName || "-";
        detailFields.description.textContent = category.description || "-";
        detailFields.partCount.textContent = `${numberText(category.partCount)}개`;
        detailFields.updatedAt.textContent = formatDate(category.updatedAt);
            renderSpecDetail(category.specDefinitions || []);

        if (openDeleteModalButton) {
            openDeleteModalButton.title = Number(category.partCount || 0) > 0
                ? "연결된 품목이 있어 삭제할 수 없습니다."
                : "";
        }
    };

    const renderSpecSummary = (container, emptyElement, specs, owner, editable) => {
        if (!container) {
            return;
        }

        container.querySelectorAll("[data-spec-summary-item]").forEach((item) => item.remove());
        if (emptyElement) {
            emptyElement.hidden = specs.length > 0;
        }

        specs.forEach((spec, index) => {
            const item = document.createElement("article");
            item.className = "spec-summary-card";
            item.dataset.specSummaryItem = "";
            item.dataset.specIndex = String(index);
            item.dataset.specOwner = owner;

            const body = document.createElement("div");
            const title = document.createElement("strong");
            title.textContent = spec.specName || "-";
            const meta = document.createElement("small");
            meta.textContent = specMetaText(spec);
            body.append(title, meta);

            if (Array.isArray(spec.options) && spec.options.length > 0) {
                const options = document.createElement("small");
                options.textContent = `선택지: ${spec.options.map((option) => option.optionLabel).join(", ")}`;
                body.append(options);
            }

            item.append(body);

            if (editable) {
                const actions = document.createElement("div");
                actions.className = "spec-summary-actions";

                const editButton = document.createElement("button");
                editButton.type = "button";
                editButton.textContent = "수정";
                editButton.dataset.editSpec = "";
                editButton.dataset.specOwner = owner;
                editButton.dataset.specIndex = String(index);

                const removeButton = document.createElement("button");
                removeButton.type = "button";
                removeButton.textContent = "삭제";
                removeButton.dataset.removeSpec = "";
                removeButton.dataset.specOwner = owner;
                removeButton.dataset.specIndex = String(index);

                actions.append(editButton, removeButton);
                item.append(actions);
            }

            container.append(item);
        });
    };

    const renderCreateSpecs = () => {
        renderSpecSummary(createSpecList, createSpecEmpty, createSpecs, "create", true);
    };

    const renderEditSpecs = () => {
        renderSpecSummary(editSpecList, editSpecEmpty, editSpecs, "edit", editSpecsEditable);
        if (editSpecAddButton) {
            editSpecAddButton.hidden = !editSpecsEditable;
            editSpecAddButton.disabled = !editSpecsEditable;
        }
        if (editSpecLockedMessage) {
            editSpecLockedMessage.hidden = editSpecsEditable;
        }
    };

    const fetchCategoryDetail = async (categoryId) => {
        const companyCode = getCompanyCode();
        return window.PcsApi.getData(
            `/api/workspaces/${encodeURIComponent(companyCode)}/categories/${categoryId}`,
            {
                authRedirect: true,
                loginCompanyCode: companyCode
            }
        );
    };

    const selectCategory = async (categoryId) => {
        selectedCategoryId = categoryId;
        const category = getSelectedCategory();
        updateSelectedRow();
        if (category) {
            renderDetail(category);
            setPanelMode("detail");
        }

        try {
            const detail = await fetchCategoryDetail(categoryId);
            mergeCategory(detail);
            renderDetail(detail);
            setPanelMode("detail");
        } catch (error) {
            showToast(error?.message || "분류 상세 정보를 불러오지 못했습니다.", "error");
        }
    };

    const showCreatePanel = () => {
        selectedCategoryId = null;
        updateSelectedRow();
        createForm?.reset();
        createSpecs = [];
        renderCreateSpecs();
        setFormMessage(createMessage);
        setPanelMode("create");
    };

    const fillEditForm = (category) => {
        if (!editForm || !category) {
            return;
        }
        editForm.elements.categoryName.value = category.categoryName || "";
        editForm.elements.description.value = category.description || "";
        editSpecs = cloneSpecs(category.specDefinitions || []);
        editSpecsEditable = Number(category.partCount || 0) === 0;
        renderEditSpecs();
        setFormMessage(editMessage);
    };

    const showEditPanel = async () => {
        const category = getSelectedCategory();
        if (!category) {
            return;
        }

        let detail = category;
        if (!Array.isArray(category.specDefinitions)) {
            try {
                detail = await fetchCategoryDetail(category.categoryId);
                mergeCategory(detail);
                renderDetail(detail);
            } catch (error) {
                showToast(error?.message || "분류 상세 정보를 불러오지 못했습니다.", "error");
                return;
            }
        }

        fillEditForm(detail);
        setPanelMode("edit");
    };

    const openSpecModal = (owner, index = null) => {
        if (!specModal || !specModalForm) {
            return;
        }
        if (owner === "edit" && !editSpecsEditable) {
            showToast("연결된 품목이 있는 분류는 사양 항목을 수정할 수 없습니다.", "error");
            return;
        }

        const specs = owner === "edit" ? editSpecs : createSpecs;
        const spec = index === null ? null : specs[index];
        specOwner = owner;
        editingSpecIndex = index;

        specModalForm.reset();
        setSpecModalMessage();

        if (spec) {
            specModalForm.elements.specName.value = spec.specName || "";
            specModalForm.elements.inputType.value = spec.inputType || "TEXT";
            specModalForm.elements.unit.value = spec.unit || "";
            specModalForm.elements.options.value = Array.isArray(spec.options)
                ? spec.options.map((option) => option.optionLabel || option.optionValue).filter(Boolean).join(", ")
                : "";
            specModalForm.elements.required.checked = spec.required === true;
            specModalForm.elements.searchable.checked = spec.searchable === true;
        }

        updateSpecOptionsVisibility();
        specModalTitle.textContent = spec ? "사양 항목을 수정합니다." : "사양 항목을 추가합니다.";
        specModalDescription.textContent = spec
            ? "선택한 사양 항목의 이름, 입력 방식, 선택지를 수정합니다."
            : "품목 등록 때 입력받을 항목 기준을 설정합니다.";
        specModalSubmit.textContent = spec ? "수정" : "추가";
        specModalSubmit.dataset.defaultText = specModalSubmit.textContent;
        specModal.showModal();
        specModalForm.elements.specName.focus();
    };

    const closeSpecModal = () => {
        if (!specModal) {
            return;
        }
        setSpecModalMessage();
        specModal.close();
    };

    const readSpecModal = () => {
        const specName = specModalForm.elements.specName.value.trim();
        const inputType = specModalForm.elements.inputType.value || "TEXT";
        const optionText = specModalForm.elements.options.value || "";
        const options = inputType === "SELECT"
            ? optionText.split(",")
                .map((value) => value.trim())
                .filter(Boolean)
                .map((value, index) => ({
                    optionLabel: value,
                    optionValue: value,
                    sortOrder: index
                }))
            : [];

        if (!specName) {
            setSpecModalMessage("사양명을 입력해 주세요.");
            return null;
        }
        if (inputType === "SELECT" && options.length === 0) {
            setSpecModalMessage("선택 방식은 선택지를 1개 이상 입력해야 합니다.");
            return null;
        }

        return {
            specName,
            inputType,
            unit: specModalForm.elements.unit.value.trim() || null,
            required: specModalForm.elements.required.checked === true,
            searchable: specModalForm.elements.searchable.checked === true,
            sortOrder: 0,
            options
        };
    };

    const saveSpecFromModal = () => {
        const spec = readSpecModal();
        if (!spec) {
            return;
        }

        const targetSpecs = specOwner === "edit" ? editSpecs : createSpecs;
        if (editingSpecIndex === null) {
            targetSpecs.push(spec);
        } else {
            targetSpecs[editingSpecIndex] = spec;
        }

        targetSpecs.forEach((item, index) => {
            item.sortOrder = index;
        });

        if (specOwner === "edit") {
            renderEditSpecs();
        } else {
            renderCreateSpecs();
        }
        closeSpecModal();
    };

    const readCategoryForm = (form, specs, includeSpecs) => {
        const body = {
            categoryName: form.elements.categoryName.value.trim(),
            description: form.elements.description.value.trim() || null
        };
        if (includeSpecs) {
            body.specDefinitions = cloneSpecs(specs);
        }
        return body;
    };

    const setFormSaving = (form, isSaving, text = "저장 중") => {
        window.PcsForm.setSaving(form, isSaving, text);
        if (!isSaving && form === editForm) {
            renderEditSpecs();
        }
    };

    const renderRows = (items) => {
        clearRows();
        currentCategories = items;

        if (!items.length) {
            setEmptyMessage("조회된 분류가 없습니다.");
            showCreatePanel();
            return;
        }

        items.forEach((category) => {
            const row = document.createElement("div");
            row.className = "data-row simple-management-data-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.dataset.categoryId = String(category.categoryId);

            row.append(
                createTextCell("분류명", category.categoryName, "strong"),
                createTextCell("설명", category.description),
                createTextCell("품목 수", `${numberText(category.partCount)}개`),
                createTextCell("수정일", formatDate(category.updatedAt))
            );

            row.addEventListener("click", () => selectCategory(category.categoryId));
            row.addEventListener("keydown", (event) => {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    selectCategory(category.categoryId);
                }
            });

            table.append(row);
        });

        if (getSelectedCategory()) {
            renderDetail(getSelectedCategory());
            updateSelectedRow();
        } else {
            updateSelectedRow();
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

    const setDeleteModalMessage = (message = "") => {
        if (!deleteModalFields.message) {
            return;
        }
        deleteModalFields.message.textContent = message;
        deleteModalFields.message.hidden = !message;
    };

    const setDeleteSaving = (isSaving) => {
        if (!deleteModal || !confirmDeleteButton) {
            return;
        }

        deleteModal.dataset.saving = String(isSaving);
        confirmDeleteButton.disabled = isSaving;
        closeDeleteModalButtons.forEach((button) => {
            button.disabled = isSaving;
        });

        if (!confirmDeleteButton.dataset.defaultText) {
            confirmDeleteButton.dataset.defaultText = confirmDeleteButton.textContent;
        }
        confirmDeleteButton.textContent = isSaving ? "삭제 중" : confirmDeleteButton.dataset.defaultText;
    };

    const closeDeleteModal = () => {
        if (!deleteModal || deleteModal.dataset.saving === "true") {
            return;
        }
        setDeleteModalMessage();
        deleteModal.close();
    };

    const openDeleteModal = () => {
        const category = getSelectedCategory();
        if (!deleteModal || !category) {
            return;
        }

        const partCount = Number(category.partCount || 0);
        if (partCount > 0) {
            showToast("연결된 품목이 있는 분류는 삭제할 수 없습니다.", "error");
            return;
        }

        deleteModalFields.name.textContent = category.categoryName || "-";
        deleteModalFields.partCount.textContent = `${numberText(partCount)}개`;
        setDeleteModalMessage();
        deleteModal.showModal();
    };

    const loadCategories = async (page = 0, options = {}) => {
        const companyCode = getCompanyCode();
        if (!companyCode) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const preserveScroll = options.preserveScroll === true;
        const fetchPage = async (targetPage) => {
            const params = buildParams(targetPage);
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/categories?${params.toString()}`,
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
                setEmptyMessage("분류 목록을 불러오는 중입니다.");
            }

            let pageData = await fetchPage(page);
            if (pageData.content.length === 0 && pageData.totalElements > 0 && pageData.page > 0) {
                pageData = await fetchPage(pageData.page - 1);
            }
            currentPage = pageData.page;

            if (options.keepSelection !== true) {
                selectedCategoryId = null;
                showCreatePanel();
            }

            renderRows(pageData.content);
            updatePagination(pageData);
        };

        const execute = async () => {
            try {
                await requestPage();
            } catch (error) {
                setEmptyMessage(error?.message || "분류 목록을 불러오지 못했습니다.");
                updatePagination({
                    totalElements: 0,
                    totalPages: 0,
                    page: 0,
                    hasPrevious: false,
                    hasNext: false
                });
                selectedCategoryId = null;
                showCreatePanel();
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
            showCreatePanel();
            await loadCategories(0);
        } catch (error) {
            setEmptyMessage(error?.message || "업체 주소를 확인할 수 없습니다.");
            showCreatePanel();
        }
    };

    filterForm.addEventListener("submit", (event) => {
        event.preventDefault();
        loadCategories(0);
    });

    document.querySelectorAll("[data-category-create-mode]").forEach((button) => {
        button.addEventListener("click", showCreatePanel);
    });

    document.querySelector("[data-category-edit-mode]")?.addEventListener("click", showEditPanel);

    document.querySelector("[data-category-detail-mode]")?.addEventListener("click", () => {
        const category = getSelectedCategory();
        if (category) {
            renderDetail(category);
            setPanelMode("detail");
        }
    });

    document.addEventListener("click", (event) => {
        const openButton = event.target.closest("[data-open-spec-modal]");
        if (openButton) {
            openSpecModal(openButton.dataset.specOwner || "create");
            return;
        }

        const editButton = event.target.closest("[data-edit-spec]");
        if (editButton) {
            openSpecModal(editButton.dataset.specOwner || "create", Number(editButton.dataset.specIndex));
            return;
        }

        const removeButton = event.target.closest("[data-remove-spec]");
        if (removeButton) {
            const owner = removeButton.dataset.specOwner || "create";
            const index = Number(removeButton.dataset.specIndex);
            if (owner === "edit") {
                if (!editSpecsEditable) {
                    showToast("연결된 품목이 있는 분류는 사양 항목을 수정할 수 없습니다.", "error");
                    return;
                }
                editSpecs.splice(index, 1);
                renderEditSpecs();
            } else {
                createSpecs.splice(index, 1);
                renderCreateSpecs();
            }
        }
    });

    closeSpecModalButtons.forEach((button) => {
        button.addEventListener("click", closeSpecModal);
    });

    specModal?.addEventListener("click", (event) => {
        if (event.target === specModal) {
            closeSpecModal();
        }
    });

    specInputType?.addEventListener("change", updateSpecOptionsVisibility);

    specModalForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        saveSpecFromModal();
    });

    createForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        if (!companyCode || createForm.dataset.saving === "true") {
            return;
        }

        try {
            setFormSaving(createForm, true);
            setFormMessage(createMessage);
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/categories`,
                {
                    method: "POST",
                    body: readCategoryForm(createForm, createSpecs, true),
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            selectedCategoryId = data.categoryId;
            await loadCategories(0, { keepSelection: true });
            mergeCategory(data);
            renderDetail(data);
            setPanelMode("detail");
            createForm.reset();
            createSpecs = [];
            renderCreateSpecs();
            showToast("분류를 등록했습니다.", "success");
        } catch (error) {
            const message = error?.message || "분류를 등록하지 못했습니다.";
            setFormMessage(createMessage, message);
            showToast(message, "error");
        } finally {
            setFormSaving(createForm, false);
        }
    });

    createForm?.addEventListener("reset", () => {
        window.setTimeout(() => {
            createSpecs = [];
            renderCreateSpecs();
            setFormMessage(createMessage);
        }, 0);
    });

    editForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        const category = getSelectedCategory();
        if (!companyCode || !category || editForm.dataset.saving === "true") {
            return;
        }

        try {
            setFormSaving(editForm, true);
            setFormMessage(editMessage);
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/categories/${category.categoryId}`,
                {
                    method: "PATCH",
                    body: readCategoryForm(editForm, editSpecs, editSpecsEditable),
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            selectedCategoryId = data.categoryId;
            await loadCategories(currentPage, {
                keepSelection: true,
                preserveScroll: true
            });
            mergeCategory(data);
            renderDetail(data);
            setPanelMode("detail");
            showToast("분류 정보를 수정했습니다.", "success");
        } catch (error) {
            const message = error?.message || "분류를 수정하지 못했습니다.";
            setFormMessage(editMessage, message);
            showToast(message, "error");
        } finally {
            setFormSaving(editForm, false);
        }
    });

    openDeleteModalButton?.addEventListener("click", openDeleteModal);

    closeDeleteModalButtons.forEach((button) => {
        button.addEventListener("click", closeDeleteModal);
    });

    deleteModal?.addEventListener("click", (event) => {
        if (event.target === deleteModal) {
            closeDeleteModal();
        }
    });

    confirmDeleteButton?.addEventListener("click", async () => {
        const companyCode = getCompanyCode();
        const category = getSelectedCategory();
        if (!companyCode || !category || deleteModal?.dataset.saving === "true") {
            return;
        }

        try {
            setDeleteSaving(true);
            await window.PcsApi.request(
                `/api/workspaces/${encodeURIComponent(companyCode)}/categories/${category.categoryId}`,
                {
                    method: "DELETE",
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            selectedCategoryId = null;
            setDeleteModalMessage();
            deleteModal?.close();
            showCreatePanel();
            await loadCategories(currentPage, { preserveScroll: true });
            showToast("분류를 삭제했습니다.", "success");
        } catch (error) {
            const message = error?.message || "분류를 삭제하지 못했습니다.";
            setDeleteModalMessage(message);
            showToast(message, "error");
        } finally {
            setDeleteSaving(false);
        }
    });

    prevButton.addEventListener("click", () => {
        if (currentPage > 0) {
            loadCategories(currentPage - 1, { preserveScroll: true });
        }
    });

    nextButton.addEventListener("click", () => {
        loadCategories(currentPage + 1, { preserveScroll: true });
    });

    initializePage();
})();
