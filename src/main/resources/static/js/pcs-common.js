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
            FAIL: "불합격"
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

    window.PcsWorkspace = {
        getCompanyCode,
        updateWorkspaceLinks
    };
    window.PcsFormat = {
        date,
        number
    };
    window.PcsHtml = {
        escape: escapeHtml
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
        grade: (value, fallback = "미정") => label("grade", value, fallback),
        unitStatus: (value, fallback) => label("unitStatus", value, fallback),
        salesStatus: (value, fallback) => label("salesStatus", value, fallback),
        inspectionResult: (value, fallback) => label("inspectionResult", value, fallback),
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
        bindDismiss
    };
})(window);
