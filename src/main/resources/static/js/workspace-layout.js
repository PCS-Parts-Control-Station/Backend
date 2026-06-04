(function () {
    const SIDEBAR_FRAGMENT_URL = "/fragments/workspace-sidebar.html";
    const companyCode = window.location.pathname.split("/").filter(Boolean)[1] || "workspace";
    const sidebarPlaceholder = document.querySelector("[data-workspace-sidebar]");
    const pageActiveRoute = sidebarPlaceholder?.dataset.activeRoute || "";

    const applyWorkspaceContext = () => {
        document.querySelectorAll("[data-company-code]").forEach((element) => {
            element.textContent = companyCode;
        });

        document.querySelectorAll("[data-route]").forEach((link) => {
            const route = link.dataset.route;
            if (!route) {
                return;
            }
            link.href = `/w/${encodeURIComponent(companyCode)}/${route}`;
        });
    };

    const getActiveRoute = () => {
        if (pageActiveRoute) {
            return pageActiveRoute;
        }

        const segments = window.location.pathname.split("/").filter(Boolean);
        return segments[0] === "w" ? segments[2] || "dashboard" : "dashboard";
    };

    const applyActiveRoute = () => {
        const activeRoute = getActiveRoute();
        const currentPath = window.location.pathname;

        document.querySelectorAll(".sidebar-nav [data-route]").forEach((link) => {
            const route = link.dataset.route;
            const isActive = route === activeRoute || (
                    route === "inbound" && currentPath.includes("/inbound/")
            );
            link.classList.toggle("active", isActive);
            if (isActive) {
                link.setAttribute("aria-current", "page");
            } else {
                link.removeAttribute("aria-current");
            }
        });
    };

    const bindSidebarToggle = () => {
        const body = document.body;
        const toggle = document.querySelector("[data-sidebar-toggle]");
        const backdrop = document.querySelector("[data-sidebar-backdrop]");
        const desktopQuery = window.matchMedia("(min-width: 1521px)");
        let breakpointSwitchTimer = null;
        let sidebarAnimationTimer = null;

        if (!toggle || !backdrop) {
            return;
        }

        const syncToggleState = () => {
            if (desktopQuery.matches) {
                const isCollapsed = body.classList.contains("sidebar-collapsed");
                toggle.setAttribute("aria-expanded", String(!isCollapsed));
                toggle.setAttribute("aria-label", isCollapsed ? "메뉴 펼치기" : "메뉴 접기");
                return;
            }

            const isOpen = body.classList.contains("sidebar-open");
            toggle.setAttribute("aria-expanded", String(isOpen));
            toggle.setAttribute("aria-label", isOpen ? "메뉴 닫기" : "메뉴 열기");
        };

        const animateSidebar = () => {
            body.classList.add("sidebar-animating");
            window.clearTimeout(sidebarAnimationTimer);
            sidebarAnimationTimer = window.setTimeout(() => {
                body.classList.remove("sidebar-animating");
            }, 260);
        };

        const closeMenu = (animate = true) => {
            if (animate) {
                animateSidebar();
            }
            body.classList.remove("sidebar-open");
            syncToggleState();
        };

        const openMenu = () => {
            animateSidebar();
            body.classList.add("sidebar-open");
            syncToggleState();
        };

        const toggleDesktopSidebar = () => {
            animateSidebar();
            body.classList.toggle("sidebar-collapsed");
            syncToggleState();
        };

        const lockBreakpointTransition = () => {
            body.classList.add("sidebar-breakpoint-switching");
            window.clearTimeout(breakpointSwitchTimer);
            breakpointSwitchTimer = window.setTimeout(() => {
                body.classList.remove("sidebar-breakpoint-switching");
            }, 260);
        };

        toggle.addEventListener("click", () => {
            if (desktopQuery.matches) {
                toggleDesktopSidebar();
                return;
            }

            if (body.classList.contains("sidebar-open")) {
                closeMenu();
                return;
            }
            openMenu();
        });

        backdrop.addEventListener("click", closeMenu);

        document.addEventListener("keydown", (event) => {
            if (event.key === "Escape") {
                closeMenu();
            }
        });

        desktopQuery.addEventListener("change", (event) => {
            lockBreakpointTransition();
            if (event.matches) {
                closeMenu(false);
            }
            syncToggleState();
        });

        syncToggleState();
    };

    const loadSession = async () => {
        const sessionName = document.querySelector("[data-session-name]");
        if (!sessionName || !window.PcsApi || !companyCode) {
            return;
        }

        try {
            const me = await window.PcsApi.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/me`, {
                authRedirect: true,
                loginCompanyCode: companyCode
            });

            if (me?.name) {
                sessionName.textContent = `${me.name} (${me.role})`;
            }
        } catch (error) {
            sessionName.textContent = "로그인 필요";
        }
    };

    const renderSidebar = async () => {
        const placeholder = sidebarPlaceholder;
        if (!placeholder) {
            applyWorkspaceContext();
            applyActiveRoute();
            bindSidebarToggle();
            await loadSession();
            return;
        }

        try {
            const response = await fetch(SIDEBAR_FRAGMENT_URL, {
                credentials: "same-origin"
            });
            if (!response.ok) {
                throw new Error("사이드바를 불러오지 못했습니다.");
            }

            const html = await response.text();
            placeholder.insertAdjacentHTML("afterend", html);
            placeholder.remove();
        } catch (error) {
            placeholder.innerHTML = '<aside class="workspace-sidebar" aria-label="업무 메뉴"><p class="sidebar-load-failed">메뉴를 불러오지 못했습니다.</p></aside>';
        }

        applyWorkspaceContext();
        applyActiveRoute();
        bindSidebarToggle();
        await loadSession();
    };

    renderSidebar();
})();
