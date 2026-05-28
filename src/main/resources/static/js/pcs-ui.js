(function (window, document) {
    const FLASH_TOAST_KEY = "pcsFlashToast";
    const DEFAULT_TOAST_DURATION = 3000;
    const TOAST_TYPES = new Set(["info", "success", "warning", "error"]);

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

    window.PcsUi = {
        toast,
        setFlashToast,
        consumeFlashToast
    };
})(window, document);
