(() => {
    const lineList = document.querySelector("[data-line-list]");
    const lineCount = document.querySelector("[data-line-count]");
    const inboundForm = document.querySelector("#inbound-register-form");
    const submitMessage = document.querySelector("[data-submit-message]");
    const partResults = document.querySelector(".part-search-results");
    let partOptions = [...document.querySelectorAll("[data-part-option]")];
    const partnerIdInput = document.querySelector("[data-partner-id]");
    const openPartnerModalButton = document.querySelector("[data-open-partner-modal]");
    const partnerModal = document.querySelector("[data-partner-modal]");
    const closePartnerModalButtons = document.querySelectorAll("[data-close-partner-modal]");
    const partnerSearchInput = document.querySelector("[data-partner-search]");
    const partnerSearchButton = document.querySelector("[data-partner-search-button]");
    const partnerList = document.querySelector("[data-partner-list]");
    const selectedPartnerName = document.querySelector("[data-selected-partner-name]");
    const selectedPartnerMeta = document.querySelector("[data-selected-partner-meta]");
    const partnerMessage = document.querySelector("[data-partner-message]");
    const lineEmpty = document.querySelector("[data-line-empty]");
    const keywordInput = document.querySelector("[data-part-keyword]");
    const categorySelect = document.querySelector("[data-part-category]");
    const searchButton = document.querySelector("[data-part-search]");
    const partSearchMessage = document.querySelector("[data-part-search-message]");
    const selectedName = document.querySelector("[data-selected-part-name]");
    const selectedMeta = document.querySelector("[data-selected-part-meta]");
    const quantityInput = document.querySelector("[data-add-quantity]");
    const reasonInput = document.querySelector("[data-add-reason]");
    const addButton = document.querySelector("[data-add-line]");
    const partModal = document.querySelector("[data-part-modal]");
    const partModalForm = document.querySelector("[data-part-modal-form]");
    const openPartModalButton = document.querySelector("[data-open-part-modal]");
    const closePartModalButtons = document.querySelectorAll("[data-close-part-modal]");
    const partModalMessage = document.querySelector("[data-part-modal-message]");
    const newPartCategorySelect = document.querySelector("[data-new-part-category]");
    const newPartManufacturerInput = document.querySelector("[data-new-part-manufacturer]");
    const newPartNameInput = document.querySelector("[data-new-part-name]");
    const newPartModelInput = document.querySelector("[data-new-part-model]");
    const newPartSafeQuantityInput = document.querySelector("[data-new-part-safe-quantity]");
    const confirmModal = document.querySelector("[data-inbound-confirm-modal]");
    const closeConfirmModalButtons = document.querySelectorAll("[data-close-confirm-modal]");
    const confirmSaveButton = document.querySelector("[data-confirm-save]");
    const confirmPartner = document.querySelector("[data-confirm-partner]");
    const confirmReason = document.querySelector("[data-confirm-reason]");
    const confirmLineCount = document.querySelector("[data-confirm-line-count]");
    const confirmTotalQuantity = document.querySelector("[data-confirm-total-quantity]");
    const registerStepSections = document.querySelectorAll("[data-inbound-register-step]");
    const sideStepItems = document.querySelectorAll("[data-inbound-register-side-step]");
    const categoryLabels = {
        graphics: "그래픽카드",
        memory: "RAM",
        storage: "SSD",
        cpu: "CPU",
    };
    const CREATED_INBOUND_KEY = "pcsCreatedInboundDocument";
    let selectedPart = null;
    let partners = [];
    let selectedPartner = null;
    let pendingInbound = null;
    let currentRegisterStep = "1";
    let partSearchStarted = false;

    if (!inboundForm || !lineList || !lineCount || !partResults || !addButton) {
        return;
    }

    const getCompanyCode = () => {
        const segments = window.location.pathname.split("/").filter(Boolean);
        return segments[0] === "w" && segments[1] ? decodeURIComponent(segments[1]) : "";
    };

    const escapeHtml = (value) => value.replace(/[&<>"']/g, (letter) => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#039;",
    }[letter]));

    const setCurrentRegisterStep = (step) => {
        const nextStep = String(step || "1");
        currentRegisterStep = nextStep;

        registerStepSections.forEach((section) => {
            const isCurrent = section.dataset.inboundRegisterStep === nextStep;
            section.classList.toggle("is-active", isCurrent);
        });

        sideStepItems.forEach((item) => {
            const isCurrent = item.dataset.inboundRegisterSideStep === nextStep;
            item.classList.toggle("is-current", isCurrent);
            if (isCurrent) {
                item.setAttribute("aria-current", "step");
            } else {
                item.removeAttribute("aria-current");
            }
        });
    };

    const hasInboundLines = () => Boolean(lineList.querySelector("[data-line-entry]"));

    const resolveCurrentRegisterStep = () => {
        if (confirmModal?.open || pendingInbound) {
            return "4";
        }
        if (hasInboundLines()) {
            return "3";
        }
        if (partSearchStarted || keywordInput.value.trim() || categorySelect.value) {
            return "2";
        }
        return "1";
    };

    const updateCurrentRegisterStep = (preferredStep = null) => {
        setCurrentRegisterStep(preferredStep || resolveCurrentRegisterStep());
    };

    const bindRegisterStepTracking = () => {
        if (!sideStepItems.length) {
            return;
        }
        updateCurrentRegisterStep();
    };

    const readPart = (option) => ({
        id: option.dataset.partId,
        name: option.dataset.partName,
        meta: option.dataset.partMeta,
        prefix: option.dataset.partPrefix,
    });

    const setPartnerMessage = (message, type = "info") => {
        if (!partnerMessage) {
            return;
        }

        partnerMessage.textContent = message;
        partnerMessage.classList.toggle("is-error", type === "error");
    };

    const partnerRoleLabel = (role) => {
        const normalizedRole = String(role || "").trim().toUpperCase();
        const labels = {
            SUPPLIER: "공급 거래처",
            CUSTOMER: "출고 거래처",
            CLIENT: "출고 거래처",
            BUYER: "출고 거래처",
            BOTH: "공급/출고 거래처",
        };
        return labels[normalizedRole] || "";
    };

    const partnerMeta = (partner) => {
        const code = partner.partnerCode || partner.code || "";
        const role = partnerRoleLabel(partner.partnerRole);
        return [code, role].filter(Boolean).join(" · ") || "공급 거래처";
    };

    const partnerSearchText = (partner) => [
        partner.partnerName,
        partner.partnerCode,
        partner.code,
        partner.representativeName,
        partner.phoneNumber,
        partner.tel,
    ].filter(Boolean).join(" ").toLowerCase();

    const updateSelectedPartnerView = () => {
        const hasPartner = Boolean(selectedPartner);
        if (partnerIdInput) {
            partnerIdInput.value = hasPartner ? String(selectedPartner.partnerId) : "";
        }
        if (selectedPartnerName) {
            selectedPartnerName.textContent = hasPartner ? selectedPartner.partnerName : "거래처 선택";
        }
        if (selectedPartnerMeta) {
            selectedPartnerMeta.textContent = hasPartner ? partnerMeta(selectedPartner) : "거래처를 검색해 선택해 주세요.";
        }
        openPartnerModalButton?.classList.toggle("is-selected", hasPartner);
    };

    const renderPartnerList = () => {
        if (!partnerList) {
            return;
        }

        const keyword = partnerSearchInput?.value.trim().toLowerCase() || "";
        const filteredPartners = keyword
                ? partners.filter((partner) => partnerSearchText(partner).includes(keyword))
                : partners;

        if (!filteredPartners.length) {
            partnerList.innerHTML = `
                <p class="partner-modal-empty">
                    ${partners.length ? "검색 결과가 없습니다." : "선택 가능한 공급 거래처가 없습니다."}
                </p>
            `;
            return;
        }

        partnerList.innerHTML = filteredPartners.map((partner) => {
            const selected = String(selectedPartner?.partnerId || "") === String(partner.partnerId);
            return `
                <button class="partner-modal-row${selected ? " is-selected" : ""}" type="button" data-partner-option="${escapeHtml(String(partner.partnerId))}">
                    <span>
                        <strong>${escapeHtml(partner.partnerName || "-")}</strong>
                        <small>${escapeHtml(partnerMeta(partner))}</small>
                    </span>
                </button>
            `;
        }).join("");
    };

    const selectPartner = (partner) => {
        selectedPartner = partner;
        updateSelectedPartnerView();
        setPartnerMessage("");
        updateCurrentRegisterStep("1");
        partnerModal?.close();
    };

    const validatePartnerSelection = () => {
        if (partnerIdInput?.value) {
            setPartnerMessage("");
            return true;
        }

        setPartnerMessage("거래처를 선택해 주세요.", "error");
        openPartnerModalButton?.focus();
        updateCurrentRegisterStep("1");
        return false;
    };

    const setPartSearchMessage = (message, type = "info") => {
        if (!partSearchMessage) {
            return;
        }

        partSearchMessage.hidden = !message;
        partSearchMessage.textContent = message;
        partSearchMessage.classList.toggle("is-error", type === "error");
    };

    const normalizeListData = (data) => {
        if (Array.isArray(data)) {
            return data;
        }
        return Array.isArray(data?.content) ? data.content : [];
    };

    const dateToken = () => {
        const now = new Date();
        const year = String(now.getFullYear());
        const month = String(now.getMonth() + 1).padStart(2, "0");
        const day = String(now.getDate()).padStart(2, "0");
        return `${year}${month}${day}`;
    };

    const partPrefix = (partCode) => {
        if (!partCode) {
            return "PCS-PART";
        }
        return partCode.startsWith("PCS-")
                ? partCode.split("-").slice(0, 2).join("-")
                : `PCS-${partCode.split("-")[0] || "PART"}`;
    };

    const partMeta = (part) => {
        const manufacturer = part.manufacturer || "";
        const modelName = part.modelName || "";
        const partCode = part.partCode || "";
        const model = `${manufacturer}${modelName ? ` ${modelName}` : ""}`.trim();
        return [model, partCode].filter(Boolean).join(" · ") || "-";
    };

    const selectPart = (option) => {
        selectedPart = readPart(option);
        partOptions.forEach((partOption) => {
            const active = partOption === option;
            partOption.classList.toggle("active", active);
            const label = partOption.querySelector("[data-select-label]");
            if (label) {
                label.textContent = active ? "선택됨" : "선택";
            }
        });
        selectedName.textContent = selectedPart.name;
        selectedMeta.textContent = selectedPart.meta;
        if (partSearchStarted) {
            updateCurrentRegisterStep("2");
        }
    };

    const clearSelectedPart = () => {
        selectedPart = null;
        partOptions.forEach((partOption) => {
            partOption.classList.remove("active");
            const label = partOption.querySelector("[data-select-label]");
            if (label) {
                label.textContent = "선택";
            }
        });
        selectedName.textContent = "품목을 검색해 주세요";
        selectedMeta.textContent = "검색 결과에서 품목을 선택하면 여기에 표시됩니다.";
        quantityInput.value = "1";
        reasonInput.value = "";
        updateCurrentRegisterStep();
    };

    const serialPreview = (prefix, quantity) => {
        const count = Number(quantity) || 1;
        const createdDate = dateToken();
        const more = count > 1 ? `<em>외 ${count - 1}개</em>` : "";
        return `
            <strong>관리번호 예시</strong>
            <span>${prefix}-${createdDate}-0001</span>
            ${more}
        `;
    };

    const createPartOption = ({ id, name, meta, prefix, category, categoryLabel }) => {
        const option = document.createElement("button");
        option.className = "part-result-row";
        option.type = "button";
        option.dataset.partOption = "";
        option.dataset.partId = id;
        option.dataset.partName = name;
        option.dataset.partMeta = meta;
        option.dataset.partPrefix = prefix;
        option.dataset.partCategoryValue = category;
        option.innerHTML = `
            <strong>${escapeHtml(name)}</strong>
            <span>${escapeHtml(meta)}</span>
            <em>${escapeHtml(categoryLabel || categoryLabels[category] || "기타")}</em>
            <b data-select-label>선택</b>
        `;
        option.addEventListener("click", () => {
            partSearchStarted = true;
            selectPart(option);
        });
        return option;
    };

    const refreshLineState = () => {
        const lines = [...lineList.querySelectorAll("[data-line-entry]")];
        lineCount.textContent = `${lines.length}개 품목`;
        if (lineEmpty) {
            lineEmpty.hidden = lines.length > 0;
        }

        lines.forEach((line, index) => {
            line.querySelector("legend").textContent = `품목 ${index + 1}`;
            line.querySelector("[data-line-part-id]").name = `lines[${index}].partId`;
            line.querySelector("[data-line-quantity]").name = `lines[${index}].quantity`;
            line.querySelector("[data-line-reason]").name = `lines[${index}].reason`;
        });
    };

    const createLine = ({ id, name, meta, prefix }, quantity, reason) => {
        const line = document.createElement("fieldset");
        line.className = "line-entry";
        line.dataset.lineEntry = "";
        line.dataset.partId = id;
        line.dataset.partName = name;
        line.dataset.partMeta = meta;
        line.dataset.partPrefix = prefix;
        line.innerHTML = `
            <legend>품목</legend>
            <input type="hidden" value="${id}" data-line-part-id>
            <div class="line-entry-grid line-review-grid">
                <div class="line-part-summary">
                    <span>품목</span>
                    <strong>${escapeHtml(name)}</strong>
                    <p>${escapeHtml(meta)}</p>
                </div>
                <label>
                    <span>수량</span>
                    <input type="number" min="1" value="${quantity}" required data-line-quantity>
                </label>
                <label class="field-wide">
                    <span>품목 사유</span>
                    <input type="text" value="${escapeHtml(reason)}" data-line-reason>
                </label>
                <button class="line-delete-button" type="button" data-delete-line>삭제</button>
            </div>
            <div class="serial-preview" aria-label="관리번호 발급 예시">
                ${serialPreview(prefix, quantity)}
            </div>
        `;
        return line;
    };

    const addLine = () => {
        if (!selectedPart) {
            setPartSearchMessage("먼저 품목을 검색하고 선택해 주세요.", "error");
            return;
        }

        const quantity = Math.max(1, Number(quantityInput.value) || 1);
        const reason = reasonInput.value.trim();
        const existingLine = lineList.querySelector(`[data-line-entry][data-part-id="${selectedPart.id}"]`);

        if (existingLine) {
            const existingQuantity = existingLine.querySelector("[data-line-quantity]");
            const existingReason = existingLine.querySelector("[data-line-reason]");
            existingQuantity.value = Number(existingQuantity.value || 0) + quantity;
            if (!existingReason.value && reason) {
                existingReason.value = reason;
            }
            existingLine.querySelector(".serial-preview").innerHTML = serialPreview(selectedPart.prefix, existingQuantity.value);
            refreshLineState();
            updateCurrentRegisterStep("3");
            clearSelectedPart();
            return;
        }

        lineList.append(createLine(selectedPart, quantity, reason));
        refreshLineState();
        updateCurrentRegisterStep("3");
        clearSelectedPart();
    };

    const filterParts = ({ keepMessage = false } = {}) => {
        const keyword = keywordInput.value.trim().toLowerCase();
        const category = categorySelect.value;
        let visibleCount = 0;

        partOptions.forEach((option) => {
            const text = option.textContent.toLowerCase();
            const keywordMatched = !keyword || text.includes(keyword);
            const categoryMatched = !category || option.dataset.partCategoryValue === category;
            const hidden = !keywordMatched || !categoryMatched;
            option.hidden = hidden;
            if (!hidden) {
                visibleCount += 1;
            }
        });

        const visibleOptions = partOptions.filter((option) => !option.hidden);
        const selectedOption = selectedPart
                ? visibleOptions.find((option) => option.dataset.partId === selectedPart.id)
                : null;

        if (visibleOptions.length && !selectedOption) {
            selectPart(visibleOptions[0]);
        }

        if (!visibleOptions.length) {
            selectedPart = null;
            selectedName.textContent = "검색 결과 없음";
            selectedMeta.textContent = "검색어를 바꾸거나 품목을 새로 등록해 주세요.";
        }

        if (!keepMessage) {
            setPartSearchMessage(visibleCount ? "" : "검색 결과가 없습니다.");
        }
    };

    const renderPartOptions = (parts) => {
        partOptions.forEach((option) => option.remove());
        partOptions = normalizeListData(parts).map((part) => createPartOption({
            id: String(part.partId),
            name: part.partName,
            meta: partMeta(part),
            prefix: partPrefix(part.partCode),
            category: String(part.categoryId || ""),
            categoryLabel: part.categoryName,
        }));
        partOptions.forEach((option) => partResults.append(option));

        if (partOptions.length) {
            setPartSearchMessage(`${partOptions.length}개 품목을 찾았습니다.`);
            selectPart(partOptions[0]);
            return;
        }

        setPartSearchMessage("검색 결과가 없습니다.");
        selectedPart = null;
        selectedName.textContent = "검색 결과 없음";
        selectedMeta.textContent = "검색어를 바꾸거나 품목을 새로 등록해 주세요.";
    };

    const searchParts = async () => {
        partSearchStarted = true;
        updateCurrentRegisterStep("2");
        const companyCode = getCompanyCode();
        const api = window.PcsApi;
        const params = new URLSearchParams({
            active: "true",
            limit: "100",
        });
        const keyword = keywordInput.value.trim();
        const categoryId = categorySelect.value;

        if (keyword) params.set("keyword", keyword);
        if (/^\d+$/.test(categoryId)) params.set("categoryId", categoryId);

        if (!companyCode) {
            setPartSearchMessage("업체 코드를 확인할 수 없습니다.", "error");
            return;
        }

        if (!api) {
            setPartSearchMessage("필요한 화면 기능을 불러오지 못했습니다. 새로고침 후 다시 시도하세요.", "error");
            return;
        }

        searchButton.disabled = true;
        setPartSearchMessage("품목을 검색하는 중입니다.");
        try {
            const parts = await api.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/parts?${params.toString()}`, {
                authRedirect: true,
                loginCompanyCode: companyCode,
            });
            renderPartOptions(parts);
        } catch (error) {
            setPartSearchMessage(error.message || "품목 검색 요청을 처리할 수 없습니다.", "error");
        } finally {
            searchButton.disabled = false;
        }
    };

    const renderCategories = (categories) => {
        const normalizedCategories = normalizeListData(categories);
        if (categorySelect) {
            categorySelect.innerHTML = '<option value="">전체 분류</option>';
            normalizedCategories.forEach((category) => {
                categorySelect.append(new Option(category.categoryName || "-", String(category.categoryId)));
            });
            categorySelect.disabled = false;
        }
        if (newPartCategorySelect) {
            newPartCategorySelect.innerHTML = '<option value="">분류 선택</option>';
            normalizedCategories.forEach((category) => {
                newPartCategorySelect.append(new Option(category.categoryName || "-", String(category.categoryId)));
            });
            newPartCategorySelect.disabled = normalizedCategories.length === 0;
        }
        if (openPartModalButton) {
            openPartModalButton.disabled = normalizedCategories.length === 0;
            openPartModalButton.title = normalizedCategories.length === 0 ? "등록된 분류가 필요합니다." : "";
        }
    };

    const appendAndSelectPart = (part) => {
        if (keywordInput) {
            keywordInput.value = "";
        }
        if (categorySelect && part.categoryId) {
            categorySelect.value = String(part.categoryId);
        }
        const option = createPartOption({
            id: String(part.partId),
            name: part.partName,
            meta: partMeta(part),
            prefix: partPrefix(part.partCode),
            category: String(part.categoryId || ""),
            categoryLabel: part.categoryName,
        });
        partResults.append(option);
        partOptions.push(option);
        selectPart(option);
        filterParts({ keepMessage: true });
    };

    const setPartModalMessage = (message, isError = false) => {
        if (!partModalMessage) {
            return;
        }
        partModalMessage.hidden = !message;
        partModalMessage.textContent = message || "";
        partModalMessage.classList.toggle("is-error", isError);
    };

    const setPartModalDisabled = (disabled) => {
        partModalForm?.querySelectorAll("input, select, button").forEach((element) => {
            if (element.matches("[data-close-part-modal]")) {
                element.disabled = disabled;
                return;
            }
            element.disabled = disabled;
        });
    };

    const createQuickPart = async () => {
        const companyCode = getCompanyCode();
        const api = window.PcsApi;

        if (!partModalForm?.reportValidity()) {
            return;
        }
        if (!companyCode) {
            setPartModalMessage("업체 코드를 확인할 수 없습니다.", true);
            return;
        }
        if (!api) {
            setPartModalMessage("공통 API 스크립트를 확인할 수 없습니다.", true);
            return;
        }

        const body = {
            categoryId: Number(newPartCategorySelect.value),
            partName: newPartNameInput.value.trim(),
            manufacturer: newPartManufacturerInput.value.trim(),
            modelName: newPartModelInput.value.trim(),
            safeQuantity: Math.max(0, Number(newPartSafeQuantityInput.value) || 0),
            specValues: []
        };

        setPartModalDisabled(true);
        setPartModalMessage("품목을 등록하는 중입니다.");
        try {
            const result = await api.request(`/api/workspaces/${encodeURIComponent(companyCode)}/parts`, {
                method: "POST",
                body,
                authRedirect: true,
                loginCompanyCode: companyCode,
            });
            const part = result?.data;
            if (!part?.partId) {
                throw new Error("등록된 품목 정보를 확인할 수 없습니다.");
            }
            partSearchStarted = true;
            appendAndSelectPart(part);
            setPartSearchMessage("새 품목을 등록하고 선택했습니다.");
            updateCurrentRegisterStep("2");
            partModalForm.reset();
            setPartModalMessage("");
            partModal?.close();
        } catch (error) {
            setPartModalMessage(error.message || "품목을 등록하지 못했습니다.", true);
        } finally {
            setPartModalDisabled(false);
        }
    };

    const loadCategories = async () => {
        if (!categorySelect && !newPartCategorySelect) {
            return;
        }

        const companyCode = getCompanyCode();
        const api = window.PcsApi;

        if (!companyCode || !api) {
            if (categorySelect) {
                categorySelect.innerHTML = '<option value="">분류 조회 불가</option>';
                categorySelect.disabled = true;
            }
            if (newPartCategorySelect) {
                newPartCategorySelect.innerHTML = '<option value="">분류 조회 불가</option>';
                newPartCategorySelect.disabled = true;
            }
            if (openPartModalButton) {
                openPartModalButton.disabled = true;
                openPartModalButton.title = "분류 목록을 불러올 수 없습니다.";
            }
            return;
        }

        if (categorySelect) {
            categorySelect.disabled = true;
            categorySelect.innerHTML = '<option value="">분류 불러오는 중</option>';
        }
        if (newPartCategorySelect) {
            newPartCategorySelect.disabled = true;
            newPartCategorySelect.innerHTML = '<option value="">분류 불러오는 중</option>';
        }
        if (openPartModalButton) {
            openPartModalButton.disabled = true;
            openPartModalButton.title = "분류 목록을 불러오는 중입니다.";
        }

        try {
            const params = new URLSearchParams({ limit: "100" });
            const data = await api.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/categories?${params.toString()}`, {
                authRedirect: true,
                loginCompanyCode: companyCode,
            });
            renderCategories(data);
        } catch (error) {
            if (categorySelect) {
                categorySelect.innerHTML = '<option value="">분류 조회 실패</option>';
                categorySelect.disabled = true;
            }
            if (newPartCategorySelect) {
                newPartCategorySelect.innerHTML = '<option value="">분류 조회 실패</option>';
                newPartCategorySelect.disabled = true;
            }
            if (openPartModalButton) {
                openPartModalButton.disabled = true;
                openPartModalButton.title = "분류 목록을 불러올 수 없습니다.";
            }
            setPartSearchMessage(error.message || "분류 목록을 불러오지 못했습니다.", "error");
        }
    };

    const renderPartners = (nextPartners) => {
        partners = nextPartners;
        openPartnerModalButton.disabled = partners.length === 0;
        renderPartnerList();
        setPartnerMessage(partners.length ? "" : "선택 가능한 공급 거래처가 없습니다.");
    };

    const loadPartners = async () => {
        if (!partnerIdInput || !openPartnerModalButton) {
            return;
        }

        const companyCode = getCompanyCode();
        const api = window.PcsApi;

        if (!companyCode) {
            openPartnerModalButton.disabled = true;
            setPartnerMessage("업체 코드를 확인할 수 없습니다.", "error");
            return;
        }

        if (!api) {
            openPartnerModalButton.disabled = true;
            setPartnerMessage("필요한 화면 기능을 불러오지 못했습니다. 새로고침 후 다시 시도하세요.", "error");
            return;
        }

        openPartnerModalButton.disabled = true;
        setPartnerMessage("거래처를 불러오는 중입니다.");

        try {
            const params = new URLSearchParams({
                partnerRole: "SUPPLIER",
                active: "true",
                limit: "100",
            });
            const data = await api.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/partners?${params.toString()}`, {
                authRedirect: true,
                loginCompanyCode: companyCode,
            });
            renderPartners(normalizeListData(data));
        } catch (error) {
            openPartnerModalButton.disabled = true;
            setPartnerMessage(error.message || "거래처 조회 요청을 처리할 수 없습니다.", "error");
        }
    };

    partOptions.forEach((option) => {
        option.addEventListener("click", () => {
            partSearchStarted = true;
            selectPart(option);
        });
    });

    searchButton.addEventListener("click", searchParts);
    keywordInput.addEventListener("input", () => {
        partSearchStarted = true;
        updateCurrentRegisterStep("2");
        filterParts();
    });
    keywordInput.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
            searchParts();
        }
    });
    categorySelect.addEventListener("change", () => {
        partSearchStarted = true;
        updateCurrentRegisterStep("2");
        filterParts();
    });
    addButton.addEventListener("click", addLine);

    lineList.addEventListener("click", (event) => {
        const deleteButton = event.target.closest("[data-delete-line]");
        if (!deleteButton) {
            return;
        }
        deleteButton.closest("[data-line-entry]").remove();
        refreshLineState();
        updateCurrentRegisterStep();
    });

    lineList.addEventListener("input", (event) => {
        const quantity = event.target.closest("[data-line-quantity]");
        if (!quantity) {
            return;
        }
        const line = quantity.closest("[data-line-entry]");
        line.querySelector(".serial-preview").innerHTML = serialPreview(line.dataset.partPrefix, quantity.value);
        updateCurrentRegisterStep("3");
    });

    openPartnerModalButton?.addEventListener("click", () => {
        renderPartnerList();
        partnerModal?.showModal();
        requestAnimationFrame(() => partnerSearchInput?.focus());
    });

    closePartnerModalButtons.forEach((button) => {
        button.addEventListener("click", () => partnerModal?.close());
    });

    partnerSearchButton?.addEventListener("click", renderPartnerList);
    partnerSearchInput?.addEventListener("input", renderPartnerList);
    partnerSearchInput?.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
            renderPartnerList();
        }
    });

    partnerList?.addEventListener("click", (event) => {
        const option = event.target.closest("[data-partner-option]");
        if (!option) {
            return;
        }
        const partner = partners.find((candidate) => String(candidate.partnerId) === option.dataset.partnerOption);
        if (partner) {
            selectPartner(partner);
        }
    });

    inboundForm.elements.reason?.addEventListener("input", () => updateCurrentRegisterStep());

    const setSubmitMessage = (message, isError = false) => {
        if (!submitMessage) {
            return;
        }
        submitMessage.textContent = message;
        submitMessage.classList.toggle("is-error", isError);
    };

    const setSubmitDisabled = (disabled) => {
        const submitButtons = [
            ...inboundForm.querySelectorAll('button[type="submit"]'),
            ...document.querySelectorAll('button[type="submit"][form="inbound-register-form"]'),
        ];
        submitButtons.forEach((button) => {
            button.disabled = disabled;
        });
    };

    const buildInboundPayload = () => {
        const lineEntries = [...lineList.querySelectorAll("[data-line-entry]")];
        return {
            partnerId: Number(inboundForm.elements.partnerId.value),
            reason: inboundForm.elements.reason.value.trim(),
            lines: lineEntries.map((line) => ({
                partId: Number(line.querySelector("[data-line-part-id]").value),
                quantity: Number(line.querySelector("[data-line-quantity]").value),
                reason: line.querySelector("[data-line-reason]").value.trim() || null,
            })),
        };
    };

    const inboundSummary = (payload) => {
        const totalQuantity = payload.lines.reduce((sum, line) => sum + line.quantity, 0);
        return {
            partnerName: selectedPartner?.partnerName || "-",
            reason: payload.reason || "-",
            lineCount: payload.lines.length,
            totalQuantity,
        };
    };

    const renderConfirmSummary = (summary) => {
        if (confirmPartner) confirmPartner.textContent = summary.partnerName;
        if (confirmReason) confirmReason.textContent = summary.reason;
        if (confirmLineCount) confirmLineCount.textContent = `${summary.lineCount}개 품목`;
        if (confirmTotalQuantity) confirmTotalQuantity.textContent = `${summary.totalQuantity}개`;
    };

    const setConfirmDisabled = (disabled) => {
        if (confirmSaveButton) {
            confirmSaveButton.disabled = disabled;
        }
        closeConfirmModalButtons.forEach((button) => {
            button.disabled = disabled;
        });
    };

    const submitInbound = async ({ companyCode, payload }) => {
        let redirecting = false;
        const summary = inboundSummary(payload);
        const api = window.PcsApi;

        setSubmitDisabled(true);
        setConfirmDisabled(true);
        setSubmitMessage("입고를 저장하는 중입니다.");

        try {
            if (!api) {
                throw new Error("필요한 화면 기능을 불러오지 못했습니다. 새로고침 후 다시 시도하세요.");
            }

            const result = await api.request(`/api/workspaces/${encodeURIComponent(companyCode)}/stock/documents/inbounds`, {
                method: "POST",
                body: payload,
                authRedirect: true,
                loginCompanyCode: companyCode,
            });

            const documentNo = result?.data?.documentNo;
            const successMessage = documentNo
                    ? `입고 전표 ${documentNo} 가 등록되었습니다.`
                    : "입고 전표가 등록되었습니다.";

            if (documentNo) {
                try {
                    window.sessionStorage.setItem(CREATED_INBOUND_KEY, JSON.stringify({
                        documentNo,
                        partnerName: summary.partnerName,
                        quantity: summary.totalQuantity
                    }));
                } catch (error) {
                    // Storage can be blocked in private or restricted browser modes.
                }
            }

            window.PcsUi?.setFlashToast({
                message: successMessage,
                type: "success",
                duration: 3000
            });

            setSubmitMessage(documentNo ? `입고 저장 완료: ${documentNo}` : "입고 저장이 완료되었습니다.");
            redirecting = true;
            window.location.href = `/w/${encodeURIComponent(companyCode)}/inbound`;
        } catch (error) {
            setSubmitMessage(error.message || "입고 저장 요청을 처리할 수 없습니다.", true);
        } finally {
            if (!redirecting) {
                setSubmitDisabled(false);
                setConfirmDisabled(false);
            }
        }
    };

    inboundForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        setSubmitMessage("");

        if (!validatePartnerSelection()) {
            return;
        }

        if (!inboundForm.reportValidity()) {
            return;
        }

        const companyCode = getCompanyCode();
        const payload = buildInboundPayload();

        if (!companyCode) {
            setSubmitMessage("업체 코드를 확인할 수 없습니다.", true);
            return;
        }
        if (!payload.lines.length) {
            setSubmitMessage("입고 품목을 1개 이상 추가해 주세요.", true);
            return;
        }

        pendingInbound = { companyCode, payload };
        updateCurrentRegisterStep("4");
        renderConfirmSummary(inboundSummary(payload));
        if (confirmModal) {
            confirmModal.showModal();
            return;
        }
        submitInbound(pendingInbound);
    });

    confirmSaveButton?.addEventListener("click", () => {
        if (!pendingInbound) {
            return;
        }

        confirmModal?.close();
        submitInbound(pendingInbound);
    });

    closeConfirmModalButtons.forEach((button) => {
        button.addEventListener("click", () => {
            confirmModal?.close();
            pendingInbound = null;
            updateCurrentRegisterStep();
        });
    });

    confirmModal?.addEventListener("click", (event) => {
        if (event.target === confirmModal) {
            confirmModal.close();
            pendingInbound = null;
            updateCurrentRegisterStep();
        }
    });

    openPartModalButton?.addEventListener("click", () => {
        setPartModalMessage("");
        partModal?.showModal();
    });

    closePartModalButtons.forEach((button) => {
        button.addEventListener("click", () => {
            partModal?.close();
        });
    });

    partModal?.addEventListener("click", (event) => {
        if (event.target === partModal) {
            partModal.close();
        }
    });

    partModalForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        if (partModalMessage) {
            partModalMessage.hidden = false;
            partModalMessage.textContent = "품목 등록은 품목 관리 화면에서 진행해 주세요.";
        }
        createQuickPart();
    });

    if (partOptions.length) {
        selectPart(partOptions[0]);
    } else {
        setPartSearchMessage("검색 버튼을 눌러 품목을 조회하세요.");
    }
    loadCategories();
    loadPartners();
    refreshLineState();
    bindRegisterStepTracking();
})();
