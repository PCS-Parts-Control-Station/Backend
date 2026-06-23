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

    const bindOutsideClose = (options = {}) => {
        const drawer = options.drawer;
        const close = options.close;
        const keepOpenSelector = options.keepOpenSelector || "";

        if (!drawer || typeof close !== "function") {
            return () => {};
        }

        const handleDocumentClick = (event) => {
            const target = event.target;
            if (
                !drawer.classList.contains("is-open") ||
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
    window.PcsDrawer = {
        bindOutsideClose
    };
})(window);
