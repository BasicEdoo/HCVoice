local ADDON_NAME, addonTable = ...
local HCVoice = _G.HCVoice or addonTable
if not HCVoice then return end

local GUI = HCVoice.GUI or {}
HCVoice.GUI = GUI

GUI.pages = GUI.pages or {}
GUI.navButtons = GUI.navButtons or {}
GUI.currentPage = GUI.currentPage or "general"
GUI.counter = GUI.counter or 0

if StaticPopupDialogs and not StaticPopupDialogs.HCVOICE_CONFIRM_ACTION then
    StaticPopupDialogs.HCVOICE_CONFIRM_ACTION = {
        text = "%s",
        button1 = YES,
        button2 = NO,
        OnAccept = function(_, data) if data and data.callback then data.callback() end end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

function GUI:ConfirmAction(message, callback)
    if StaticPopup_Show and StaticPopupDialogs and StaticPopupDialogs.HCVOICE_CONFIRM_ACTION then
        StaticPopup_Show("HCVOICE_CONFIRM_ACTION", message, nil, { callback = callback })
    elseif callback then
        callback()
    end
end

local PAGE_DEFS = {
    { key = "general", label = "Overview" },
    { key = "reactions", label = "Reactions" },
    { key = "replies", label = "Replies" },
    { key = "profiles", label = "Profiles" },
    { key = "voices", label = "Voice Lab" },
    { key = "advanced", label = "Advanced" },
    { key = "history", label = "Recent decisions" },
}

local PAGE_COPY = {
    survival = "Your character's combat story, party deaths and your pet's confirmed danger or death.",
    social = "Deliberate greetings, established interactions and earned thanks.",
    combat = "Real danger, difficult victories, safe pre-pull waiting and announced mana breaks.",
    world = "Safe idle variation and optional, meaning-based personal-loot reactions.",
}

local function nextName(prefix)
    GUI.counter = GUI.counter + 1
    return "HCVoice" .. prefix .. GUI.counter
end

local function markCustom()
    if HCVoice.db then HCVoice.db.preset = "custom" end
end

local function showTooltip(owner, title, body)
    if not GameTooltip then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(title or "HCVoice", 1, 0.82, 0)
    if body and body ~= "" then GameTooltip:AddLine(body, 1, 1, 1, true) end
    GameTooltip:Show()
end

local function hideTooltip()
    if GameTooltip then GameTooltip:Hide() end
end

local function wireCloseButton(frame, onClick)
    if not frame then return end
    local frameName = frame.GetName and frame:GetName() or nil
    local closeButton = frame.CloseButton or (frameName and _G[frameName .. "CloseButton"])
    if not closeButton then
        closeButton = CreateFrame("Button", frameName and (frameName .. "CloseButton") or nil, frame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    end
    closeButton:SetFrameLevel(frame:GetFrameLevel() + 10)
    closeButton:EnableMouse(true)
    closeButton:SetScript("OnClick", onClick or function() frame:Hide() end)
    frame.CloseButton = closeButton
end

local function addPageRefresher(page, fn)
    page.refreshers = page.refreshers or {}
    page.refreshers[#page.refreshers + 1] = fn
end

local function createText(parent, text, size, x, y, width, justify)
    local font = parent:CreateFontString(nil, "ARTWORK", size and "GameFontNormalLarge" or "GameFontHighlight")
    font:SetPoint("TOPLEFT", x or 0, y or 0)
    if width then
        font:SetWidth(width)
        font:SetJustifyH(justify or "LEFT")
        font:SetWordWrap(true)
    end
    font:SetText(text or "")
    return font
end

local function createSection(parent, text, y)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 4, y)
    title:SetText(text)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(0.45, 0.36, 0.15, 0.65)
    line:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    line:SetPoint("RIGHT", parent, "RIGHT", -12, 0)
    line:SetHeight(1)
    return y - 34
end

local function createButton(parent, label, x, y, width, height, onClick, tooltip)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", x, y)
    button:SetSize(width or 120, height or 24)
    button:SetText(label)
    button:SetScript("OnClick", onClick)
    if tooltip then
        button:SetScript("OnEnter", function(self) showTooltip(self, label, tooltip) end)
        button:SetScript("OnLeave", hideTooltip)
    end
    return button
end

local function createCheckbox(page, label, tooltip, x, y, getter, setter, trackPreset)
    local check = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", x, y)
    check:SetSize(24, 24)
    local text = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("LEFT", check, "RIGHT", 4, 0)
    text:SetWidth(330)
    text:SetJustifyH("LEFT")
    text:SetText(label)
    check.Label = text
    check:SetScript("OnClick", function(self)
        setter(self:GetChecked() == true)
        if trackPreset ~= false then markCustom() end
    end)
    check:SetScript("OnEnter", function(self) showTooltip(self, label, tooltip) end)
    check:SetScript("OnLeave", hideTooltip)
    addPageRefresher(page, function() check:SetChecked(getter() == true) end)
    return check
end

local function createSlider(page, label, tooltip, x, y, width, minValue, maxValue, step, getter, setter, formatter)
    local name = nextName("Slider")
    local slider = CreateFrame("Slider", name, page, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y - 18)
    slider:SetWidth(width or 240)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step or 1)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end

    local labelText = page:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    labelText:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 5)
    labelText:SetText(label)
    local valueText = page:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    valueText:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 5)

    local low = _G[name .. "Low"]
    local high = _G[name .. "High"]
    local builtInText = _G[name .. "Text"]
    if low then low:SetText(tostring(minValue)) end
    if high then high:SetText(tostring(maxValue)) end
    if builtInText then builtInText:SetText("") end

    slider._updating = false
    slider:SetScript("OnValueChanged", function(self, value)
        local rounded = math.floor((value / (step or 1)) + 0.5) * (step or 1)
        valueText:SetText(formatter and formatter(rounded) or tostring(rounded))
        if not self._updating then
            setter(rounded)
            HCVoice:SanitizeDatabase()
            markCustom()
        end
    end)
    slider:SetScript("OnMouseUp", function()
        HCVoice:SanitizeDatabase()
        HCVoice:InitializeUnitState()
        GUI:RefreshCurrentPage()
    end)
    slider:SetScript("OnEnter", function(self) showTooltip(self, label, tooltip) end)
    slider:SetScript("OnLeave", hideTooltip)

    addPageRefresher(page, function()
        slider._updating = true
        local value = getter()
        slider:SetValue(value)
        valueText:SetText(formatter and formatter(value) or tostring(value))
        slider._updating = false
    end)
    return slider
end

