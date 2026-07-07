(function (window) {
    const STORE_KEY = "__pcsNavigationState";

    const isBlank = (value) => value === null || value === undefined || String(value).trim() === "";

    const stringValue = (value) => isBlank(value) ? "" : String(value).trim();

    const normalizeKeys = (keys) => Array.isArray(keys) ? keys.filter(Boolean) : [];

    const readParams = () => new URLSearchParams(window.location.search);

    const stateObject = () => {
        const state = window.history.state;
        return state && typeof state === "object" ? { ...state } : {};
    };

    const readStore = (state = window.history.state) => {
        const store = state?.[STORE_KEY];
        return store && typeof store === "object" ? { ...store } : {};
    };

    const replaceHistoryState = (state, url = window.location.href) => {
        window.history.replaceState(state, "", url);
    };

    const buildUrl = (params) => {
        const query = params.toString();
        return `${window.location.pathname}${query ? `?${query}` : ""}${window.location.hash || ""}`;
    };

    const createUrlStateController = (options = {}) => {
        const namespace = options.namespace || window.location.pathname;
        const managedKeys = normalizeKeys(options.managedKeys);
        const defaults = options.defaults || {};

        const read = () => {
            const params = readParams();
            const current = { ...defaults };

            managedKeys.forEach((key) => {
                if (params.has(key)) {
                    current[key] = params.get(key) || "";
                }
            });

            return current;
        };

        const write = (nextState = {}, writeOptions = {}) => {
            const params = readParams();
            const merged = {
                ...read(),
                ...nextState,
            };

            managedKeys.forEach((key) => params.delete(key));
            managedKeys.forEach((key) => {
                const value = stringValue(merged[key]);
                const defaultValue = stringValue(defaults[key]);
                if (!value || value === defaultValue) {
                    return;
                }
                params.set(key, value);
            });

            const nextHistoryState = writeOptions.captureScroll === false
                ? stateObject()
                : saveScrollToState(stateObject(), writeOptions.extraState || {});
            const nextUrl = buildUrl(params);
            const method = writeOptions.mode === "push" ? "pushState" : "replaceState";
            window.history[method](nextHistoryState, "", nextUrl);
        };

        const saveScrollToState = (state = stateObject(), extraState = {}) => {
            const store = readStore(state);
            store[namespace] = {
                ...(store[namespace] || {}),
                scrollX: window.scrollX,
                scrollY: window.scrollY,
                ...extraState,
            };
            return {
                ...state,
                [STORE_KEY]: store,
            };
        };

        const saveScroll = (extraState = {}) => {
            replaceHistoryState(saveScrollToState(stateObject(), extraState));
        };

        const restoreScroll = (restoreOptions = {}) => {
            const store = readStore();
            const saved = store[namespace] || {};
            const x = Number(saved.scrollX || 0);
            const y = Number(saved.scrollY || 0);
            if (!Number.isFinite(x) || !Number.isFinite(y)) {
                return;
            }

            const behavior = restoreOptions.behavior || "auto";
            window.requestAnimationFrame(() => {
                window.scrollTo({ left: x, top: y, behavior });
                window.requestAnimationFrame(() => window.scrollTo({ left: x, top: y, behavior }));
            });
        };

        const bindScrollCapture = () => {
            const capture = () => saveScroll();
            const captureWhenHidden = () => {
                if (document.visibilityState === "hidden") {
                    capture();
                }
            };

            window.addEventListener("pagehide", capture);
            document.addEventListener("visibilitychange", captureWhenHidden);

            return () => {
                window.removeEventListener("pagehide", capture);
                document.removeEventListener("visibilitychange", captureWhenHidden);
            };
        };

        return {
            read,
            write,
            saveScroll,
            restoreScroll,
            bindScrollCapture,
        };
    };

    const captureFormState = (form, options = {}) => {
        if (!form) {
            return {};
        }

        const fields = normalizeKeys(options.fields);
        const result = {};
        const formData = new FormData(form);

        fields.forEach((field) => {
            result[field] = stringValue(formData.get(field));
        });

        return result;
    };

    const applyFormState = (form, state = {}, options = {}) => {
        if (!form) {
            return;
        }

        const fields = normalizeKeys(options.fields);
        fields.forEach((field) => {
            const element = form.elements[field];
            if (!element) {
                return;
            }
            element.value = stringValue(state[field]);
        });
    };

    const numberParam = (value, fallback = 0) => {
        const parsed = Number(value);
        return Number.isFinite(parsed) && parsed >= 0 ? Math.floor(parsed) : fallback;
    };

    window.PcsNavigationState = {
        createUrlStateController,
        captureFormState,
        applyFormState,
        numberParam,
    };
})(window);
