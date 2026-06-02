(() => {
    const body = document.body;
    const toggle = document.querySelector("[data-sidebar-toggle]");
    const backdrop = document.querySelector("[data-sidebar-backdrop]");
    const desktopQuery = window.matchMedia("(min-width: 1521px)");

    if (!toggle || !backdrop) {
        return;
    }

    const closeMenu = () => {
        body.classList.remove("sidebar-open");
        toggle.setAttribute("aria-expanded", "false");
        toggle.setAttribute("aria-label", "메뉴 열기");
    };

    const openMenu = () => {
        body.classList.add("sidebar-open");
        toggle.setAttribute("aria-expanded", "true");
        toggle.setAttribute("aria-label", "메뉴 닫기");
    };

    toggle.addEventListener("click", () => {
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
        if (event.matches) {
            closeMenu();
        }
    });
})();

(() => {
    const lineList = document.querySelector("[data-line-list]");
    const lineCount = document.querySelector("[data-line-count]");
    const inboundForm = document.querySelector("#inbound-register-form");
    const submitMessage = document.querySelector("[data-submit-message]");
    const partResults = document.querySelector(".part-search-results");
    let partOptions = [...document.querySelectorAll("[data-part-option]")];
    const partnerSelect = document.querySelector("[data-partner-select]");
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
    const confirmModal = document.querySelector("[data-inbound-confirm-modal]");
    const closeConfirmModalButtons = document.querySelectorAll("[data-close-confirm-modal]");
    const confirmSaveButton = document.querySelector("[data-confirm-save]");
    const confirmPartner = document.querySelector("[data-confirm-partner]");
    const confirmReason = document.querySelector("[data-confirm-reason]");
    const confirmLineCount = document.querySelector("[data-confirm-line-count]");
    const confirmTotalQuantity = document.querySelector("[data-confirm-total-quantity]");
    const categoryLabels = {
        graphics: "그래픽카드",
        memory: "RAM",
        storage: "SSD",
        cpu: "CPU",
    };
    const CREATED_INBOUND_KEY = "pcsCreatedInboundDocument";
    let selectedPart = null;
    let pendingInbound = null;

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
        return [model, partCode].filter(Boolean).join(" · ");
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
    };

    const serialPreview = (prefix, quantity) => {
        const count = Number(quantity) || 1;
        const createdDate = dateToken();
        const second = count >= 2 ? `<span>${prefix}-${createdDate}-0002</span>` : "";
        const more = count > 2 ? `<span>외 ${count - 2}개</span>` : "";
        return `
            <strong>관리번호 발급 예시</strong>
            <span>${prefix}-${createdDate}-0001</span>
            ${second}
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
        option.addEventListener("click", () => selectPart(option));
        return option;
    };

    const refreshLineState = () => {
        const lines = [...lineList.querySelectorAll("[data-line-entry]")];
        lineCount.textContent = `${lines.length}개 라인`;
        if (lineEmpty) {
            lineEmpty.hidden = lines.length > 0;
        }

        lines.forEach((line, index) => {
            line.querySelector("legend").textContent = `라인 ${index + 1}`;
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
            <legend>라인</legend>
            <input type="hidden" value="${id}" data-line-part-id>
            <div class="line-entry-grid line-review-grid">
                <div class="line-part-summary">
                    <span>부품</span>
                    <strong>${escapeHtml(name)}</strong>
                    <p>${escapeHtml(meta)}</p>
                </div>
                <label>
                    <span>수량</span>
                    <input type="number" min="1" value="${quantity}" required data-line-quantity>
                </label>
                <label class="field-wide">
                    <span>라인 사유</span>
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
            setPartSearchMessage("먼저 부품을 검색하고 선택해 주세요.", "error");
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
            return;
        }

        lineList.append(createLine(selectedPart, quantity, reason));
        refreshLineState();
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
            selectedMeta.textContent = "검색어를 바꾸거나 부품을 새로 등록해 주세요.";
        }

        if (!keepMessage) {
            setPartSearchMessage(visibleCount ? "" : "검색 결과가 없습니다.");
        }
    };

    const renderPartOptions = (parts) => {
        partOptions.forEach((option) => option.remove());
        partOptions = parts.map((part) => createPartOption({
            id: String(part.partId),
            name: part.partName,
            meta: partMeta(part),
            prefix: partPrefix(part.partCode),
            category: String(part.categoryId || ""),
            categoryLabel: part.categoryName,
        }));
        partOptions.forEach((option) => partResults.append(option));

        if (partOptions.length) {
            setPartSearchMessage(`${partOptions.length}개 부품을 찾았습니다.`);
            selectPart(partOptions[0]);
            return;
        }

        setPartSearchMessage("검색 결과가 없습니다.");
        selectedPart = null;
        selectedName.textContent = "검색 결과 없음";
        selectedMeta.textContent = "검색어를 바꾸거나 부품을 새로 등록해 주세요.";
    };

    const searchParts = async () => {
        const companyCode = getCompanyCode();
        const api = window.PcsApi;
        const params = new URLSearchParams({
            active: "true",
            limit: "20",
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
            setPartSearchMessage("공통 API 스크립트를 확인할 수 없습니다.", "error");
            return;
        }

        searchButton.disabled = true;
        setPartSearchMessage("부품을 검색하는 중입니다.");
        try {
            const parts = await api.getData(`/api/workspaces/${encodeURIComponent(companyCode)}/parts?${params.toString()}`, {
                authRedirect: true,
                loginCompanyCode: companyCode,
            });
            renderPartOptions(parts || []);
        } catch (error) {
            setPartSearchMessage(error.message || "부품 검색 요청을 처리할 수 없습니다.", "error");
        } finally {
            searchButton.disabled = false;
        }
    };

    const renderPartners = (partners) => {
        if (!partnerSelect) {
            return;
        }

        partnerSelect.innerHTML = "";
        const placeholder = new Option("거래처 선택", "");
        partnerSelect.append(placeholder);

        partners.forEach((partner) => {
            const option = new Option(partner.partnerName, String(partner.partnerId));
            option.dataset.partnerRole = partner.partnerRole || "";
            partnerSelect.append(option);
        });

        partnerSelect.disabled = partners.length === 0;
        setPartnerMessage(partners.length ? "" : "선택 가능한 공급 거래처가 없습니다.");
    };

    const loadPartners = async () => {
        if (!partnerSelect) {
            return;
        }

        const companyCode = getCompanyCode();
        const api = window.PcsApi;

        if (!companyCode) {
            partnerSelect.innerHTML = '<option value="">업체 코드를 확인할 수 없습니다</option>';
            partnerSelect.disabled = true;
            setPartnerMessage("업체 코드를 확인할 수 없습니다.", "error");
            return;
        }

        if (!api) {
            partnerSelect.innerHTML = '<option value="">공통 API 스크립트를 확인할 수 없습니다</option>';
            partnerSelect.disabled = true;
            setPartnerMessage("공통 API 스크립트를 확인할 수 없습니다.", "error");
            return;
        }

        partnerSelect.disabled = true;
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
            partnerSelect.innerHTML = '<option value="">거래처를 불러오지 못했습니다</option>';
            setPartnerMessage(error.message || "거래처 조회 요청을 처리할 수 없습니다.", "error");
        }
    };

    partOptions.forEach((option) => {
        option.addEventListener("click", () => selectPart(option));
    });

    searchButton.addEventListener("click", searchParts);
    keywordInput.addEventListener("input", filterParts);
    keywordInput.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
            searchParts();
        }
    });
    categorySelect.addEventListener("change", filterParts);
    addButton.addEventListener("click", addLine);

    lineList.addEventListener("click", (event) => {
        const deleteButton = event.target.closest("[data-delete-line]");
        if (!deleteButton) {
            return;
        }
        deleteButton.closest("[data-line-entry]").remove();
        refreshLineState();
    });

    lineList.addEventListener("input", (event) => {
        const quantity = event.target.closest("[data-line-quantity]");
        if (!quantity) {
            return;
        }
        const line = quantity.closest("[data-line-entry]");
        line.querySelector(".serial-preview").innerHTML = serialPreview(line.dataset.partPrefix, quantity.value);
    });

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
        const partnerName = inboundForm.elements.partnerId.selectedOptions[0]?.textContent?.trim() || "-";
        const totalQuantity = payload.lines.reduce((sum, line) => sum + line.quantity, 0);
        return {
            partnerName,
            reason: payload.reason || "-",
            lineCount: payload.lines.length,
            totalQuantity,
        };
    };

    const renderConfirmSummary = (summary) => {
        if (confirmPartner) confirmPartner.textContent = summary.partnerName;
        if (confirmReason) confirmReason.textContent = summary.reason;
        if (confirmLineCount) confirmLineCount.textContent = `${summary.lineCount}개 라인`;
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
                throw new Error("공통 API 스크립트를 확인할 수 없습니다.");
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
            setSubmitMessage("부품 라인을 1개 이상 추가해 주세요.", true);
            return;
        }

        pendingInbound = { companyCode, payload };
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
        });
    });

    confirmModal?.addEventListener("click", (event) => {
        if (event.target === confirmModal) {
            confirmModal.close();
        }
    });

    openPartModalButton?.addEventListener("click", () => {
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
            partModalMessage.textContent = "부품 등록 API 연결 후 사용할 수 있습니다. 지금은 부품관리에서 등록해 주세요.";
        }
    });

    if (partOptions.length) {
        selectPart(partOptions[0]);
    } else {
        setPartSearchMessage("검색 버튼을 눌러 부품을 조회하세요.");
    }
    loadPartners();
    refreshLineState();
})();
