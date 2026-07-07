(function (window) {
    const DEFAULT_SIZE = 20;
    const DEFAULT_VISIBLE_PAGES = 5;

    const toNumber = (value, fallback) => {
        const number = Number(value);
        return Number.isFinite(number) ? number : fallback;
    };

    const normalizePageData = (data, fallbackSize = DEFAULT_SIZE) => {
        if (Array.isArray(data)) {
            return {
                content: data,
                page: 0,
                size: data.length || fallbackSize,
                totalElements: data.length,
                totalPages: data.length ? 1 : 0,
                hasPrevious: false,
                hasNext: false,
                summary: null
            };
        }

        const page = Math.max(0, toNumber(data?.page, 0));
        const size = Math.max(1, toNumber(data?.size, fallbackSize));
        const totalElements = Math.max(0, toNumber(data?.totalElements, 0));
        const totalPages = Math.max(0, toNumber(data?.totalPages, 0));

        return {
            content: Array.isArray(data?.content) ? data.content : Array.isArray(data?.items) ? data.items : [],
            page,
            size,
            totalElements,
            totalPages,
            hasPrevious: data?.hasPrevious === true,
            hasNext: data?.hasNext === true,
            summary: data?.summary || null
        };
    };

    const buildParams = ({ page = 0, size = DEFAULT_SIZE, form = null, extraParams = {} } = {}) => {
        const params = new URLSearchParams({
            page: String(Math.max(0, page)),
            size: String(Math.max(1, size))
        });

        if (form) {
            const formData = new FormData(form);
            for (const [key, value] of formData.entries()) {
                const trimmed = String(value).trim();
                if (trimmed) {
                    params.set(key, trimmed);
                }
            }
        }

        Object.entries(extraParams).forEach(([key, value]) => {
            if (value === null || value === undefined || value === "") {
                return;
            }
            params.set(key, String(value));
        });

        return params;
    };

    const formatPageInfo = (pageData) => {
        if (!pageData.totalPages) {
            return "0건";
        }
        return `${pageData.page + 1} / ${pageData.totalPages} 페이지 · 총 ${pageData.totalElements.toLocaleString("ko-KR")}건`;
    };

    const getVisiblePages = (pageData, visibleCount = DEFAULT_VISIBLE_PAGES) => {
        const totalPages = Math.max(0, toNumber(pageData?.totalPages, 0));
        const currentPage = Math.min(Math.max(0, toNumber(pageData?.page, 0)), Math.max(0, totalPages - 1));
        const maxVisible = Math.max(1, toNumber(visibleCount, DEFAULT_VISIBLE_PAGES));

        if (totalPages <= maxVisible) {
            return Array.from({ length: totalPages }, (_, index) => index);
        }

        const half = Math.floor(maxVisible / 2);
        const maxStart = Math.max(0, totalPages - maxVisible);
        const start = Math.min(Math.max(0, currentPage - half), maxStart);

        return Array.from({ length: maxVisible }, (_, index) => start + index);
    };

    const ensureNumberContainer = ({ container, prevButton, nextButton, numberContainer }) => {
        if (numberContainer) {
            return numberContainer;
        }

        const actions = prevButton?.parentElement || nextButton?.parentElement || container?.querySelector(".pagination-actions");
        if (!actions) {
            return null;
        }

        const existing = actions.querySelector("[data-page-numbers]");
        if (existing) {
            return existing;
        }

        const created = document.createElement("span");
        created.className = "pagination-numbers";
        created.dataset.pageNumbers = "";
        created.setAttribute("aria-label", "페이지 번호");

        if (nextButton) {
            actions.insertBefore(created, nextButton);
        } else {
            actions.append(created);
        }

        return created;
    };

    const emitPageChange = ({ container, page }) => {
        container?.dispatchEvent(new CustomEvent("pcs:page-change", {
            bubbles: true,
            detail: { page }
        }));
    };

    const renderNumberButtons = ({ pageData, container, prevButton, nextButton, numberContainer, onPageClick, visiblePages }) => {
        const numbers = ensureNumberContainer({ container, prevButton, nextButton, numberContainer });
        if (!numbers) {
            return;
        }

        const pages = getVisiblePages(pageData, visiblePages);
        numbers.replaceChildren();
        numbers.hidden = pageData.totalPages <= 1;

        pages.forEach((page) => {
            const button = document.createElement("button");
            button.type = "button";
            button.className = "pagination-number";
            button.textContent = String(page + 1);
            button.dataset.page = String(page);
            button.setAttribute("aria-label", `${page + 1} 페이지`);

            if (page === pageData.page) {
                button.classList.add("is-active");
                button.disabled = true;
                button.setAttribute("aria-current", "page");
            } else {
                button.addEventListener("click", () => {
                    if (typeof onPageClick === "function") {
                        onPageClick(page);
                        return;
                    }
                    emitPageChange({ container, page });
                });
            }

            numbers.append(button);
        });
    };

    const updateControls = ({
        pageData,
        container,
        info,
        prevButton,
        nextButton,
        numberContainer = null,
        onPageClick = null,
        visiblePages = DEFAULT_VISIBLE_PAGES
    }) => {
        if (container) {
            container.hidden = pageData.totalPages <= 1;
        }
        if (info) {
            info.textContent = formatPageInfo(pageData);
        }
        if (prevButton) {
            prevButton.disabled = !pageData.hasPrevious;
        }
        if (nextButton) {
            nextButton.disabled = !pageData.hasNext;
        }
        renderNumberButtons({ pageData, container, prevButton, nextButton, numberContainer, onPageClick, visiblePages });
    };

    const captureScroll = () => ({
        top: window.scrollY,
        left: window.scrollX
    });

    const restoreScrollPosition = (position) => {
        if (!position) {
            return;
        }
        window.requestAnimationFrame(() => {
            window.scrollTo(position.left, position.top);
            window.requestAnimationFrame(() => window.scrollTo(position.left, position.top));
        });
    };

    const withPreservedScroll = async (task) => {
        const position = captureScroll();
        try {
            return await task();
        } finally {
            restoreScrollPosition(position);
        }
    };

    const setListLoading = ({ container = null, target = null, overlay = null, isLoading = false } = {}) => {
        container?.classList.toggle("is-list-loading", isLoading);
        target?.setAttribute("aria-busy", String(isLoading));
        if (overlay) {
            overlay.hidden = !isLoading;
            overlay.setAttribute("aria-hidden", String(!isLoading));
        }
    };

    const setPaginationButtonsLoading = ({ pagination = null, prevButton = null, nextButton = null, pageData = null, isLoading = false } = {}) => {
        pagination?.querySelectorAll(".pagination-actions button").forEach((button) => {
            if (button === prevButton) {
                button.disabled = isLoading || !pageData?.hasPrevious;
                return;
            }
            if (button === nextButton) {
                button.disabled = isLoading || !pageData?.hasNext;
                return;
            }
            if (button.classList.contains("pagination-number")) {
                const page = Number(button.dataset.page);
                button.disabled = isLoading || page === Number(pageData?.page ?? 0);
            }
        });
    };

    const setLoadingState = ({
        listContainer = null,
        target = null,
        overlay = null,
        pagination = null,
        prevButton = null,
        nextButton = null,
        pageData = null,
        isLoading = false
    } = {}) => {
        setListLoading({
            container: listContainer,
            target,
            overlay,
            isLoading
        });
        setPaginationButtonsLoading({
            pagination,
            prevButton,
            nextButton,
            pageData,
            isLoading
        });
    };

    window.PcsPagination = {
        DEFAULT_SIZE,
        normalizePageData,
        buildParams,
        formatPageInfo,
        getVisiblePages,
        updateControls,
        setListLoading,
        setPaginationButtonsLoading,
        setLoadingState,
        captureScroll,
        restoreScrollPosition,
        withPreservedScroll
    };
})(window);
