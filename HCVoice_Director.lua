local _, addon = ...
local H = _G.HCVoice or addon
local function now() return GetTime() end
local urgent = { firstDamage = true, needHealing = true, fleeDanger = true, lowMana = true, extraEnemy = true, hardAggro = true, hugeHit = true, petDanger = true }
local mourning = { partyDeath = true, petDeath = true }
local celebration = { hardVictory = true, playerLevel = true, partyLevel = true, greatLoot = true, exceptionalLoot = true }
local ambient = { partyJoke = true, partyBanter = true, idleYawn = true, sillyLoot = true }
local humor = { JOKE = true, LAUGH = true, GUFFAW = true, GIGGLE = true, CACKLE = true, YAWN = true, BORED = true, WHISTLE = true, MOO = true }
local combatOnly = { firstDamage = true, needHealing = true, fleeDanger = true, extraEnemy = true, hardAggro = true, hugeHit = true }
local petCommands = { petAttack = true, petRecall = true }
H.reactionRules = { urgent = urgent, celebration = celebration, ambient = ambient }

function H:RecordDecision(reaction, outcome, reason)
    if not self.state then return end
    local history = self.state.decisions or {}
    self.state.decisions = history
    local key = type(reaction) == "table" and (reaction.semanticKey or reaction.scenario) or reaction
    if type(reaction) == "table" and reaction.bossEncounter then key = reaction.bossEncounter.card.name .. "/" .. reaction.bossMoment end
    local last = history[#history]
    if last and last.scenario == key and last.reason == reason and now() - last.at < 1 then return end
    history[#history + 1] = { at = now(), scenario = key, token = type(reaction) == "table" and reaction.token or nil, outcome = outcome, reason = reason }
    while #history > 50 do table.remove(history, 1) end
end

function H:GetDecisionText()
    local lines = { "Recent decisions (an attempted call does not confirm audible playback):" }
    for _, item in ipairs(self.state.decisions or {}) do
        lines[#lines + 1] = string.format("%.1fs ago  %s%s: %s - %s", now() - item.at, item.scenario or "manual", item.token and (" /" .. item.token:lower()) or "", item.outcome, item.reason or "")
    end
    return table.concat(lines, "\n")
end

function H:SetEnabled(enabled)
    self.db.enabled = enabled == true
    self:ResetRuntimeState()
    if self.LivingWorld then self.LivingWorld:OnWorldChanged() end
    if self.GUI then self.GUI:Refresh() end
end

function H:MomentKey(key, subject, sender)
    if key == "playerLevel" or key == "partyLevel" then
        return "level:" .. self.NameKey(subject or sender or UnitName("player"))
    end
    if key == "partyDeath" then return "death:" .. self.NameKey(subject) end
    if key == "hardVictory" then return "victory:" .. tostring(subject or "group") end
    if key == "wipeRecovery" then return "wipe:group" end
end

function H:GetReactionLane(key)
    return urgent[key] and "urgent" or petCommands[key] and "petCommand" or ambient[key] and "ambient" or "social"
end

function H:ReactionDelay(reaction)
    if reaction.force then return 0 end
    local spacing = (reaction.lane == "urgent" or reaction.lane == "petCommand") and 1.25 or self.db.globalCooldown
    return math.max(0, spacing - (now() - self.state.lastAnyEmoteAt), (reaction.notBefore or 0) - now())
end

function H:IsReactionStillValid(r)
    if not r or not self.db.enabled then return false, "disabled" end
    if r.expiresAt < now() then return false, "moment expired" end
    if r.generation ~= self.state.generation then return false, "context changed" end
    if UnitIsDeadOrGhost("player") or UnitHealth("player") <= 0 then return false, "player is not alive" end
    local key = r.semanticKey or r.scenario
    if not self:IsVoiceAvailable(r.token) then return false, "voice unavailable for this race" end
    if ambient[key] and self:HasDrinkAura() then return false, "drinking for mana" end
    if key == "lowMana" and self:IsAnnouncedManaBreak() then return false, "mana break already announced" end
    if key == "partyWait" and self:IsAnnouncedManaBreak() then return false, "already waiting for mana" end
    if key == "idleYawn" and not self:IsRelaxedMoment(true) then return false, "idle moment ended" end
    if (key == "partyJoke" or key == "partyBanter") and not self:IsRelaxedMoment(false) then return false, "not a relaxed moment" end
    if key == "partyJoke" and not IsInGroup() then return false, "party ended" end
    if r.scenario == "reply" then
        if not self.db.reply.enabled or self.db.reply.mode == "off" or not self.db.reply.categories[r.category] then return false, "reply disabled" end
        if self.db.reply.disableAutoInCombat and self.state.inCombat and not (r.dungeonReply and self:IsInDungeon()) then return false, "busy fighting" end
        if now() - (self.state.reply.lastReplyAt[r.conversationKey] or -math.huge) < self.db.reply.samePlayerCooldown then return false, "already answered this exchange" end
    else
        local cfg = self:GetScenarioConfig(key == "partyBanter" and "partyJoke" or key)
        if cfg and (not cfg.enabled or cfg.mode ~= "automatic") then return false, "scenario disabled or manual" end
    end
    if r.targetName and self.state.reply.ignored[self.NameKey(r.targetName)] then return false, "player ignored" end
    if r.targetKey and self.state.reply.ignored[r.targetKey] then return false, "player ignored" end
    if combatOnly[key] and (not self.state.inCombat or r.combat ~= self.state.combat) then return false, "fight ended" end
    if key == "firstDamage" and (not self:IsCombatHelpNeeded() or (r.helpHealth and self:UnitHealthPercent("player") >= r.helpHealth + 10)) then return false, "pressure eased" end
    if key == "extraEnemy" and self:GetActiveCombatEnemyCount() < 2 then return false, "additional enemy gone" end
    if key == "hardAggro" and r.targetKey and not self.state.combat.enemies[r.targetKey] then return false, "dangerous enemy gone" end
    if key == "needHealing" and self:UnitHealthPercent("player") > self.db.thresholds.healing then return false, "health recovered" end
    if key == "fleeDanger" and self:UnitHealthPercent("player") > self.db.thresholds.flee then return false, "danger passed" end
    if key == "lowMana" and (self:PlayerManaPercent() > self.db.thresholds.mana or not (self.state.inCombat or IsInGroup())) then return false, "mana recovered or no group" end
    if not urgent[key] and not petCommands[key] and self.state.inCombat and not mourning[key] and r.scenario ~= "reply" and not r.boss then return false, "new fight takes precedence" end
    if key == "hardVictory" and self.Bosses and self.Bosses:OwnsVictory(r.targetKey, r.subjectName) then return false, "handled by boss encounter" end
    if celebration[key] and now() < (self.state.somberUntil or 0) then return false, "a party death takes precedence" end
    if (ambient[key] or (humor[r.token] and not petCommands[key])) and now() < math.max(self.state.somberUntil or 0, self.state.seriousUntil or 0) then return false, "give the serious moment space" end
    if r.momentKey and now() - ((self.state.moments or {})[r.momentKey] or -math.huge) < 8 then return false, "already reacted to this moment" end
    if r.validate then
        local ok, valid = pcall(r.validate)
        if not ok or valid ~= true then return false, "context no longer matches" end
    end
    return true
end

function H:RestoreCancelledCombatWarning(r, reason)
    if r.combat ~= self.state.combat or not self.state.inCombat then return end
    local key = r.semanticKey or r.scenario
    if (self.state.lastScenarioAt[key] or -math.huge) >= r.requestedAt then return end
    -- Acceptance reserves the warning; a recovered, unplayed warning must not
    -- consume the next genuine threshold crossing.
    if key == "needHealing" and reason == "health recovered" then self.state.healthArmed.healing = true end
    if key == "fleeDanger" and reason == "danger passed" then
        self.state.healthArmed.flee = true
        if r.displacedHealingWarning then
            self.state.healthArmed.healing = true
            self.state.combat.recheckHealth = true
        end
    end
    if key == "firstDamage" and reason == "pressure eased" then
        self.state.combat.firstDamageAnnounced = false
        self.state.combat.pressureEvents = {}
    end
    if key == "extraEnemy" and reason == "additional enemy gone" then self.state.combat.incomingAnnounced = false end
    if key == "hardAggro" and reason == "dangerous enemy gone" then
        self.state.combat.incomingAnnounced = false
        self.state.combat.hardAggroAnnounced = false
    end
end

function H:EnqueueReaction(r)
    local key = r.semanticKey or r.scenario
    r.generation = self.state.generation
    r.combat = r.combat or self.state.combat
    r.lane = self:GetReactionLane(key)
    r.requestedAt = r.requestedAt or now()
    -- Target greetings have already waited for greetingDelaySeconds.
    if r.scenario == "greetPlayer" then r.notBefore = r.notBefore or now() end
    r.notBefore = r.notBefore or now() + ((r.lane == "urgent" or r.lane == "petCommand") and 0.5 or 0.6 + math.random() * 0.9)
    r.expiresAt = r.expiresAt or now() + (mourning[key] and 45 or r.lane == "urgent" and 6 or 12)
    r.momentKey = r.momentKey or self:MomentKey(key, r.subjectName or r.targetName)
    if mourning[key] then self.state.somberUntil = now() + 30 end
    if key == "nearDeath" or key == "fleeDanger" then self.state.seriousUntil = now() + 20 end
    local valid, reason = self:IsReactionStillValid(r)
    if not valid then self:RecordDecision(r, "skipped", reason); return false end
    local queue = self.state.reactionQueue
    for i = #queue, 1, -1 do
        local old = queue[i]
        local oldKey = old.semanticKey or old.scenario
        local same = (r.momentKey and old.momentKey == r.momentKey) or (old.scenario == r.scenario and old.targetKey == r.targetKey and old.category == r.category)
        local burst = r.lane == "urgent" and old.lane == "urgent" and math.abs(r.requestedAt - old.requestedAt) < 0.5
        local closeCelebration = celebration[key] and celebration[oldKey] and now() - old.requestedAt < 3
        local sameJoin = key == "welcomeParty" and oldKey == key and now() - old.requestedAt < 2
        if same or burst or closeCelebration or sameJoin then
            if old.priority >= r.priority then
                if oldKey == "fleeDanger" and key == "needHealing" then old.displacedHealingWarning = true end
                self:RecordDecision(r, "merged", "same moment already queued")
                return true
            end
            if key == "fleeDanger" and oldKey == "needHealing" then r.displacedHealingWarning = true end
            table.remove(queue, i)
            self:RecordDecision(old, "merged", "more relevant reaction selected")
        end
    end
    queue[#queue + 1] = r
    table.sort(queue, function(a, b) return a.priority == b.priority and a.requestedAt < b.requestedAt or a.priority > b.priority end)
    -- Keep ordinary moments bounded separately so they cannot erase a raid's
    -- distinct buff givers merely by occupying the six normal queue slots.
    local ordinary, buffThanks = 0, 0
    for _, pending in ipairs(queue) do
        if pending.scenario == "thankBuff" and pending.targetKey then buffThanks = buffThanks + 1
        else ordinary = ordinary + 1 end
    end
    for i = #queue, 1, -1 do
        local pending = queue[i]
        local isBuffThanks = pending.scenario == "thankBuff" and pending.targetKey
        if (isBuffThanks and buffThanks > 40) or (not isBuffThanks and ordinary > 6) then
            self:RecordDecision(table.remove(queue, i), "skipped", "queue capacity")
            if isBuffThanks then buffThanks = buffThanks - 1 else ordinary = ordinary - 1 end
        end
    end
    for index, pending in ipairs(queue) do
        if pending.scenario == "thankBuff" and pending.targetKey and pending.expiresAt >= now() then
            -- Equal-time arrivals can be reordered by Lua's sort. Allow every
            -- remaining giver to reach their slot at the selected spacing.
            pending.expiresAt = math.max(pending.expiresAt, now() + self:ReactionDelay(pending) + index * self.db.globalCooldown + 2)
        end
    end
    self:RecordDecision(r, "queued", "waiting for a fitting moment")
    self:ScheduleReactionFlush(0.05)
    return true
end

function H:ScheduleReactionFlush(delay)
    local state = self.state
    local due = now() + math.max(0.01, delay or 0.15)
    if state.flushDue and state.flushDue <= due then return end
    state.flushSerial = (state.flushSerial or 0) + 1
    local serial = state.flushSerial
    state.flushDue = due
    C_Timer.After(math.max(0.01, due - now()), function()
        if self.state ~= state or state.flushSerial ~= serial then return end
        state.flushDue = nil
        self:FlushReactionQueue()
    end)
end

function H:PerformReaction(r)
    local valid, reason = self:IsReactionStillValid(r)
    if not valid then self:RecordDecision(r, "skipped", reason); return false end
    if self:ReactionDelay(r) > 0 then return false end
    local success = self:PerformToken(r.token, r.targetName, r.force, r.targetUnit)
    if success then self:MarkReactionPlayed(r) end
    self:RecordDecision(r, success and "attempted" or "blocked", success and "emote API call completed; audio unconfirmed" or "client did not allow the call")
    return success
end

function H:FlushReactionQueue()
    local queue = self.state.reactionQueue
    for i = #queue, 1, -1 do
        local valid, reason = self:IsReactionStillValid(queue[i])
        if not valid then
            self:RestoreCancelledCombatWarning(queue[i], reason)
            self:RecordDecision(queue[i], "skipped", reason)
            table.remove(queue, i)
        end
    end
    if self.state.combat.recheckHealth then
        self.state.combat.recheckHealth = nil
        self:HandlePlayerHealth()
    end
    local nextDelay
    for i, r in ipairs(queue) do
        local delay = self:ReactionDelay(r)
        if mourning[r.semanticKey or r.scenario] and self.state.inCombat then delay = math.max(delay, 0.5) end
        if delay <= 0 then
            table.remove(queue, i)
            self:PerformReaction(r)
            if #queue > 0 then self:ScheduleReactionFlush(0.05) end
            return
        end
        nextDelay = math.min(nextDelay or delay, delay)
    end
    if nextDelay then self:ScheduleReactionFlush(nextDelay + 0.01) end
end

function H:PruneRuntimeHistory()
    local cutoff = now() - 10800
    for _, map in ipairs({ self.state.lastScenarioAt, self.state.lastTargetAt, self.state.moments or {}, self.state.reply.lastReplyAt, self.state.reply.lastOutgoingAt, self.state.reply.lastPromptAt }) do
        for key, at in pairs(map) do if type(at) == "number" and at < cutoff then map[key] = nil end end
    end
    for key, at in pairs(self.state.reply.lastIncomingAt) do
        if now() - at > 120 then self.state.reply.lastIncomingAt[key] = nil; self.state.reply.lastIncomingSignature[key] = nil end
    end
    for name, key in pairs(self.state.social.aliases or {}) do
        if not self.state.social.encounters[key] then self.state.social.aliases[name] = nil end
    end
end
