(function (window, document) {
    const FLASH_TOAST_KEY = "pcsFlashToast";
    const DEFAULT_TOAST_DURATION = 3000;
    const TOAST_TYPES = new Set(["info", "success", "warning", "error"]);
    const MODAL_SCROLL_LOCK_CLASS = "pcs-modal-scroll-locked";
    const MODAL_SCROLLBAR_COMPENSATION = "--pcs-modal-scrollbar-compensation";

    let modalScrollLocked = false;

    const normalizeToast = (options) => {
        const payload = typeof options === "string" ? { message: options } : (options || {});
        const message = String(payload.message || "").trim();
        const type = TOAST_TYPES.has(payload.type) ? payload.type : "info";
        const duration = Number(payload.duration) > 0 ? Number(payload.duration) : DEFAULT_TOAST_DURATION;

        return {
            message,
            type,
            duration
        };
    };

    const ensureToastRegion = () => {
        let region = document.querySelector("[data-pcs-toast-region]");

        if (region) {
            return region;
        }

        region = document.createElement("div");
        region.className = "pcs-toast-region";
        region.dataset.pcsToastRegion = "";
        region.setAttribute("role", "status");
        region.setAttribute("aria-live", "polite");
        region.setAttribute("aria-atomic", "false");
        document.body.append(region);
        return region;
    };

    const toast = (options) => {
        const payload = normalizeToast(options);

        if (!payload.message) {
            return null;
        }

        const toastElement = document.createElement("div");
        toastElement.className = `pcs-toast pcs-toast-${payload.type}`;
        toastElement.textContent = payload.message;

        ensureToastRegion().append(toastElement);

        requestAnimationFrame(() => {
            toastElement.classList.add("is-visible");
        });

        window.setTimeout(() => {
            toastElement.classList.remove("is-visible");
            toastElement.addEventListener("transitionend", () => toastElement.remove(), { once: true });
        }, payload.duration);

        return toastElement;
    };

    const setFlashToast = (options) => {
        const payload = normalizeToast(options);

        if (!payload.message) {
            return;
        }

        try {
            window.sessionStorage.setItem(FLASH_TOAST_KEY, JSON.stringify(payload));
        } catch (error) {
            // Storage can be blocked in private or restricted browser modes.
        }
    };

    const removeFlashToast = () => {
        try {
            window.sessionStorage.removeItem(FLASH_TOAST_KEY);
        } catch (error) {
            // Ignore storage cleanup failures.
        }
    };

    const consumeFlashToast = () => {
        let payload = null;

        try {
            const rawPayload = window.sessionStorage.getItem(FLASH_TOAST_KEY);
            removeFlashToast();
            payload = rawPayload ? JSON.parse(rawPayload) : null;
        } catch (error) {
            removeFlashToast();
        }

        if (payload?.message) {
            toast(payload);
        }

        return payload;
    };

    const hasOpenDialog = () => Boolean(document.querySelector("dialog[open]"));

    const scrollbarWidth = () => Math.max(0, window.innerWidth - document.documentElement.clientWidth);

    const lockModalScroll = () => {
        if (modalScrollLocked || !document.body) {
            return;
        }

        const compensation = scrollbarWidth();
        document.documentElement.classList.add(MODAL_SCROLL_LOCK_CLASS);
        document.body.classList.add(MODAL_SCROLL_LOCK_CLASS);
        document.body.style.setProperty(MODAL_SCROLLBAR_COMPENSATION, `${compensation}px`);
        modalScrollLocked = true;
    };

    const unlockModalScroll = () => {
        if (!modalScrollLocked || hasOpenDialog()) {
            return;
        }

        document.documentElement.classList.remove(MODAL_SCROLL_LOCK_CLASS);
        document.body?.classList.remove(MODAL_SCROLL_LOCK_CLASS);
        document.body?.style.removeProperty(MODAL_SCROLLBAR_COMPENSATION);
        modalScrollLocked = false;
    };

    const syncModalScrollLock = () => {
        if (hasOpenDialog()) {
            lockModalScroll();
            return;
        }
        unlockModalScroll();
    };

    const bindDialogScrollLock = () => {
        if (!window.HTMLDialogElement?.prototype) {
            return;
        }

        const dialogPrototype = window.HTMLDialogElement.prototype;
        const originalShowModal = dialogPrototype.showModal;
        const originalClose = dialogPrototype.close;

        if (typeof originalShowModal === "function" && !originalShowModal.__pcsScrollLockPatched) {
            const patchedShowModal = function (...args) {
                const result = originalShowModal.apply(this, args);
                syncModalScrollLock();
                return result;
            };
            patchedShowModal.__pcsScrollLockPatched = true;
            dialogPrototype.showModal = patchedShowModal;
        }

        if (typeof originalClose === "function" && !originalClose.__pcsScrollLockPatched) {
            const patchedClose = function (...args) {
                const result = originalClose.apply(this, args);
                window.setTimeout(syncModalScrollLock, 0);
                return result;
            };
            patchedClose.__pcsScrollLockPatched = true;
            dialogPrototype.close = patchedClose;
        }

        document.addEventListener("close", () => window.setTimeout(syncModalScrollLock, 0), true);
        document.addEventListener("cancel", () => window.setTimeout(syncModalScrollLock, 0), true);

        if (window.MutationObserver) {
            const observer = new MutationObserver(syncModalScrollLock);
            observer.observe(document.documentElement, {
                attributes: true,
                attributeFilter: ["open"],
                subtree: true
            });
        }

        syncModalScrollLock();
    };

    bindDialogScrollLock();

    window.PcsUi = {
        toast,
        setFlashToast,
        consumeFlashToast,
        syncModalScrollLock
    };
})(window, document);
