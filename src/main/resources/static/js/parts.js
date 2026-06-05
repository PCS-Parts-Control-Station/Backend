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
    const createForm = document.querySelector("[data-part-create-form]");
    const editForm = document.querySelector("[data-part-edit-form]");
    const detailFields = {
        name: document.querySelector("[data-detail-name]"),
        code: document.querySelector("[data-detail-code]"),
        category: document.querySelector("[data-detail-category]"),
        manufacturer: document.querySelector("[data-detail-manufacturer]"),
        model: document.querySelector("[data-detail-model]"),
        stock: document.querySelector("[data-detail-stock]"),
        safeQuantity: document.querySelector("[data-detail-safe-quantity]"),
        estimatedPrice: document.querySelector("[data-detail-estimated-price]")
    };
    const summaryFields = {
        total: document.querySelector("[data-summary-total]"),
        stock: document.querySelector("[data-summary-stock]"),
        lowStock: document.querySelector("[data-summary-low-stock]")
    };

    let currentPage = 0;
    let currentParts = [];
    let selectedPartId = null;
    let categoryOptions = [];

    const getCompanyCode = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : "";
    };

    const numberText = (value) => Number(value || 0).toLocaleString("ko-KR");

    const getCurrentStock = (part) => Number(part?.currentStockQuantity ?? part?.stockQuantity ?? 0);

    const getSafeQuantity = (part) => Number(part?.safeQuantity ?? 0);

    const isLowStock = (part) => {
        const safeQuantity = getSafeQuantity(part);
        return safeQuantity > 0 && getCurrentStock(part) < safeQuantity;
    };

    const formatMoney = (value) => {
        const amount = Number(value ?? 0);
        if (!Number.isFinite(amount) || amount <= 0) {
            return "0원";
        }
        return `${amount.toLocaleString("ko-KR")}원`;
    };

    const getCategoryNameById = (categoryId) => {
        const category = categoryOptions.find((item) => String(item.categoryId) === String(categoryId));
        return category ? category.categoryName : "-";
    };

    const getPartCategoryName = (part) => part?.categoryName || getCategoryNameById(part?.categoryId);

    const clearRows = () => {
        table?.querySelectorAll(".data-row:not(.table-head)").forEach((row) => row.remove());
    };

    const setEmptyMessage = (message) => {
        clearRows();
        const row = document.createElement("div");
        row.className = "data-row management-data-row part-management-data-row empty-data-row";
        row.setAttribute("role", "row");

        const cell = document.createElement("span");
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", "안내");
        cell.textContent = message;

        row.append(cell);
        table.append(row);
    };

    const createStackedCell = (label, primary, secondary, className = "part-meta-cell") => {
        const cell = document.createElement("span");
        cell.className = className;
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", label);

        const primaryElement = document.createElement("strong");
        primaryElement.textContent = primary || "-";
        cell.append(primaryElement);

        if (secondary) {
            const secondaryElement = document.createElement("small");
            secondaryElement.textContent = secondary;
            cell.append(secondaryElement);
        }

        return cell;
    };

    const createTextCell = (label, text) => {
        const cell = document.createElement("span");
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", label);
        cell.textContent = text || "-";
        return cell;
    };

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

    const setPanelMode = (mode) => {
        panelViews.forEach((panel) => {
            const isActive = panel.dataset.partPanel === mode;
            panel.hidden = !isActive;
            panel.classList.toggle("is-active", isActive);
        });
    };

    const getSelectedPart = () => {
        return currentParts.find((part) => String(part.partId) === String(selectedPartId)) || null;
    };

    const updateSelectedRow = () => {
        table?.querySelectorAll("[data-part-id]").forEach((row) => {
            const isSelected = String(row.dataset.partId) === String(selectedPartId);
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
        });
    };

    const renderDetail = (part) => {
        if (!part) {
            return;
        }

        detailFields.name.textContent = part.partName || "-";
        detailFields.code.textContent = part.partCode || "-";
        detailFields.category.textContent = getPartCategoryName(part);
        detailFields.manufacturer.textContent = part.manufacturer || "-";
        detailFields.model.textContent = part.modelName || "-";
        detailFields.stock.textContent = `${numberText(getCurrentStock(part))}개`;
        detailFields.safeQuantity.textContent = `${numberText(getSafeQuantity(part))}개`;
        detailFields.estimatedPrice.textContent = formatMoney(part.estimatedPrice);
    };

    const fillEditForm = (part) => {
        if (!editForm || !part) {
            return;
        }
        editForm.elements.partName.value = part.partName || "";
        editForm.elements.manufacturer.value = part.manufacturer || "";
        editForm.elements.modelName.value = part.modelName || "";
        editForm.elements.partCode.value = part.partCode || "";
        editForm.elements.categoryId.value = part.categoryId || "";
        editForm.elements.estimatedPrice.value = part.estimatedPrice ?? 0;
        editForm.elements.safeQuantity.value = part.safeQuantity ?? 0;
    };

    const selectPart = (partId) => {
        selectedPartId = partId;
        const part = getSelectedPart();
        updateSelectedRow();
        if (!part) {
            return;
        }
        renderDetail(part);
        setPanelMode("detail");
    };

    const showCreatePanel = () => {
        selectedPartId = null;
        updateSelectedRow();
        createForm?.reset();
        setPanelMode("create");
    };

    const renderSummary = (pageData) => {
        if (!summaryFields.total || !pageData) {
            return;
        }

        const items = pageData.content || [];
        const summary = pageData.summary || {};
        const totalStock = summary.totalStock ?? items.reduce((sum, part) => sum + getCurrentStock(part), 0);
        const lowStockCount = summary.lowStockCount ?? items.filter(isLowStock).length;

        summaryFields.total.textContent = numberText(summary.totalCount ?? pageData.totalElements ?? items.length);
        summaryFields.stock.textContent = numberText(totalStock);
        summaryFields.lowStock.textContent = numberText(lowStockCount);
    };

    const renderRows = (items) => {
        clearRows();
        currentParts = items;

        if (!items.length) {
            setEmptyMessage("조회된 부품이 없습니다.");
            showCreatePanel();
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
                createStackedCell("부품명", part.partName, part.partCode, "part-primary-cell"),
                createStackedCell("제조사 / 모델", part.manufacturer, part.modelName),
                createTextCell("카테고리", getPartCategoryName(part)),
                createQuantityCell("현재 재고", currentStock, lowStock ? "재고 부족" : ""),
                createQuantityCell("안전 재고", safeQuantity, "", lowStock)
            );

            row.addEventListener("click", () => selectPart(part.partId));
            row.addEventListener("keydown", (event) => {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    selectPart(part.partId);
                }
            });

            table.append(row);
        });

        if (getSelectedPart()) {
            renderDetail(getSelectedPart());
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
        targetForm.querySelectorAll("button, input, textarea, select").forEach((element) => {
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

    const readNumberField = (targetForm, fieldName) => {
        const value = targetForm.elements[fieldName]?.value;
        if (value === undefined || value === "") {
            return 0;
        }
        const number = Number(value);
        return Number.isFinite(number) ? number : 0;
    };

    const readPartForm = (targetForm) => ({
        partName: targetForm.elements.partName.value.trim(),
        manufacturer: targetForm.elements.manufacturer.value.trim(),
        modelName: targetForm.elements.modelName.value.trim(),
        partCode: targetForm.elements.partCode.value.trim(),
        categoryId: targetForm.elements.categoryId.value || null,
        estimatedPrice: readNumberField(targetForm, "estimatedPrice"),
        safeQuantity: readNumberField(targetForm, "safeQuantity")
    });

    const populateCategorySelect = (selectElement) => {
        if (!selectElement) {
            return;
        }

        const currentValue = selectElement.value;
        const isFilterSelect = selectElement.closest(".filter-form") !== null;
        selectElement.innerHTML = isFilterSelect ? '<option value="">전체</option>' : '<option value="">선택</option>';

        categoryOptions.forEach((category) => {
            const option = document.createElement("option");
            option.value = category.categoryId;
            option.textContent = category.categoryName;
            selectElement.append(option);
        });

        selectElement.value = currentValue;
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
            document.querySelectorAll("select[name='categoryId']").forEach(populateCategorySelect);
        } catch (error) {
            console.error("카테고리 목록을 불러오지 못했습니다.", error);
        }
    };

    const loadParts = async (page = 0, options = {}) => {
        const companyCode = getCompanyCode();
        if (!companyCode) {
            setEmptyMessage("업체 주소가 올바르지 않습니다.");
            return;
        }

        const preserveScroll = options.preserveScroll === true;
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
                setEmptyMessage("부품 목록을 불러오는 중입니다.");
            }

            let pageData = await fetchPage(page);
            if (pageData.content.length === 0 && pageData.totalElements > 0 && pageData.page > 0) {
                pageData = await fetchPage(pageData.page - 1);
            }
            currentPage = pageData.page;

            if (options.keepSelection !== true) {
                selectedPartId = null;
            }

            renderRows(pageData.content);
            updatePagination(pageData);
            renderSummary(pageData);
        };

        const execute = async () => {
            try {
                await requestPage();
            } catch (error) {
                setEmptyMessage(error?.message || "부품 목록을 불러오지 못했습니다.");
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
            await loadCategoryOptions(companyCode);
            await loadParts(0);
        } catch (error) {
            setEmptyMessage(error?.message || "업체 주소를 확인할 수 없습니다.");
        }
    };

    filterForm.addEventListener("submit", (event) => {
        event.preventDefault();
        loadParts(0);
    });

    document.querySelectorAll("[data-part-create-mode]").forEach((button) => {
        button.addEventListener("click", showCreatePanel);
    });

    document.querySelector("[data-part-edit-mode]")?.addEventListener("click", () => {
        const part = getSelectedPart();
        if (!part) {
            return;
        }
        fillEditForm(part);
        setPanelMode("edit");
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

    createForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const companyCode = getCompanyCode();
        if (!companyCode || createForm.dataset.saving === "true") {
            return;
        }

        try {
            setFormSaving(createForm, true);
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/parts`,
                {
                    method: "POST",
                    body: readPartForm(createForm),
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            selectedPartId = data?.partId || null;
            await loadParts(0, { keepSelection: true });
            showToast("부품을 등록했습니다.", "success");
            createForm.reset();
        } catch (error) {
            showToast(error?.message || "부품을 등록하지 못했습니다.", "error");
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

        try {
            setFormSaving(editForm, true);

            await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/parts/${part.partId}`,
                {
                    method: "PATCH",
                    body: readPartForm(editForm),
                    authRedirect: true,
                    loginCompanyCode: companyCode
                }
            );

            selectedPartId = part.partId;
            await loadParts(currentPage, { keepSelection: true, preserveScroll: true });
            const refreshedPart = getSelectedPart();
            if (refreshedPart) {
                renderDetail(refreshedPart);
                setPanelMode("detail");
            }
            showToast("부품 정보를 수정했습니다.", "success");
        } catch (error) {
            showToast(error?.message || "부품을 수정하지 못했습니다.", "error");
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
