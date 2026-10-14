local _, addon = ...
local H = _G.HCVoice or addon
local B = { cards = {}, byNPC = {}, dungeons = {}, dungeonOrder = {}, maps = {}, outdoorMaps = {}, PREFIX = "HCVB1" }
H.Bosses = B
local function now() return GetTime() end
local function set(list)
    local result = {}
    for _, id in ipairs(list or {}) do result[id] = true end
    return result
end

function B:RegisterDungeon(key, name, map)
    self.dungeons[key] = { key = key, name = name, map = map }
    self.dungeonOrder[#self.dungeonOrder + 1] = key
    self.maps[map] = true
end

function B:Register(card)
    assert(not self.cards[card.key], "duplicate boss card")
    assert(self.dungeons[card.dungeon], "unknown boss dungeon")
    card.map = self.dungeons[card.dungeon].map
    card.members = set(card.npcs)
    card.required = set(card.finish or card.npcs)
    card.starts = set(card.starts or card.npcs)
    self.cards[card.key] = card
    for map in pairs(card.extraMaps or {}) do self.outdoorMaps[map] = true end
    for _, id in ipairs(card.npcs) do
        assert(not self.byNPC[id], "duplicate boss NPC")
        self.byNPC[id] = card
    end
end

function B:NPCID(guid)
    if type(guid) ~= "string" then return nil end
    local kind, id = guid:match("^(%a+)%-[^%-]+%-[^%-]+%-[^%-]+%-[^%-]+%-(%d+)%-[^%-]+$")
    return (kind == "Creature" or kind == "Vehicle") and tonumber(id) or nil
end

function B:MatchesMap(card, map)
    return card.map == map or (card.extraMaps and card.extraMaps[map] == true)
end

function B:Map()
    if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC or not WOW_PROJECT_CLASSIC then return nil end
    if not C_GameRules or not C_GameRules.IsHardcoreActive or not C_GameRules.IsHardcoreActive() then return nil end
    if not GetInstanceInfo then return nil end
    local _, kind, _, _, _, _, _, map = GetInstanceInfo()
    if kind == "party" or kind == "raid" then
        if self.maps[map] then return map end
    elseif kind == "none" then
        -- The catalogue explicitly includes the three khans before Maraudon's portals.
        if self.outdoorMaps[map] then return map end
    end
end

function B:Enabled(card)
    local cfg = H:GetScenarioConfig("bossReactions")
    return H.db and H.db.enabled and cfg and cfg.enabled and cfg.mode == "automatic"
        and (not card or H.db.bossDungeons[card.dungeon] ~= false)
end

function B:Sanitize()
    if type(H.db.bossDungeons) ~= "table" then H.db.bossDungeons = {} end
    for key in pairs(H.db.bossDungeons) do
        if not self.dungeons[key] then H.db.bossDungeons[key] = nil end
    end
    for key in pairs(self.dungeons) do H.db.bossDungeons[key] = H.db.bossDungeons[key] ~= false end
end

function B:AnyCombat()
    if H.state.inCombat or UnitAffectingCombat("player") or UnitAffectingCombat("pet") then return true end
    for _, unit in ipairs(H:GroupUnits()) do
        if UnitExists(unit) and UnitAffectingCombat(unit) then return true end
        local pet = unit:gsub("^(%a+)(%d+)$", "%1pet%2")
        if UnitExists(pet) and UnitAffectingCombat(pet) then return true end
    end
    return false
end

function B:RosterKey()
    local guids = { UnitGUID("player") or "" }
    for _, unit in ipairs(H:GroupUnits()) do
        if UnitExists(unit) then guids[#guids + 1] = UnitGUID(unit) or "" end
    end
    table.sort(guids)
    return table.concat(guids, ":")
end

function B:Reset()
    if not H.state then return end
    H.state.bosses = { map = self:Map(), roster = self:RosterKey(), encounters = {},
        pending = {}, claims = {}, seenOpenings = {}, lastAt = -math.huge,
        quietUntil = 0, suspended = self:AnyCombat() }
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        pcall(C_ChatInfo.RegisterAddonMessagePrefix, self.PREFIX)
    end
end

function B:State()
    if not H.state or not H.db then return nil end
    if not H.state.bosses then self:Reset() end
    local s = H.state.bosses
    local map = self:Map()
    if s.map ~= map then self:Reset(); s = H.state.bosses end
    if not map or not self:Enabled() then return nil end
    if s.suspended then
        if self:AnyCombat() then return nil end
        s.suspended = false
    end
    return s
end

function B:GroupGUID(guid)
    if not guid then return false end
    if guid == UnitGUID("player") or guid == UnitGUID("pet") then return true end
    for _, unit in ipairs(H:GroupUnits()) do
        if guid == UnitGUID(unit) then return true end
        local pet = unit:gsub("^(%a+)(%d+)$", "%1pet%2")
        if guid == UnitGUID(pet) then return true end
    end
    return false
end

function B:SafeExpression()
    if UnitIsDeadOrGhost("player") or UnitHealth("player") <= 0 then return false end
    if (UnitCastingInfo and UnitCastingInfo("player")) or (UnitChannelInfo and UnitChannelInfo("player")) then return false end
    if HasFullControl and not HasFullControl() then return false end
    if H:UnitHealthPercent("player") <= H.db.thresholds.healing then return false end
    if now() < math.max(H.state.somberUntil or 0, H.state.seriousUntil or 0) then return false end
    for _, unit in ipairs(H:GroupUnits()) do
        if UnitExists(unit) and (UnitIsDeadOrGhost(unit) or UnitHealth(unit) <= 0) then return false end
    end
    for _, reaction in ipairs(H.state.reactionQueue) do
        if reaction.lane == "urgent" and H:IsReactionStillValid(reaction) then return false end
    end
    return true
end

local function encounterKey(card, guid)
    -- A multi-NPC encounter must have the same key whichever member a client sees first.
    local scope = guid:match("^%a+%-([^%-]+%-[^%-]+%-[^%-]+%-[^%-]+)%-") or guid
    return card.key .. ":" .. (card.independent and guid or scope)
end

function B:Encounter(card, guid, create)
    local s = self:State()
    if not s or not self:MatchesMap(card, s.map) or not self:Enabled(card) then return nil end
    local key = encounterKey(card, guid)
    local e = s.encounters[key]
    if not e and create then
        e = { key = key, card = card, guid = guid, observed = {}, dead = {},
            used = {}, phaseCount = 0, lastEvent = now(), names = {} }
        s.encounters[key] = e
    end
    return e, s
end

function B:Complete(e)
    if not e.engaged then return false end
    if e.card.independent then return e.dead[self:NPCID(e.guid)] == true end
    for id in pairs(e.card.required) do if not e.dead[id] then return false end end
    return true
end

function B:OwnsVictory(guid, name)
    local s = self:State()
    if not s then return false end
    local card = self.byNPC[self:NPCID(guid)]
    if card and self:MatchesMap(card, s.map) and self:Enabled(card) then return true end
    for _, e in pairs(s.encounters) do
        if self:Enabled(e.card) and name and e.names[name] then return true end
    end
    return false
end

function B:Send(kind, e, moment)
    if not IsInGroup() or not C_ChatInfo or not C_ChatInfo.SendAddonMessage then return end
    local message = table.concat({ kind, tostring(H.state.bosses.map), e.card.key, e.guid, moment }, "|")
    if #message <= 255 then
        pcall(C_ChatInfo.SendAddonMessage, self.PREFIX, message, IsInRaid() and "RAID" or "PARTY")
    end
end

function B:SenderGUID(sender)
    for _, unit in ipairs(H:GroupUnits()) do
        if UnitExists(unit) then
            local full = GetUnitName and GetUnitName(unit, true) or UnitName(unit)
            if H.NameKey(sender) == H.NameKey(full) then return UnitGUID(unit) end
        end
    end
end

function B:OnMessage(prefix, message, channel, sender)
    if prefix ~= self.PREFIX or (channel ~= "PARTY" and channel ~= "RAID") then return end
    local s = self:State()
    if not s or type(message) ~= "string" or #message > 255 then return end
    local actor = self:SenderGUID(sender)
    if not actor or actor == UnitGUID("player") then return end
    local kind, map, key, guid, moment = message:match("^([CP])|(%d+)|([%w%-]+)|([%w%-]+)|([%w%-]+)$")
    local card = key and self.cards[key]
    if not card or tonumber(map) ~= s.map or not self:MatchesMap(card, s.map) or not self:Enabled(card) then return end
    if not card.members[self:NPCID(guid)] then return end
    local phase = tonumber(moment:match("^phase(%d+)$"))
    if moment ~= "open" and moment ~= "victory"
        and not (phase and ((card.transition and card.transition[phase]) or (card.spells and card.spells[phase]))) then return end
    local id = encounterKey(card, guid) .. ":" .. moment
    local claim = s.claims[id]
    if not claim or now() - claim.at > 8 then claim = { actors = {}, at = now() }; s.claims[id] = claim end
    claim.actors[actor] = true
    if kind == "P" then claim.played = true end
    -- Packets only suppress locally observed moments. They never create reactions.
end

function B:Queue(e, moment, token, guid, isNotice)
    local s = self:State()
    if not s or not token or e.used[moment] or not self:SafeExpression() then return false end
    if moment == "open" and (UnitGUID("target") ~= guid or not UnitCanAttack("player", "target")) then return false end
    if moment ~= "victory" and now() - s.lastAt < 12 then e.used[moment] = true; return false end
    if now() < s.quietUntil then e.used[moment] = true; return false end
    local chance = (H:GetScenarioConfig("bossReactions").chance or 100) * H.db.frequency / 100
    e.used[moment] = true
    if math.random() * 100 > chance then return false end
    local id = e.key .. ":" .. moment
    local claim = s.claims[id]
    if not claim or now() - claim.at > 8 then claim = { actors = {}, at = now() }; s.claims[id] = claim end
    claim.actors[UnitGUID("player") or ""] = true
    self:Send("C", e, moment)
    local reaction = {
        scenario = "bossReactions", token = token, priority = moment == "victory" and 74 or 24,
        targetKey = id, momentKey = "boss:" .. id, boss = true,
        bossEncounter = e, bossMoment = moment, bossNotice = isNotice,
        notBefore = now() + 0.8, expiresAt = now() + (moment == "victory" and 12 or 3),
        suppressLivingWorld = true,
    }
    if moment == "open" then
        -- A directed emote requires our actual target, even for NPCs with identical names.
        reaction.targetName, reaction.targetUnit = UnitName("target"), "target"
    end
    reaction.validate = function()
        if H.state.bosses ~= s or self:State() ~= s or s.encounters[e.key] ~= e or not self:Enabled(e.card) then return false end
        if not self:SafeExpression() or now() < s.quietUntil or now() - s.lastAt < 12 then return false end
        if s.claims[id] ~= claim or claim.played then return false end
        local winner = UnitGUID("player") or ""
        for actor in pairs(claim.actors) do if actor < winner then winner = actor end end
        if winner ~= UnitGUID("player") then return false end
        if moment == "victory" then return self:Complete(e) and not self:AnyCombat() and not e.sorrow end
        if self:Complete(e) or e.finished then return false end
        if moment == "open" then
            if UnitGUID("target") ~= guid or UnitIsDeadOrGhost("target") or not UnitCanAttack("player", "target") then return false end
            if isNotice and (self:AnyCombat() or GetUnitSpeed("player") > 0) then return false end
        else
            if not e.engaged or not self:AnyCombat() then return false end
        end
        return true
    end
    local queued = H:EnqueueReaction(reaction)
    if queued then s.pending[id] = reaction end
    return queued
end

function B:OnPlayed(r)
    if not r.boss then return end
    local s = H.state.bosses
    if not s then return end
    s.lastAt = now()
    self:Send("P", r.bossEncounter, r.bossMoment)
end

function B:Notice()
    local s = self:State()
    if not s or self:AnyCombat() or not UnitExists("target") or not UnitCanAttack("player", "target") then return end
    local guid = UnitGUID("target")
    local card = self.byNPC[self:NPCID(guid)]
    if not card or not card.notice or not card.starts[self:NPCID(guid)] or s.seenOpenings[guid] then return end
    local generation = H.state.generation
    C_Timer.After(1.5, function()
        if H.state.generation ~= generation or H.state.bosses ~= s or UnitGUID("target") ~= guid or self:AnyCombat() then return end
        local e = self:Encounter(card, guid, true)
        if not e or e.engaged or e.used.open then return end
        s.seenOpenings[guid] = true
        self:Queue(e, "open", card.open, guid, true)
    end)
end

function B:Engage(guid, name)
    local id = self:NPCID(guid)
    local card = self.byNPC[id]
    if not card then return end
    local e, s = self:Encounter(card, guid, false)
    if not e and not card.starts[id] then return end
    if not e then e, s = self:Encounter(card, guid, true) end
    if not e or e.finished then return end
    local first = not e.engaged
    local newMember = not e.observed[id]
    -- A living combat event overrides a previous death (resurrection / feigned death).
    e.observed[id], e.dead[id], e.lastEvent = guid, nil, now()
    e.clearSince, e.finalAt = nil, nil
    e.engaged = true
    if name then e.names[name] = true end
    if first then
        if not s.seenOpenings[guid] then self:Queue(e, "open", card.open, guid, false) end
    elseif newMember and card.transition and card.transition[id] then
        self:Phase(e, id, card.transition[id])
    end
    return e
end

function B:Phase(e, id, token)
    if e.phaseCount >= 2 or e.used["phase" .. id] then return end
    e.phaseCount = e.phaseCount + 1
    self:Queue(e, "phase" .. id, token)
end

function B:OnCombatLog(info)
    local s = self:State()
    if not s then return end
    local event, source, dest = info[2], info[4], info[8]
    if event == "UNIT_DIED" and self:GroupGUID(dest) then
        for _, e in pairs(s.encounters) do if e.engaged and not e.finished then e.sorrow = true end end
    end
    local sourceCard, destCard = self.byNPC[self:NPCID(source)], self.byNPC[self:NPCID(dest)]
    local attack = event == "SWING_DAMAGE" or event == "SWING_MISSED" or event == "RANGE_DAMAGE"
        or event == "RANGE_MISSED" or event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" or event == "SPELL_MISSED"
    if attack then
        if sourceCard and self:GroupGUID(dest) then self:Engage(source, info[5]) end
        if destCard and self:GroupGUID(source) then self:Engage(dest, info[9]) end
    end
    if event == "UNIT_DIED" and destCard then
        local e = self:Encounter(destCard, dest, false)
        local id = self:NPCID(dest)
        if e and e.observed[id] == dest and not e.finished then
            e.dead[id] = true
            e.lastEvent = now()
            if self:Complete(e) then e.finalAt = now() end
            self:WatchEnd(e)
        end
    end
    if sourceCard and (event == "SPELL_CAST_SUCCESS" or event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then
        local e = self:Encounter(sourceCard, source, false)
        if not e or not e.engaged or e.finished then return end
        local spell = sourceCard.spells and sourceCard.spells[info[12]]
        if spell and event == spell.event and (not spell.selfTarget or dest == UnitGUID("player")) then
            if spell.revive then e.dead[spell.revive] = nil end
            self:Phase(e, info[12], spell.token)
        end
    end
end

function B:WatchEnd(e)
    local s = H.state.bosses
    if e.watching then return end
    e.watching = true
    local function check()
        if H.state.bosses ~= s or s.encounters[e.key] ~= e then return end
        e.watching = false
        if not self:State() or e.finished then return end
        if self:AnyCombat() then
            e.clearSince = nil
            if now() - e.lastEvent < 120 then self:WatchEnd(e) end
            return
        end
        e.clearSince = e.clearSince or now()
        local quietFor = now() - e.clearSince
        if quietFor < (e.card.settle or 4) then self:WatchEnd(e); return end
        if self:Complete(e) then
            e.finished = true
            if not e.sorrow then self:Queue(e, "victory", e.card.victory) end
        elseif quietFor >= 15 then
            -- No death proof means reset/escape, never victory. Keep sight deduplication.
            s.encounters[e.key] = nil
        else self:WatchEnd(e) end
    end
    C_Timer.After(0.5, check)
end

function B:Tick()
    local s = self:State()
    if not s then return end
    for key, e in pairs(s.encounters) do
        if e.engaged and not e.finished then self:WatchEnd(e) end
        if now() - e.lastEvent > 1800 then s.encounters[key] = nil end
    end
    for key, claim in pairs(s.claims) do if now() - claim.at > 15 then s.claims[key] = nil end end
    for key, r in pairs(s.pending) do if r.expiresAt < now() then s.pending[key] = nil end end
end

function B:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then self:Reset()
    elseif event == "GROUP_ROSTER_UPDATE" then
        if H.state.bosses and H.state.bosses.roster ~= self:RosterKey() then self:Reset() end
    elseif event == "PLAYER_TARGET_CHANGED" then self:Notice()
    elseif event == "PLAYER_REGEN_ENABLED" then self:Tick()
    elseif event == "CHAT_MSG_ADDON" then self:OnMessage(...)
    elseif event == "CHAT_MSG_MONSTER_YELL" or event == "CHAT_MSG_MONSTER_SAY" then
        local _, _, _, _, _, _, _, _, _, _, _, guid = ...
        local card = self.byNPC[self:NPCID(guid)]
        local s = self:State()
        if s and card and self:MatchesMap(card, s.map) then s.quietUntil = now() + 3 end
    end
end
