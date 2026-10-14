local ADDON_NAME, addonTable = ...
local HCVoice = _G.HCVoice or addonTable
if not HCVoice then return end

local LivingWorld = HCVoice.LivingWorld or {}
HCVoice.LivingWorld = LivingWorld

LivingWorld.PREFIX = "HCVLW1"
LivingWorld.PROTOCOL = 2

local GROUP_CHANNELS = { PARTY = true, RAID = true, INSTANCE_CHAT = true }
local NEARBY_SCENE_SOURCES = { EMOTE = true, WHISPER = true }

local function option(token, weight)
    return { token = token, weight = weight }
end

-- These policies describe replies to meanings, never random event mappings.
-- Major group moments involve everyone; directed moments only involve the
-- intended player; banter is intentionally allowed to produce silence.
local POLICIES = {
    hardVictory = {
        label = "boss or elite victory", audience = "crowd", groupPreferred = true,
        hybridAuto = true, essential = true, chance = 100, coalesce = 8,
        delayMin = 0.25, delayMax = 2.0, priority = 80,
        preferLocal = true,
        options = { option("CHEER", 65), option("ROAR", 10), option("VICTORY", 15), option("APPLAUD", 10) },
    },
    partyDeath = {
        label = "party member fell", audience = "crowd", groupOnly = true,
        hybridAuto = true, essential = true, chance = 100, coalesce = 6,
        delayMin = 0.35, delayMax = 1.8, priority = 75, allowInCombat = false,
        preferLocal = true, responseTarget = "target",
        options = { option("MOURN", 55), option("CRY", 22), option("SALUTE", 15), option("SIGH", 8) },
    },
    wipeRecovery = {
        label = "recovered from a party wipe", audience = "crowd", groupOnly = true,
        hybridAuto = true, essential = true, chance = 100, coalesce = 12,
        delayMin = 0.5, delayMax = 2.4, priority = 70, responseTarget = "sender",
        preferLocal = true, coalesceGroup = true,
        options = { option("SIGH", 65), option("CRY", 35) },
    },
    playerLevel = {
        label = "party member gained a level", audience = "crowd", groupPreferred = true,
        hybridAuto = true, essential = true, chance = 100, coalesce = 6,
        delayMin = 0.2, delayMax = 1.6, priority = 65, responseTarget = "sender",
        family = "groupLevel", preferLocal = true,
        options = { option("CONGRATULATE", 50), option("CHEER", 25), option("APPLAUD", 15), option("VICTORY", 10) },
    },
    partyLevel = {
        label = "party member gained a level", audience = "crowd", groupOnly = true,
        hybridAuto = true, essential = true, chance = 100, coalesce = 6,
        delayMin = 0.2, delayMax = 1.6, priority = 65, responseTarget = "target",
        family = "groupLevel", preferLocal = true,
        options = { option("CONGRATULATE", 50), option("CHEER", 25), option("APPLAUD", 15), option("VICTORY", 10) },
    },
    nearDeath = {
        label = "survived a dangerous fight", audience = "banter", groupPreferred = true,
        hybridAuto = true, chance = 60, coalesce = 8,
        delayMin = 0.5, delayMax = 2.2, priority = 45, responseTarget = "sender",
        options = { option("SIGH", 75), option("SALUTE", 25) },
    },
    welcomeParty = {
        label = "welcomed you to the party", audience = "target", groupOnly = true,
        chance = 100, coalesce = 5, delayMin = 0.35, delayMax = 1.2,
        priority = 40, responseTarget = "sender",
        options = { option("THANK", 48), option("HELLO", 20), option("NOD", 17), option("SALUTE", 10), option("BOW", 5) },
    },
    greetPlayer = {
        label = "greeted you", audience = "target", chance = 100, coalesce = 4,
        delayMin = 0.25, delayMax = 1.0, priority = 35, responseTarget = "sender",
        options = { option("HELLO", 42), option("WAVE", 24), option("NOD", 18), option("SALUTE", 11), option("BOW", 5) },
    },
    socialFarewell = {
        label = "said farewell", audience = "target", chance = 100, coalesce = 5,
        delayMin = 0.3, delayMax = 1.2, priority = 32, responseTarget = "sender",
        options = { option("BYE", 48), option("WAVE", 27), option("SALUTE", 15), option("NOD", 10) },
    },
    thankHealer = {
        label = "thanked you for healing", audience = "target", groupPreferred = true,
        chance = 100, coalesce = 8, delayMin = 0.3, delayMax = 1.1,
        priority = 45, responseTarget = "sender",
        options = { option("WELCOME", 50), option("NOD", 22), option("SALUTE", 18), option("BOW", 10) },
    },
    thankBuff = {
        label = "thanked you for a buff", audience = "target", chance = 100,
        coalesce = 8, delayMin = 0.3, delayMax = 1.1, priority = 35,
        responseTarget = "sender",
        options = { option("WELCOME", 50), option("NOD", 24), option("SALUTE", 16), option("BOW", 10) },
    },
    thankAssist = {
        label = "thanked you for helping in combat", audience = "target",
        chance = 100, coalesce = 8, delayMin = 0.3, delayMax = 1.2,
        priority = 38, responseTarget = "sender",
        options = { option("WELCOME", 42), option("NOD", 28), option("SALUTE", 20), option("BOW", 10) },
    },
    thankResurrection = {
        label = "thanked you for resurrecting them", audience = "target",
        chance = 100, coalesce = 10, delayMin = 0.4, delayMax = 1.3,
        priority = 45, responseTarget = "sender",
        options = { option("WELCOME", 44), option("NOD", 26), option("SALUTE", 20), option("BOW", 10) },
    },
    thankTrade = {
        label = "thanked you for a gift", audience = "target", chance = 100,
        coalesce = 8, delayMin = 0.3, delayMax = 1.1, priority = 38,
        responseTarget = "sender",
        options = { option("WELCOME", 48), option("THANK", 12), option("NOD", 20), option("SALUTE", 12), option("BOW", 8) },
    },
    partyWait = {
        label = "asked the party to wait", audience = "target", groupOnly = true,
        chance = 100, coalesce = 10, delayMin = 0.3, delayMax = 1.1,
        priority = 30, responseTarget = "sender",
        options = { option("NOD", 44), option("WAIT", 24), option("FOLLOW", 17), option("SALUTE", 15) },
    },
    sillyLoot = {
        label = "found ridiculous loot", audience = "banter", groupPreferred = true,
        hybridAuto = true, chance = 62, coalesce = 8,
        delayMin = 0.45, delayMax = 2.0, priority = 25, responseTarget = "sender",
        options = { option("GUFFAW", 32), option("LAUGH", 27), option("JOKE", 21), option("SIGH", 12), option("APPLAUD", 8) },
    },
    greatLoot = {
        label = "found rare loot", audience = "banter", groupPreferred = true,
        hybridAuto = true, chance = 75, coalesce = 8,
        delayMin = 0.35, delayMax = 1.8, priority = 38, responseTarget = "sender",
        options = { option("CONGRATULATE", 40), option("CHEER", 30), option("APPLAUD", 18), option("VICTORY", 12) },
    },
    exceptionalLoot = {
        label = "found exceptional loot", audience = "crowd", groupPreferred = true,
        hybridAuto = true, chance = 92, coalesce = 10,
        delayMin = 0.25, delayMax = 1.8, priority = 48, responseTarget = "sender",
        options = { option("GASP", 32), option("CONGRATULATE", 28), option("CHEER", 22), option("ROAR", 8), option("VICTORY", 6), option("APPLAUD", 4) },
    },
    idleYawn = {
        label = "broke a long silence", audience = "banter", groupPreferred = true,
        -- Boredom and tiredness describe the player, not a prompt for others.
        localOnly = true, options = {},
    },
    partyJoke = {
        label = "started a party joke", audience = "banter", groupOnly = true,
        hybridAuto = true, singleResponder = true, chance = 100, coalesce = 8,
        delayMin = 0.45, delayMax = 2.1, priority = 28, responseTarget = "sender",
        options = { option("GUFFAW", 34), option("LAUGH", 29), option("GIGGLE", 8), option("APPLAUD", 7) },
    },
    partyBanter = {
        label = "started a joke", audience = "banter", hybridAuto = true, singleResponder = true,
        chance = 82, coalesce = 5, delayMin = 0.35, delayMax = 1.9,
        priority = 30, responseTarget = "sender",
        options = { option("GUFFAW", 34), option("LAUGH", 29), option("GIGGLE", 8), option("APPLAUD", 7) },
    },
}

