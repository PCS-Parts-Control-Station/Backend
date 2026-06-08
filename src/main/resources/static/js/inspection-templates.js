(function () {
    const CATEGORIES = {
        COMMON: "공통",
        GPU: "그래픽카드",
        MEMORY: "메모리",
        STORAGE: "저장장치"
    };

    const INPUT_TYPES = {
        CHECK: "통과/불합격",
        NUMBER: "숫자",
        TEXT: "텍스트",
        SELECT: "선택형"
    };

    const ACTIVE_LABELS = {
        true: "사용 중",
        false: "중지"
    };

    const GROUPS = {
        BASIC: "주요 검수 항목",
        DETAIL: "추가 검수 항목"
    };

    const GRADE_IMPACTS = {
        LOW: "낮음",
        MEDIUM: "중간",
        HIGH: "높음"
    };

    const FAIL_POLICIES = {
        NONE: "영향 없음",
        GRADE_DOWN: "등급 하향",
        MARK_DEFECTIVE: "불량 처리",
        BLOCK_SALE: "판매 차단"
    };

    const templates = [
        {
            id: "TPL-GPU-001",
            templateName: "그래픽카드 기본 검수",
            category: "GPU",
            version: 1,
            active: true,
            createdBy: "관리자",
            updatedAt: "2026-06-06",
            items: [
                {
                    id: "ITEM-GPU-001",
                    itemName: "외관 상태",
                    itemGroup: "BASIC",
                    inputType: "CHECK",
                    required: true,
                    gradeImpact: "MEDIUM",
                    failPolicy: "GRADE_DOWN",
                    active: true,
                    options: []
                },
                {
                    id: "ITEM-GPU-002",
                    itemName: "동작 테스트",
                    itemGroup: "BASIC",
                    inputType: "CHECK",
                    required: true,
                    gradeImpact: "HIGH",
                    failPolicy: "MARK_DEFECTIVE",
                    active: true,
                    options: []
                },
                {
                    id: "ITEM-GPU-003",
                    itemName: "소음 상태",
                    itemGroup: "DETAIL",
                    inputType: "SELECT",
                    required: false,
                    gradeImpact: "LOW",
                    failPolicy: "GRADE_DOWN",
                    active: true,
                    options: [
                        { id: "OPT-GPU-001", optionLabel: "정상", active: true },
                        { id: "OPT-GPU-002", optionLabel: "팬 소음", active: true },
                        { id: "OPT-GPU-003", optionLabel: "고주파", active: true }
                    ]
                }
            ]
        },
        {
            id: "TPL-MEM-001",
            templateName: "메모리 기본 검수",
            category: "MEMORY",
            version: 1,
            active: true,
            createdBy: "관리자",
            updatedAt: "2026-06-06",
            items: [
                {
                    id: "ITEM-MEM-001",
                    itemName: "외관 상태",
                    itemGroup: "BASIC",
                    inputType: "CHECK",
                    required: true,
                    gradeImpact: "MEDIUM",
                    failPolicy: "GRADE_DOWN",
                    active: true,
                    options: []
                },
                {
                    id: "ITEM-MEM-002",
                    itemName: "메모리 테스트",
                    itemGroup: "BASIC",
                    inputType: "CHECK",
                    required: true,
                    gradeImpact: "HIGH",
                    failPolicy: "MARK_DEFECTIVE",
                    active: true,
                    options: []
                }
            ]
        },
        {
            id: "TPL-COM-001",
            templateName: "기본 부품 검수",
            category: "COMMON",
            version: 1,
            active: false,
            createdBy: "관리자",
            updatedAt: "2026-06-01",
            items: [
                {
                    id: "ITEM-COM-001",
                    itemName: "구성품 확인",
                    itemGroup: "BASIC",
                    inputType: "TEXT",
                    required: false,
                    gradeImpact: "LOW",
                    failPolicy: "NONE",
                    active: true,
                    options: []
                }
            ]
        }
    ];

    const filterForm = document.querySelector("[data-template-filter-form]");
    const table = document.querySelector("[data-template-table]");
    const panelViews = document.querySelectorAll("[data-template-panel]");
    const createForm = document.querySelector("[data-template-create-form]");
    const editForm = document.querySelector("[data-template-edit-form]");
    const itemForm = document.querySelector("[data-template-item-form]");
    const builderEmpty = document.querySelector("[data-template-builder-empty]");
    const builderBody = document.querySelector("[data-template-builder-body]");
    const builderDescription = document.querySelector("[data-template-builder-description]");
    const itemList = document.querySelector("[data-template-item-list]");
    const selectedItemDetail = document.querySelector("[data-selected-item-detail]");
    const selectedItemSummary = document.querySelector("[data-selected-item-summary]");
    const detailFields = {
        name: document.querySelector("[data-detail-template-name]"),
        category: document.querySelector("[data-detail-category]"),
        version: document.querySelector("[data-detail-version]"),
        active: document.querySelector("[data-detail-active]"),
        basicCount: document.querySelector("[data-detail-basic-count]"),
        detailCount: document.querySelector("[data-detail-detail-count]"),
        optionCount: document.querySelector("[data-detail-option-count]"),
        createdBy: document.querySelector("[data-detail-created-by]"),
        updatedAt: document.querySelector("[data-detail-updated-at]")
    };
    const summaryFields = {
        total: document.querySelector("[data-summary-total]"),
        active: document.querySelector("[data-summary-active]"),
        items: document.querySelector("[data-summary-items]"),
        options: document.querySelector("[data-summary-options]")
    };
    const counts = {
        item: document.querySelector("[data-template-item-count]")
    };

    let selectedTemplateId = null;
    let selectedItemId = null;
    let editingItemId = null;
    let editingOptionId = null;

    const numberText = (value) => Number(value || 0).toLocaleString("ko-KR");

    const showToast = (message, type = "info") => {
        window.PcsUi?.toast({ message, type });
    };

    const normalizeText = (value) => String(value || "").trim().replace(/\s+/g, " ").toLowerCase();

    const hasDuplicateTemplateName = (templateName, excludedTemplateId = null) => {
        const normalized = normalizeText(templateName);
        return templates.some((template) => template.id !== excludedTemplateId && normalizeText(template.templateName) === normalized);
    };

    const hasDuplicateItemName = (template, itemName, excludedItemId = null) => {
        const normalized = normalizeText(itemName);
        return template.items.some((item) => item.id !== excludedItemId && normalizeText(item.itemName) === normalized);
    };

    const hasDuplicateOptionLabel = (item, optionLabel, excludedOptionId = null) => {
        const normalized = normalizeText(optionLabel);
        return item.options.some((itemOption) => itemOption.id !== excludedOptionId && normalizeText(itemOption.optionLabel) === normalized);
    };

    const countOptions = (template) => template.items.reduce((sum, item) => sum + item.options.length, 0);

    const getSelectedTemplate = () => {
        return templates.find((template) => template.id === selectedTemplateId) || null;
    };

    const getSelectedItem = (template = getSelectedTemplate()) => {
        if (!template) {
            return null;
        }
        return template.items.find((item) => item.id === selectedItemId) || null;
    };

    const createCell = (label, content, tagName = "span") => {
        const cell = document.createElement(tagName);
        cell.setAttribute("role", "cell");
        cell.setAttribute("data-label", label);
        if (content instanceof Node) {
            cell.append(content);
        } else {
            cell.textContent = content || "-";
        }
        return cell;
    };

    const createBadge = (text, className = "badge-info") => {
        const badge = document.createElement("em");
        badge.className = `badge ${className}`;
        badge.textContent = text;
        return badge;
    };

    const setPanelMode = (mode) => {
        panelViews.forEach((panel) => {
            const isActive = panel.dataset.templatePanel === mode;
            panel.hidden = !isActive;
            panel.classList.toggle("is-active", isActive);
        });
    };

    const clearRows = () => {
        table?.querySelectorAll(".data-row:not(.table-head)").forEach((row) => row.remove());
    };

    const setEmptyMessage = (message) => {
        clearRows();
        const row = document.createElement("div");
        row.className = "data-row inspection-template-row empty-data-row";
        row.setAttribute("role", "row");
        row.append(createCell("안내", message));
        table.append(row);
    };

    const getFilteredTemplates = () => {
        const keyword = filterForm.elements.keyword.value.trim().toLowerCase();
        const category = filterForm.elements.category.value;
        const active = filterForm.elements.active.value;

        return templates.filter((template) => {
            const matchesKeyword = !keyword ||
                template.templateName.toLowerCase().includes(keyword) ||
                CATEGORIES[template.category].toLowerCase().includes(keyword);
            const matchesCategory = !category || template.category === category;
            const matchesActive = active === "" || String(template.active) === active;
            return matchesKeyword && matchesCategory && matchesActive;
        });
    };

    const updateSummary = () => {
        const totalItems = templates.reduce((sum, template) => sum + template.items.length, 0);
        const totalOptions = templates.reduce((sum, template) => sum + countOptions(template), 0);

        summaryFields.total.textContent = numberText(templates.length);
        summaryFields.active.textContent = numberText(templates.filter((template) => template.active).length);
        summaryFields.items.textContent = numberText(totalItems);
        summaryFields.options.textContent = numberText(totalOptions);
    };

    const updateSelectedRow = () => {
        table?.querySelectorAll("[data-template-id]").forEach((row) => {
            const isSelected = row.dataset.templateId === selectedTemplateId;
            row.classList.toggle("is-selected", isSelected);
            row.setAttribute("aria-selected", String(isSelected));
        });
    };

    const renderDetail = (template) => {
        if (!template) {
            return;
        }

        const basicCount = template.items.filter((item) => item.itemGroup === "BASIC").length;
        const detailCount = template.items.filter((item) => item.itemGroup === "DETAIL").length;

        detailFields.name.textContent = template.templateName;
        detailFields.category.textContent = CATEGORIES[template.category];
        detailFields.version.textContent = `v${template.version}`;
        detailFields.active.textContent = template.active ? "사용 중" : "사용 안 함";
        detailFields.active.className = `badge ${template.active ? "badge-available" : "badge-inactive"}`;
        detailFields.basicCount.textContent = `${numberText(basicCount)}개`;
        detailFields.detailCount.textContent = `${numberText(detailCount)}개`;
        detailFields.optionCount.textContent = `${numberText(countOptions(template))}개`;
        detailFields.createdBy.textContent = template.createdBy;
        detailFields.updatedAt.textContent = template.updatedAt;
    };

    const fillEditForm = (template) => {
        if (!template || !editForm) {
            return;
        }

        editForm.elements.templateName.value = template.templateName;
        editForm.elements.category.value = template.category;
        editForm.elements.version.value = template.version;
        editForm.elements.active.checked = template.active;
    };

    const renderRows = () => {
        const items = getFilteredTemplates();
        clearRows();
        updateSummary();

        if (!items.length) {
            setEmptyMessage("조회된 검수 템플릿이 없습니다.");
            selectedTemplateId = null;
            renderBuilder();
            setPanelMode("create");
            return;
        }

        items.forEach((template) => {
            const row = document.createElement("div");
            row.className = "data-row inspection-template-row is-selectable";
            row.setAttribute("role", "row");
            row.setAttribute("tabindex", "0");
            row.dataset.templateId = template.id;

            row.append(
                createCell("템플릿", template.templateName, "strong"),
                createCell("카테고리", CATEGORIES[template.category]),
                createCell("버전", `v${template.version}`),
                createCell("항목", `${numberText(template.items.length)}개`),
                createCell("상태", createBadge(template.active ? "사용 중" : "사용 안 함", template.active ? "badge-available" : "badge-inactive")),
                createCell("수정일", template.updatedAt)
            );

            row.addEventListener("click", () => selectTemplate(template.id));
            row.addEventListener("keydown", (event) => {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    selectTemplate(template.id);
                }
            });

            table.append(row);
        });

        if (selectedTemplateId && !items.some((template) => template.id === selectedTemplateId)) {
            selectedTemplateId = items[0].id;
        }

        if (!selectedTemplateId) {
            selectedTemplateId = items[0].id;
        }

        const selectedTemplate = getSelectedTemplate();
        renderDetail(selectedTemplate);
        renderBuilder();
        setPanelMode("detail");
        updateSelectedRow();
    };

    const addOptionToItem = (template, item, form) => {
        const optionLabel = form.elements.optionLabel.value.trim();
        if (!optionLabel) {
            showToast("선택지명을 입력해 주세요.", "warning");
            return;
        }
        if (hasDuplicateOptionLabel(item, optionLabel)) {
            showToast("이미 등록된 선택지명입니다.", "warning");
            return;
        }

        item.options.push({
            id: `OPT-${Date.now()}`,
            optionLabel,
            active: true
        });
        selectedItemId = item.id;
        editingItemId = null;
        editingOptionId = null;
        updateTemplateTimestamp(template);
        form.reset();
        renderRows();
        selectTemplate(template.id);
        showToast("선택지를 추가했습니다.", "success");
    };

    const updateOptionLabel = (template, item, optionId, form) => {
        const option = item.options.find((itemOption) => itemOption.id === optionId);
        const optionLabel = form.elements.optionLabel.value.trim();
        if (!option || !optionLabel) {
            showToast("선택지명을 입력해 주세요.", "warning");
            return;
        }
        if (hasDuplicateOptionLabel(item, optionLabel, optionId)) {
            showToast("이미 등록된 선택지명입니다.", "warning");
            return;
        }

        option.optionLabel = optionLabel;
        selectedItemId = item.id;
        editingItemId = null;
        editingOptionId = null;
        updateTemplateTimestamp(template);
        renderRows();
        selectTemplate(template.id);
        showToast("선택지를 수정했습니다.", "success");
    };

    const toggleOptionActive = (template, item, optionId) => {
        const option = item.options.find((itemOption) => itemOption.id === optionId);
        if (!option) {
            return;
        }

        option.active = !option.active;
        selectedItemId = item.id;
        editingItemId = null;
        editingOptionId = null;
        updateTemplateTimestamp(template);
        renderRows();
        selectTemplate(template.id);
        showToast(option.active ? "선택지를 사용 중으로 변경했습니다." : "선택지를 중지했습니다.", "success");
    };

    const updateItemFromForm = (template, item, form) => {
        const itemName = form.elements.itemName.value.trim();
        if (!itemName) {
            showToast("항목명을 입력해 주세요.", "warning");
            return;
        }
        if (hasDuplicateItemName(template, itemName, item.id)) {
            showToast("이미 등록된 항목명입니다.", "warning");
            return;
        }

        const previousInputType = item.inputType;
        item.itemName = itemName;
        item.itemGroup = form.elements.itemGroup.value;
        item.inputType = form.elements.inputType.value;
        item.required = form.elements.required.checked;
        item.gradeImpact = form.elements.gradeImpact.value;
        item.failPolicy = form.elements.failPolicy.value;
        if (previousInputType === "SELECT" && item.inputType !== "SELECT") {
            item.options = [];
            editingOptionId = null;
        }

        selectedItemId = item.id;
        editingItemId = null;
        updateTemplateTimestamp(template);
        renderRows();
        selectTemplate(template.id);
        showToast("검수 항목을 수정했습니다.", "success");
    };

    const createItemEditForm = (template, item) => {
        const form = document.createElement("form");
        form.className = "template-item-edit-form template-inline-form";
        form.setAttribute("action", "#");
        form.setAttribute("method", "post");
        form.setAttribute("autocomplete", "off");

        const title = document.createElement("h4");
        title.textContent = "항목 수정";

        const nameLabel = document.createElement("label");
        nameLabel.innerHTML = `
            <span>항목명</span>
            <input type="text" name="itemName" required>
        `;
        nameLabel.querySelector("input").value = item.itemName;

        const group = document.createElement("div");
        group.className = "template-inline-grid";
        group.innerHTML = `
            <label>
                <span>항목 구분</span>
                <select name="itemGroup" required>
                    <option value="BASIC">주요 검수 항목</option>
                    <option value="DETAIL">추가 검수 항목</option>
                </select>
            </label>
            <label>
                <span>입력 방식</span>
                <select name="inputType" required>
                    <option value="CHECK">통과/불합격</option>
                    <option value="NUMBER">숫자</option>
                    <option value="TEXT">텍스트</option>
                    <option value="SELECT">선택형</option>
                </select>
            </label>
        `;
        group.querySelector("[name='itemGroup']").value = item.itemGroup;
        group.querySelector("[name='inputType']").value = item.inputType;

        const policy = document.createElement("div");
        policy.className = "template-inline-grid";
        policy.innerHTML = `
            <label>
                <span>등급 영향</span>
                <select name="gradeImpact" required>
                    <option value="LOW">낮음</option>
                    <option value="MEDIUM">중간</option>
                    <option value="HIGH">높음</option>
                </select>
            </label>
            <label>
                <span>실패 정책</span>
                <select name="failPolicy" required>
                    <option value="NONE">영향 없음</option>
                    <option value="GRADE_DOWN">등급 하향</option>
                    <option value="MARK_DEFECTIVE">불량 처리</option>
                    <option value="BLOCK_SALE">판매 차단</option>
                </select>
            </label>
        `;
        policy.querySelector("[name='gradeImpact']").value = item.gradeImpact;
        policy.querySelector("[name='failPolicy']").value = item.failPolicy;

        const requiredLabel = document.createElement("label");
        requiredLabel.className = "switch-row";
        requiredLabel.innerHTML = `
            <input type="checkbox" name="required">
            <span>필수 항목</span>
        `;
        requiredLabel.querySelector("input").checked = item.required;

        const actions = document.createElement("div");
        actions.className = "template-card-actions";

        const saveButton = document.createElement("button");
        saveButton.className = "btn btn-primary";
        saveButton.type = "submit";
        saveButton.textContent = "저장";

        const cancelButton = document.createElement("button");
        cancelButton.className = "btn btn-secondary";
        cancelButton.type = "button";
        cancelButton.textContent = "취소";
        cancelButton.addEventListener("click", () => {
            editingItemId = null;
            renderSelectedItemDetail(template);
        });

        actions.append(saveButton, cancelButton);
        form.append(title, nameLabel, group, policy, requiredLabel, actions);
        form.addEventListener("submit", (event) => {
            event.preventDefault();
            updateItemFromForm(template, item, form);
        });

        return form;
    };

    const renderItemOptions = (template, item) => {
        const wrap = document.createElement("div");
        wrap.className = "template-option-strip";

        const header = document.createElement("div");
        header.className = "template-option-strip-header";
        const title = document.createElement("strong");
        title.textContent = "선택지";
        const count = document.createElement("span");
        const activeOptionCount = item.options.filter((itemOption) => itemOption.active).length;
        count.textContent = `${numberText(item.options.length)}개 · 사용 중 ${numberText(activeOptionCount)}개`;
        header.append(title, count);

        const values = document.createElement("div");
        values.className = "template-option-values";
        if (!item.options.length) {
            const empty = document.createElement("span");
            empty.className = "template-empty-note";
            empty.textContent = "등록된 선택지가 없습니다.";
            values.append(empty);
        } else {
            item.options.forEach((itemOption) => {
                if (editingOptionId === itemOption.id) {
                    const form = document.createElement("form");
                    form.className = "template-option-edit-form";
                    form.setAttribute("action", "#");
                    form.setAttribute("method", "post");

                    const field = document.createElement("input");
                    field.name = "optionLabel";
                    field.value = itemOption.optionLabel;
                    field.required = true;
                    field.setAttribute("aria-label", "선택지명");

                    const saveButton = document.createElement("button");
                    saveButton.className = "btn btn-primary";
                    saveButton.type = "submit";
                    saveButton.textContent = "저장";

                    const cancelButton = document.createElement("button");
                    cancelButton.className = "btn btn-secondary";
                    cancelButton.type = "button";
                    cancelButton.textContent = "취소";
                    cancelButton.addEventListener("click", () => {
                        editingOptionId = null;
                        renderSelectedItemDetail(template);
                    });

                    form.append(field, saveButton, cancelButton);
                    form.addEventListener("submit", (event) => {
                        event.preventDefault();
                        updateOptionLabel(template, item, itemOption.id, form);
                    });
                    values.append(form);
                    setTimeout(() => field.focus(), 0);
                    return;
                }

                const value = document.createElement("div");
                value.className = `template-option-value ${itemOption.active ? "" : "is-inactive"}`;

                const label = document.createElement("strong");
                label.textContent = itemOption.optionLabel;

                const status = createBadge(itemOption.active ? "사용 중" : "중지", itemOption.active ? "badge-available" : "badge-inactive");

                const actions = document.createElement("div");
                actions.className = "template-option-actions";

                const editButton = document.createElement("button");
                editButton.className = "btn btn-secondary";
                editButton.type = "button";
                editButton.textContent = "수정";
                editButton.addEventListener("click", () => {
                    editingItemId = null;
                    editingOptionId = itemOption.id;
                    renderSelectedItemDetail(template);
                });

                const toggleButton = document.createElement("button");
                toggleButton.className = "btn btn-secondary";
                toggleButton.type = "button";
                toggleButton.textContent = itemOption.active ? "중지" : "사용";
                toggleButton.addEventListener("click", () => toggleOptionActive(template, item, itemOption.id));

                actions.append(editButton, toggleButton);
                value.append(label, status, actions);
                values.append(value);
            });
        }

        const editor = document.createElement("details");
        editor.className = "template-option-editor";
        const summary = document.createElement("summary");
        summary.textContent = "선택지 추가";

        const form = document.createElement("form");
        form.className = "template-option-inline-form";
        form.setAttribute("action", "#");
        form.setAttribute("method", "post");
        form.setAttribute("autocomplete", "off");

        const labelInput = document.createElement("label");
        const labelText = document.createElement("span");
        const labelField = document.createElement("input");
        labelText.textContent = "선택지명";
        labelField.name = "optionLabel";
        labelField.placeholder = "예: 팬 소음";
        labelField.required = true;
        labelInput.append(labelText, labelField);

        const submitButton = document.createElement("button");
        submitButton.className = "btn btn-primary";
        submitButton.type = "submit";
        submitButton.textContent = "추가";

        form.append(labelInput, submitButton);
        form.addEventListener("submit", (event) => {
            event.preventDefault();
            addOptionToItem(template, item, form);
        });

        editor.append(summary, form);
        wrap.append(header, values, editor);
        return wrap;
    };

    const renderItemCard = (template, item) => {
        const card = document.createElement("article");
        card.className = `template-item-card ${item.active ? "" : "is-inactive"}`;
        card.classList.toggle("is-selected", item.id === selectedItemId);
        card.dataset.itemId = item.id;
        card.setAttribute("role", "button");
        card.setAttribute("tabindex", "0");
        card.setAttribute("aria-pressed", String(item.id === selectedItemId));

        const summary = document.createElement("div");
        summary.className = "template-item-summary";

        const name = document.createElement("div");
        name.className = "template-item-name";
        const title = document.createElement("strong");
        title.textContent = item.itemName;
        name.append(title);
        if (item.required) {
            const requiredMark = document.createElement("span");
            requiredMark.className = "template-required-mark";
            requiredMark.textContent = "*필수";
            name.append(requiredMark);
        }

        const typeBadge = createBadge(INPUT_TYPES[item.inputType], item.inputType === "SELECT" ? "badge-blue" : "badge-info");
        const activeBadge = createBadge(ACTIVE_LABELS[String(item.active)], item.active ? "badge-available" : "badge-inactive");

        summary.append(name, typeBadge, activeBadge);
        card.append(summary);
        card.addEventListener("click", () => selectItem(item.id));
        card.addEventListener("keydown", (event) => {
            if (event.key === "Enter" || event.key === " ") {
                event.preventDefault();
                selectItem(item.id);
            }
        });
        return card;
    };

    const renderSelectedItemDetail = (template) => {
        const item = getSelectedItem(template);
        selectedItemDetail.innerHTML = "";

        if (!item) {
            selectedItemSummary.textContent = "항목 미선택";
            const empty = document.createElement("div");
            empty.className = "template-empty-note";
            empty.textContent = "왼쪽 목록에서 항목을 선택해 주세요.";
            selectedItemDetail.append(empty);
            return;
        }

        selectedItemSummary.textContent = INPUT_TYPES[item.inputType];

        const head = document.createElement("div");
        head.className = "template-selected-head";
        const title = document.createElement("strong");
        title.textContent = item.itemName;
        if (item.required) {
            const requiredMark = document.createElement("span");
            requiredMark.className = "template-required-mark";
            requiredMark.textContent = "*필수";
            title.append(" ", requiredMark);
        }
        const badges = document.createElement("div");
        badges.className = "template-selected-badges";
        badges.append(
            createBadge(INPUT_TYPES[item.inputType], item.inputType === "SELECT" ? "badge-blue" : "badge-info"),
            createBadge(ACTIVE_LABELS[String(item.active)], item.active ? "badge-available" : "badge-inactive")
        );
        head.append(title, badges);

        const meta = document.createElement("dl");
        meta.className = "template-item-meta";
        [
            ["항목 구분", GROUPS[item.itemGroup]],
            ["등급 영향", GRADE_IMPACTS[item.gradeImpact]],
            ["실패 정책", FAIL_POLICIES[item.failPolicy]],
            ["선택지", `${numberText(item.options.length)}개`]
        ].forEach(([label, value]) => {
            const group = document.createElement("div");
            const dt = document.createElement("dt");
            const dd = document.createElement("dd");
            dt.textContent = label;
            dd.textContent = value;
            group.append(dt, dd);
            meta.append(group);
        });

        const actions = document.createElement("div");
        actions.className = "template-card-actions";

        const editButton = document.createElement("button");
        editButton.type = "button";
        editButton.textContent = editingItemId === item.id ? "수정 중" : "항목 수정";
        editButton.disabled = editingItemId === item.id;
        editButton.addEventListener("click", () => {
            editingItemId = item.id;
            editingOptionId = null;
            renderSelectedItemDetail(template);
        });

        const toggleButton = document.createElement("button");
        toggleButton.type = "button";
        toggleButton.textContent = item.active ? "항목 중지" : "항목 사용";
        toggleButton.addEventListener("click", () => {
            item.active = !item.active;
            selectedItemId = item.id;
            editingItemId = null;
            editingOptionId = null;
            updateTemplateTimestamp(template);
            renderRows();
            showToast("항목 상태를 변경했습니다.", "success");
        });
        actions.append(editButton, toggleButton);

        selectedItemDetail.append(head, meta, actions);
        if (editingItemId === item.id) {
            selectedItemDetail.append(createItemEditForm(template, item));
            return;
        }
        if (item.inputType === "SELECT") {
            selectedItemDetail.append(renderItemOptions(template, item));
        }
    };

    const renderItems = (template) => {
        itemList.innerHTML = "";
        if (!template.items.some((item) => item.id === selectedItemId)) {
            selectedItemId = template.items[0]?.id || null;
        }

        ["BASIC", "DETAIL"].forEach((groupKey) => {
            const groupItems = template.items.filter((item) => item.itemGroup === groupKey);
            const group = document.createElement("section");
            group.className = "template-group";

            const title = document.createElement("div");
            title.className = "template-group-title";
            const titleText = document.createElement("span");
            titleText.textContent = GROUPS[groupKey];
            const titleCount = document.createElement("em");
            titleCount.textContent = `${numberText(groupItems.length)}개`;
            title.append(titleText, titleCount);
            group.append(title);

            if (!groupItems.length) {
                const empty = document.createElement("div");
                empty.className = "template-empty-note";
                empty.textContent = "등록된 항목이 없습니다.";
                group.append(empty);
            } else {
                groupItems.forEach((item) => group.append(renderItemCard(template, item)));
            }

            itemList.append(group);
        });

        renderSelectedItemDetail(template);
    };

    function renderBuilder() {
        const template = getSelectedTemplate();
        if (!template) {
            builderEmpty.hidden = false;
            builderBody.hidden = true;
            builderDescription.textContent = "템플릿을 선택하면 항목과 선택지를 편집할 수 있습니다.";
            selectedItemId = null;
            editingItemId = null;
            editingOptionId = null;
            return;
        }

        builderEmpty.hidden = true;
        builderBody.hidden = false;
        builderDescription.textContent = `${template.templateName}의 검수 입력 항목입니다.`;
        counts.item.textContent = `항목 ${numberText(template.items.length)} · 선택지 ${numberText(countOptions(template))}`;
        renderItems(template);
    }

    const selectTemplate = (templateId) => {
        selectedTemplateId = templateId;
        editingItemId = null;
        editingOptionId = null;
        const template = getSelectedTemplate();
        if (!template) {
            return;
        }
        if (!template.items.some((item) => item.id === selectedItemId)) {
            selectedItemId = template.items[0]?.id || null;
        }
        renderDetail(template);
        renderBuilder();
        setPanelMode("detail");
        updateSelectedRow();
    };

    const selectItem = (itemId) => {
        selectedItemId = itemId;
        editingItemId = null;
        editingOptionId = null;
        const template = getSelectedTemplate();
        if (!template) {
            return;
        }
        renderItems(template);
    };

    const showCreatePanel = () => {
        selectedTemplateId = null;
        selectedItemId = null;
        editingItemId = null;
        editingOptionId = null;
        createForm?.reset();
        if (createForm?.elements.active) {
            createForm.elements.active.checked = true;
        }
        renderBuilder();
        updateSelectedRow();
        setPanelMode("create");
    };

    const updateTemplateTimestamp = (template) => {
        template.updatedAt = new Date().toISOString().slice(0, 10);
    };

    filterForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        renderRows();
    });

    document.querySelectorAll("[data-template-create-mode], [data-new-template-button]").forEach((button) => {
        button.addEventListener("click", showCreatePanel);
    });

    document.querySelector("[data-template-edit-mode]")?.addEventListener("click", () => {
        const template = getSelectedTemplate();
        if (!template) {
            return;
        }
        fillEditForm(template);
        setPanelMode("edit");
    });

    document.querySelector("[data-template-detail-mode]")?.addEventListener("click", () => {
        const template = getSelectedTemplate();
        if (!template) {
            showCreatePanel();
            return;
        }
        renderDetail(template);
        setPanelMode("detail");
    });

    document.querySelector("[data-template-active-toggle]")?.addEventListener("click", () => {
        const template = getSelectedTemplate();
        if (!template) {
            return;
        }
        template.active = !template.active;
        updateTemplateTimestamp(template);
        renderRows();
        showToast("템플릿 상태를 변경했습니다.", "success");
    });

    createForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        const form = createForm.elements;
        const templateName = form.templateName.value.trim();
        if (!templateName) {
            showToast("템플릿명을 입력해 주세요.", "warning");
            return;
        }
        if (hasDuplicateTemplateName(templateName)) {
            showToast("이미 등록된 템플릿명입니다.", "warning");
            return;
        }

        const template = {
            id: `TPL-${Date.now()}`,
            templateName,
            category: form.category.value,
            version: Number(form.version.value || 1),
            active: form.active.checked,
            createdBy: "관리자",
            updatedAt: new Date().toISOString().slice(0, 10),
            items: []
        };

        templates.unshift(template);
        selectedTemplateId = template.id;
        filterForm.elements.active.value = "";
        createForm.reset();
        createForm.elements.active.checked = true;
        renderRows();
        showToast("템플릿을 등록했습니다.", "success");
    });

    editForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        const template = getSelectedTemplate();
        if (!template) {
            return;
        }

        const form = editForm.elements;
        const templateName = form.templateName.value.trim();
        if (!templateName) {
            showToast("템플릿명을 입력해 주세요.", "warning");
            return;
        }
        if (hasDuplicateTemplateName(templateName, template.id)) {
            showToast("이미 등록된 템플릿명입니다.", "warning");
            return;
        }

        template.templateName = templateName;
        template.category = form.category.value;
        template.version = Number(form.version.value || 1);
        template.active = form.active.checked;
        updateTemplateTimestamp(template);
        renderRows();
        showToast("템플릿 정보를 수정했습니다.", "success");
    });

    itemForm?.addEventListener("submit", (event) => {
        event.preventDefault();
        const template = getSelectedTemplate();
        if (!template) {
            showToast("항목을 추가할 템플릿을 먼저 선택해 주세요.", "warning");
            return;
        }

        const form = itemForm.elements;
        const itemName = form.itemName.value.trim();
        if (!itemName) {
            showToast("항목명을 입력해 주세요.", "warning");
            return;
        }
        if (hasDuplicateItemName(template, itemName)) {
            showToast("이미 등록된 항목명입니다.", "warning");
            return;
        }

        const item = {
            id: `ITEM-${Date.now()}`,
            itemName,
            itemGroup: form.itemGroup.value,
            inputType: form.inputType.value,
            required: form.required.checked,
            gradeImpact: form.gradeImpact.value,
            failPolicy: form.failPolicy.value,
            active: true,
            options: []
        };

        template.items.push(item);
        selectedItemId = item.id;
        editingItemId = null;
        editingOptionId = null;
        updateTemplateTimestamp(template);
        itemForm.reset();
        renderRows();
        selectTemplate(template.id);
        showToast("검수 항목을 추가했습니다.", "success");
    });

    if (!filterForm || !table) {
        return;
    }

    renderRows();
})();
