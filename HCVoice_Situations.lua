local _, addon = ...
local H = _G.HCVoice or addon
local function now() return GetTime() end

-- Drink spell IDs from the Classic Era 1.15.9.69547 client table. Matching IDs
-- avoids confusing regeneration buffs, potions or food with a real mana break.
local DRINK_SPELLS = {
    [430] = true, [431] = true, [432] = true, [1133] = true, [1135] = true,
    [1137] = true, [10250] = true, [22734] = true, [24355] = true,
    [25696] = true, [26261] = true, [26402] = true, [26473] = true,
    [26475] = true, [29007] = true, [446714] = true, [468767] = true,
}

function H:HasDrinkAura()
    for index = 1, 40 do
        local spellID
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local aura = C_UnitAuras.GetAuraDataByIndex("player", index, "HELPFUL")
            if not aura then break end
            spellID = aura.spellId
        elseif UnitBuff then
            local name, _, _, _, _, _, _, _, _, id = UnitBuff("player", index)
            if not name then break end
            spellID = id
        else
            return false
        end
        if DRINK_SPELLS[spellID] then return true end
    end
    return false
end

local function partyIdentity()
    local members = {}
    for i = 1, 4 do
        local guid = UnitGUID("party" .. i)
        if guid then members[#members + 1] = guid end
    end
    table.sort(members)
    return table.concat(members, ":")
end

local function cancelQueued(key)
    for i = #H.state.reactionQueue, 1, -1 do
        local r = H.state.reactionQueue[i]
        if r.scenario == key then
            H:RecordDecision(r, "skipped", "mana break changed the context")
            table.remove(H.state.reactionQueue, i)
        end
    end
end

function H:IsManaBreakSafe(phase)
    local cfg = self:GetScenarioConfig("manaBreak")
    return self.db.enabled and cfg and cfg.enabled and cfg.mode == "automatic"
        and UnitPowerMax("player", Enum and Enum.PowerType and Enum.PowerType.Mana or 0) > 0
        and IsInGroup() and not (IsInRaid and IsInRaid())
        and self:IsRelaxedMoment(not (phase and (phase.resume or phase.finished)))
        and (not phase or phase.group == partyIdentity())
end

function H:IsAnnouncedManaBreak()
    local phase = self.state.manaBreak
    return phase and phase.active and not phase.cancelled and phase.waitQueued
        and self:IsManaBreakSafe(phase) and self:HasDrinkAura()
end

function H:CancelManaBreak()
    local phase = self.state.manaBreak
    if phase then phase.cancelled = true; phase.finished = false end
end

function H:HandleManaBreakMovement()
    local phase = self.state.manaBreak
    if phase and not phase.cancelled and phase.announced and self:PlayerManaPercent() >= 90
        and now() - phase.startedAt >= 3 then
        -- Leaving the drink with enough mana is a normal completion. Wait for
        -- the aura to end before NOD; movement with low mana remains a cancel.
        phase.resume = true
    else
        self:CancelManaBreak()
    end
    self:HandleManaBreak()
end

function H:HandleManaBreak(initial)
    if not self.state or not self.db then return end
    local active = self:HasDrinkAura()
    local phase = self.state.manaBreak
    if phase and phase.finished and (active or self:PlayerManaPercent() < 90 or not self:IsManaBreakSafe(phase)) then
        self:CancelManaBreak()
    end
    if active and (initial or not phase or not phase.active) then
        phase = { active = true, startedAt = now(), group = partyIdentity(), cancelled = true }
        self.state.manaBreak = phase
        if initial or not self:IsManaBreakSafe(phase) or self:PlayerManaPercent() > 60 then return end
        phase.cancelled = false
        phase.waitQueued = self:RequestReaction("manaBreak", nil, nil, {
            validate = function()
                return self.state.manaBreak == phase and not phase.cancelled and phase.active
                    and self:IsManaBreakSafe(phase) and self:HasDrinkAura() and self:PlayerManaPercent() < 90
            end,
        })
        if phase.waitQueued then cancelQueued("lowMana") end
    elseif phase and phase.active then
        if initial or not self:IsManaBreakSafe(phase) then self:CancelManaBreak() end
        if not active then
            phase.active = false
            if not phase.cancelled and phase.announced and now() - phase.startedAt >= 3 and self:PlayerManaPercent() >= 90 then
                phase.finished = true
                self:RequestReaction("manaReady", nil, nil, {
                    validate = function()
                        return self.state.manaBreak == phase and phase.finished and not phase.cancelled
                            and self:IsManaBreakSafe(phase) and not self:HasDrinkAura() and self:PlayerManaPercent() >= 90
                    end,
                })
            end
        end
    end
end

function H:OnSituationPlayed(reaction)
    if reaction.scenario == "manaBreak" and self.state.manaBreak then
        self.state.manaBreak.announced = true
    end
end

function H:HandlePetDeath(guid)
    local pet = self.state and self.state.pet
    if not pet or not guid or pet.guid ~= guid or not pet.alive then return end
    if pet.lostAt and now() - pet.lostAt > 5 then return end
    pet.alive, pet.lowArmed = false, false
    self:RequestReaction("petDeath", nil, guid, {
        targetUnit = "pet",
        subjectName = pet.name,
        momentKey = "petDeath:" .. guid .. ":" .. tostring(now()),
        validate = function()
            local current = UnitGUID("pet")
            return self.state.pet == pet and not pet.alive
                and current == guid and UnitIsDeadOrGhost("pet")
        end,
    })
end

function H:HandlePetState(initial)
    if not self.state or not self.db then return end
    local guid = UnitGUID("pet")
    local pet = self.state.pet
    if not guid or not UnitExists("pet") then
        if pet then pet.lostAt = pet.lostAt or now() end
        return
    end
    local alive = not UnitIsDeadOrGhost("pet") and UnitHealth("pet") > 0
    local hp = self:UnitHealthPercent("pet")
    if initial or not pet or pet.guid ~= guid then
        self.state.pet = { guid = guid, name = UnitName("pet"), alive = alive, lowArmed = hp > 25 }
        return
    end
    pet.lostAt = nil
    if UnitIsDeadOrGhost("pet") then self:HandlePetDeath(guid); return end
    if not alive then return end -- Missing health data is not death evidence.
    pet.alive = true
    if hp >= 60 then pet.lowArmed = true end
    local fighting = self.state.inCombat or (UnitAffectingCombat and UnitAffectingCombat("pet"))
    if pet.lowArmed and hp <= 25 and fighting then
        pet.lowArmed = false
        self:RequestReaction("petDanger", nil, guid, {
            targetUnit = "pet",
            validate = function()
                return self.state.pet == pet and pet.alive and UnitGUID("pet") == guid
                    and not UnitIsDeadOrGhost("pet") and UnitHealth("pet") > 0 and self:UnitHealthPercent("pet") <= 25
                    and (self.state.inCombat or (UnitAffectingCombat and UnitAffectingCombat("pet")) == true)
            end,
        })
    end
end

-- Observe command state; never issue, replace or repeat a protected pet action.
function H:GetPetControlSnapshot()
    if not GetPetActionInfo or not PetHasActionBar or not PetHasActionBar()
        or not UnitExists("pet") or UnitIsDeadOrGhost("pet") or UnitHealth("pet") <= 0 then return end
    local snapshot = { guid = UnitGUID("pet"), target = UnitGUID("pettarget"), attack = false, follow = false, stay = false }
    if not snapshot.guid then return end
    for slot = 1, (NUM_PET_ACTION_SLOTS or 10) do
        local name, _, isToken, active = GetPetActionInfo(slot)
        if isToken and (active == true or active == 1) then
            if name == "PET_ACTION_ATTACK" or (IsPetAttackAction and IsPetAttackAction(slot)) then snapshot.attack = true
            elseif name == "PET_ACTION_FOLLOW" then snapshot.follow = true
            elseif name == "PET_ACTION_WAIT" then snapshot.stay = true end
        end
    end
    snapshot.away = snapshot.attack or snapshot.stay
    return snapshot
end

function H:RefreshPetCommandState(initial)
    if not self.state then return end
    local snapshot = self:GetPetControlSnapshot()
    if not snapshot then self.state.petOrders = nil; return end
    local orders = self.state.petOrders
    if initial or not orders or orders.guid ~= snapshot.guid then
        orders = { guid = snapshot.guid, snapshot = snapshot, attackUsed = snapshot.attack, lastAwayAt = -math.huge }
        self.state.petOrders = orders
    end
    -- Keep the previous away state briefly: PET_BAR_UPDATE may arrive before
    -- the secure post-hook for a Follow command in the same frame.
    if snapshot.away or orders.snapshot.away then orders.lastAwayAt = now() end
    if not snapshot.attack and not self.state.inCombat
        and not (UnitAffectingCombat and (UnitAffectingCombat("player") or UnitAffectingCombat("pet"))) then
        orders.attackUsed = false
    end
    orders.snapshot = snapshot
    return orders, snapshot
end

local function petOrderMatches(order, snapshot)
    if not snapshot or snapshot.guid ~= order.guid then return false end
    if order.kind == "attack" then
        return snapshot.attack and snapshot.target == order.target
            and UnitExists("pettarget") and UnitCanAttack("player", "pettarget")
            and not UnitIsDeadOrGhost("pettarget") and UnitHealth("pettarget") > 0
    end
    return snapshot.follow and not snapshot.attack
end

function H:ObservePetCommand(kind, targetUnit)
    if not self.state or not self.db then return end
    local orders, snapshot = self:RefreshPetCommandState()
    if not orders or not self.db.enabled then return end
    local target
    if kind == "attack" then
        targetUnit = type(targetUnit) == "string" and targetUnit ~= "" and targetUnit or "target"
        if not UnitExists(targetUnit) or not UnitCanAttack("player", targetUnit)
            or UnitIsDeadOrGhost(targetUnit) or UnitHealth(targetUnit) <= 0 then return end
        target = UnitGUID(targetUnit)
        if not target then return end
    elseif kind ~= "recall" or (not snapshot.away and now() - orders.lastAwayAt > 0.75) then
        return
    end
    local old = orders.command
    if old and old.kind == kind and old.target == target and now() - old.at < 2 then return end
    local order = { kind = kind, guid = orders.guid, target = target, at = now() }
    orders.command = order -- A newer command cancels the previous voice.
    if kind == "attack" and orders.attackUsed then return end
    local state = self.state
    local key = kind == "attack" and "petAttack" or "petRecall"
    local function confirm()
        if self.state ~= state or state.petOrders ~= orders or orders.command ~= order or not self.db.enabled then return end
        local currentOrders, current = self:RefreshPetCommandState()
        if currentOrders ~= orders then return end
        if not petOrderMatches(order, current) then
            if now() - order.at < 1 then C_Timer.After(0.1, confirm) end
            return
        end
        if kind == "attack" then orders.attackUsed = true end
        self:RequestReaction(key, nil, order.guid, {
            targetUnit = "pet",
            expiresIn = 2,
            validate = function()
                return self.state == state and state.petOrders == orders and orders.command == order
                    and petOrderMatches(order, self:GetPetControlSnapshot())
            end,
        })
    end
    C_Timer.After(0.1, confirm)
end

function H:InstallPetCommandHooks()
    if not hooksecurefunc then return end
    self.petCommandHooks = self.petCommandHooks or {}
    local function install(name, callback)
        if not self.petCommandHooks[name] and type(_G[name]) == "function" then
            self.petCommandHooks[name] = pcall(hooksecurefunc, name, callback)
        end
    end
    install("PetAttack", function(unit) H:ObservePetCommand("attack", unit) end)
    install("PetFollow", function() H:ObservePetCommand("recall") end)
    install("CastPetAction", function(slot, unit)
        if not GetPetActionInfo then return end
        local name, _, isToken = GetPetActionInfo(slot)
        if not isToken then return end
        if name == "PET_ACTION_ATTACK" or (IsPetAttackAction and IsPetAttackAction(slot)) then H:ObservePetCommand("attack", unit)
        elseif name == "PET_ACTION_FOLLOW" then H:ObservePetCommand("recall") end
    end)
end