LivingWorld.policies = POLICIES

local function now()
    return GetTime and GetTime() or 0
end

local function serverTime()
    return GetServerTime and GetServerTime() or 0
end

local function normalizeName(name) return HCVoice.NormalizeName(name) end
local function nameKey(name) return HCVoice.NameKey(name) end

local function playerName()
    return normalizeName(UnitName and UnitName("player") or nil)
end

local function isPlayerAlive()
    if UnitIsDeadOrGhost and UnitIsDeadOrGhost("player") then return false end
    return not UnitHealth or (UnitHealth("player") or 0) > 0
end

local function sanitizeField(value, maximum)
    value = tostring(value or ""):gsub("[~%c]", "")
    return value:sub(1, maximum or 64)
end

local function ensureState()
    if not HCVoice.state then return nil end
    local state = HCVoice.state.livingWorld
    if not state then
        state = {
            counter = 0,
            peers = {},
            seen = {},
            senderRates = {},
            lastCoalesceAt = {},
            lastStructuredAt = {},
            lastVisibleAt = {},
            recentTokens = {},
            pending = {},
            lastSentAt = -math.huge,
        }
        HCVoice.state.livingWorld = state
    end
    return state
end

local function groupChannel()
    if IsInGroup and LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return "INSTANCE_CHAT" end
    if IsInRaid and IsInRaid() then return "RAID" end
    if IsInGroup and IsInGroup() then return "PARTY" end
