(function (window) {
    const getCompanyCode = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : "";
    };

    const updateWorkspaceLinks = (companyCode) => {
        if (!companyCode) {
            return;
        }

        document.querySelectorAll("a[href^='/w/pcs-seoul']").forEach((link) => {
            link.href = link.getAttribute("href").replace(
                    "/w/pcs-seoul",
                    `/w/${encodeURIComponent(companyCode)}`
            );
        });

        const brandWorkspace = document.querySelector(".sidebar-brand small");
        if (brandWorkspace) {
            brandWorkspace.textContent = companyCode;
        }
    };

    const date = (value) => {
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

    const number = (value) => Number(value || 0).toLocaleString("ko-KR");

    const escapeHtml = (value) => String(value ?? "")
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#39;");

    const toast = (message, type = "info") => {
        window.PcsUi?.toast({
            message,
            type
        });
    };

    const setSaving = (form, isSaving, savingText = "저장 중") => {
        if (!form) {
            return;
        }

        form.dataset.saving = String(isSaving);
        form.querySelectorAll("button, input, select, textarea").forEach((element) => {
            element.disabled = isSaving;
        });

        const submitButton = form.querySelector("button[type='submit']");
        if (!submitButton) {
            return;
        }

        if (!submitButton.dataset.defaultText) {
            submitButton.dataset.defaultText = submitButton.textContent;
        }
        submitButton.textContent = isSaving ? savingText : submitButton.dataset.defaultText;
    };

    const clearRows = (table) => {
        table?.querySelectorAll(".data-row:not(.table-head)").forEach((row) => row.remove());
    };

    const textCell = (label, text, tagName = "span") => {
        const cell = document.createElement(tagName);
        cell.setAttribute("role", "cell");
        if (label) {
            cell.setAttribute("data-label", label);
        }
        const value = text || "-";
        cell.textContent = value;
        cell.title = value;
        return cell;
    };

    const emptyRow = (table, options = {}) => {
        if (!table) {
            return;
        }

        clearRows(table);

        const row = document.createElement("div");
        row.className = options.rowClassName || "data-row empty-data-row";
        row.setAttribute("role", "row");

        const cell = document.createElement("span");
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", options.label || "안내");
        cell.textContent = options.message || "";

        row.append(cell);
        table.append(row);
    };

    const isDrawerOpen = (drawer, predicate) => {
        if (!drawer) {
            return false;
        }
        if (typeof predicate === "function") {
            return Boolean(predicate(drawer));
        }
        if (drawer.hidden) {
            return false;
        }
        if (drawer.classList.contains("is-open")) {
            return true;
        }
        return drawer.getAttribute("aria-hidden") === "false";
    };

    const bindOutsideClose = (options = {}) => {
        const drawer = options.drawer;
        const close = options.close;
        const keepOpenSelector = options.keepOpenSelector || "";
        const isOpen = options.isOpen;

        if (!drawer || typeof close !== "function") {
            return () => {};
        }

        const handleDocumentClick = (event) => {
            const target = event.target;
            if (
                !isDrawerOpen(drawer, isOpen) ||
                !(target instanceof Element) ||
                drawer.contains(target) ||
                (keepOpenSelector && target.closest(keepOpenSelector))
            ) {
                return;
            }

            close({ restoreFocus: false });
        };

        document.addEventListener("click", handleDocumentClick);
        return () => document.removeEventListener("click", handleDocumentClick);
    };

    const bindEscapeClose = (options = {}) => {
        const drawer = options.drawer;
        const close = options.close;
        const isOpen = options.isOpen;
        const shouldIgnore = options.shouldIgnoreEscape;

        if (!drawer || typeof close !== "function") {
            return () => {};
        }

        const handleKeydown = (event) => {
            if (
                event.key !== "Escape" ||
                !isDrawerOpen(drawer, isOpen) ||
                (typeof shouldIgnore === "function" && shouldIgnore(event))
            ) {
                return;
            }

            close();
        };

        document.addEventListener("keydown", handleKeydown);
        return () => document.removeEventListener("keydown", handleKeydown);
    };

    const bindDismiss = (options = {}) => {
        const unbindOutside = bindOutsideClose(options);
        const unbindEscape = bindEscapeClose(options);

        return () => {
            unbindOutside();
            unbindEscape();
        };
    };

    const toElement = (target) => {
        if (!target) {
            return null;
        }
        if (target instanceof Element || target === document) {
            return target;
        }
        if (typeof target === "string") {
            return document.querySelector(target);
        }
        return null;
    };

    const toElements = (target) => {
        if (!target) {
            return [];
        }
        if (target instanceof Element) {
            return [target];
        }
        if (typeof target === "string") {
            return Array.from(document.querySelectorAll(target));
        }
        return Array.from(target);
    };

    const setText = (element, value, fallback = "-") => {
        if (!element) {
            return;
        }
        const nextValue = value === null || value === undefined || value === "" ? fallback : String(value);
        element.textContent = nextValue;
        element.title = nextValue;
    };

    const resolveFieldTarget = (field) => {
        if (!field) {
            return null;
        }
        if (field instanceof Element || typeof field === "string") {
            return toElement(field);
        }
        return toElement(field.target);
    };

    const resolveFieldValue = (field, key, data, row) => {
        if (field && typeof field === "object" && !(field instanceof Element)) {
            if (typeof field.value === "function") {
                return field.value(data, row);
            }
            return data[field.source || field.key || key];
        }
        return data[key];
    };

    const normalizeListData = (data) => {
        if (Array.isArray(data)) {
            return data;
        }
        return Array.isArray(data?.content) ? data.content : [];
    };

    const bindCategoryPicker = (options = {}) => {
        const input = toElement(options.input);
        const label = toElement(options.label);
        const modal = toElement(options.modal);
        const search = toElement(options.search);
        const list = toElement(options.list);
        const message = toElement(options.message);
        const openButtons = toElements(options.openButtons);
        const closeButtons = toElements(options.closeButtons);
        const clearButtons = toElements(options.clearButtons);
        const defaultLabel = options.defaultLabel || "전체";
        const loadingMessage = options.loadingMessage || "분류 목록을 불러오는 중입니다.";
        const emptyMessage = options.emptyMessage || "등록된 분류가 없습니다.";
        const noResultMessage = options.noResultMessage || "검색된 분류가 없습니다.";
        const loadFailureMessage = options.loadFailureMessage || "분류를 불러오지 못했습니다.";
        const pageSize = options.size || 100;

        let categories = normalizeListData(options.categories || []);
        let loaded = categories.length > 0;
        let loading = false;

        const categoryId = (category) => category?.categoryId ?? category?.id ?? "";
        const categoryName = (category) => category?.categoryName || category?.name || "이름 없음";
        const categoryDescription = (category) => category?.description || "설명 없음";
        const selectedValue = () => input?.value || "";
        const selectedCategory = () => categories.find((category) => String(categoryId(category)) === String(selectedValue())) || null;

        const setMessage = (text = "") => {
            if (message) {
                message.textContent = text;
            }
        };

        const appendEmpty = (text) => {
            if (!list) {
                return;
            }

            list.innerHTML = "";
            const empty = document.createElement("p");
            empty.className = "spec-builder-empty";
            empty.textContent = text;
            list.append(empty);
        };

        const syncLabel = () => {
            if (!label) {
                return;
            }
            label.textContent = selectedCategory() ? categoryName(selectedCategory()) : defaultLabel;
        };

        const matchesKeyword = (category, keyword) => {
            if (!keyword) {
                return true;
            }

            const target = `${categoryName(category)} ${categoryDescription(category)}`.toLowerCase();
            return target.includes(keyword.toLowerCase());
        };

        const render = () => {
            if (!list) {
                return;
            }

            if (!loaded && loading) {
                appendEmpty(loadingMessage);
                return;
            }

            const keyword = search?.value.trim() || "";
            const selectedCategoryId = selectedValue();
            const filteredCategories = categories.filter((category) => matchesKeyword(category, keyword));
            list.innerHTML = "";

            if (filteredCategories.length === 0) {
                appendEmpty(keyword ? noResultMessage : emptyMessage);
                return;
            }

            filteredCategories.forEach((category) => {
                const button = document.createElement("button");
                button.type = "button";
                button.className = "category-picker-option";
                if (String(categoryId(category)) === String(selectedCategoryId)) {
                    button.classList.add("is-selected");
                }

                const name = document.createElement("strong");
                name.textContent = categoryName(category);

                const description = document.createElement("small");
                description.textContent = categoryDescription(category);

                button.append(name, description);
                button.addEventListener("click", () => {
                    setValue(categoryId(category), {
                        emitChange: true,
                        close: true
                    });
                });

                list.append(button);
            });
        };

        const buildApiUrl = (companyCode) => {
            if (typeof options.apiUrl === "function") {
                return options.apiUrl(companyCode);
            }
            if (options.apiUrl) {
                return options.apiUrl;
            }
            if (!companyCode) {
                return "";
            }
            return `/api/workspaces/${encodeURIComponent(companyCode)}/categories?size=${pageSize}`;
        };

        const buildApiOptions = (companyCode) => ({
            authRedirect: true,
            loginCompanyCode: companyCode,
            ...(typeof options.apiOptions === "function" ? options.apiOptions(companyCode) : options.apiOptions || {})
        });

        const load = async () => {
            const companyCode = options.companyCode || getCompanyCode();
            const apiUrl = buildApiUrl(companyCode);

            if (!apiUrl || !window.PcsApi?.getData) {
                categories = [];
                loaded = true;
                appendEmpty(loadFailureMessage);
                syncLabel();
                return categories;
            }

            loading = true;
            setMessage("");
            appendEmpty(loadingMessage);

            try {
                const data = await window.PcsApi.getData(apiUrl, buildApiOptions(companyCode));
                categories = normalizeListData(data);
                loaded = true;
                syncLabel();
                render();
                return categories;
            } catch (error) {
                categories = [];
                loaded = true;
                setMessage(error?.message || loadFailureMessage);
                syncLabel();
                render();
                return categories;
            } finally {
                loading = false;
            }
        };

        function setValue(value, setOptions = {}) {
            if (input) {
                input.value = value ? String(value) : "";
            }
            syncLabel();
            render();

            if (setOptions.close && modal) {
                modal.close();
            }
            if (setOptions.emitChange && typeof options.onChange === "function") {
                options.onChange(input?.value || "", selectedCategory());
            }
        }

        const open = () => {
            if (!modal) {
                return;
            }

            if (search) {
                search.value = "";
            }
            setMessage("");
            render();
            if (typeof modal.showModal === "function" && !modal.open) {
                modal.showModal();
            }
            if (!loaded && !loading) {
                load();
            }
            window.setTimeout(() => search?.focus(), 0);
        };

        const close = () => {
            modal?.close();
        };

        openButtons.forEach((button) => button.addEventListener("click", open));
        closeButtons.forEach((button) => button.addEventListener("click", close));
        clearButtons.forEach((button) => {
            button.addEventListener("click", () => {
                setValue("", {
                    emitChange: true,
                    close: true
                });
            });
        });
        search?.addEventListener("input", render);
        modal?.addEventListener("click", (event) => {
            if (event.target === modal) {
                close();
            }
        });

        syncLabel();
        render();

        return {
            load,
            render,
            open,
            close,
            setValue,
            getValue: selectedValue,
            getSelectedCategory: selectedCategory
        };
    };

    const bindDatasetDetailDrawer = (options = {}) => {
        const drawer = toElement(options.drawer);
        const container = toElement(options.container) || document;
        const rowSelector = options.rowSelector || "";
        const fields = options.fields || {};
        const closeButtons = toElements(options.closeButtons);
        const activeClass = options.activeClass || "is-selected";
        const keepOpenSelector = options.keepOpenSelector || rowSelector;
        const clearSelectionOnClose = options.clearSelectionOnClose !== false;

        if (!drawer || !rowSelector) {
            return {
                open: () => {},
                close: () => {},
                update: () => {}
            };
        }

        const findRows = () => Array.from(container.querySelectorAll(rowSelector));

        const setDrawerOpen = (isOpen) => {
            if (isOpen) {
                drawer.hidden = false;
            }
            drawer.classList.toggle("is-open", isOpen);
            drawer.setAttribute("aria-hidden", String(!isOpen));
        };

        const open = () => setDrawerOpen(true);

        const clearSelection = () => {
            findRows().forEach((row) => {
                row.classList.remove(activeClass);
                row.removeAttribute("aria-selected");
            });
        };

        const close = () => {
            setDrawerOpen(false);
            if (clearSelectionOnClose) {
                clearSelection();
            }
        };

        const update = (row) => {
            if (!row) {
                return;
            }

            findRows().forEach((item) => {
                const isSelected = item === row;
                item.classList.toggle(activeClass, isSelected);
                item.setAttribute("aria-selected", String(isSelected));
            });

            const data = row.dataset || {};
            Object.entries(fields).forEach(([key, field]) => {
                const target = resolveFieldTarget(field);
                const value = resolveFieldValue(field, key, data, row);
                const fallback = field && typeof field === "object" && !(field instanceof Element)
                        ? field.fallback || "-"
                        : "-";
                setText(target, value, fallback);
            });

            if (typeof options.onUpdate === "function") {
                options.onUpdate(row, data);
            }
            open();
        };

        container.addEventListener("click", (event) => {
            const target = event.target;
            const row = target instanceof Element ? target.closest(rowSelector) : null;
            if (!row || !container.contains(row)) {
                return;
            }
            update(row);
        });

        container.addEventListener("keydown", (event) => {
            if (event.key !== "Enter" && event.key !== " ") {
                return;
            }

            const target = event.target;
            const row = target instanceof Element ? target.closest(rowSelector) : null;
            if (!row || !container.contains(row)) {
                return;
            }

            event.preventDefault();
            update(row);
        });

        closeButtons.forEach((button) => {
            button.addEventListener("click", () => close());
        });

        bindDismiss({
            drawer,
            close,
            keepOpenSelector,
            isOpen: options.isOpen,
            shouldIgnoreEscape: options.shouldIgnoreEscape
        });

        return {
            open,
            close,
            update
        };
    };

    window.PcsWorkspace = {
        getCompanyCode,
        updateWorkspaceLinks
    };
    window.PcsFormat = {
        date,
        number
    };
    window.PcsHtml = {
        escape: escapeHtml,
        setText
    };
    window.PcsFeedback = {
        toast
    };
    window.PcsForm = {
        setSaving
    };
    window.PcsTable = {
        clearRows,
        textCell,
        emptyRow
    };
    window.PcsDrawer = {
        isOpen: isDrawerOpen,
        bindOutsideClose,
        bindEscapeClose,
        bindDismiss,
        bindDatasetDetailDrawer
    };
    window.PcsCategoryPicker = {
        bind: bindCategoryPicker
    };
})(window);
