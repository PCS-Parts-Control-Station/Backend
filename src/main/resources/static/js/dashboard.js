(function () {
    const companyCode = window.location.pathname.split("/").filter(Boolean)[1] || "workspace";
    const summarySection = document.querySelector("[data-dashboard-summary]");
    const todoList = document.querySelector("[data-dashboard-todos]");
    const stockList = document.querySelector("[data-dashboard-stock]");
    const recentList = document.querySelector("[data-dashboard-recent]");
    const errorBox = document.querySelector("[data-dashboard-error]");
    const PAGE_SIZE = 5;
    const todoPager = {
        root: document.querySelector("[data-dashboard-todo-pager]"),
        text: document.querySelector("[data-dashboard-todo-page-text]"),
        prev: document.querySelector("[data-dashboard-todo-prev]"),
        next: document.querySelector("[data-dashboard-todo-next]")
    };
    const recentPager = {
        root: document.querySelector("[data-dashboard-recent-pager]"),
        text: document.querySelector("[data-dashboard-recent-page-text]"),
        prev: document.querySelector("[data-dashboard-recent-prev]"),
        next: document.querySelector("[data-dashboard-recent-next]")
    };
    let todosState = [];
    let recentState = [];
    let todoPage = 0;
    let recentPage = 0;

    const numberText = (value) => {
        const number = Number(value || 0);
        return Number.isFinite(number) ? number.toLocaleString("ko-KR") : "0";
    };

    const ratioText = (value) => {
        const number = Number(value || 0);
        return Number.isFinite(number) ? String(Math.max(0, Math.min(100, Math.floor(number)))) : "0";
    };

    const dateTimeText = (value) => {
        if (!value) {
            return "-";
        }
        const normalized = String(value).replace("T", " ");
        const match = normalized.match(/^(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})/);
        if (!match) {
            return normalized;
        }
        return `${match[2]}.${match[3]} ${match[4]}:${match[5]}`;
    };

    const escapeHtml = (value) => String(value ?? "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");

    const routeHref = (route) => `/w/${encodeURIComponent(companyCode)}/${String(route || "dashboard")}`;

    const withQuery = (href, params = {}) => {
        const url = new URL(href, window.location.origin);
        Object.entries(params).forEach(([key, value]) => {
            if (value === null || value === undefined || String(value).trim() === "") {
                return;
            }
            url.searchParams.set(key, String(value).trim());
        });
        return `${url.pathname}${url.search}`;
    };

    const todoRoute = (todo) => {
        if (todo?.type === "STOCK_HOLD" || todo?.type === "STOCK_UNAVAILABLE") {
            return "part-units";
        }
        return todo?.route || "dashboard";
    };

    const todoParams = (todo) => {
        const params = {};
        if (todo?.type === "INSPECTION_WAITING") {
            params.partId = todo?.partId || "";
            params.hasWaiting = "true";
            params.partName = todo?.title || "";
            params.categoryName = todo?.categoryName || "";
            return params;
        }
        params.keyword = todo?.title || "";
        if (todo?.type === "STOCK_HOLD") {
            params.partState = "SALES_HOLD";
        }
        if (todo?.type === "STOCK_UNAVAILABLE") {
            params.partState = "SALES_UNAVAILABLE";
        }
        return params;
    };

    const todoHref = (todo) => withQuery(routeHref(todoRoute(todo)), todoParams(todo));

    const recentHref = (activity) => {
        const isStockDocument = activity?.type === "INBOUND" || activity?.type === "OUTBOUND";
        const route = isStockDocument ? "documents" : activity?.route;
        const params = {};
        if (activity?.documentNo && activity.documentNo !== "-") {
            params.documentNo = activity.documentNo;
            params.keyword = activity.documentNo;
        }
        if (isStockDocument) {
            params.documentType = activity.type;
        }
        return withQuery(routeHref(route), params);
    };

    const badgeClass = (type) => {
        switch (type) {
            case "INSPECTION_WAITING":
                return "badge-warning";
            case "STOCK_UNAVAILABLE":
                return "badge-danger";
            case "STOCK_HOLD":
                return "badge-info";
            case "OUTBOUND":
                return "badge-info";
            default:
                return "badge-info";
        }
    };

    const activityBadgeClass = (type) => {
        switch (type) {
            case "OUTBOUND":
                return "badge-warning";
            case "INITIAL":
            case "CORRECTION":
            case "REINSPECTION":
                return "badge-info";
            default:
                return "badge-active";
        }
    };

    const renderSummary = (summary = {}) => {
        document.querySelectorAll("[data-summary-value]").forEach((element) => {
            const key = element.dataset.summaryValue;
            element.textContent = numberText(summary[key]);
        });
        summarySection?.setAttribute("aria-busy", "false");
    };

    const renderStockStatus = (stockStatus = {}) => {
        const availableRatio = ratioText(stockStatus.availableRatio);
        const holdRatio = ratioText(stockStatus.holdRatio);
        const unavailableRatio = ratioText(stockStatus.unavailableRatio);
        const totalQuantity = Number(stockStatus.availableQuantity || 0)
            + Number(stockStatus.holdQuantity || 0)
            + Number(stockStatus.unavailableQuantity || 0);

        const donut = stockList?.querySelector("[data-stock-donut]");
        donut?.style.setProperty("--available", `${availableRatio}%`);
        donut?.style.setProperty("--hold", `${holdRatio}%`);
        donut?.setAttribute(
            "aria-label",
            `판매 가능 ${availableRatio}%, 판매 보류 ${holdRatio}%, 판매 불가 ${unavailableRatio}%`
        );

        const totalElement = stockList?.querySelector("[data-stock-total]");
        if (totalElement) {
            totalElement.textContent = numberText(totalQuantity);
        }

        stockList?.querySelectorAll("[data-stock-ratio]").forEach((element) => {
            const key = element.dataset.stockRatio;
            element.textContent = ratioText(stockStatus[key]);
        });

        stockList?.querySelectorAll("[data-stock-quantity]").forEach((element) => {
            const key = element.dataset.stockQuantity;
            element.textContent = numberText(stockStatus[key]);
        });
    };

    const pageCount = (items) => Math.max(1, Math.ceil(items.length / PAGE_SIZE));

    const pageItems = (items, page) => {
        const start = page * PAGE_SIZE;
        return items.slice(start, start + PAGE_SIZE);
    };

    const renderPager = (pager, items, page) => {
        if (!pager.root || !pager.text || !pager.prev || !pager.next) {
            return;
        }
        const totalPages = pageCount(items);
        pager.root.hidden = items.length <= PAGE_SIZE;
        pager.text.textContent = `${page + 1} / ${totalPages}`;
        pager.prev.disabled = page <= 0;
        pager.next.disabled = page >= totalPages - 1;
    };

    const renderTodos = () => {
        if (!todoList) {
            return;
        }
        if (!todosState.length) {
            todoList.innerHTML = '<p class="dashboard-empty-text">현재 우선 처리 항목이 없습니다.</p>';
            renderPager(todoPager, todosState, todoPage);
            return;
        }

        todoList.innerHTML = pageItems(todosState, todoPage).map((todo, index) => `
            <a href="${escapeHtml(todoHref(todo))}">
                <span class="todo-rank">${todoPage * PAGE_SIZE + index + 1}</span>
                <span class="todo-main">
                    <strong>${escapeHtml(todo.title || "-")}</strong>
                    <span class="todo-meta">
                        <small class="badge ${badgeClass(todo.type)}">${escapeHtml(todo.label || "-")}</small>
                        <small class="todo-category">품목: ${escapeHtml(todo.categoryName || "-")}</small>
                    </span>
                </span>
                <em>${numberText(todo.count)}개</em>
            </a>
        `).join("");
        renderPager(todoPager, todosState, todoPage);
    };

    const renderRecentActivities = () => {
        if (!recentList) {
            return;
        }
        if (!recentState.length) {
            recentList.innerHTML = '<p class="dashboard-empty-text">최근 처리 내역이 없습니다.</p>';
            renderPager(recentPager, recentState, recentPage);
            return;
        }

        recentList.innerHTML = pageItems(recentState, recentPage).map((activity) => `
            <a class="recent-activity-item" href="${escapeHtml(recentHref(activity))}">
                <span class="badge ${activityBadgeClass(activity.type)}">${escapeHtml(activity.label || "-")}</span>
                <span>
                    <strong>${escapeHtml(activity.title || "-")}</strong>
                    <small>${escapeHtml(activity.documentNo || "-")}</small>
                </span>
                <em>
                    <b>${numberText(activity.quantity)}개</b>
                    <time>${escapeHtml(dateTimeText(activity.processedAt))}</time>
                </em>
            </a>
        `).join("");
        renderPager(recentPager, recentState, recentPage);
    };

    const showError = (message) => {
        if (!errorBox) {
            return;
        }
        errorBox.textContent = message;
        errorBox.hidden = false;
    };

    const loadDashboard = async () => {
        if (!window.PcsApi) {
            showError("운영 현황을 불러올 수 없습니다.");
            return;
        }

        try {
            await window.PcsApi.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/me`, {
                authRedirect: true,
                loginCompanyCode: companyCode
            });

            const dashboard = await window.PcsApi.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/dashboard`, {
                authRedirect: true,
                loginCompanyCode: companyCode
            });
            renderSummary(dashboard?.summary);
            renderStockStatus(dashboard?.stockStatus);
            todosState = dashboard?.todos || [];
            recentState = dashboard?.recentActivities || [];
            todoPage = 0;
            recentPage = 0;
            renderTodos();
            renderRecentActivities();
        } catch (error) {
            renderSummary();
            renderStockStatus();
            todosState = [];
            recentState = [];
            todoPage = 0;
            recentPage = 0;
            renderTodos();
            renderRecentActivities();
            showError(error.message || "운영 현황을 불러오지 못했습니다.");
        }
    };

    todoPager.prev?.addEventListener("click", () => {
        todoPage = Math.max(0, todoPage - 1);
        renderTodos();
    });

    todoPager.next?.addEventListener("click", () => {
        todoPage = Math.min(pageCount(todosState) - 1, todoPage + 1);
        renderTodos();
    });

    recentPager.prev?.addEventListener("click", () => {
        recentPage = Math.max(0, recentPage - 1);
        renderRecentActivities();
    });

    recentPager.next?.addEventListener("click", () => {
        recentPage = Math.min(pageCount(recentState) - 1, recentPage + 1);
        renderRecentActivities();
    });

    void loadDashboard();
})();
