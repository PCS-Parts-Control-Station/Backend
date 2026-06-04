(function () {
    const PAGE_SIZE = 10;

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
    const deleteModal = document.querySelector("[data-category-delete-modal]");
    const openDeleteModalButton = document.querySelector("[data-open-category-delete-modal]");
    const closeDeleteModalButtons = document.querySelectorAll("[data-close-category-delete-modal]");
    const confirmDeleteButton = document.querySelector("[data-confirm-category-delete]");
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

    const getCompanyCode = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : "";
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

    const numberText = (value) => Number(value || 0).toLocaleString("ko-KR");

    const clearRows = () => {
        table?.querySelectorAll(".data-row:not(.table-head)").forEach((row) => row.remove());
    };

    const setEmptyMessage = (message) => {
        clearRows();
        const row = document.createElement("div");
        row.className = "data-row simple-management-data-row empty-data-row";
        row.setAttribute("role", "row");

        const cell = document.createElement("span");
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", "안내");
        cell.textContent = message;

        row.append(cell);
        table.append(row);
    };

    const createTextCell = (label, text, tagName = "span") => {
        const cell = document.createElement(tagName);
        cell.setAttribute("role", "cell");
        if (label) {
            cell.setAttribute("data-label", label);
        }
        cell.textContent = text || "-";
        return cell;
    };

    const setPanelMode = (mode) => {
        panelViews.forEach((panel) => {
            const isActive = panel.dataset.categoryPanel === mode;
            panel.hidden = !isActive;
            panel.classList.toggle("is-active", isActive);
        });
    };

    const getSelectedCategory = () => {
        return currentCategories.find((category) => String(category.categoryId) === String(selectedCategoryId)) || null;
    };

    const updateSelectedRow = () => {
        table?.querySelectorAll("[data-category-id]").forEach((row) => {
            const isSelected = String(row.dataset.categoryId) === String(selectedCategoryId);
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
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

        if (openDeleteModalButton) {
            openDeleteModalButton.title = Number(category.partCount || 0) > 0
                ? "연결된 부품이 있어 삭제할 수 없습니다."
                : "";
        }
    };

    const fillEditForm = (category) => {
        if (!editForm || !category) {
            return;
        }
        editForm.elements.categoryName.value = category.categoryName || "";
        editForm.elements.description.value = category.description || "";
    };

    const selectCategory = (categoryId) => {
        selectedCategoryId = categoryId;
        const category = getSelectedCategory();
        updateSelectedRow();
        if (!category) {
            return;
        }
        renderDetail(category);
        setPanelMode("detail");
    };

    const showCreatePanel = () => {
        selectedCategoryId = null;
        updateSelectedRow();
        createForm?.reset();
        setPanelMode("create");
    };

    const renderRows = (items) => {
        clearRows();
        currentCategories = items;

        if (!items.length) {
            setEmptyMessage("조회된 카테고리가 없습니다.");
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
                createTextCell("카테고리명", category.categoryName, "strong"),
                createTextCell("설명", category.description),
                createTextCell("부품 수", `${numberText(category.partCount)}개`),
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
            showCreatePanel();
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

    const showToast = (message, type = "info") => {
        window.PcsUi?.toast({
            message,
            type
        });
    };

    const setFormSaving = (targetForm, isSaving, savingText = "저장 중") => {
        if (!targetForm) {
            return;
        }

        targetForm.dataset.saving = String(isSaving);
        targetForm.querySelectorAll("button, input, textarea").forEach((element) => {
            element.disabled = isSaving;
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
            showToast("연결된 부품이 있는 카테고리는 삭제할 수 없습니다.", "error");
            return;
        }

        deleteModalFields.name.textContent = category.categoryName || "-";
        deleteModalFields.partCount.textContent = `${numberText(partCount)}개`;
        setDeleteModalMessage();
        deleteModal.showModal();
    };

    const readCategoryForm = (targetForm) => ({
        categoryName: targetForm.elements.categoryName.value.trim(),
        description: targetForm.elements.description.value.trim() || null
    });

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
                setEmptyMessage("카테고리 목록을 불러오는 중입니다.");
            }

            let pageData = await fetchPage(page);
            if (pageData.content.length === 0 && pageData.totalElements > 0 && pageData.page > 0) {
                pageData = await fetchPage(pageData.page - 1);
            }
            currentPage = pageData.page;

            if (options.keepSelection !== true) {
                selectedCategoryId = null;
            }

            renderRows(pageData.content);
            updatePagination(pageData);
        };

        const execute = async () => {
            try {
                await requestPage();
            } catch (error) {
                setEmptyMessage(error?.message || "카테고리 목록을 불러오지 못했습니다.");
                updatePagination({
                    totalElements: 0,
                    totalPages: 0,
                    page: 0,
                    hasPrevious: false,
                    hasNext: false
                });
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
            await loadCategories(0);
        } catch (error) {
            setEmptyMessage(error?.message || "업체 주소를 확인할 수 없습니다.");
        }
    };

    filterForm.addEventListener("submit", (event) => {
        event.preventDefault();
        loadCategories(0);
    });

    document.querySelectorAll("[data-category-create-mode]").forEach((button) => {
        button.addEventListener("click", showCreatePanel);
    });

    document.querySelector("[data-category-edit-mode]")?.addEventListener("click", () => {
        const category = getSelectedCategory();
        if (!category) {
            return;
        }
        fillEditForm(category);
        setPanelMode("edit");
    });

    document.querySelector("[data-category-detail-mode]")?.addEventListener("click", () => {
        const category = getSelectedCategory();
        if (!category) {
            showCreatePanel();
            return;
        }
        renderDetail(category);
        setPanelMode("detail");
    });

    createForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        if (!companyCode || createForm.dataset.saving === "true") {
            return;
        }

        try {
            setFormSaving(createForm, true);
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/categories`,
                {
                    method: "POST",
                    body: readCategoryForm(createForm),
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            selectedCategoryId = data.categoryId;
            await loadCategories(0, { keepSelection: true });
            showToast("카테고리를 등록했습니다.", "success");
            createForm.reset();
        } catch (error) {
            showToast(error?.message || "카테고리를 등록하지 못했습니다.", "error");
        } finally {
            setFormSaving(createForm, false);
        }
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
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/categories/${category.categoryId}`,
                {
                    method: "PATCH",
                    body: readCategoryForm(editForm),
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            selectedCategoryId = data.categoryId;
            await loadCategories(currentPage, { keepSelection: true, preserveScroll: true });
            const refreshedCategory = getSelectedCategory();
            if (refreshedCategory) {
                renderDetail(refreshedCategory);
                setPanelMode("detail");
            }
            showToast("카테고리 정보를 수정했습니다.", "success");
        } catch (error) {
            showToast(error?.message || "카테고리를 수정하지 못했습니다.", "error");
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
            await loadCategories(currentPage, { preserveScroll: true });
            showToast("카테고리를 삭제했습니다.", "success");
        } catch (error) {
            const message = error?.message || "카테고리를 삭제하지 못했습니다.";
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