local voiceCategories = {}
for _, item in ipairs(HCVoice.voiceOptions) do
    voiceCategories[item.category] = voiceCategories[item.category] or {}
    voiceCategories[item.category][#voiceCategories[item.category] + 1] = item
end

local categoryOrder = { "Official speech", "Vocal reaction", "Animated reaction", "RP interaction" }

local function availableVoices(options)
    local result = {}
    for _, item in ipairs(options) do
        if HCVoice:IsVoiceAvailable(item.token) then result[#result + 1] = item end
    end
    return result
end

local function createVoiceDropdown(page, x, y, width, label, allowAuto, getter, setter, trackPreset)
    local name = nextName("Dropdown")
    local dropdown = CreateFrame("Frame", name, page, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", x - 16, y)
    if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(dropdown, width or 145) end
    if UIDropDownMenu_JustifyText then UIDropDownMenu_JustifyText(dropdown, "LEFT") end

    if label then
        local labelText = page:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, -2)
        labelText:SetText(label)
    end

    local function selectValue(value)
        setter(value)
        if trackPreset ~= false then markCustom() end
        if UIDropDownMenu_SetText then
            local item = HCVoice.voiceByToken[value]
            UIDropDownMenu_SetText(dropdown, value == "AUTO" and "AUTO: class-aware" or (item and (item.label .. "  /" .. string.lower(value)) or value))
        end
    end

    if UIDropDownMenu_Initialize then
        UIDropDownMenu_Initialize(dropdown, function(_, level, menuList)
            level = level or 1
            if level == 1 then
                if allowAuto then
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = "AUTO: class-aware"
                    info.value = "AUTO"
                    info.checked = getter() == "AUTO"
                    info.func = function() selectValue("AUTO") end
                    UIDropDownMenu_AddButton(info, level)
                end
                for _, category in ipairs(categoryOrder) do
                    if voiceCategories[category] then
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = category
                        info.hasArrow = true
                        info.notCheckable = true
                        info.menuList = category
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            elseif level == 2 and menuList and voiceCategories[menuList] then
                for _, item in ipairs(availableVoices(voiceCategories[menuList])) do
                    local token = item.token
                    local itemLabel = item.label
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = itemLabel .. "  /" .. string.lower(token)
                    info.value = token
                    info.checked = getter() == token
                    info.func = function() selectValue(token) end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end)
    else
        local cycle = createButton(page, "Cycle voice", x, y, width or 145, 24, function()
            local current = getter()
            local index = 1
            local options = availableVoices(HCVoice.voiceOptions)
            for i, item in ipairs(options) do if item.token == current then index = i + 1 end end
            if index > #options then index = 1 end
            selectValue(options[index].token)
        end)
        dropdown = cycle
    end

    addPageRefresher(page, function()
        local value = getter()
        local item = HCVoice.voiceByToken[value]
        local text = value == "AUTO" and "AUTO: class-aware" or (item and (item.label .. "  /" .. string.lower(value)) or value)
        if UIDropDownMenu_SetText then UIDropDownMenu_SetText(dropdown, text) elseif dropdown.SetText then dropdown:SetText(text) end
    end)
    return dropdown
end

local function createChoiceDropdown(page, x, y, width, label, choices, getter, setter, tooltip, trackPreset)
    local name = nextName("ChoiceDropdown")
    local dropdown = CreateFrame("Frame", name, page, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", x - 16, y)
    if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(dropdown, width or 180) end
    if UIDropDownMenu_JustifyText then UIDropDownMenu_JustifyText(dropdown, "LEFT") end

    if label then
        local labelText = page:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, -2)
        labelText:SetText(label)
    end

    local function currentChoices()
        return type(choices) == "function" and (choices() or {}) or (choices or {})
    end
    local function labelFor(value)
        for _, choice in ipairs(currentChoices()) do if choice.value == value then return choice.label end end
        return value and tostring(value) or "No saved profiles"
    end
    local function selectValue(value)
        setter(value)
        if trackPreset ~= false then markCustom() end
        if UIDropDownMenu_SetText then UIDropDownMenu_SetText(dropdown, labelFor(value)) end
        GUI:RefreshCurrentPage()
    end

    if UIDropDownMenu_Initialize then
        UIDropDownMenu_Initialize(dropdown, function(_, level)
            local list = currentChoices()
            if #list == 0 then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "No saved profiles"
                info.disabled = true
                info.notCheckable = true
                UIDropDownMenu_AddButton(info, level or 1)
                return
            end
            for _, choice in ipairs(list) do
                local value, choiceLabel = choice.value, choice.label
                local info = UIDropDownMenu_CreateInfo()
                info.text = choiceLabel
                info.value = value
                info.checked = getter() == value
                info.func = function() selectValue(value) end
                UIDropDownMenu_AddButton(info, level or 1)
            end
        end)
    else
        dropdown = createButton(page, "Change", x, y, width or 180, 24, function()
            local list = currentChoices()
            if #list == 0 then return end
            local current, index = getter(), 1
            for i, choice in ipairs(list) do if choice.value == current then index = i + 1 end end
            if index > #list then index = 1 end
            selectValue(list[index].value)
        end, tooltip)
    end

    if tooltip then
        dropdown:SetScript("OnEnter", function(self) showTooltip(self, label or "HCVoice", tooltip) end)
        dropdown:SetScript("OnLeave", hideTooltip)
    end
    addPageRefresher(page, function()
        local text = labelFor(getter())
        if UIDropDownMenu_SetText then UIDropDownMenu_SetText(dropdown, text) elseif dropdown.SetText then dropdown:SetText(text) end
    end)
    return dropdown
end

local function createInputBox(parent, x, y, width, height)
    local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    edit:SetPoint("TOPLEFT", x, y)
    edit:SetSize(width or 300, height or 30)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(20000)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    return edit
end

local function countEnabledScenarios()
    local count = 0
    for _, def in ipairs(HCVoice.scenarioDefinitions) do
        local cfg = HCVoice:GetScenarioConfig(def.key)
        if cfg and cfg.enabled then count = count + 1 end
    end
    return count
end

local SCENARIO_MODE_CHOICES = {
    { value = "automatic", label = "Automatic" },
    { value = "manual", label = "Manual only" },
    { value = "off", label = "Off" },
}

local function createScenarioRow(page, def, y)
    local cfg = function() return HCVoice:GetScenarioConfig(def.key) end
    local row = CreateFrame("Frame", nil, page)
    row:SetPoint("TOPLEFT", 2, y)
    row:SetSize(660, 64)

    local check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", 0, -1)
    check:SetSize(24, 24)
    local title = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("LEFT", check, "RIGHT", 3, 0)
    title:SetWidth(250)
    title:SetJustifyH("LEFT")
    title:SetText(def.label)
    local description = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", 29, -27)
    description:SetWidth(275)
    description:SetJustifyH("LEFT")
    description:SetText(def.description)

    check:SetScript("OnClick", function(self)
        HCVoice:SetScenarioValue(def.key, "mode", self:GetChecked() == true and (def.defaultMode or "automatic") or "off")
        markCustom()
        GUI:RefreshCurrentPage()
    end)
    check:SetScript("OnEnter", function(self) showTooltip(self, def.label, def.description) end)
    check:SetScript("OnLeave", hideTooltip)

    createChoiceDropdown(page, 305, y - 3, 132, "Mode", SCENARIO_MODE_CHOICES,
        function() return cfg().mode end,
        function(value) HCVoice:SetScenarioValue(def.key, "mode", value) end,
        "Automatic reacts when the event is understood. Manual only leaves the voice in Voice Lab. Off disables the scenario. Normal events never open a popup.")

    local fixedVoice = def.variantLabel and ("Variation: " .. def.variantLabel) or ("Meaning: /" .. string.lower(def.emote))
    createText(page, fixedVoice, false, 468, y - 22, 138)
    createButton(page, "Test", 617, y - 21, 54, 22, function()
        HCVoice:PlayVoice(def.emote, false)
    end, "Plays this scenario's fixed voice immediately without changing scenario cooldowns.")

    addPageRefresher(page, function() check:SetChecked(cfg().mode ~= "off") end)

    local divider = page:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0.2, 0.2, 0.2, 0.55)
    divider:SetPoint("TOPLEFT", 4, y - 62)
    divider:SetSize(650, 1)
    return y - 68
end

local function buildScenarioGroup(page, key, title, y, allowedKeys)
    y = createSection(page, title, y)
    local allowed = nil
    if allowedKeys then
        allowed = {}
        for _, scenarioKey in ipairs(allowedKeys) do allowed[scenarioKey] = true end
    end
    for _, def in ipairs(HCVoice:GetScenarioDefinitions(key)) do
        if not allowed or allowed[def.key] then y = createScenarioRow(page, def, y) end
    end
    return y - 12
end

function GUI:BuildReactionsPage(page)
    local y = -8
    createText(page, "Reactions", true, 4, y, 650)
    y = y - 34
    createText(page, "Every event keeps one meaning. Choose whether HCVoice reacts automatically, leaves it manual, or stays off. These events never open popup suggestions.", false, 4, y, 650)
    y = y - 56

    y = createSection(page, "Survival thresholds", y)
    createSlider(page, "OOM mana", "Calls OOM when mana reaches this percentage while fighting or grouped.", 4, y, 300, 5, 90, 1, function() return HCVoice.db.thresholds.mana end, function(v) HCVoice.db.thresholds.mana = v end, function(v) return v .. "%" end)
    createSlider(page, "HEALME health", "Calls HEALME at this health percentage during combat.", 350, y, 280, 10, 80, 1, function() return HCVoice.db.thresholds.healing end, function(v) HCVoice.db.thresholds.healing = v end, function(v) return v .. "%" end)
    y = y - 82
    createSlider(page, "FLEE health", "Calls FLEE at this emergency health percentage.", 4, y, 300, 1, 40, 1, function() return HCVoice.db.thresholds.flee end, function(v) HCVoice.db.thresholds.flee = v end, function(v) return v .. "%" end)
    y = y - 86

    y = buildScenarioGroup(page, "survival", "Survival, party & pets", y)
    y = buildScenarioGroup(page, "combat", "Combat", y)
    y = createSection(page, "Boss reactions - Classic Era Hardcore", y)
    createCheckbox(page, "Automatic boss voices and animations", "Boss-specific standard emotes. No popup choices or custom dialogue.", 4, y,
        function() return HCVoice:GetScenarioConfig("bossReactions").mode == "automatic" end,
        function(value) HCVoice:SetScenarioValue("bossReactions", "mode", value and "automatic" or "off") end)
    y = y - 36
    createText(page, "Individual reactions for dungeon bosses, rares and quest encounters. Danger and mourning take priority. Choose the dungeons you want below.", false, 4, y, 650)
    y = y - 50
    if HCVoice.Bosses then
        for index, key in ipairs(HCVoice.Bosses.dungeonOrder) do
            local dungeon = HCVoice.Bosses.dungeons[key]
            local column = (index - 1) % 2
            local check = createCheckbox(page, dungeon.name, "Enable automatic boss reactions in " .. dungeon.name .. ".", 4 + column * 340, y,
                function() return HCVoice.db.bossDungeons[key] ~= false end,
                function(value) HCVoice.db.bossDungeons[key] = value == true end)
            check.Label:SetWidth(296)
            if column == 1 then y = y - 40 end
        end
    end
    y = y - 18
    y = buildScenarioGroup(page, "world", "World, idle & optional loot", y)
    page:SetHeight(math.max(900, -y + 70))
end

function GUI:BuildRepliesPage(page)
    local y = -8
    local characterName = UnitName and UnitName("player") or "your character"
    createText(page, "Replies & encounters", true, 4, y, 650)
    y = y - 34
    createText(page, "HCVoice remembers short social encounters for " .. characterName .. ". Greetings are deliberate and replies are contextual. Party departures always trigger BYE; target-based farewells require an encounter.", false, 4, y, 650)
    y = y - 62

    y = createSection(page, "Encounter flow", y)
    createText(page, "Hold friendly target  ->  HELLO  ->  interact or reply  ->  leave  ->  possible BYE", false, 4, y, 650)
    y = y - 48
    createSlider(page, "Hold target before HELLO", "Prevents accidental tab-target greetings.", 4, y, 300, 0.5, 4, 0.5, function() return HCVoice.db.advanced.greetingDelaySeconds end, function(v) HCVoice.db.advanced.greetingDelaySeconds = v end, function(v) return string.format("%.1f sec", v) end)
    createSlider(page, "Minimum encounter before BYE", "The encounter must last this long before losing the target can produce BYE.", 350, y, 280, 1, 20, 1, function() return HCVoice.db.advanced.minimumEncounterSeconds end, function(v) HCVoice.db.advanced.minimumEncounterSeconds = v end, function(v) return v .. " sec" end)
    y = y - 88

    y = createSection(page, "Living World", y)
    createText(page, "HCVoice users can understand the meaning behind group moments and nearby social emotes. Messages stay inside WoW and are sent only when a real scene happens.", false, 4, y, 650)
    y = y - 58
    createCheckbox(page, "Enable Living World interactions", "Master switch for semantic HCVoice-to-HCVoice scenes. Local reactions keep working when this is off.", 4, y,
        function() return HCVoice.db.livingWorld.enabled end,
        function(v) HCVoice.db.livingWorld.enabled = v; if not v then HCVoice.db.livingWorld.mode = "off" elseif HCVoice.db.livingWorld.mode == "off" then HCVoice.db.livingWorld.mode = "hybrid" end end)
    createCheckbox(page, "Share party, raid and dungeon moments", "Boss victories, party deaths, levels, loot and other authored group scenes.", 350, y,
        function() return HCVoice.db.livingWorld.group end,
        function(v) HCVoice.db.livingWorld.group = v end)
    y = y - 42
    createCheckbox(page, "Allow nearby social scenes", "Listens for nearby visible emotes and uses hidden addon whispers for directed interactions. HCVoice never sends normal chat text.", 4, y,
        function() return HCVoice.db.livingWorld.nearby end,
        function(v) HCVoice.db.livingWorld.nearby = v end)
    createChoiceDropdown(page, 350, y + 3, 280, "Living World response mode", {
        { value = "off", label = "Off" },
        { value = "hybrid", label = "Balanced automatic" },
        { value = "auto", label = "All safe responses" },
    }, function() return HCVoice.db.livingWorld.mode end, function(v) HCVoice.db.livingWorld.mode = v; HCVoice.db.livingWorld.enabled = v ~= "off" end,
    "Living World scenes react automatically or stay silent. They never open a popup.")
    y = y - 78
    createSlider(page, "Shared scene frequency", "Chance to participate in non-essential Living World scenes.", 4, y, 300, 0, 100, 5, function() return HCVoice.db.livingWorld.frequency end, function(v) HCVoice.db.livingWorld.frequency = v end, function(v) return v .. "%" end)
    y = y - 82
    createButton(page, "Test boss victory", 4, y, 155, 28, function()
        if HCVoice.LivingWorld then HCVoice.LivingWorld:Simulate("boss") end
    end, "Simulates another HCVoice user starting a major dungeon victory scene.")
    createButton(page, "Test party joke", 169, y, 145, 28, function()
        if HCVoice.LivingWorld then HCVoice.LivingWorld:Simulate("joke") end
    end, "Simulates a nearby party member using JOKE or SILLY.")
    createButton(page, "Test party death", 324, y, 155, 28, function()
        if HCVoice.LivingWorld then HCVoice.LivingWorld:Simulate("death") end
    end, "Simulates a party-wide death scene without changing real party state.")
    createButton(page, "More tests in chat", 489, y, 155, 28, function()
        HCVoice:Message("Use /hcv lwtest for the complete Living World test list.")
    end)
    y = y - 66

    y = buildScenarioGroup(page, "social", "Player encounters", y, { "greetPlayer", "socialFarewell" })
    y = buildScenarioGroup(page, "social", "Party & gratitude", y, { "welcomeParty", "partyLevel", "thankHealer", "thankBuff", "thankAssist", "thankResurrection", "thankTrade", "readyCheckYes", "readyCheckNo" })
    createText(page, "Party departures always trigger /bye to each departing member while HCV is on, including Quiet mode. No chance roll, minimum membership time or cooldown applies.", false, 4, y, 650)
    y = y - 60

    y = createSection(page, "Incoming emote replies", y)
    createText(page, "In dungeons, recognized directed emotes are answered automatically, including during combat. Outside dungeons, clear emotes receive natural replies; flirting, insults and other ambiguous interactions can offer a choice.", false, 4, y, 650)
    y = y - 60
    createCheckbox(page, "Enable contextual replies", "Enables automatic dungeon replies, plus natural replies and optional choices elsewhere.", 4, y, function() return HCVoice.db.reply.enabled end, function(v) HCVoice.db.reply.enabled = v; HCVoice.db.reply.mode = v and "hybrid" or "off" end)
    y = y - 42
    createText(page, "Only directed emotes can offer choices. English standard emotes are recognized; custom text is never answered automatically.", false, 4, y, 300)
    createSlider(page, "Reply chance outside dungeons", "Outside dungeons: chance to answer an obvious directed emote. Skipped replies stay silent. Dungeons answer automatically with the usual conversation cooldowns.", 350, y, 280, 0, 100, 5, function() return HCVoice.db.reply.autoChance end, function(v) HCVoice.db.reply.autoChance = v end, function(v) return v .. "%" end)
    y = y - 82
    createCheckbox(page, "Pause combat replies elsewhere", "Applies outside dungeons. Dungeon replies remain automatic during combat. Ambiguous emotes outside dungeons may still offer a choice.", 4, y, function() return HCVoice.db.reply.disableAutoInCombat end, function(v) HCVoice.db.reply.disableAutoInCombat = v end)
    y = y - 42

    y = createSection(page, "Reply categories", y)
    local categories = {
        { "greetings", "Greetings", "HELLO, WAVE, SALUTE, BOW and BYE." },
        { "thanks", "Thanks", "Answers direct thanks with WELCOME or NOD." },
        { "congratulations", "Congratulations", "Answers congratulations with THANK." },
        { "friendly", "Jokes & friendly gestures", "Directed MOO gets a playful reply. Sighs, yawns and boredom get automatic dungeon replies or choices elsewhere." },
        { "requests", "Help & healing requests", "NOD when ready; WAIT when low on mana or busy." },
        { "tactical", "Tactical calls", "Contextual automatic replies in dungeons; optional reply choices elsewhere." },
        { "affection", "Flirting & affection", "Contextual automatic replies in dungeons; FLIRT/KISS/HUG choices elsewhere. A whistle is not assumed to be flirting." },
        { "hostile", "Insults", "Answers NO in dungeons; offers NO, RASP or LAUGH choices elsewhere." },
        { "unknown", "Unknown directed emotes", "Conservative suggestions outside dungeons when no rule matches. Silent in dungeons." },
    }
    local categoryY = y
    for index, item in ipairs(categories) do
        local key, label, tooltip = item[1], item[2], item[3]
        local x = index <= 5 and 4 or 350
        local row = index <= 5 and index - 1 or index - 6
        createCheckbox(page, label, tooltip, x, categoryY - row * 36, function() return HCVoice.db.reply.categories[key] end, function(v) HCVoice.db.reply.categories[key] = v end)
    end
    y = y - 198

    y = createSection(page, "Reply timing", y)
    createSlider(page, "Popup duration outside dungeons", "How long a reply choice remains visible outside dungeons.", 4, y, 300, 5, 30, 1, function() return HCVoice.db.reply.popupSeconds end, function(v) HCVoice.db.reply.popupSeconds = v end, function(v) return v .. " sec" end)
    createSlider(page, "Same-exchange cooldown", "Minimum time before repeating the same kind of exchange with a player. A greeting and a later thank-you are separate.", 350, y, 280, 30, 1800, 30, function() return HCVoice.db.reply.samePlayerCooldown end, function(v) HCVoice.db.reply.samePlayerCooldown = v end, function(v) return math.floor(v / 60) .. " min" end)
    y = y - 84

    createButton(page, "Test flirt popup", 4, y, 150, 28, function()
        GUI:ShowReplyPrompt({ kind = "reply", sender = "FriendlyPlayer", playerKey = "TEST", message = "FriendlyPlayer flirts with " .. characterName .. ".", options = { "FLIRT", "NOD", "BOW", "NO" }, needsSuggestion = true, test = true })
    end)
    createButton(page, "Test help request", 164, y, 170, 28, function()
        GUI:ShowReplyPrompt({ kind = "reply", sender = "FriendlyPlayer", playerKey = "TEST2", message = "FriendlyPlayer cries out for help.", options = { "NOD", "WAIT", "SALUTE", "HELPME" }, needsSuggestion = true, test = true })
    end)
    createButton(page, "Clear ignored players", 344, y, 180, 28, function()
        wipe(HCVoice.state.reply.ignored)
        HCVoice:Message("session reply ignores cleared")
    end, "Ignore choices are session-only and already clear on reload.")
    page:SetHeight(math.max(1300, -y + 90))
end

function GUI:BuildProfilesPage(page)
    local y = -8
    createText(page, "Profiles", true, 4, y, 650)
    y = y - 34
    createText(page, "Character settings remain separate. Saved profiles are account-wide, and export strings can be sent to friends without sharing personal character data.", false, 4, y, 650)
    y = y - 62

    page.selectedProfile = page.selectedProfile or nil
    page.profileChoices = page.profileChoices or {}
    local function refreshChoices()
        wipe(page.profileChoices)
        for _, name in ipairs(HCVoice:GetProfileNames()) do page.profileChoices[#page.profileChoices + 1] = { value = name, label = name } end
        local exists = false
        for _, choice in ipairs(page.profileChoices) do if choice.value == page.selectedProfile then exists = true end end
        if not exists then page.selectedProfile = page.profileChoices[1] and page.profileChoices[1].value or nil end
    end
    refreshChoices()

    y = createSection(page, "Saved profiles", y)
    createChoiceDropdown(page, 4, y, 280, "Selected profile", function() refreshChoices(); return page.profileChoices end,
        function() return page.selectedProfile end, function(v) page.selectedProfile = v end,
        "Profiles are shared by all characters on this WoW account.", false)
    local nameBox = createInputBox(page, 350, y + 1, 275, 30)
    createText(page, "Profile name", false, 350, y + 24, 200)
    y = y - 58

    local status = createText(page, "", false, 4, y - 42, 650)
    local function setStatus(message, good)
        status:SetText((good and "|cff55ff55" or "|cffff7777") .. tostring(message or "") .. "|r")
    end
    local function saveNow(name)
        local ok, result = HCVoice:SaveProfile(name)
        setStatus(ok and ("Saved profile: " .. result) or result, ok)
        if ok then page.selectedProfile = result; nameBox:SetText(result); refreshChoices(); GUI:RefreshCurrentPage() end
    end
    createButton(page, "Save current", 4, y, 145, 28, function()
        local name = HCVoice:NormalizeProfileName(nameBox:GetText())
        nameBox:SetText(name)
        local exists = HCVoice.accountDB and HCVoice.accountDB.profiles and HCVoice.accountDB.profiles[name]
        if exists then GUI:ConfirmAction("Overwrite profile '" .. name .. "'?", function() saveNow(name) end) else saveNow(name) end
    end, "Stores the current character settings as an account-wide profile.")
    createButton(page, "Load selected", 159, y, 145, 28, function()
        if not page.selectedProfile then setStatus("Select a saved profile first.", false); return end
        local selected = page.selectedProfile
        GUI:ConfirmAction("Replace this character's settings with profile '" .. selected .. "'?", function()
            local ok, result = HCVoice:LoadProfile(selected)
            setStatus(ok and ("Loaded profile: " .. result) or result, ok)
        end)
    end)
    createButton(page, "Delete selected", 314, y, 145, 28, function()
        if not page.selectedProfile then setStatus("Select a saved profile first.", false); return end
        local selected = page.selectedProfile
        GUI:ConfirmAction("Delete profile '" .. selected .. "'?", function()
            local ok, result = HCVoice:DeleteProfile(selected)
            setStatus(ok and ("Deleted profile: " .. result) or result, ok)
            if ok then page.selectedProfile = nil; refreshChoices(); GUI:RefreshCurrentPage() end
        end)
    end)
    y = y - 92

    y = createSection(page, "Share with friends", y)
    createText(page, "Share behavior settings with a friend. Import applies the listed settings; missing settings, window placement and local troubleshooting preferences are kept.", false, 4, y, 650)
    y = y - 48
    local transferBox = createInputBox(page, 4, y, 635, 32)
    y = y - 48
    createButton(page, "Export current", 4, y, 150, 28, function()
        transferBox:SetText(HCVoice:ExportProfile())
        transferBox:SetFocus()
        transferBox:HighlightText()
        setStatus("Profile string ready. Press Ctrl+C.", true)
    end)
    createButton(page, "Import pasted", 164, y, 150, 28, function()
        local text = transferBox:GetText()
        GUI:ConfirmAction("Apply the behavior settings in this profile? Settings missing from the text will stay unchanged.", function()
            local ok, result = HCVoice:ImportProfile(text)
            setStatus(result, ok)
        end)
    end)
    createButton(page, "Reset character", 324, y, 150, 28, function()
        GUI:ConfirmAction("Reset HCVoice settings for this character to defaults?", function() HCVoice:ResetDefaults(); setStatus("Character settings reset.", true) end)
    end)
    addPageRefresher(page, refreshChoices)
    page:SetHeight(math.max(620, -y + 100))
end

function GUI:CreatePage(key)
    local page = CreateFrame("Frame", nil, self.scroll)
    page:SetWidth(680)
    page:Hide()
    page.refreshers = {}
    page.key = key
    self.pages[key] = page

    if key == "general" then self:BuildGeneralPage(page)
    elseif key == "reactions" then self:BuildReactionsPage(page)
    elseif key == "replies" then self:BuildRepliesPage(page)
    elseif key == "profiles" then self:BuildProfilesPage(page)
    elseif key == "advanced" then self:BuildAdvancedPage(page)
    elseif key == "voices" then self:BuildVoicePage(page)
    elseif key == "history" then self:BuildHistoryPage(page) end
    return page
end

function GUI:BuildHistoryPage(page)
    local history = createText(page, "", false, 4, -12, 650)
    addPageRefresher(page, function() history:SetText(HCVoice:GetDecisionText()) end)
    page:SetHeight(1200)
end

function GUI:BuildGeneralPage(page)
    local y = -8
    local characterName = UnitName and UnitName("player") or "your character"
    createText(page, HCVoice.displayName, true, 4, y, 650)
    y = y - 34
    createText(page, "Semantic RP for " .. characterName .. ": every voice has a reason. Dungeon replies are automatic, with no popups. Elsewhere, ambiguous directed emotes can offer a reply choice.", false, 4, y, 650)
    y = y - 52

    y = createSection(page, "Master controls", y)
    createCheckbox(page, "Enable automatic RP reactions", "Master switch. Manual Voice Lab tests remain available.", 4, y, function() return HCVoice.db.enabled end, function(value) HCVoice:SetEnabled(value) end)
    y = y - 34
    createCheckbox(page, "Show debug decisions in chat", "Prints accepted and blocked HCVoice reactions for troubleshooting.", 4, y, function() return HCVoice.db.debug end, function(value) HCVoice.db.debug = value end)
    y = y - 34
    createCheckbox(page, "Show loaded message", "Prints the addon version when the UI loads.", 4, y, function() return HCVoice.db.announceLoaded end, function(value) HCVoice.db.announceLoaded = value end)
    y = y - 58

    createSlider(page, "Local RP frequency", "How often local non-essential moments initiate a reaction. Direct reply and Living World frequency are separate.", 4, y, 300, 0, 100, 5, function() return HCVoice.db.frequency end, function(value) HCVoice.db.frequency = value end, function(value) return value .. "%" end)
    createSlider(page, "Social voice spacing", "Space between social voices. Urgent warnings use a short separate spacing and discard outdated warnings.", 350, y, 280, 2, 60, 1, function() return HCVoice.db.globalCooldown end, function(value) HCVoice.db.globalCooldown = value end, function(value) return value .. " sec" end)
    y = y - 92

    y = createSection(page, "Presets", y)
    createText(page, "Presets configure local reactions, direct replies and Living World together. Category exclusions are preserved. Party departures always trigger BYE while HCV is on.", false, 4, y, 650)
    y = y - 34
    createButton(page, "Quiet", 4, y, 120, 28, function() HCVoice:ApplyPreset("quiet") end, "Only survival, deaths, rare warnings and major victories.")
    createButton(page, "Balanced", 134, y, 120, 28, function() HCVoice:ApplyPreset("balanced") end, "Recommended default with restrained social RP.")
    createButton(page, "Classic RP", 264, y, 140, 28, function() HCVoice:ApplyPreset("classicRP") end, "Full semantic default profile for any Classic Era character.")
    createButton(page, "Full RP", 414, y, 120, 28, function() HCVoice:ApplyPreset("fullRP") end, "Enables every scenario, including experimental and playful ones.")
    y = y - 58

    local summary = createText(page, "", false, 4, y, 650)
    addPageRefresher(page, function()
        summary:SetText(string.format("Active preset: |cffffffff%s|r   •   Enabled scenarios: |cffffffff%d / %d|r   •   Version: |cffffffff%s|r", HCVoice.db.preset or "custom", countEnabledScenarios(), #HCVoice.scenarioDefinitions, HCVoice.version))
    end)
    y = y - 42

    createButton(page, "Open reactions", 4, y, 150, 28, function() GUI:SelectPage("reactions") end)
    createButton(page, "Open replies", 164, y, 150, 28, function() GUI:SelectPage("replies") end)
    createButton(page, "Reset character", 324, y, 160, 28, function()
        GUI:ConfirmAction("Reset HCVoice settings for this character to defaults?", function() HCVoice:ResetDefaults() end)
    end, "Restores HCVoice defaults for this character only.")
    page:SetHeight(math.max(620, -y + 70))
end

function GUI:BuildScenarioPage(page, key)
    local y = -8
    local titles = { survival = "Survival & Pets", social = "Social RP", combat = "Combat RP", world = "World & Idle" }
    createText(page, titles[key] or key, true, 4, y, 650)
    y = y - 34
    createText(page, PAGE_COPY[key] or "", false, 4, y, 650)
    y = y - 60

    if key == "survival" then
        y = createSection(page, "Thresholds", y)
        createSlider(page, "Low mana", "Triggers the Low Mana scenario when mana reaches this percentage.", 4, y, 300, 5, 90, 1, function() return HCVoice.db.thresholds.mana end, function(value) HCVoice.db.thresholds.mana = value end, function(value) return value .. "%" end)
        createSlider(page, "Mana rearm", "Low Mana can trigger again only after mana recovers to this percentage.", 350, y, 280, 10, 100, 1, function() return HCVoice.db.thresholds.manaRearm end, function(value) HCVoice.db.thresholds.manaRearm = value end, function(value) return value .. "%" end)
        y = y - 78
        createSlider(page, "Need healing", "Triggers HEALME at this health percentage while in combat.", 4, y, 300, 10, 80, 1, function() return HCVoice.db.thresholds.healing end, function(value) HCVoice.db.thresholds.healing = value end, function(value) return value .. "%" end)
        createSlider(page, "Healing rearm", "HEALME can trigger again after health recovers to this percentage.", 350, y, 280, 15, 100, 1, function() return HCVoice.db.thresholds.healingRearm end, function(value) HCVoice.db.thresholds.healingRearm = value end, function(value) return value .. "%" end)
        y = y - 78
        createSlider(page, "Flee danger", "Triggers FLEE at this emergency combat health percentage.", 4, y, 300, 1, 40, 1, function() return HCVoice.db.thresholds.flee end, function(value) HCVoice.db.thresholds.flee = value end, function(value) return value .. "%" end)
        createSlider(page, "Flee rearm", "FLEE can trigger again after health recovers to this percentage.", 350, y, 280, 6, 100, 1, function() return HCVoice.db.thresholds.fleeRearm end, function(value) HCVoice.db.thresholds.fleeRearm = value end, function(value) return value .. "%" end)
        y = y - 92
    end

    y = createSection(page, "RP scenarios", y)
    for _, def in ipairs(HCVoice:GetScenarioDefinitions(key)) do y = createScenarioRow(page, def, y) end
    page:SetHeight(math.max(620, -y + 40))
end

function GUI:BuildAdvancedPage(page)
    local y = -8
    createText(page, "Advanced", true, 4, y, 650)
    y = y - 34
    createText(page, "Timing and detection controls. These values affect automatic scenario recognition, not manual Voice Lab tests.", false, 4, y, 650)
    y = y - 62

    y = createSection(page, "Detection", y)
    createSlider(page, "Idle reaction delay", "How long you must remain stationary and safe before an idle reaction is considered.", 4, y, 300, 1, 30, 1, function() return HCVoice.db.advanced.idleMinutes end, function(value) HCVoice.db.advanced.idleMinutes = value end, function(value) return value .. " min" end)
    createSlider(page, "Party wait delay", "As party leader, how long to stand still with a distant member before WAIT is considered.", 350, y, 280, 5, 60, 1, function() return HCVoice.db.advanced.partyWaitSeconds end, function(value) HCVoice.db.advanced.partyWaitSeconds = value end, function(value) return value .. " sec" end)
    y = y - 84
    createText(page, "INCOMING is fixed to the second hostile attacker. Targeting a rare or elite never triggers it by itself.", false, 4, y - 18, 300)
    createSlider(page, "Healing required for THANK", "External healing during one combat must reach this percentage of your maximum health.", 350, y, 280, 5, 75, 5, function() return HCVoice.db.advanced.healerThanksPercent end, function(value) HCVoice.db.advanced.healerThanksPercent = value end, function(value) return value .. "%" end)
    y = y - 84
    createSlider(page, "Minimum hard-fight duration", "Near-death SIGH is only considered after combat lasts at least this long.", 4, y, 300, 3, 60, 1, function() return HCVoice.db.advanced.hardFightSeconds end, function(value) HCVoice.db.advanced.hardFightSeconds = value end, function(value) return value .. " sec" end)
    createSlider(page, "Hard target level difference", "A normal enemy this many levels above you counts as a hard encounter.", 350, y, 280, 0, 10, 1, function() return HCVoice.db.advanced.hardLevelDelta end, function(value) HCVoice.db.advanced.hardLevelDelta = value end, function(value) return "+" .. value end)
    y = y - 84
    createSlider(page, "Same-player social cooldown", "Minimum time before greeting, flirting or taunting the same player again.", 4, y, 300, 1, 180, 1, function() return HCVoice.db.advanced.socialTargetCooldownMinutes end, function(value) HCVoice.db.advanced.socialTargetCooldownMinutes = value end, function(value) return value .. " min" end)
    createSlider(page, "Encounter memory", "How long a recent interaction remains eligible for a natural farewell.", 350, y, 280, 30, 900, 30, function() return HCVoice.db.advanced.encounterMemorySeconds end, function(value) HCVoice.db.advanced.encounterMemorySeconds = value end, function(value) return math.floor(value / 60) .. " min" end)
    y = y - 84
    createSlider(page, "Farewell delay", "Small pause before BYE after leaving a player target.", 4, y, 300, 0.2, 4, 0.2, function() return HCVoice.db.advanced.farewellDelaySeconds end, function(value) HCVoice.db.advanced.farewellDelaySeconds = value end, function(value) return string.format("%.1f sec", value) end)
    y = y - 92

    y = createSection(page, "Rearm & reply timing", y)
    createSlider(page, "Mana rearm", "OOM can trigger again only after mana recovers to this percentage.", 4, y, 300, 10, 100, 1, function() return HCVoice.db.thresholds.manaRearm end, function(value) HCVoice.db.thresholds.manaRearm = value end, function(value) return value .. "%" end)
    createSlider(page, "Healing rearm", "HEALME can trigger again only after health recovers to this percentage.", 350, y, 280, 15, 100, 1, function() return HCVoice.db.thresholds.healingRearm end, function(value) HCVoice.db.thresholds.healingRearm = value end, function(value) return value .. "%" end)
    y = y - 84
    createSlider(page, "Flee rearm", "FLEE can trigger again only after health recovers to this percentage.", 4, y, 300, 6, 100, 1, function() return HCVoice.db.thresholds.fleeRearm end, function(value) HCVoice.db.thresholds.fleeRearm = value end, function(value) return value .. "%" end)
    createSlider(page, "Reply prompt cooldown", "Prevents duplicate popups from the same player.", 350, y, 280, 2, 60, 1, function() return HCVoice.db.reply.promptCooldown end, function(value) HCVoice.db.reply.promptCooldown = value end, function(value) return value .. " sec" end)
    y = y - 100

    y = createSection(page, "Safety", y)
    createText(page, "HCVoice uses Blizzard emotes. If the client blocks an automatic call, it stays silent. Voice Lab lets you try a voice manually. A completed emote call does not confirm that sound played.", false, 4, y, 650)
    y = y - 78
    createButton(page, "Clear reaction cooldowns", 4, y, 190, 28, function()
        HCVoice.state.lastAnyEmoteAt = -math.huge
        wipe(HCVoice.state.lastScenarioAt)
        wipe(HCVoice.state.lastTargetAt)
        wipe(HCVoice.state.reply.lastReplyAt)
        wipe(HCVoice.state.reply.lastOutgoingAt)
        wipe(HCVoice.state.reply.lastPromptAt)
        wipe(HCVoice.state.reply.lastIncomingSignature)
        wipe(HCVoice.state.reply.lastIncomingAt)
        wipe(HCVoice.state.social.encounters)
        HCVoice.state.social.targetSession = nil
        HCVoice:Message("reaction, encounter and reply cooldowns cleared")
    end)
    page:SetHeight(math.max(900, -y + 70))
end

function GUI:BuildVoicePage(page)
    local y = -8
    createText(page, "Voice Lab", true, 4, y, 650)
    y = y - 34
    createText(page, "Test Classic speech, sounds and animated reactions. HUG is also kept as a text RP interaction. Race-specific voices appear only for the matching race.", false, 4, y, 650)
    y = y - 70

    page.selectedVoice = page.selectedVoice or "HELLO"
    page.useTarget = false
    createVoiceDropdown(page, 4, y, 260, "Selected voice", false, function() return page.selectedVoice end, function(value) page.selectedVoice = value; GUI:RefreshCurrentPage() end, false)
    createCheckbox(page, "Use current target", "Targets the emote text at your selected unit when possible.", 330, y - 3, function() return page.useTarget end, function(value) page.useTarget = value end, false)
    createButton(page, "Play selected", 520, y - 1, 140, 28, function() HCVoice:PlayVoice(page.selectedVoice, page.useTarget) end)
    y = y - 72

    local guidanceUsage = createText(page, "", false, 4, y, 650)
    local guidanceMode = createText(page, "", false, 4, y - 34, 650)
    addPageRefresher(page, function()
        local item = HCVoice.voiceByToken[page.selectedVoice]
        guidanceUsage:SetText("|cffffcc00Natural use:|r " .. (item and item.usage or "Manual RP use only."))
        guidanceMode:SetText("|cffffcc00Recommended mode:|r " .. (item and item.mode or "Manual"))
    end)
    y = y - 88

    local function buildVoiceGrid(category)
        y = createSection(page, category, y)
        local options = availableVoices(voiceCategories[category] or {})
        local columns = 3
        local buttonWidth = 205
        for index, item in ipairs(options) do
            local token = item.token
            local itemLabel = item.label
            local column = (index - 1) % columns
            local row = math.floor((index - 1) / columns)
            local bx = 4 + column * 220
            local by = y - row * 34
            createButton(page, itemLabel .. "  /" .. string.lower(token), bx, by, buttonWidth, 26, function()
                page.selectedVoice = token
                HCVoice:PlayVoice(token, page.useTarget)
                GUI:RefreshCurrentPage()
            end)
        end
        y = y - math.ceil(#options / columns) * 34 - 18
    end

    buildVoiceGrid("Official speech")
    buildVoiceGrid("Vocal reaction")
    buildVoiceGrid("Animated reaction")
    buildVoiceGrid("RP interaction")
    page:SetHeight(math.max(620, -y + 40))
end

function GUI:RefreshCurrentPage()
    local page = self.pages[self.currentPage]
    if not page or not page.refreshers then return end
    for _, fn in ipairs(page.refreshers) do fn() end
end

function GUI:Refresh()
    if self.enabledText and HCVoice.db then
        self.enabledText:SetText(HCVoice.db.enabled and "|cff55ff55Automatic RP: ON|r" or "|cffff5555Automatic RP: OFF|r")
    end
    self:RefreshCurrentPage()
end

function GUI:CleanupTransientUI()
    if CloseDropDownMenus then
        CloseDropDownMenus()
    elseif UIDropDownMenu_CloseDropDown then
        UIDropDownMenu_CloseDropDown()
    end
    hideTooltip()
    if self.HideReplyPrompt then self:HideReplyPrompt() end
end

function GUI:Close()
    if self.frame then
        self.frame:StopMovingOrSizing()
        self.frame:Hide()
    end
    self:CleanupTransientUI()
end

function GUI:SelectPage(key)
    if not self.frame then return end
    local page = self.pages[key] or self:CreatePage(key)
    self.currentPage = key

    -- ScrollFrame:SetScrollChild does not hide the previous child in Classic Era.
    -- Explicitly hide every cached page so tab contents can never overlap.
    for _, existingPage in pairs(self.pages) do
        existingPage:Hide()
    end
    self.scroll:SetScrollChild(page)
    page:Show()
    self.scroll:SetVerticalScroll(0)
    for navKey, button in pairs(self.navButtons) do
        if navKey == key then button:Disable() else button:Enable() end
    end
    self:RefreshCurrentPage()
end

function GUI:CreateMainFrame()
    if self.frame then return self.frame end
    local frame = CreateFrame("Frame", "HCVoiceRPDirectorFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(900, 690)
    if UIParent.GetWidth and frame.SetScale then frame:SetScale(math.min(1, (UIParent:GetWidth() - 30) / 900, (UIParent:GetHeight() - 30) / 690)) end
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    if frame.TitleText then frame.TitleText:SetText(HCVoice.displayName) end
    wireCloseButton(frame, function() GUI:Close() end)
    if UISpecialFrames then
        local registered = false
        for _, frameName in ipairs(UISpecialFrames) do if frameName == "HCVoiceRPDirectorFrame" then registered = true; break end end
        if not registered then UISpecialFrames[#UISpecialFrames + 1] = "HCVoiceRPDirectorFrame" end
    end

    local sidebar = CreateFrame("Frame", nil, frame)
    sidebar:SetPoint("TOPLEFT", 12, -34)
    sidebar:SetPoint("BOTTOMLEFT", 12, 12)
    sidebar:SetWidth(158)
    self.sidebar = sidebar

    local logo = sidebar:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    logo:SetPoint("TOPLEFT", 8, -8)
    logo:SetText("RP Reactions")
    local version = sidebar:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    version:SetPoint("TOPLEFT", logo, "BOTTOMLEFT", 0, -4)
    version:SetText("v" .. HCVoice.version)

    local navY = -62
    for _, def in ipairs(PAGE_DEFS) do
        local pageKey = def.key
        local pageLabel = def.label
        local button = createButton(sidebar, pageLabel, 4, navY, 146, 28, function() GUI:SelectPage(pageKey) end)
        self.navButtons[pageKey] = button
        navY = navY - 34
    end

    local enabledText = sidebar:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    self.enabledText = enabledText
    enabledText:SetPoint("BOTTOMLEFT", 8, 50)
    enabledText:SetWidth(140)
    enabledText:SetJustifyH("LEFT")
    frame:SetScript("OnShow", function()
        enabledText:SetText(HCVoice.db.enabled and "|cff55ff55Automatic RP: ON|r" or "|cffff5555Automatic RP: OFF|r")
        GUI:SelectPage(GUI.currentPage or "general")
    end)
    frame:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
        GUI:CleanupTransientUI()
    end)

    local openHint = sidebar:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    openHint:SetPoint("BOTTOMLEFT", 8, 18)
    openHint:SetText("/hcvoice  or  /hcv")

    local scroll = CreateFrame("ScrollFrame", "HCVoiceRPDirectorScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 181, -42)
    scroll:SetPoint("BOTTOMRIGHT", -32, 20)
    self.scroll = scroll
    self.frame = frame
    return frame
end

function GUI:Toggle()
    local frame = self:CreateMainFrame()
    if frame:IsShown() then self:Close() else frame:Show() end
end

function GUI:CreateReplyFrame()
    if self.replyFrame then return self.replyFrame end
    local frame = CreateFrame("Frame", "HCVoiceReplyFrame", UIParent, "BackdropTemplate")
    frame:SetSize(320, 140)
    frame:SetPoint("RIGHT", UIParent, "RIGHT", -24, -100)
    if frame.SetScale and UIParent.GetWidth then frame:SetScale(math.min(1, (UIParent:GetWidth() - 20) / 320)) end
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.08, 0.08, 0.08, 0.88)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6)
    local pos = HCVoice.db.ui.replyPosition
    if type(pos) == "table" and type(pos.x) == "number" and type(pos.y) == "number" then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
    end
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        if x and y then HCVoice.db.ui.replyPosition = { x = x, y = y } end
    end)
    frame:Hide()
    wireCloseButton(frame, function() GUI:HideReplyPrompt() end)

    frame.senderText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frame.senderText:SetPoint("TOPLEFT", 12, -13)
    frame.senderText:SetWidth(270)
    frame.senderText:SetHeight(16)
    frame.senderText:SetWordWrap(false)
    frame.senderText:SetJustifyH("LEFT")

    frame.messageText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    frame.messageText:SetPoint("TOPLEFT", 12, -34)
    frame.messageText:SetWidth(296)
    frame.messageText:SetHeight(16)
    frame.messageText:SetJustifyH("LEFT")
    frame.messageText:SetWordWrap(false)
    frame:SetScript("OnEnter", function(self)
        if self.data then showTooltip(self, self.data.title or self.data.sender, self.data.message) end
    end)
    frame:SetScript("OnLeave", hideTooltip)

    frame.replyButtons = {}
    for index = 1, 4 do
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        button:SetSize(144, 26)
        button:SetNormalFontObject("GameFontNormalSmall")
        button:SetHighlightFontObject("GameFontHighlightSmall")
        button:SetPoint("TOPLEFT", 12 + column * 152, -56 - row * 30)
        button:SetScript("OnClick", function(self)
            local data = frame.data
            local success = false
            if data and self.token and (data.test or HCVoice:IsPromptValid(data)) then
                success = HCVoice:ExecuteSuggestedReply(self.token, data.sender, data.playerKey)
            end
            if success then GUI:HideReplyPrompt() end
        end)
        frame.replyButtons[index] = button
    end

    frame.ignoreButton = CreateFrame("Button", nil, frame)
    frame.ignoreButton:SetNormalFontObject("GameFontDisableSmall")
    frame.ignoreButton:SetHighlightFontObject("GameFontHighlightSmall")
    frame.ignoreButton:SetSize(132, 20)
    frame.ignoreButton:SetPoint("BOTTOMLEFT", 8, 5)
    frame.ignoreButton:SetText("Ignore player")
    frame.ignoreButton:SetScript("OnClick", function()
        if frame.data then HCVoice:IgnoreReplyPlayer(frame.data.playerKey, frame.data.sender) end
        GUI:HideReplyPrompt()
    end)

    frame:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
        hideTooltip()
    end)
    if UISpecialFrames then
        local registered = false
        for _, frameName in ipairs(UISpecialFrames) do if frameName == "HCVoiceReplyFrame" then registered = true; break end end
        if not registered then UISpecialFrames[#UISpecialFrames + 1] = "HCVoiceReplyFrame" end
    end
    self.replyFrame = frame
    return frame
end

function GUI:HideReplyPrompt()
    self.replyGeneration = (self.replyGeneration or 0) + 1
    if self.replyFrame then
        self.replyFrame:StopMovingOrSizing()
        self.replyFrame:Hide()
        self.replyFrame.data = nil
    end
end

local REPLY_LABELS = {
    HELLO = "Say hello", WAVE = "Wave back", SALUTE = "Salute",
    BOW = "Bow politely", NOD = "Smile and nod", NO = "No, thank you",
    THANK = "Say thanks", WELCOME = "You're welcome", BYE = "Say goodbye",
    FLIRT = "Flirt back", KISS = "Kiss", HUG = "Hug",
    LAUGH = "Laugh", GUFFAW = "Laugh loudly", JOKE = "Tell a joke",
    WHISTLE = "Whistle", MOO = "Moo back", SIGH = "Sigh", YAWN = "Yawn",
    WAIT = "Ask to wait", HELPME = "Ask for help", FOLLOW = "Follow me",
    ATTACKMYTARGET = "Mark the target", OPENFIRE = "Open fire",
    CHARGE = "Charge!", FLEE = "Call for retreat", RASP = "Taunt back",
}

local function replyLabel(token)
    token = string.upper(tostring(token or ""))
    return REPLY_LABELS[token] or ("/" .. string.lower(token))
end

function GUI:ShowReplyPrompt(data)
    if HCVoice:IsInDungeon() then self:HideReplyPrompt(); return false end
    if not data or data.kind ~= "reply" or data.needsSuggestion ~= true or not data.options or #data.options == 0 then return end
    if not data.test and not HCVoice:IsPromptValid(data) then return false end
    local frame = self:CreateReplyFrame()
    if frame:IsShown() and frame.data then
        HCVoice:RecordDecision("reply", "skipped", "a suggestion is already being considered")
        return false
    end
    frame.data = data
    frame:SetHeight(#data.options <= 2 and 110 or 140)
    frame.senderText:SetText(data.title or ((data.sender or "A player") .. " emoted toward you"))
    frame.messageText:SetText(data.message or "Choose a reply")
    for index, button in ipairs(frame.replyButtons) do
        local token = data.options[index]
        if token then
            button.token = token
            button:SetText(replyLabel(token))
            button:Show()
        else
            button.token = nil
            button:Hide()
        end
    end
    if data.test then frame.ignoreButton:Hide() else frame.ignoreButton:Show() end
    frame:Show()

    self.replyGeneration = (self.replyGeneration or 0) + 1
    local generation = self.replyGeneration
    local duration = HCVoice.db and HCVoice.db.reply and HCVoice.db.reply.popupSeconds or 12
    data.expiresAt = data.expiresAt or GetTime() + duration
    duration = math.min(duration, math.max(0, data.expiresAt - GetTime()))
    C_Timer.After(duration, function()
        if GUI.replyGeneration == generation then GUI:HideReplyPrompt() end
    end)
    return true
end
