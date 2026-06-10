(function () {
    const SIDEBAR_FRAGMENT_URL = "/fragments/workspace-sidebar.html";
    const companyCode = window.location.pathname.split("/").filter(Boolean)[1] || "workspace";
    const sidebarPlaceholder = document.querySelector("[data-workspace-sidebar]");
    const pageActiveRoute = sidebarPlaceholder?.dataset.activeRoute || "";
    const isCollapsibleSidebarPage = document.body.classList.contains("has-collapsible-sidebar");

    if (isCollapsibleSidebarPage) {
        document.body.classList.add("sidebar-collapsed");
    }

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
        if (segments[0] === "w") {
            return segments.slice(2).join("/") || "dashboard";
        }
        return "dashboard";
    };

    const applyActiveRoute = () => {
        const activeRoute = getActiveRoute();
        const currentPath = window.location.pathname;

        document.querySelectorAll(".sidebar-nav [data-route]").forEach((link) => {
            const route = link.dataset.route;
            const isActive = route === activeRoute || 
                             (route === "inbound" && currentPath.includes("/inbound/"));
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
        let sidebarAnimationTimer = null;

        if (!toggle || !backdrop) {
            return;
        }

        const syncToggleState = () => {
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

        const lockPageScroll = () => {
            const scrollbarWidth = Math.max(0, window.innerWidth - document.documentElement.clientWidth);
            body.style.setProperty("--sidebar-scrollbar-compensation", `${scrollbarWidth}px`);
            body.classList.add("sidebar-scroll-locked");
        };

        const unlockPageScroll = () => {
            body.classList.remove("sidebar-scroll-locked");
            body.style.removeProperty("--sidebar-scrollbar-compensation");
        };

        const closeMenu = (animate = true) => {
            if (animate) {
                animateSidebar();
            }
            body.classList.remove("sidebar-open");
            body.classList.add("sidebar-collapsed");
            unlockPageScroll();
            syncToggleState();
        };

        const openMenu = () => {
            animateSidebar();
            lockPageScroll();
            body.classList.remove("sidebar-collapsed");
            body.classList.add("sidebar-open");
            syncToggleState();
        };

        toggle.addEventListener("click", () => {
            if (body.classList.contains("sidebar-open")) {
                closeMenu();
                return;
            }
            openMenu();
        });

        backdrop.addEventListener("click", () => closeMenu());

        document.addEventListener("keydown", (event) => {
            if (event.key === "Escape" && body.classList.contains("sidebar-open")) {
                closeMenu();
            }
        });

        closeMenu(false);
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
