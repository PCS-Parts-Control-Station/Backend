(function (window) {
    const getCompanyCode = () => {
        const match = window.location.pathname.match(/^\/w\/([^/]+)/);
        return match ? decodeURIComponent(match[1]) : "";
    };

    const createWorkspaceContext = (value = getCompanyCode()) => {
        const companyCode = String(value || "").trim();
        const apiBase = companyCode
            ? `/api/workspaces/${encodeURIComponent(companyCode)}`
            : "";

        return {
            companyCode,
            apiBase,
            apiUrl: (path = "") => `${apiBase}${String(path || "")}`,
            apiOptions: (options = {}) => ({
                authRedirect: true,
                loginCompanyCode: companyCode,
                ...options
            })
        };
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

    const localDate = (value = new Date()) => {
        const target = value instanceof Date ? value : new Date(value);
        if (Number.isNaN(target.getTime())) {
            return "-";
        }
        const year = String(target.getFullYear());
        const month = String(target.getMonth() + 1).padStart(2, "0");
        const day = String(target.getDate()).padStart(2, "0");
        return `${year}-${month}-${day}`;
    };

    const dateTime = (value) => {
        if (!value) {
            return "-";
        }
        if (Array.isArray(value)) {
            const [year, month, day, hour = 0, minute = 0] = value;
            if (year && month && day) {
                return `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")} ${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`;
            }
        }
        const text = String(value);
        if (/^\d{4}-\d{2}-\d{2}/.test(text)) {
            return text.replace("T", " ").slice(0, 16);
        }
        const target = new Date(value);
        if (Number.isNaN(target.getTime())) {
            return text.replace("T", " ").slice(0, 16);
        }
        const hour = String(target.getHours()).padStart(2, "0");
        const minute = String(target.getMinutes()).padStart(2, "0");
        return `${localDate(target)} ${hour}:${minute}`;
    };

    const number = (value) => {
        const numericValue = Number(value ?? 0);
        return Number.isFinite(numericValue) ? numericValue.toLocaleString("ko-KR") : "0";
    };

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

    const LABELS = {
        documentType: {
            INBOUND: "입고",
            OUTBOUND: "출고"
        },
        documentStatus: {
            COMPLETED: "완료",
            CANCELED: "취소"
        },
        partnerRole: {
            SUPPLIER: "공급처",
            CUSTOMER: "고객",
            CLIENT: "고객",
            BUYER: "고객",
            BOTH: "공급처/고객"
        },
        partnerRoleLong: {
            SUPPLIER: "공급 거래처",
            CUSTOMER: "출고 거래처",
            CLIENT: "출고 거래처",
            BUYER: "출고 거래처",
            BOTH: "공급/출고 거래처"
        },
        partnerType: {
            PC_CAFE: "피시방",
            PERSON: "개인",
            COMPANY: "기업",
            ETC: "기타"
        },
        userRole: {
            OWNER: "최고 관리자",
            ADMIN: "관리자",
            STAFF: "작업자"
        },
        grade: {
            A: "A",
            B: "B",
            C: "C",
            DEFECTIVE: "불량",
            NONE: "미정"
        },
        unitStatus: {
            IN_STOCK: "보관",
            OUTBOUND: "출고",
            DISPOSED: "폐기",
            CANCELED: "취소"
        },
        salesStatus: {
            AVAILABLE: "판매 가능",
            HOLD: "판매 보류",
            UNAVAILABLE: "판매 불가"
        },
        inspectionResult: {
            PASS: "통과",
            FAIL: "불합격",
            WARN: "주의",
            NA: "해당 없음"
        },
        inspectionStatus: {
            WAITING: "검수 전",
            IN_PROGRESS: "진행 중",
            COMPLETED: "완료"
        },
        inspectionType: {
            INITIAL: "최초",
            CORRECTION: "정정",
            REINSPECTION: "재검수"
        },
        inspectionItemGroup: {
            BASIC: "주요 검수 항목",
            DETAIL: "추가 검수 항목"
        },
        inspectionInputType: {
            CHECK: "통과/불합격",
            NUMBER: "숫자",
            TEXT: "텍스트",
            SELECT: "선택"
        }
    };

    const normalizeCode = (value) => String(value || "").trim().toUpperCase();

    const label = (group, value, fallback = "-") => {
        const code = normalizeCode(value);
        if (!code) {
            return fallback;
        }
        return LABELS[group]?.[code] || value || fallback;
    };

    const documentTypeClass = (type) => {
        const code = normalizeCode(type);
        if (code === "INBOUND") {
            return "badge-blue";
        }
        if (code === "OUTBOUND") {
            return "badge-orange";
        }
        return "badge-gray";
    };

    const documentStatusClass = (status) => normalizeCode(status) === "CANCELED" ? "badge-inactive" : "badge-active";

    const gradeClass = (grade) => {
        const code = normalizeCode(grade);
        if (code === "A") return "grade-a";
        if (code === "B") return "grade-b";
        if (code === "C") return "grade-c";
        if (code === "DEFECTIVE") return "grade-defective";
        return "";
    };

    const gradeBadgeClass = (grade) => {
        const code = normalizeCode(grade);
        if (code === "DEFECTIVE") return "badge-danger";
        if (code === "NONE") return "badge-grade-none";
        if (code === "A") return "badge-grade-a";
        if (code === "B") return "badge-grade-b";
        if (code === "C") return "badge-grade-c";
        return "badge-blue";
    };

    const unitStatusBadgeClass = (status) => {
        const code = normalizeCode(status);
        if (code === "OUTBOUND") return "badge-warning";
        if (code === "DISPOSED" || code === "CANCELED") return "badge-danger";
        return "badge-active";
    };

    const currentSalesStatus = (unitStatus, salesStatus) => {
        const unitCode = normalizeCode(unitStatus);
        if (unitCode === "OUTBOUND") {
            return normalizeCode(salesStatus) === "AVAILABLE" ? "판매 완료" : "출고 완료";
        }
        if (unitCode === "DISPOSED" || unitCode === "CANCELED") {
            return label("unitStatus", unitStatus);
        }
        return label("salesStatus", salesStatus);
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

    const setDrawerOpen = (drawer, isOpen) => {
        if (!drawer) {
            return;
        }
        if (isOpen) {
            drawer.hidden = false;
        }
        drawer.classList.toggle("is-open", isOpen);
        drawer.setAttribute("aria-hidden", String(!isOpen));
        if (!isOpen && drawer.classList.contains("right-side-drawer-panel")) {
            drawer.hidden = true;
        }
    };

    const openDrawer = (drawer, options = {}) => {
        setDrawerOpen(drawer, true);
        if (options.focus !== false) {
            drawer?.focus?.({ preventScroll: true });
        }
    };

    const closeDrawer = (drawer, options = {}) => {
        setDrawerOpen(drawer, false);
        if (options.restoreFocus !== false && options.lastTrigger?.isConnected) {
            options.lastTrigger.focus({ preventScroll: true });
        }
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

    const loadAllCategories = async (companyCode, options = {}) => {
        const pageSize = Math.max(1, Number(options.size || 100));
        const apiOptions = typeof options.apiOptions === "function"
            ? options.apiOptions(companyCode)
            : options.apiOptions || {
                authRedirect: true,
                loginCompanyCode: companyCode
            };
        const allCategories = [];
        let page = 0;
        let totalPages = 1;

        if (!companyCode || !window.PcsApi?.getData) {
            return allCategories;
        }

        do {
            const params = new URLSearchParams({
                page: String(page),
                size: String(pageSize)
            });
            const data = await window.PcsApi.getData(
                `/api/workspaces/${encodeURIComponent(companyCode)}/categories?${params.toString()}`,
                apiOptions
            );
            const content = normalizeListData(data);
            allCategories.push(...content);

            if (Array.isArray(data)) {
                break;
            }

            const parsedTotalPages = Number(data?.totalPages);
            totalPages = Number.isFinite(parsedTotalPages) && parsedTotalPages >= 0
                ? parsedTotalPages
                : page + 1;
            page += 1;
        } while (page < totalPages);

        return allCategories;
    };

    const categoryId = (category) => category?.categoryId ?? category?.id ?? "";

    const categoryName = (category) => category?.categoryName || category?.name || "이름 없음";

    const categoryDescription = (category) => category?.description || "설명 없음";

    const categoryPartCount = (category) => Number(category?.partCount ?? category?.partsCount ?? 0);

    const createCategoryPickerOption = (category, options = {}) => {
        const button = document.createElement("button");
        button.type = "button";
        button.className = "category-picker-option";

        const currentCategoryId = categoryId(category);
        if (String(currentCategoryId) === String(options.selectedCategoryId || "")) {
            button.classList.add("is-selected");
        }

        const name = document.createElement("strong");
        name.textContent = categoryName(category);

        const count = document.createElement("span");
        count.className = "category-picker-count";
        count.textContent = `품목 ${number(categoryPartCount(category))}개`;

        const description = document.createElement("small");
        description.textContent = categoryDescription(category);

        button.append(name, count, description);
        if (typeof options.onSelect === "function") {
            button.addEventListener("click", () => options.onSelect(category, currentCategoryId));
        }

        return button;
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
                list.append(createCategoryPickerOption(category, {
                    selectedCategoryId,
                    onSelect: (selectedCategory, selectedCategoryIdValue) => {
                        setValue(selectedCategoryIdValue, {
                            emitChange: true,
                            close: true
                        });
                    }
                }));
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
                if (options.apiUrl || typeof options.apiUrl === "function") {
                    const data = await window.PcsApi.getData(apiUrl, buildApiOptions(companyCode));
                    categories = normalizeListData(data);
                } else {
                    categories = await loadAllCategories(companyCode, {
                        size: pageSize,
                        apiOptions: buildApiOptions
                    });
                }
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
            getSelectedCategory: selectedCategory,
            getCategories: () => categories.slice()
        };
    };

    const partnerId = (partner) => partner?.partnerId ?? partner?.id ?? "";

    const partnerName = (partner) => partner?.partnerName || partner?.name || "-";

    const defaultPartnerMeta = (partner) => {
        const code = partner?.partnerCode || partner?.code || "";
        const role = label("partnerRole", partner?.partnerRole, "");
        return [code, role].filter(Boolean).join(" · ") || "거래처";
    };

    const bindPartnerPicker = (options = {}) => {
        const input = toElement(options.input);
        const modal = toElement(options.modal);
        const search = toElement(options.search);
        const list = toElement(options.list);
        const message = toElement(options.message);
        const nameTarget = toElement(options.nameTarget);
        const metaTarget = toElement(options.metaTarget);
        const openButtons = toElements(options.openButtons);
        const closeButtons = toElements(options.closeButtons);
        const allowEmpty = options.allowEmpty === true;
        const emptyName = options.emptyName || "전체 거래처";
        const emptyMeta = options.emptyMeta || "거래처를 검색해 선택해 주세요.";
        const emptyDescription = options.emptyDescription || "거래처 조건 없이 조회합니다.";
        const noResultMessage = options.noResultMessage || "검색 결과가 없습니다.";
        const unavailableMessage = options.unavailableMessage || "선택 가능한 거래처가 없습니다.";
        const loadingMessage = options.loadingMessage || "거래처를 불러오는 중입니다.";
        const failureMessage = options.failureMessage || "거래처를 불러오지 못했습니다.";
        const getMeta = typeof options.getMeta === "function" ? options.getMeta : defaultPartnerMeta;
        const pageSize = Math.min(100, Math.max(1, Number(options.size || 50)));
        const debounceMs = Math.max(0, Number(options.debounceMs ?? 200));

        let partners = normalizeListData(options.partners || []);
        let selectedPartner = options.selectedPartner || null;
        let requestId = 0;
        let searchTimer = null;
        let loading = false;
        let loaded = options.partners !== undefined;
        let loadedKeyword = loaded ? "" : null;

        const selectedValue = () => input?.value || "";

        const setMessage = (text = "", isError = false) => {
            if (!message) {
                return;
            }
            message.textContent = text;
            message.classList.toggle("is-error", isError);
        };

        const syncView = () => {
            const hasPartner = Boolean(selectedPartner && partnerId(selectedPartner));
            if (input) {
                input.value = hasPartner ? String(partnerId(selectedPartner)) : "";
            }
            if (nameTarget) {
                nameTarget.textContent = hasPartner ? partnerName(selectedPartner) : emptyName;
            }
            if (metaTarget) {
                metaTarget.textContent = hasPartner ? getMeta(selectedPartner) : emptyMeta;
            }
            openButtons.forEach((button) => button.classList.toggle("is-selected", hasPartner));
        };

        const appendPartnerOption = (partner) => {
            if (!list) {
                return;
            }
            const id = String(partnerId(partner));
            const button = document.createElement("button");
            button.type = "button";
            button.className = "partner-modal-row";
            button.dataset.partnerOption = id;
            button.classList.toggle("is-selected", id === String(partnerId(selectedPartner)));

            const content = document.createElement("span");
            const name = document.createElement("strong");
            const meta = document.createElement("small");
            name.textContent = partnerName(partner);
            meta.textContent = getMeta(partner);
            content.append(name, meta);
            button.append(content);
            list.append(button);
        };

        const render = () => {
            if (!list) {
                return;
            }
            list.innerHTML = "";

            if (allowEmpty) {
                const button = document.createElement("button");
                button.type = "button";
                button.className = "partner-modal-row";
                button.dataset.partnerOption = "";
                button.classList.toggle("is-selected", !selectedPartner);
                const content = document.createElement("span");
                const name = document.createElement("strong");
                const meta = document.createElement("small");
                name.textContent = emptyName;
                meta.textContent = emptyDescription;
                content.append(name, meta);
                button.append(content);
                list.append(button);
            }

            partners.forEach(appendPartnerOption);
            if (!partners.length) {
                const empty = document.createElement("p");
                empty.className = "partner-modal-empty";
                empty.textContent = search?.value.trim() ? noResultMessage : unavailableMessage;
                list.append(empty);
            }
        };

        const buildApiOptions = (companyCode) => ({
            authRedirect: true,
            loginCompanyCode: companyCode,
            ...(typeof options.apiOptions === "function" ? options.apiOptions(companyCode) : options.apiOptions || {})
        });

        const load = async (loadOptions = {}) => {
            const companyCode = options.companyCode || getCompanyCode();
            if (!companyCode || !window.PcsApi?.getData) {
                partners = [];
                render();
                setMessage(failureMessage, true);
                return partners;
            }

            const currentRequestId = ++requestId;
            const keyword = loadOptions.keyword ?? search?.value.trim() ?? "";
            const params = new URLSearchParams({
                active: "true",
                page: "0",
                size: String(pageSize)
            });
            if (keyword) {
                params.set("keyword", keyword);
            }
            if (options.partnerRole) {
                params.set("partnerRole", options.partnerRole);
            }

            loading = true;
            setMessage(loadingMessage);
            openButtons.forEach((button) => {
                button.disabled = true;
            });

            try {
                const apiUrl = typeof options.apiUrl === "function"
                    ? options.apiUrl(companyCode, params)
                    : options.apiUrl || `/api/workspaces/${encodeURIComponent(companyCode)}/partners?${params.toString()}`;
                const data = await window.PcsApi.getData(apiUrl, buildApiOptions(companyCode));
                if (currentRequestId !== requestId) {
                    return partners;
                }
                partners = normalizeListData(data);
                loaded = true;
                loadedKeyword = keyword;
                const currentValue = selectedValue();
                if (currentValue && !selectedPartner) {
                    selectedPartner = partners.find((partner) => String(partnerId(partner)) === String(currentValue)) || null;
                }
                syncView();
                render();
                setMessage("");
                return partners;
            } catch (error) {
                if (currentRequestId !== requestId) {
                    return partners;
                }
                partners = [];
                render();
                setMessage(error?.message || failureMessage, true);
                if (typeof options.onError === "function") {
                    options.onError(error);
                }
                return partners;
            } finally {
                if (currentRequestId === requestId) {
                    loading = false;
                    openButtons.forEach((button) => {
                        button.disabled = false;
                    });
                }
            }
        };

        const select = (partner, selectOptions = {}) => {
            selectedPartner = partner || null;
            syncView();
            render();
            setMessage("");
            if (selectOptions.close !== false) {
                modal?.close();
            }
            if (selectOptions.emitChange !== false && typeof options.onChange === "function") {
                options.onChange(selectedPartner, selectedValue());
            }
        };

        const open = () => {
            if (!modal) {
                return;
            }
            if (search) {
                search.value = "";
            }
            render();
            if (typeof modal.showModal === "function" && !modal.open) {
                modal.showModal();
            }
            if ((!loaded || loadedKeyword !== "") && !loading) {
                void load({ keyword: "" });
            }
            window.setTimeout(() => search?.focus(), 0);
        };

        const close = () => modal?.close();

        openButtons.forEach((button) => button.addEventListener("click", open));
        closeButtons.forEach((button) => button.addEventListener("click", close));
        search?.addEventListener("input", () => {
            window.clearTimeout(searchTimer);
            searchTimer = window.setTimeout(() => void load(), debounceMs);
        });
        search?.addEventListener("keydown", (event) => {
            if (event.key === "Enter") {
                event.preventDefault();
                window.clearTimeout(searchTimer);
                void load();
            }
        });
        list?.addEventListener("click", (event) => {
            const option = event.target.closest("[data-partner-option]");
            if (!option || !list.contains(option)) {
                return;
            }
            const id = option.dataset.partnerOption;
            select(id ? partners.find((partner) => String(partnerId(partner)) === id) : null);
        });
        modal?.addEventListener("click", (event) => {
            if (event.target === modal && !loading) {
                close();
            }
        });

        syncView();
        render();

        return {
            load,
            render,
            open,
            close,
            select,
            setSelected: (partner, setOptions = {}) => select(partner, {
                close: false,
                emitChange: false,
                ...setOptions
            }),
            getSelected: () => selectedPartner,
            getPartners: () => partners.slice()
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
            if (typeof options.onClose === "function") {
                options.onClose();
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
        createContext: createWorkspaceContext,
        updateWorkspaceLinks
    };
    window.PcsFormat = {
        date,
        dateTime,
        localDate,
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
    window.PcsLabels = {
        label,
        documentType: (value, fallback) => label("documentType", value, fallback),
        documentStatus: (value, fallback) => label("documentStatus", value, fallback),
        partnerRole: (value, fallback) => label("partnerRole", value, fallback),
        partnerRoleLong: (value, fallback) => label("partnerRoleLong", value, fallback),
        partnerType: (value, fallback) => label("partnerType", value, fallback),
        userRole: (value, fallback) => label("userRole", value, fallback),
        grade: (value, fallback = "미정") => label("grade", value, fallback),
        unitStatus: (value, fallback) => label("unitStatus", value, fallback),
        salesStatus: (value, fallback) => label("salesStatus", value, fallback),
        inspectionResult: (value, fallback) => label("inspectionResult", value, fallback),
        inspectionStatus: (value, fallback) => label("inspectionStatus", value, fallback),
        inspectionType: (value, fallback) => label("inspectionType", value, fallback),
        inspectionItemGroup: (value, fallback) => label("inspectionItemGroup", value, fallback),
        inspectionInputType: (value, fallback) => label("inspectionInputType", value, fallback),
        currentSalesStatus,
        documentTypeClass,
        documentStatusClass,
        gradeClass,
        gradeBadgeClass,
        unitStatusBadgeClass
    };
    window.PcsDrawer = {
        isOpen: isDrawerOpen,
        open: openDrawer,
        close: closeDrawer,
        setOpen: setDrawerOpen,
        bindOutsideClose,
        bindEscapeClose,
        bindDismiss,
        bindDatasetDetailDrawer
    };
    window.PcsCategory = {
        loadAll: loadAllCategories
    };
    window.PcsCategoryPicker = {
        bind: bindCategoryPicker,
        createOption: createCategoryPickerOption
    };
    window.PcsPartnerPicker = {
        bind: bindPartnerPicker
    };
})(window);