end

local function isGroupMember(name)
    local wanted = nameKey(name)
    if wanted == "" then return false end
    if wanted == nameKey(playerName()) then return true end
    for index = 1, 4 do
        local unit = "party" .. index
        if UnitExists and UnitExists(unit) and wanted == nameKey(UnitName(unit)) then return true end
    end
    for index = 1, 40 do
        local unit = "raid" .. index
        if UnitExists and UnitExists(unit) and wanted == nameKey(UnitName(unit)) then return true end
    end
    return false
end

local function isSelectedGroupResponder(scene)
    -- The initiator assigns exactly one known compatible participant.
    return scene and scene.responder and scene.responder ~= "" and nameKey(scene.responder) == nameKey(playerName())
end

local function isGroupChannel(channel)
    return GROUP_CHANNELS[string.upper(tostring(channel or ""))] == true
end

local function coalesceKey(sceneKey, targetName, sender)
    local policy = POLICIES[sceneKey]
    local family = policy and policy.family or sceneKey
    local subject = nameKey(targetName)
    if subject == "" then subject = policy and policy.coalesceGroup and "group" or nameKey(sender) end
    return tostring(family or "") .. ":" .. subject
end

local function sceneFamily(sceneKey)
    local policy = POLICIES[sceneKey]
    return policy and policy.family or sceneKey
end

