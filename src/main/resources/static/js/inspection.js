(() => {
    const documentRows = document.querySelectorAll("[data-mock-inspection-document]");
    const historyRows = document.querySelectorAll("[data-mock-inspection-id]");
    const inspectionForm = document.querySelector("[data-inspection-form]");
    const clearFormButton = document.querySelector("[data-inspection-form-clear]");
    const documentSummaryCard = document.querySelector("[data-inspection-document-summary-card]");
    const historyDetailPanel = document.querySelector("[data-inspection-history-detail]");
    const targetStep = document.querySelector("[data-inspection-target-step]");
    const formStep = document.querySelector("[data-inspection-form-step]");
    const documentFields = {
        subtitle: document.querySelector("[data-inspection-document-subtitle]"),
        documentNo: document.querySelector("[data-inspection-document-no]"),
        status: document.querySelector("[data-inspection-document-status]"),
        total: document.querySelector("[data-inspection-document-total]"),
        completed: document.querySelector("[data-inspection-document-completed]"),
        waiting: document.querySelector("[data-inspection-document-waiting]"),
        defective: document.querySelector("[data-inspection-document-defective]"),
        partner: document.querySelector("[data-inspection-document-partner]"),
        createdAt: document.querySelector("[data-inspection-document-created-at]"),
        summary: document.querySelector("[data-inspection-document-summary]"),
        lineCount: document.querySelector("[data-inspection-document-line-count]"),
        lines: document.querySelector("[data-inspection-document-lines]"),
    };
    const formFields = {
        subtitle: document.querySelector("[data-inspection-form-subtitle]"),
        unit: document.querySelector("[data-inspection-form-unit]"),
        status: document.querySelector("[data-inspection-form-status]"),
        grade: document.querySelector("[data-inspection-form-grade]"),
        sales: document.querySelector("[data-inspection-form-sales]"),
        documentNo: document.querySelector("[data-inspection-form-document-no]"),
        part: document.querySelector("[data-inspection-form-part]"),
        model: document.querySelector("[data-inspection-form-model]"),
        badges: document.querySelector("[data-inspection-form-badges]"),
        serials: document.querySelector("[data-inspection-form-serials]"),
        applyNote: document.querySelector("[data-inspection-form-apply-note]"),
        templateItemCount: document.querySelector("[data-inspection-template-item-count]"),
        templateItems: document.querySelector("[data-inspection-template-items]"),
        message: document.querySelector("[data-inspection-form-message]"),
    };
    const confirmModal = document.querySelector("[data-inspection-confirm-modal]");
    const confirmElements = {
        unit: document.querySelector("[data-confirm-unit]"),
        result: document.querySelector("[data-confirm-result]"),
        saveBtn: document.querySelector("[data-confirm-save]"),
        closeBtns: document.querySelectorAll("[data-close-confirm-modal]"),
    };
    const historyFields = {
        unit: document.querySelector("[data-inspection-history-unit]"),
        type: document.querySelector("[data-inspection-history-type]"),
        grade: document.querySelector("[data-inspection-history-grade]"),
        result: document.querySelector("[data-inspection-history-result]"),
        documentNo: document.querySelector("[data-inspection-history-document-no]"),
        part: document.querySelector("[data-inspection-history-part]"),
        date: document.querySelector("[data-inspection-history-date]"),
        worker: document.querySelector("[data-inspection-history-worker]"),
        sales: document.querySelector("[data-inspection-history-sales]"),
        memo: document.querySelector("[data-inspection-history-memo]"),
        relation: document.querySelector("[data-inspection-history-relation]"),
        itemCount: document.querySelector("[data-inspection-history-item-count]"),
        items: document.querySelector("[data-inspection-history-items]"),
    };

    let activeDocumentNo = null;
    let activeFormUnit = null;
    let activeFormUnits = [];

    const inspectionDocuments = {
        "IN-20260529-K8J4P2M9": {
            documentNo: "IN-20260529-K8J4P2M9",
            partner: "용산전자",
            createdAt: "2026-05-29",
            summary: "DDR4 16GB 외 3종",
            status: "진행 중",
            total: 300,
            completed: 80,
            waiting: 220,
            defective: 6,
            lines: [
                {
                    partName: "Samsung DDR4 16GB",
                    modelName: "M378A2K43CB1-CTD",
                    quantity: 120,
                    units: [
                        { serial: "PCS-RAM-20260529-0133", status: "대기", grade: "미정", sales: "보류" },
                        { serial: "PCS-RAM-20260529-0134", status: "대기", grade: "미정", sales: "보류" },
                        { serial: "PCS-RAM-20260529-0135", status: "완료", grade: "A", sales: "가능" },
                    ],
                },
                {
                    partName: "RTX 3060 12GB",
                    modelName: "Ventus 2X OC",
                    quantity: 30,
                    units: [
                        { serial: "PCS-GPU-20260529-0041", status: "완료", grade: "B", sales: "가능" },
                        { serial: "PCS-GPU-20260529-0042", status: "대기", grade: "미정", sales: "보류" },
                    ],
                },
            ],
        },
        "IN-20260528-Q2HD7Z1A": {
            documentNo: "IN-20260528-Q2HD7Z1A",
            partner: "강남PC",
            createdAt: "2026-05-28",
            summary: "RTX 3060 외 1종",
            status: "진행 중",
            total: 40,
            completed: 12,
            waiting: 28,
            defective: 2,
            lines: [
                {
                    partName: "RTX 3060 12GB",
                    modelName: "Gaming X Trio",
                    quantity: 20,
                    units: [
                        { serial: "PCS-GPU-20260528-0021", status: "대기", grade: "미정", sales: "보류" },
                        { serial: "PCS-GPU-20260528-0022", status: "완료", grade: "A", sales: "가능" },
                    ],
                },
                {
                    partName: "Micron DDR4 8GB",
                    modelName: "MTA8ATF1G64AZ",
                    quantity: 20,
                    units: [
                        { serial: "PCS-RAM-20260528-0088", status: "대기", grade: "미정", sales: "보류" },
                    ],
                },
            ],
        },
        "IN-20260527-M6F8TN3B": {
            documentNo: "IN-20260527-M6F8TN3B",
            partner: "개인매입",
            createdAt: "2026-05-27",
            summary: "SSD 500GB",
            status: "완료",
            total: 8,
            completed: 8,
            waiting: 0,
            defective: 0,
            lines: [
                {
                    partName: "Samsung 970 EVO Plus 500GB",
                    modelName: "MZ-V7S500",
                    quantity: 8,
                    units: [
                        { serial: "PCS-SSD-20260527-0017", status: "완료", grade: "A", sales: "가능" },
                        { serial: "PCS-SSD-20260527-0018", status: "완료", grade: "B", sales: "가능" },
                    ],
                },
            ],
        },
    };

    const inspectionHistories = {
        10024: {
            unit: "PCS-SSD-000128",
            documentNo: "IN-20260527-M6F8TN3B",
            part: "Samsung 970 EVO Plus 500GB",
            date: "2026-06-02",
            type: "최초",
            typeClass: "badge-active",
            grade: "A",
            gradeClass: "badge-blue",
            result: "통과",
            resultClass: "badge-active",
            worker: "김관리",
            sales: "판매 가능",
            memo: "벤치 테스트와 외관 검수 모두 통과",
            relation: "원본 검수",
            items: [
                { name: "외관 상태", result: "통과", memo: "흠집 없음" },
                { name: "부팅 테스트", result: "통과", memo: "정상 인식" },
                { name: "성능 테스트", result: "통과", memo: "기준 점수 이상" },
            ],
        },
        10023: {
            unit: "PCS-GPU-000172",
            documentNo: "IN-20260528-Q2HD7Z1A",
            part: "RTX 2060 Ventus OC",
            date: "2026-06-01",
            type: "정정",
            typeClass: "badge-warning",
            grade: "불량",
            gradeClass: "badge-danger",
            result: "불합격",
            resultClass: "badge-danger",
            worker: "박검수",
            sales: "판매 불가",
            memo: "팬 소음 재확인 후 불량으로 정정",
            relation: "원본 검수 #10018 기준 정정",
            items: [
                { name: "외관 상태", result: "통과", memo: "외관 이상 없음" },
                { name: "팬 동작", result: "불합격", memo: "고속 회전 시 소음 발생" },
                { name: "부하 테스트", result: "불합격", memo: "온도 상승 과다" },
            ],
        },
    };

    const inspectionTemplates = [
        {
            templateId: 1,
            category: "COMMON",
            templateName: "기본 부품 검수",
            version: 1,
            active: true,
            items: [
                { itemId: 101, itemGroup: "BASIC", itemName: "외관 상태", inputType: "CHECK", required: true, gradeImpact: "LOW", failPolicy: "NONE" },
                { itemId: 102, itemGroup: "BASIC", itemName: "관리번호 라벨 확인", inputType: "CHECK", required: true, gradeImpact: "LOW", failPolicy: "NONE" },
                { itemId: 103, itemGroup: "DETAIL", itemName: "특이사항", inputType: "TEXT", required: false, gradeImpact: "LOW", failPolicy: "NONE" },
            ],
        },
        {
            templateId: 2,
            category: "GPU",
            templateName: "그래픽카드 검수",
            version: 1,
            active: true,
            items: [
                { itemId: 201, itemGroup: "BASIC", itemName: "외관 상태", inputType: "CHECK", required: true, gradeImpact: "LOW", failPolicy: "NONE" },
                { itemId: 202, itemGroup: "DETAIL", itemName: "팬 동작", inputType: "CHECK", required: true, gradeImpact: "HIGH", failPolicy: "BLOCK_SALE" },
                { itemId: 203, itemGroup: "DETAIL", itemName: "부하 온도", inputType: "NUMBER", required: false, gradeImpact: "MEDIUM", failPolicy: "GRADE_DOWN", unit: "℃" },
                {
                    itemId: 204,
                    itemGroup: "DETAIL",
                    itemName: "소음 상태",
                    inputType: "SELECT",
                    required: false,
                    gradeImpact: "MEDIUM",
                    failPolicy: "GRADE_DOWN",
                    options: [
                        { optionId: 2041, optionLabel: "정상", optionValue: "NORMAL" },
                        { optionId: 2042, optionLabel: "약간 있음", optionValue: "MINOR_NOISE" },
                        { optionId: 2043, optionLabel: "심함", optionValue: "SEVERE_NOISE" },
                    ],
                },
            ],
        },
        {
            templateId: 3,
            category: "MEMORY",
            templateName: "메모리 검수",
            version: 1,
            active: true,
            items: [
                { itemId: 301, itemGroup: "BASIC", itemName: "외관 상태", inputType: "CHECK", required: true, gradeImpact: "LOW", failPolicy: "NONE" },
                { itemId: 302, itemGroup: "BASIC", itemName: "용량 인식", inputType: "CHECK", required: true, gradeImpact: "HIGH", failPolicy: "BLOCK_SALE" },
                { itemId: 303, itemGroup: "DETAIL", itemName: "메모리 테스트 결과", inputType: "SELECT", required: true, gradeImpact: "HIGH", failPolicy: "MARK_DEFECTIVE", options: [
                    { optionId: 3031, optionLabel: "오류 없음", optionValue: "NO_ERROR" },
                    { optionId: 3032, optionLabel: "오류 발생", optionValue: "ERROR_FOUND" },
                ] },
                { itemId: 304, itemGroup: "DETAIL", itemName: "테스트 시간", inputType: "NUMBER", required: false, gradeImpact: "LOW", failPolicy: "NONE", unit: "분" },
            ],
        },
        {
            templateId: 4,
            category: "STORAGE",
            templateName: "저장장치 검수",
            version: 1,
            active: true,
            items: [
                { itemId: 401, itemGroup: "BASIC", itemName: "외관 상태", inputType: "CHECK", required: true, gradeImpact: "LOW", failPolicy: "NONE" },
                { itemId: 402, itemGroup: "DETAIL", itemName: "SMART 상태", inputType: "SELECT", required: true, gradeImpact: "HIGH", failPolicy: "MARK_DEFECTIVE", options: [
                    { optionId: 4021, optionLabel: "정상", optionValue: "GOOD" },
                    { optionId: 4022, optionLabel: "주의", optionValue: "CAUTION" },
                    { optionId: 4023, optionLabel: "불량", optionValue: "BAD" },
                ] },
                { itemId: 403, itemGroup: "DETAIL", itemName: "사용 시간", inputType: "NUMBER", required: false, gradeImpact: "LOW", failPolicy: "NONE", unit: "시간" },
            ],
        },
    ];

    const escapeHtml = (value) => String(value || "").replace(/[&<>"']/g, (letter) => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#039;",
    }[letter]));

    const numberText = (value) => Number(value || 0).toLocaleString("ko-KR");
    const statusBadgeClass = (status) => status === "완료" ? "badge-active" : "badge-warning";

    const salesBadgeClass = (sales) => {
        if (sales === "가능" || sales === "판매 가능") return "badge-active";
        if (sales === "판매 불가") return "badge-danger";
        return "badge-warning";
    };

    const itemGroupText = (group) => group === "BASIC" ? "기본 항목" : "상세 항목";
    const inputTypeText = (type) => ({
        CHECK: "통과/불합격",
        NUMBER: "숫자",
        TEXT: "텍스트",
        SELECT: "선택",
    }[type] || type);
    const failPolicyText = (policy) => ({
        NONE: "영향 없음",
        GRADE_DOWN: "등급 하향",
        MARK_DEFECTIVE: "불량 처리",
        BLOCK_SALE: "판매 차단",
    }[policy] || policy);

    const templateCategoryForLine = (line) => {
        const text = `${line?.partName || ""} ${line?.modelName || ""}`.toUpperCase();
        if (text.includes("RTX") || text.includes("GPU") || text.includes("GRAPHIC")) return "GPU";
        if (text.includes("DDR") || text.includes("RAM") || text.includes("MEMORY") || text.includes("MICRON")) return "MEMORY";
        if (text.includes("SSD") || text.includes("HDD") || text.includes("EVO") || text.includes("STORAGE")) return "STORAGE";
        return "COMMON";
    };

    const defaultTemplateForContexts = (contexts) => {
        if (!contexts?.length) return inspectionTemplates[0];
        const categories = new Set(contexts.map((context) => templateCategoryForLine(context.line)));
        const category = categories.size === 1 ? Array.from(categories)[0] : "COMMON";
        return inspectionTemplates.find((template) => template.active && template.category === category)
                || inspectionTemplates.find((template) => template.active && template.category === "COMMON")
                || inspectionTemplates.find((template) => template.active);
    };

    const selectedTemplate = () => {
        const templateId = Number(inspectionForm?.elements.templateId?.value);
        return inspectionTemplates.find((template) => template.templateId === templateId);
    };

    const renderTemplateOptions = (contexts) => {
        if (!inspectionForm?.elements.templateId) return;
        const defaultTemplate = defaultTemplateForContexts(contexts);
        inspectionForm.elements.templateId.innerHTML = inspectionTemplates
                .filter((template) => template.active)
                .map((template) => `
                    <option value="${template.templateId}"${template === defaultTemplate ? " selected" : ""}>
                        ${escapeHtml(template.templateName)} v${numberText(template.version)}
                    </option>
                `).join("");
        renderTemplateItems(defaultTemplate?.templateId);
    };

    const renderTemplateItemControl = (item) => {
        const baseName = `item_${item.itemId}`;
        if (item.inputType === "NUMBER") {
            return `
                <div class="inspection-template-control-grid">
                    <input type="number" name="${baseName}_valueNumber" data-inspection-template-value placeholder="${escapeHtml(item.unit || "값")}">
                    <select name="${baseName}_result" data-inspection-template-result>
                        <option value="PASS">통과</option>
                        <option value="WARN">주의</option>
                        <option value="FAIL">불합격</option>
                        <option value="NA">해당 없음</option>
                    </select>
                </div>
            `;
        }
        if (item.inputType === "TEXT") {
            return `
                <textarea name="${baseName}_valueText" data-inspection-template-value rows="2" placeholder="확인 내용을 입력해 주세요"></textarea>
            `;
        }
        if (item.inputType === "SELECT") {
            const options = (item.options || []).map((option) => `
                <option value="${option.optionId}" data-option-value="${escapeHtml(option.optionValue)}">${escapeHtml(option.optionLabel)}</option>
            `).join("");
            return `
                <select name="${baseName}_selectedOptionId" data-inspection-template-value>
                    <option value="">선택</option>
                    ${options}
                </select>
            `;
        }
        return `
            <select name="${baseName}_result" data-inspection-template-result>
                <option value="PASS">통과</option>
                <option value="FAIL">불합격</option>
                <option value="NA">해당 없음</option>
            </select>
        `;
    };

    const renderTemplateItems = (templateId) => {
        if (!formFields.templateItems) return;
        const template = inspectionTemplates.find((candidate) => candidate.templateId === Number(templateId));
        if (!template?.items?.length) {
            formFields.templateItems.innerHTML = '<p class="detail-empty-text">검수 템플릿을 선택하면 항목이 표시됩니다.</p>';
            if (formFields.templateItemCount) formFields.templateItemCount.textContent = "항목 없음";
            return;
        }

        const groupedItems = ["BASIC", "DETAIL"].map((group) => ({
            group,
            items: template.items.filter((item) => item.itemGroup === group && item.active !== false),
        })).filter((entry) => entry.items.length);

        formFields.templateItems.innerHTML = groupedItems.map((entry) => `
            <section class="inspection-template-group" data-inspection-template-group="${entry.group}">
                <header>
                    <strong>${itemGroupText(entry.group)}</strong>
                    <span>${numberText(entry.items.length)}개 항목</span>
                </header>
                <div class="inspection-template-items">
                    ${entry.items.map((item) => `
                        <label class="inspection-check-item inspection-template-item" data-template-item-id="${item.itemId}" data-template-input-type="${item.inputType}" data-template-required="${item.required}">
                            <span>
                                <strong>${escapeHtml(item.itemName)}</strong>
                                <small>
                                    ${inputTypeText(item.inputType)}
                                    ${item.required ? " · 필수" : ""}
                                    ${item.failPolicy !== "NONE" ? ` · ${failPolicyText(item.failPolicy)}` : ""}
                                </small>
                            </span>
                            ${renderTemplateItemControl(item)}
                        </label>
                    `).join("")}
                </div>
            </section>
        `).join("");
        if (formFields.templateItemCount) formFields.templateItemCount.textContent = `${numberText(template.items.length)}개 항목`;
    };

    const collectInspectionItemResults = () => {
        const template = selectedTemplate();
        const missingItems = [];
        const itemResults = (template?.items || []).map((item) => {
            const itemElement = formFields.templateItems?.querySelector(`[data-template-item-id="${item.itemId}"]`);
            const resultField = itemElement?.querySelector("[data-inspection-template-result]");
            const valueField = itemElement?.querySelector("[data-inspection-template-value]");
            const result = resultField?.value || "PASS";
            const value = valueField?.value || "";
            if (item.required && valueField && !value) {
                missingItems.push(item.itemName);
            }

            const selectedOption = item.inputType === "SELECT" && valueField
                    ? valueField.options[valueField.selectedIndex]
                    : null;
            return {
                itemId: item.itemId,
                itemNameSnapshot: item.itemName,
                result,
                valueText: item.inputType === "TEXT" ? value : null,
                valueNumber: item.inputType === "NUMBER" && value ? Number(value) : null,
                selectedOptionId: item.inputType === "SELECT" && value ? Number(value) : null,
                selectedOptionLabelSnapshot: selectedOption?.textContent || null,
                selectedOptionValueSnapshot: selectedOption?.dataset.optionValue || null,
            };
        });
        return { itemResults, missingItems };
    };

    const setSelectedDocumentRow = (documentNo) => {
        documentRows.forEach((row) => {
            const selected = row.dataset.mockInspectionDocument === documentNo;
            row.classList.toggle("is-selected", selected);
            row.setAttribute("aria-selected", String(selected));
        });
    };

    const setSelectedHistoryRow = (inspectionId) => {
        historyRows.forEach((row) => {
            const selected = row.dataset.mockInspectionId === inspectionId;
            row.classList.toggle("is-selected", selected);
            row.setAttribute("aria-selected", String(selected));
        });
    };

    const findUnitContext = (serial) => {
        for (const documentDetail of Object.values(inspectionDocuments)) {
            for (const line of documentDetail.lines) {
                const unit = line.units.find((candidate) => candidate.serial === serial);
                if (unit) return { document: documentDetail, line, unit };
            }
        }
        return null;
    };

    const findUnitContexts = (serials) => serials
            .map((serial) => findUnitContext(serial))
            .filter(Boolean);

    const setFormDisabled = (disabled) => {
        if (!inspectionForm) return;
        inspectionForm.querySelectorAll("select, input, textarea, button[type='submit']").forEach((field) => {
            field.disabled = disabled;
        });
        if (clearFormButton) clearFormButton.disabled = disabled;
    };

    const setFormMessage = (message) => {
        if (!formFields.message) return;
        formFields.message.textContent = message || "";
        formFields.message.hidden = !message;
    };

    const resetInspectionForm = () => {
        if (!inspectionForm) return;
        inspectionForm.reset();
        inspectionForm.elements.result.value = "PASS";
        inspectionForm.elements.grade.value = "A";
        inspectionForm.elements.salesStatus.value = "AVAILABLE";
        setFormMessage("");
    };

    const clearInspectionForm = () => {
        activeFormUnit = null;
        activeFormUnits = [];
        resetInspectionForm();
        setFormDisabled(true);
        if (formFields.subtitle) formFields.subtitle.textContent = "2번에서 관리번호를 선택하면 검수 결과를 입력할 수 있습니다.";
        if (formFields.unit) formFields.unit.textContent = "검수 대상 없음";
        if (formFields.badges) {
            formFields.badges.innerHTML = `
                <em class="badge badge-warning" data-inspection-form-status>-</em>
                <em class="badge badge-blue" data-inspection-form-grade>-</em>
                <em class="badge badge-warning" data-inspection-form-sales>-</em>
            `;
            formFields.status = formFields.badges.querySelector("[data-inspection-form-status]");
            formFields.grade = formFields.badges.querySelector("[data-inspection-form-grade]");
            formFields.sales = formFields.badges.querySelector("[data-inspection-form-sales]");
        }
        if (formFields.serials) {
            formFields.serials.innerHTML = "";
            formFields.serials.hidden = true;
        }
        if (formFields.documentNo) formFields.documentNo.textContent = "-";
        if (formFields.part) formFields.part.textContent = "-";
        if (formFields.model) formFields.model.textContent = "-";
        if (formFields.applyNote) formFields.applyNote.textContent = "관리번호를 선택하면 저장 적용 범위가 표시됩니다.";
        if (formFields.templateItemCount) formFields.templateItemCount.textContent = "항목 없음";
        if (formFields.templateItems) {
            formFields.templateItems.innerHTML = '<p class="detail-empty-text">검수 템플릿을 선택하면 항목이 표시됩니다.</p>';
        }
        formStep?.classList.remove("is-active");
        setFormMessage("검수할 관리번호를 먼저 선택해 주세요.");
    };

    const updateLineSelectionState = (lineElement) => {
        if (!lineElement) return;
        const checkedUnits = lineElement.querySelectorAll("[data-inspection-unit-check]:checked");
        const selectedCount = checkedUnits.length;
        const countText = lineElement.querySelector("[data-line-selected-count]");
        const selectedButton = lineElement.querySelector("[data-inspection-line-selected-action]");
        if (countText) countText.textContent = selectedCount ? `${numberText(selectedCount)}개 선택` : "선택 없음";
        if (selectedButton) selectedButton.disabled = selectedCount === 0;
    };

    const renderDocumentLines = (lines) => {
        if (!documentFields.lines) return;
        if (!lines?.length) {
            documentFields.lines.innerHTML = '<p class="detail-empty-text">검수 대상 부품이 없습니다.</p>';
            return;
        }

        documentFields.lines.innerHTML = lines.map((line, lineIndex) => {
            const completedCount = (line.units || []).filter((unit) => unit.status === "완료").length;
            const waitingSerials = (line.units || [])
                    .filter((unit) => unit.status !== "완료")
                    .map((unit) => unit.serial);
            const units = line.units?.length ? line.units.map((unit) => `
                <li class="${unit.status === "완료" ? "is-completed" : "is-waiting"}">
                    <input type="checkbox" aria-label="${escapeHtml(unit.serial)} 선택" value="${escapeHtml(unit.serial)}" data-inspection-unit-check${unit.status === "완료" ? " disabled" : ""}>
                    <span class="inspection-unit-main">
                        <code>${escapeHtml(unit.serial)}</code>
                        <span class="inspection-unit-badges">
                            <em class="badge ${statusBadgeClass(unit.status)}">${escapeHtml(unit.status)}</em>
                            <em class="badge ${unit.grade === "미정" ? "badge-warning" : "badge-blue"}">${escapeHtml(unit.grade)}</em>
                        </span>
                    </span>
                    <button class="inspection-unit-action-button" type="button" data-inspection-unit-action="${escapeHtml(unit.serial)}">${unit.status === "완료" ? "재검수" : "검수"}</button>
                </li>
            `).join("") : '<li><span>관리번호가 없습니다.</span></li>';

            return `
                <article class="inspection-target-item" data-inspection-line="${lineIndex}">
                    <header>
                        <span class="inspection-target-heading">
                            <span class="inspection-target-title">
                                <strong>${escapeHtml(line.partName)}</strong>
                                <small>${escapeHtml(line.modelName)}</small>
                                <em class="badge badge-blue">${numberText(line.quantity)}개</em>
                            </span>
                        </span>
                        <span class="inspection-target-summary">대기 ${numberText(waitingSerials.length)}개 · 완료 ${numberText(completedCount)}개</span>
                    </header>
                    <div class="inspection-bulk-actions">
                        <span data-line-selected-count>선택 없음</span>
                        <div>
                            <button class="inspection-line-primary-action" type="button" data-inspection-line-selected-action disabled>선택 검수</button>
                            <button class="inspection-line-quiet-action" type="button" data-inspection-line-waiting-action="${escapeHtml(waitingSerials.join(","))}"${waitingSerials.length ? "" : " disabled"}>대기만 선택</button>
                        </div>
                    </div>
                    <ul class="inspection-unit-list">${units}</ul>
                </article>
            `;
        }).join("");
    };

    const renderDocumentDetail = (documentNo) => {
        const detail = inspectionDocuments[documentNo];
        if (!detail) return;

        activeDocumentNo = documentNo;
        setSelectedDocumentRow(documentNo);
        clearInspectionForm();
        if (documentSummaryCard) documentSummaryCard.hidden = false;
        if (documentFields.subtitle) documentFields.subtitle.hidden = true;
        if (documentFields.documentNo) documentFields.documentNo.textContent = detail.documentNo;
        if (documentFields.status) {
            documentFields.status.className = `badge ${statusBadgeClass(detail.status)}`;
            documentFields.status.textContent = detail.status;
        }
        if (documentFields.total) documentFields.total.textContent = `${numberText(detail.total)}개`;
        if (documentFields.completed) documentFields.completed.textContent = `${numberText(detail.completed)}개`;
        if (documentFields.waiting) documentFields.waiting.textContent = `${numberText(detail.waiting)}개`;
        if (documentFields.defective) documentFields.defective.textContent = `${numberText(detail.defective)}개`;
        if (documentFields.partner) documentFields.partner.textContent = detail.partner;
        if (documentFields.createdAt) documentFields.createdAt.textContent = detail.createdAt;
        if (documentFields.summary) documentFields.summary.textContent = detail.summary;
        if (documentFields.lineCount) documentFields.lineCount.textContent = `${numberText(detail.lines.length)}개 묶음`;
        renderDocumentLines(detail.lines);
        targetStep?.classList.add("is-active");
    };

    const syncInspectionFormRule = () => {
        if (!inspectionForm) return;
        const result = inspectionForm.elements.result;
        const grade = inspectionForm.elements.grade;
        const salesStatus = inspectionForm.elements.salesStatus;
        if (!result || !grade || !salesStatus) return;
        let adjusted = false;
        if (result.value === "FAIL") {
            adjusted = grade.value !== "DEFECTIVE" || salesStatus.value !== "UNAVAILABLE";
            if (adjusted) {
                grade.value = "DEFECTIVE";
                salesStatus.value = "UNAVAILABLE";
                grade.classList.remove("highlight-changed");
                salesStatus.classList.remove("highlight-changed");
                void grade.offsetWidth;
                grade.classList.add("highlight-changed");
                salesStatus.classList.add("highlight-changed");
            }
            return adjusted;
        }
        if (grade.value === "DEFECTIVE") {
            adjusted = result.value !== "FAIL" || salesStatus.value !== "UNAVAILABLE";
            if (adjusted) {
                result.value = "FAIL";
                salesStatus.value = "UNAVAILABLE";
                result.classList.remove("highlight-changed");
                salesStatus.classList.remove("highlight-changed");
                void result.offsetWidth;
                result.classList.add("highlight-changed");
                salesStatus.classList.add("highlight-changed");
            }
        }
        return adjusted;
    };

    const renderInspectionForm = (serials) => {
        const targetSerials = Array.isArray(serials) ? serials : [serials];
        const contexts = findUnitContexts(targetSerials);
        if (!contexts.length) return;

        const { document: documentDetail, line, unit } = contexts[0];
        const sameLine = contexts.every((context) => context.line === line);
        activeDocumentNo = documentDetail.documentNo;
        activeFormUnit = unit;
        activeFormUnits = contexts.map((context) => context.unit);
        resetInspectionForm();
        setFormDisabled(false);
        renderTemplateOptions(contexts);
        setSelectedDocumentRow(documentDetail.documentNo);

        if (formFields.subtitle) {
            formFields.subtitle.textContent = contexts.length === 1
                    ? `${documentDetail.documentNo} · ${line.partName}`
                    : `${documentDetail.documentNo} · ${numberText(contexts.length)}개 일괄 검수`;
        }
        if (formFields.unit) {
            formFields.unit.textContent = contexts.length === 1
                    ? unit.serial
                    : `선택 ${numberText(contexts.length)}개 관리번호`;
        }
        if (formFields.badges) {
            if (contexts.length === 1) {
                formFields.badges.innerHTML = `
                    <em class="badge ${statusBadgeClass(unit.status)}" data-inspection-form-status>${escapeHtml(unit.status)}</em>
                    <em class="badge ${unit.grade === "미정" ? "badge-warning" : "badge-blue"}" data-inspection-form-grade>${escapeHtml(unit.grade)}</em>
                    <em class="badge ${salesBadgeClass(unit.sales)}" data-inspection-form-sales>${escapeHtml(unit.sales)}</em>
                `;
            } else {
                formFields.badges.innerHTML = `
                    <em class="badge badge-active" data-inspection-form-status>일괄 검수</em>
                    <em class="badge badge-blue" data-inspection-form-grade>${numberText(contexts.length)}개 적용</em>
                `;
            }
            formFields.status = formFields.badges.querySelector("[data-inspection-form-status]");
            formFields.grade = formFields.badges.querySelector("[data-inspection-form-grade]");
            formFields.sales = formFields.badges.querySelector("[data-inspection-form-sales]");
        }
        if (formFields.serials) {
            if (contexts.length > 1) {
                formFields.serials.innerHTML = contexts.map((c) => `<span>${escapeHtml(c.unit.serial)}</span>`).join("");
                formFields.serials.hidden = false;
            } else {
                formFields.serials.innerHTML = "";
                formFields.serials.hidden = true;
            }
        }
        if (formFields.documentNo) formFields.documentNo.textContent = documentDetail.documentNo;
        if (formFields.part) formFields.part.textContent = sameLine ? line.partName : "여러 부품";
        if (formFields.model) formFields.model.textContent = sameLine ? line.modelName : "여러 모델";
        if (formFields.applyNote) {
            formFields.applyNote.textContent = contexts.length === 1
                    ? "저장 시 이 관리번호 1개에만 검수 결과가 반영됩니다."
                    : `저장 시 선택한 ${numberText(contexts.length)}개 관리번호에 동일한 결과가 반영됩니다.`;
        }
        formStep?.classList.add("is-active");
        setFormMessage("");
        requestAnimationFrame(() => {
            formStep?.scrollIntoView({ block: "start", behavior: "smooth" });
        });
    };

    const renderHistoryItems = (items) => {
        if (!historyFields.items) return;
        if (!items?.length) {
            historyFields.items.innerHTML = '<p class="detail-empty-text">검수 항목 결과가 없습니다.</p>';
            return;
        }

        historyFields.items.innerHTML = items.map((item) => `
            <article class="inspection-result-item">
                <header>
                    <strong>${escapeHtml(item.name)}</strong>
                    <em class="badge ${item.result === "통과" ? "badge-active" : "badge-danger"}">${escapeHtml(item.result)}</em>
                </header>
                <p>${escapeHtml(item.memo)}</p>
            </article>
        `).join("");
    };

    const renderHistoryDetail = (inspectionId) => {
        const detail = inspectionHistories[inspectionId];
        if (!detail) return;

        if (historyDetailPanel) historyDetailPanel.hidden = false;
        setSelectedHistoryRow(inspectionId);
        if (historyFields.unit) historyFields.unit.textContent = detail.unit;
        if (historyFields.type) {
            historyFields.type.className = `badge ${detail.typeClass}`;
            historyFields.type.textContent = detail.type;
        }
        if (historyFields.grade) {
            historyFields.grade.className = `badge ${detail.gradeClass}`;
            historyFields.grade.textContent = detail.grade;
        }
        if (historyFields.result) {
            historyFields.result.className = `badge ${detail.resultClass}`;
            historyFields.result.textContent = detail.result;
        }
        if (historyFields.documentNo) historyFields.documentNo.textContent = detail.documentNo;
        if (historyFields.part) historyFields.part.textContent = detail.part;
        if (historyFields.date) historyFields.date.textContent = detail.date;
        if (historyFields.worker) historyFields.worker.textContent = detail.worker;
        if (historyFields.sales) historyFields.sales.textContent = detail.sales;
        if (historyFields.memo) historyFields.memo.textContent = detail.memo;
        if (historyFields.relation) historyFields.relation.textContent = detail.relation;
        if (historyFields.itemCount) historyFields.itemCount.textContent = `${numberText(detail.items.length)}개 항목`;
        renderHistoryItems(detail.items);
    };

    document.addEventListener("click", (event) => {
        const documentButton = event.target.closest("[data-inspection-document-action]");
        if (documentButton) {
            renderDocumentDetail(documentButton.dataset.inspectionDocumentAction);
            return;
        }

        const unitButton = event.target.closest("[data-inspection-unit-action]");
        if (unitButton) {
            renderInspectionForm(unitButton.dataset.inspectionUnitAction);
            return;
        }

        const selectedLineButton = event.target.closest("[data-inspection-line-selected-action]");
        if (selectedLineButton) {
            const lineElement = selectedLineButton.closest("[data-inspection-line]");
            const serials = Array.from(lineElement?.querySelectorAll("[data-inspection-unit-check]:checked") || [])
                    .map((input) => input.value);
            renderInspectionForm(serials);
            return;
        }

        const waitingLineButton = event.target.closest("[data-inspection-line-waiting-action]");
        if (waitingLineButton) {
            const serials = waitingLineButton.dataset.inspectionLineWaitingAction.split(",").filter(Boolean);
            renderInspectionForm(serials);
            return;
        }

        const historyButton = event.target.closest("[data-inspection-history-action]");
        if (historyButton) {
            renderHistoryDetail(historyButton.dataset.inspectionHistoryAction);
        }
    });

    document.addEventListener("change", (event) => {
        const unitCheck = event.target.closest("[data-inspection-unit-check]");
        if (unitCheck) {
            updateLineSelectionState(unitCheck.closest("[data-inspection-line]"));
            return;
        }
        if (event.target.matches("[name='templateId']")) {
            renderTemplateItems(event.target.value);
            return;
        }
        if (event.target.matches("[name='result'], [name='grade']")) {
            if (syncInspectionFormRule()) {
                setFormMessage("불합격 또는 불량은 판매 불가 상태로 자동 반영됩니다.");
            }
        }
    });

    documentRows.forEach((row) => {
        row.addEventListener("click", (event) => {
            if (event.target.closest("button")) return;
            renderDocumentDetail(row.dataset.mockInspectionDocument);
        });
        row.addEventListener("keydown", (event) => {
            if (event.key !== "Enter" && event.key !== " ") return;
            event.preventDefault();
            renderDocumentDetail(row.dataset.mockInspectionDocument);
        });
    });

    historyRows.forEach((row) => {
        row.addEventListener("click", (event) => {
            if (event.target.closest("button")) return;
            renderHistoryDetail(row.dataset.mockInspectionId);
        });
        row.addEventListener("keydown", (event) => {
            if (event.key !== "Enter" && event.key !== " ") return;
            event.preventDefault();
            renderHistoryDetail(row.dataset.mockInspectionId);
        });
    });

    clearFormButton?.addEventListener("click", clearInspectionForm);

    confirmElements.closeBtns.forEach((btn) => {
        btn.addEventListener("click", () => confirmModal?.close());
    });

    confirmElements.saveBtn?.addEventListener("click", () => {
        const targetCount = activeFormUnits.length || 1;
        confirmModal?.close();
        setFormMessage(`검수 등록 API 연결 전 mock 화면입니다. ${numberText(targetCount)}개 관리번호 저장 완료.`);
        // Note: Real implementation would refresh table and history here
    });

    inspectionForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        if (!activeFormUnit) {
            setFormMessage("검수할 관리번호를 찾을 수 없습니다.");
            return;
        }
        syncInspectionFormRule();
        if (inspectionForm.elements.grade?.value === "DEFECTIVE"
                && inspectionForm.elements.salesStatus?.value !== "UNAVAILABLE") {
            setFormMessage("불량 등급은 판매 불가로 저장해야 합니다.");
            return;
        }
        const { itemResults, missingItems } = collectInspectionItemResults();
        if (missingItems.length) {
            setFormMessage(`필수 검수 항목을 입력해 주세요: ${missingItems.join(", ")}`);
            return;
        }
        
        if (confirmModal) {
            const targetCount = activeFormUnits.length || 1;
            const resultText = inspectionForm.elements.result.options[inspectionForm.elements.result.selectedIndex].text;
            const gradeText = inspectionForm.elements.grade.options[inspectionForm.elements.grade.selectedIndex].text;
            
            confirmElements.unit.textContent = targetCount === 1 ? activeFormUnit.serial : `${numberText(targetCount)}개 관리번호`;
            confirmElements.result.textContent = `${resultText} · ${gradeText} 등급 · ${numberText(itemResults.length)}개 항목`;
            confirmModal.showModal();
        }
    });

    clearInspectionForm();
})();