local function splitMessage(message)
    local fields = {}
    for field in (tostring(message or "") .. "~"):gmatch("(.-)~") do
        fields[#fields + 1] = field
    end
    return fields
end

local function voiceBias(token)
    local item = HCVoice.voiceByToken and HCVoice.voiceByToken[token]
    if not item then return 0 end
    return item.category == "Animated reaction" and 0.78 or 1.35
end

-- Roles only nudge variation. They never prevent a player from joining a
-- major group reaction, and they do not create character personalities.
local ROLE_TOKEN_BIAS = {
    TANK = { ROAR = 1.22, SALUTE = 1.18, VICTORY = 1.15, NOD = 1.10 },
    HEALER = { CONGRATULATE = 1.22, APPLAUD = 1.18, THANK = 1.15, WELCOME = 1.15, SIGH = 1.10 },
    DAMAGER = { CHEER = 1.10, VICTORY = 1.10, JOKE = 1.08, LAUGH = 1.08, GUFFAW = 1.08 },
}

local CLASS_TOKEN_BIAS = {
    HUNTER = { CHEER = 1.10, JOKE = 1.10, GUFFAW = 1.08, VICTORY = 1.06 },
    PRIEST = { CONGRATULATE = 1.08, APPLAUD = 1.08, THANK = 1.08, SIGH = 1.06 },
    WARRIOR = { ROAR = 1.10, SALUTE = 1.08, VICTORY = 1.08 },
}

local function roleTokenBias(token)
    local multiplier = 1
    local role = UnitGroupRolesAssigned and UnitGroupRolesAssigned("player") or "NONE"
    local roleBias = ROLE_TOKEN_BIAS[role]
    if roleBias then multiplier = multiplier * (roleBias[token] or 1) end
    local classFile
    if UnitClass then
        local _, detectedClass = UnitClass("player")
        classFile = detectedClass
    end
    local classBias = CLASS_TOKEN_BIAS[classFile]
    if classBias then multiplier = multiplier * (classBias[token] or 1) end
    return multiplier
end

function LivingWorld:GetSettings()
    return HCVoice.db and HCVoice.db.livingWorld or nil
end

function LivingWorld:RegisterPrefix()
    if not C_ChatInfo or not C_ChatInfo.RegisterAddonMessagePrefix then return false end
    local ok, result = pcall(C_ChatInfo.RegisterAddonMessagePrefix, self.PREFIX)
    return ok and (result == nil or result == true or result == 0)
end

function LivingWorld:Initialize()
    ensureState()
    self:RegisterPrefix()
    self:AnnouncePresence()
end

function LivingWorld:OnWorldChanged()
    local state = ensureState()
    if not state then return end
    state.peers = {}
    state.seen = {}
    state.pending = {}
    state.lastStructuredAt = {}
    state.lastVisibleAt = {}
    self:RegisterPrefix()
    self:AnnouncePresence()
end

function LivingWorld:NextSceneId()
    local state = ensureState()
    if not state then return nil end
    state.counter = state.counter + 1
    local identity = tostring(UnitGUID and UnitGUID("player") or playerName() or "player")
    identity = identity:gsub("[^%w]", "")
    identity = identity:sub(-10)
    return string.format("%d.%d.%s", serverTime(), state.counter, identity)
end

function LivingWorld:BuildMessage(kind, scene)
    return table.concat({
        sanitizeField(kind, 1),
        tostring(self.PROTOCOL),
        sanitizeField(scene.id, 48),
        sanitizeField(scene.key, 32),
        sanitizeField(scene.sourceToken, 24),
        sanitizeField(scene.targetName, 48),
        tostring(tonumber(scene.depth) or 0),
        tostring(tonumber(scene.sentAt) or serverTime()),
        sanitizeField(scene.subjectKey, 70),
        sanitizeField(scene.responder, 48),
    }, "~")
end

function LivingWorld:ParseMessage(message)
    local fields = splitMessage(message)
    if #fields ~= 8 and #fields ~= 10 then return nil end
    local kind, protocol = fields[1], tonumber(fields[2])
    if (kind ~= "S" and kind ~= "R") or (protocol ~= 1 and protocol ~= self.PROTOCOL) then return nil end
    if (protocol == 1 and #fields ~= 8) or (protocol == 2 and #fields ~= 10) then return nil end
    local scene = {
        kind = kind,
        id = fields[3],
        key = fields[4],
        sourceToken = string.upper(fields[5] or ""),
        targetName = normalizeName(fields[6]),
        depth = tonumber(fields[7]),
        sentAt = tonumber(fields[8]),
        subjectKey = fields[9] ~= "" and fields[9] or nil,
        responder = normalizeName(fields[10]),
    }
    if scene.id == "" or not POLICIES[scene.key] or not HCVoice.voiceByToken[scene.sourceToken] then return nil end
    if not scene.depth or scene.depth < 0 or scene.depth > 1 or not scene.sentAt then return nil end
    if (kind == "S" and scene.depth ~= 0) or (kind == "R" and scene.depth ~= 1) then return nil end
    if scene.sentAt <= 0 or math.abs(serverTime() - scene.sentAt) > 45 then return nil end
    return scene
end

function LivingWorld:SendRaw(message, channel, target)
    if not C_ChatInfo or not C_ChatInfo.SendAddonMessage or not channel then return false end
    local ok, result = pcall(C_ChatInfo.SendAddonMessage, self.PREFIX, message, channel, target)
    return ok and (result == nil or result == true or result == 0)
end

function LivingWorld:ChooseTransport(policy, targetName)
    local settings = self:GetSettings()
    if not settings or not settings.enabled then return nil end
    local grouped = groupChannel()
    if policy.groupOnly then
        if settings.group and grouped then return grouped end
        return nil
    end
    if settings.group and grouped and (policy.groupPreferred or policy.audience == "crowd" or policy.audience == "banter" or isGroupMember(targetName)) then
        return grouped
    end
    if not settings.nearby then return nil end
    if policy.audience == "target" and targetName then return "WHISPER", targetName end
    -- Nearby ambient interaction is discovered through visible emote events.
    -- HCVoice never falls back to normal text-chat transport.
    return nil
end

function LivingWorld:IsScopeEnabled(channel)
    local settings = self:GetSettings()
    if not settings or not settings.enabled then return false end
    channel = string.upper(tostring(channel or ""))
    if GROUP_CHANNELS[channel] then return settings.group == true end
    if NEARBY_SCENE_SOURCES[channel] then return settings.nearby == true end
    return false
end

function LivingWorld:AllowSender(sender)
    local state = ensureState()
    if not state then return false end
    local key = nameKey(sender)
    if key == "" then return false end
    local t = now()
    local rate = state.senderRates[key]
    if not rate or t - rate.startedAt >= 10 then
        state.senderRates[key] = { startedAt = t, count = 1 }
        return true
    end
    if rate.count >= 4 then return false end
    rate.count = rate.count + 1
    return true
end

function LivingWorld:SelectCandidate(candidates, sourceToken)
    local state = ensureState()
    local total, weighted = 0, {}
    local t = now()
    for _, candidate in ipairs(candidates or {}) do
        local token = string.upper(tostring(candidate.token or ""))
        if HCVoice:IsVoiceAvailable(token) and (not candidate.groupOnly or (IsInGroup and IsInGroup())) then
            local weight = math.max(0, tonumber(candidate.weight) or 0) * voiceBias(token)
            weight = weight * roleTokenBias(token)
            local recentAt = state and state.recentTokens[token] or nil
            if recentAt and t - recentAt < 60 then weight = weight * 0.18 end
            if token == sourceToken then weight = weight * 0.45 end
            if weight > 0 then
                total = total + weight
                weighted[#weighted + 1] = { token = token, ceiling = total }
            end
        end
    end
    if total <= 0 then return nil end
    local roll = math.random() * total
    for _, candidate in ipairs(weighted) do
        if roll <= candidate.ceiling then return candidate.token end
    end
    return weighted[#weighted] and weighted[#weighted].token or nil
end

function LivingWorld:SelectVariant(variants, fallbackToken)
    return self:SelectCandidate(variants, string.upper(tostring(fallbackToken or ""))) or fallbackToken
end

function LivingWorld:ResponseTarget(policy, scene)
    if policy.responseTarget == "sender" then return normalizeName(scene.sender) end
    if policy.responseTarget == "target" then return normalizeName(scene.targetName) end
    return nil
end

function LivingWorld:IsEligible(policy, scene)
    if policy.groupOnly and not isGroupChannel(scene.channel) then return false end
    if policy.singleResponder and not isSelectedGroupResponder(scene) then return false end
    if policy.audience == "target" then
        return nameKey(scene.targetName) ~= "" and nameKey(scene.targetName) == nameKey(playerName())
    end
    return true
end

function LivingWorld:ShouldAuto(policy)
    local settings = self:GetSettings()
    if not settings or settings.mode == "off" then return false end
    if settings.mode == "auto" then return true end
    return settings.mode == "hybrid" and (policy.hybridAuto == true or policy.audience == "target")
end

function LivingWorld:QueueAutomatic(scene, policy, token, targetName)
    if scene.key == "hardVictory" and not scene.simulated and HCVoice.Bosses and HCVoice.Bosses:OwnsVictory(nil, scene.targetName) then return false end
    local capturedState = HCVoice.state
    local reaction = {
        scenario = "livingWorldResponse", semanticKey = scene.key, token = token,
        targetName = targetName, targetKey = scene.id, priority = policy.priority or 30,
        notBefore = now() + (policy.delayMin or 0.6) + math.random() * math.max(0, (policy.delayMax or 1.5) - (policy.delayMin or 0.6)),
        suppressLivingWorld = true, livingSceneId = scene.id, livingChannel = scene.channel,
        livingSender = scene.sender,
        momentKey = HCVoice:MomentKey(scene.key, scene.targetName, scene.sender),
        validate = function()
            return HCVoice.state == capturedState and self:GetSettings().enabled and self:ShouldAuto(policy)
                and (scene.simulated or self:IsScopeEnabled(scene.channel))
                and (scene.simulated or not isGroupChannel(scene.channel) or isGroupMember(scene.sender))
                and (scene.simulated or self:IsEligible(policy, scene))
                and not HCVoice.state.reply.ignored[nameKey(scene.sender)]
        end,
    }
    if scene.simulated then reaction.livingChannel = nil end
    return HCVoice:EnqueueReaction(reaction)
end

function LivingWorld:HasPendingLocalScene(sceneKey, scene)
    local wanted = scene and HCVoice:MomentKey(sceneKey, scene.targetName, scene.sender)
    if not wanted then return false end
    for _, queued in ipairs(HCVoice.state.reactionQueue) do
        if queued.momentKey == wanted then return true end
    end
    return false
end

function LivingWorld:HandleScene(scene, simulated)
    local policy = POLICIES[scene.key]
    if not policy then return false end
    if policy.localOnly then return true end
    if scene.key == "partyJoke" then
        HCVoice.state.nextPartyJokeAt = now() + 600 + math.random() * 300
    end
    if not simulated and not self:IsEligible(policy, scene) then return false end
    scene.simulated = simulated == true
    local cfg = HCVoice:GetScenarioConfig(scene.key == "partyBanter" and "partyJoke" or scene.key)
    if cfg and (not cfg.enabled or cfg.mode ~= "automatic") then return true end
    if not simulated and not self:IsScopeEnabled(scene.channel) then return false end
    if not isPlayerAlive() then return true end
    if HCVoice.state.inCombat and policy.allowInCombat ~= true and scene.key ~= "partyDeath" then return true end
    local state = ensureState()
    local key = coalesceKey(scene.key, scene.targetName, scene.sender)
    local previous = state.lastCoalesceAt[key] or -math.huge
    if not simulated and now() - previous < (policy.coalesce or 4) then return true end
    state.lastCoalesceAt[key] = now()
    if policy.preferLocal and self:HasPendingLocalScene(scene.key, scene) then return true end

    local settings = self:GetSettings()
    if not settings or settings.mode == "off" then return true end
    local auto = self:ShouldAuto(policy)
    if auto then
        local chance = tonumber(policy.chance) or 100
        if not policy.essential then chance = chance * ((HCVoice.db.livingWorld.frequency or 70) / 100) end
        if math.random() * 100 > chance then return true end
        local token = self:SelectCandidate(policy.options, scene.sourceToken)
        if not token then return true end
        return self:QueueAutomatic(scene, policy, token, self:ResponseTarget(policy, scene))
    end
    -- Structured scenes either react automatically according to the selected
    -- Living World level or stay silent. They never open the suggestion UI.
    return true
end

function LivingWorld:OnReactionPlayed(reaction)
    local state = ensureState()
    if not state or not reaction then return end
    if reaction.token then state.recentTokens[reaction.token] = now() end

    if reaction.suppressLivingWorld then
        if reaction.livingSceneId and reaction.livingChannel then
            local marker = {
                id = reaction.livingSceneId,
                key = reaction.semanticKey or "partyBanter",
                sourceToken = reaction.token,
                targetName = nil,
                depth = 1,
                sentAt = serverTime(),
            }
            local channel, target = reaction.livingChannel, nil
            if channel == "WHISPER" then target = reaction.livingSender end
            self:SendRaw(self:BuildMessage("R", marker), channel, target)
        end
        return
    end

    local policy = POLICIES[reaction.scenario]
    local settings = self:GetSettings()
    if not policy or policy.localOnly or not settings or not settings.enabled then return end
    local channel, channelTarget = self:ChooseTransport(policy, reaction.subjectName or reaction.targetName)
    if not channel then return end
    if now() - (state.lastSentAt or -math.huge) < 0.35 then return end

    local key = coalesceKey(reaction.scenario, reaction.subjectName or reaction.targetName, playerName())
    if now() - (state.lastCoalesceAt[key] or -math.huge) < (policy.coalesce or 4) then return end
    local scene = {
        id = self:NextSceneId(),
        key = reaction.scenario,
        sourceToken = reaction.token,
        targetName = reaction.subjectName or reaction.targetName,
        subjectKey = reaction.momentKey,
        depth = 0,
        sentAt = serverTime(),
    }
    if not scene.id then return end
    if policy.singleResponder then scene.responder = self:ChooseResponder(scene.id) end
    state.lastCoalesceAt[key] = now()
    state.seen[scene.id] = now()
    state.lastSentAt = now()
    self:SendRaw(self:BuildMessage("S", scene), channel, channelTarget)
end

function LivingWorld:AnnouncePresence(replyOnly)
    local state, channel = ensureState(), groupChannel()
    if not state or not channel then return end
    if now() - (state.lastPresenceAt or -math.huge) < 2 then return end
    state.lastPresenceAt = now()
    local cfg = HCVoice:GetScenarioConfig("partyJoke")
    local settings = self:GetSettings()
    local ready = HCVoice.db.enabled and settings.enabled and settings.group and settings.mode ~= "off" and cfg and cfg.mode == "automatic"
    self:SendRaw("H~2~" .. (ready and "1" or "0") .. "~" .. (replyOnly and "R" or "Q"), channel)
end

function LivingWorld:ChooseResponder(id)
    local state = ensureState()
    local candidates = {}
    for name, peer in pairs(state.peers) do
        if peer.ready and now() - peer.at < 100 and isGroupMember(name) and nameKey(name) ~= nameKey(playerName()) and not HCVoice.state.reply.ignored[name] then candidates[#candidates + 1] = name end
    end
    if #candidates == 0 then return nil end
    table.sort(candidates)
    local hash = 0
    for i = 1, #id do hash = (hash * 33 + id:byte(i)) % 2147483647 end
    return candidates[hash % #candidates + 1]
end

function LivingWorld:HandleAddonMessage(prefix, message, channel, sender)
    if prefix ~= self.PREFIX or not HCVoice.db or nameKey(sender) == nameKey(playerName()) then return end
    local state = ensureState()
    if type(message) ~= "string" or #message > 255 then return end
    local ready, kind = message:match("^H~2~([01])~([RQ])$")
    if ready then
        if not isGroupChannel(channel) or not isGroupMember(sender) or not self:AllowSender(sender) then return end
        state.peers[nameKey(sender)] = { ready = ready == "1", at = now() }
        if kind == "Q" then self:AnnouncePresence(true) end
        return
    end
    if not HCVoice.db.enabled or not self:IsScopeEnabled(channel) then return end
    if isGroupChannel(channel) and not isGroupMember(sender) then return end
    if HCVoice.state.reply.ignored[nameKey(sender)] or not self:AllowSender(sender) then return end
    local scene = self:ParseMessage(message)
    if not scene then return end
    scene.sender, scene.channel = normalizeName(sender), channel
    -- Match a specific emote, never mute every action from the same sender.
    local signature = nameKey(sender) .. ":" .. scene.sourceToken
    state.lastStructuredAt[signature] = now()
    for i = #HCVoice.state.reactionQueue, 1, -1 do
        local queued = HCVoice.state.reactionQueue[i]
        if queued.scenario == "reply" and nameKey(queued.targetName) == nameKey(sender) and queued.incomingToken == scene.sourceToken then table.remove(HCVoice.state.reactionQueue, i) end
    end
    if scene.kind == "R" then return end
    if state.seen[scene.id] then return end
    state.seen[scene.id] = now()
    local recent = state.lastVisibleAt[signature]
    if recent and now() - recent < 2 and now() - (HCVoice.state.reply.lastOutgoingAt[nameKey(sender)] or -math.huge) < 2 then return end
    self:HandleScene(scene, false)
end

function LivingWorld:HandleVisibleEmote(data)
    local settings = self:GetSettings()
    if not settings or not settings.enabled or settings.mode == "off" or not data or not data.classification then return false end
    local senderKey, classification = nameKey(data.sender), data.classification
    if senderKey == nameKey(playerName()) or (data.guid and data.guid ~= "" and data.guid == UnitGUID("player")) then return false end
    local state = ensureState()
    local signature = senderKey .. ":" .. classification.incomingToken
    if classification.safe and now() - (state.lastStructuredAt[signature] or -math.huge) < 2 then return true end
    state.lastVisibleAt[signature] = now()
    -- Directed actions use the social director. Group banter is coordinated by
    -- its structured scene, so mixed groups cannot accidentally elect a chorus.
    if data.directed or isGroupMember(data.sender) then return false end
    if data.custom or not settings.nearby or classification.incomingToken ~= "LAUGH" then return false end
    local action = HCVoice:EmoteAction(data.message, data.sender)
    if not (action:find("joke", 1, true) or action:find("silly", 1, true)) then return false end
    local scene = { id = "V." .. sanitizeField(data.lineID or math.floor(now() * 10), 24) .. "." .. senderKey,
        key = "partyBanter", sourceToken = "JOKE", depth = 0, sentAt = serverTime(),
        sender = data.sender, channel = "EMOTE", responder = playerName() }
    return self:HandleScene(scene, false)
end

function LivingWorld:Simulate(input)
    local alias = string.lower(tostring(input or "")):match("^%s*(.-)%s*$")
    local aliases = {
        boss = "hardVictory", victory = "hardVictory", death = "partyDeath",
        wipe = "wipeRecovery",
        level = "partyLevel", hello = "greetPlayer", thanks = "thankHealer",
        joke = "partyBanter", silly = "partyBanter", partyjoke = "partyJoke", grey = "sillyLoot",
        loot = "greatLoot", epic = "exceptionalLoot", survive = "nearDeath",
        wait = "partyWait",
    }
    local sceneKey = aliases[alias]
    if not sceneKey then
        HCVoice:Message("Living World tests: boss, death, wipe, level, hello, thanks, joke, grey, loot, epic, survive, wait")
        return false
    end
    local policy = POLICIES[sceneKey]
    local target = policy.audience == "target" and playerName() or (sceneKey == "partyDeath" or sceneKey == "partyLevel") and "PartyFriend" or nil
    local sourceToken = policy.options[1] and policy.options[1].token or "CHEER"
    local scene = {
        id = "TEST." .. tostring(math.floor(now() * 1000)),
        key = sceneKey,
        sourceToken = sourceToken,
        targetName = target,
        depth = 0,
        sentAt = serverTime(),
        sender = "PartyFriend",
        channel = "PARTY",
    }
    HCVoice:Message("simulating Living World scene: " .. policy.label)
    return self:HandleScene(scene, true)
end

function LivingWorld:OnTick()
    local state = ensureState()
    if not state then return end
    local t = now()
    if t - (state.lastPresenceAt or -math.huge) > 30 then self:AnnouncePresence() end
    for name, peer in pairs(state.peers) do if t - peer.at > 100 or not isGroupMember(name) then state.peers[name] = nil end end
    for id, timestamp in pairs(state.seen) do if t - timestamp > 90 then state.seen[id] = nil end end
    for key, timestamp in pairs(state.lastCoalesceAt) do if t - timestamp > 180 then state.lastCoalesceAt[key] = nil end end
    for key, timestamp in pairs(state.lastStructuredAt) do if t - timestamp > 10 then state.lastStructuredAt[key] = nil end end
    for key, timestamp in pairs(state.lastVisibleAt) do if t - timestamp > 10 then state.lastVisibleAt[key] = nil end end
    for token, timestamp in pairs(state.recentTokens) do if t - timestamp > 300 then state.recentTokens[token] = nil end end
    for key, rate in pairs(state.senderRates) do if t - (rate.startedAt or 0) > 30 then state.senderRates[key] = nil end end
end
