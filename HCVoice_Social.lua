local _, addon = ...
local H = _G.HCVoice or addon

local replyRules = {
    { token = "BYE", category = "greetings", words = { "waves goodbye", "says goodbye", "goodbye", "farewell", "bids you farewell" }, options = { "BYE", "WAVE", "NOD", "SALUTE" }, safe = true },
    { token = "WELCOME", category = "greetings", words = { "welcomes you", "welcome to the group", "welcome to" }, options = { "THANK", "NOD", "SALUTE", "BOW" }, safe = true },
    { token = "ATTACKMYTARGET", category = "tactical", words = { "attack my target", "attack his target", "attack her target", "focus my target", "focus his target", "focus her target" }, options = { "NOD", "WAIT", "SALUTE", "ATTACKMYTARGET" }, safe = false },
    { token = "OPENFIRE", category = "tactical", words = { "open fire", "fire at will", "begin firing" }, options = { "NOD", "WAIT", "OPENFIRE", "CHARGE" }, safe = false },
    { token = "CHARGE", category = "tactical", words = { "calls for a charge", "orders you to charge", "charge forward" }, options = { "NOD", "WAIT", "CHARGE", "FLEE" }, safe = false },
    { token = "HEALME", category = "requests", words = { "cries out for healing", "needs healing", "heal me", "healing from you" }, options = { "NOD", "WAIT", "SALUTE", "HELPME" }, safe = false },
    { token = "HELPME", category = "requests", words = { "cries for help", "asks for help", "help me" }, options = { "NOD", "WAIT", "SALUTE", "HELPME" }, safe = false },
    { token = "OOM", category = "tactical", words = { "out of mana", "low on mana", "no mana" }, options = { "WAIT", "NOD", "SALUTE", "HELPME" }, safe = false },
    { token = "INCOMING", category = "tactical", words = { "incoming", "enemies approach", "under attack" }, options = { "NOD", "WAIT", "FLEE", "CHARGE" }, safe = false },
    { token = "FLEE", category = "tactical", words = { "flee", "run away", "retreat" }, options = { "NOD", "FLEE", "WAIT", "HELPME" }, safe = false },
    { token = "FOLLOW", category = "tactical", words = { "follow me", "motions for you to follow" }, options = { "NOD", "WAIT", "SALUTE", "FOLLOW" }, safe = false },
    { token = "WAIT", category = "tactical", words = { "wait for you", "asks you to wait", "waits for you" }, options = { "NOD", "WAIT", "SALUTE", "FOLLOW" }, safe = false },
    { token = "WAVE", category = "greetings", words = { " waves", "wave at", "waves at" }, options = { "WAVE", "HELLO", "NOD", "SALUTE" }, safe = true },
    { token = "SALUTE", category = "greetings", words = { "salute", "salutes" }, options = { "SALUTE", "NOD", "HELLO", "BOW" }, safe = true },
    { token = "BOW", category = "greetings", words = { " bows", "bow before", "bows before" }, options = { "BOW", "NOD", "SALUTE", "HELLO" }, safe = true },
    { token = "HELLO", category = "greetings", words = { "hello", "greets", "greet", "hails", "hail" }, options = { "HELLO", "WAVE", "NOD", "SALUTE" }, safe = true },
    { token = "THANK", category = "thanks", words = { "thanks", "thank you", "thank" }, options = { "WELCOME", "NOD", "SALUTE", "BOW" }, safe = true },
    { token = "CONGRATULATE", category = "congratulations", words = { "congratulates", "congratulate", "applauds", "applaud", "cheers", "claps" }, options = { "THANK", "CHEER", "BOW", "NOD" }, safe = true },
    { token = "NOD", category = "friendly", words = { " nods", "nod at", "smiles", "smile at" }, options = { "NOD", "HELLO", "SALUTE", "WAVE" }, safe = true },
    { token = "LAUGH", category = "friendly", words = { "laughs", "chuckles", "giggles", "jokes", "silly" }, options = { "GUFFAW", "LAUGH", "JOKE", "NOD" }, safe = true },
    { token = "MOO", category = "friendly", words = { "moos" }, options = { "MOO", "LAUGH", "NOD", "WHISTLE" }, safe = true },
    { token = "WHISTLE", category = "affection", words = { "whistles", "lets forth a sharp whistle" }, options = { "WHISTLE", "LAUGH", "NOD", "NO" }, safe = false },
    { token = "SIGH", category = "friendly", words = { "sighs", "lets out a long, drawn-out sigh" }, options = { "SIGH", "NOD", "BOW", "NO" }, safe = false },
    { token = "YAWN", category = "friendly", words = { "yawns" }, options = { "WAIT", "NOD", "YAWN", "NO" }, safe = false },
    { token = "BORED", category = "friendly", words = { "is terribly bored", "is overcome with boredom" }, options = { "JOKE", "WHISTLE", "NOD", "NO" }, safe = false },
    { token = "HUG", category = "affection", words = { "hugs", "embraces" }, options = { "NOD", "BOW", "HUG", "NO" }, safe = false },
    { token = "FLIRT", category = "affection", words = { "kisses", "flirts", "wink", "winks" }, options = { "NOD", "BOW", "NO", "SALUTE" }, safe = false },
    { token = "RASP", category = "hostile", words = { "rude", "spits", "raspberry", "mocks", "taunts", "insults" }, options = { "NO", "RASP", "LAUGH", "SALUTE" }, safe = false },
}


local function now() return GetTime() end
local function copy(t) local result = {}; for k,v in pairs(t or {}) do result[k]=v end; return result end
local function plain(value)
    return tostring(value or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H.-|h(.-)|h", "%1")
end
local function escaped(value) return (value:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")) end

function H:IsInDungeon()
    if not IsInInstance then return false end
    local inside, instanceType = IsInInstance()
    return inside and instanceType == "party"
end

function H:EmoteAction(message, sender)
    local text = plain(message):lower():match("^%s*(.-)%s*$")
    local names = { tostring(sender or ""):lower(), tostring(sender or ""):match("^[^-]+") or "" }
    for _, name in ipairs(names) do
        name = name:lower()
        if name ~= "" and text:sub(1, #name + 1) == name .. " " then return text:sub(#name + 2) end
    end
    return text:gsub("^you ", "")
end

function H:ClassifyIncomingEmote(message, sender, custom)
    local action = self:EmoteAction(message, sender)
    local english = not GetLocale or GetLocale() == "enUS" or GetLocale() == "enGB"
    if english then
        -- A sensitive meaning always outranks a friendly word in the same action.
        for pass = 1, 2 do
            for _, rule in ipairs(replyRules) do
                if (pass == 1 and not rule.safe) or (pass == 2 and rule.safe) then
                    for _, word in ipairs(rule.words) do
                        word = word:match("^%s*(.-)%s*$")
                        if action:find("%f[%a]" .. escaped(word) .. "%f[%A]") then
                            local startsAction = action:find("^" .. escaped(word)) ~= nil
                            local safe = rule.safe == true and not custom and startsAction
                            return { category = rule.category, incomingToken = rule.token, options = copy(rule.options), safe = safe, needsSuggestion = not safe }
                        end
                    end
                end
            end
        end
    end
    return { category = "unknown", incomingToken = "UNKNOWN", options = { "NOD", "NO", "SALUTE", "HELLO" }, safe = false, needsSuggestion = true }
end

function H:IsEmoteDirectedAtPlayer(message, targetName, sender)
    local player = self.NameKey(UnitName("player"))
    if targetName and targetName ~= "" then return self.NameKey(targetName) == player end
    local action = self:EmoteAction(message, sender)
    if action:find("^thanks you%f[%A]") or action:find("^welcomes you%f[%A]")
        or action:find("^greets you%f[%A]") or action:find("^hugs you%f[%A]")
        or action:find("^kisses you%f[%A]") or action:find("^salutes you%f[%A]")
        or action:find("^congratulates you%f[%A]") or action:find("^insults you%f[%A]")
        or action:find("^mocks you%f[%A]") or action:find("^taunts you%f[%A]") then return true end
    -- Only a complete recipient after an explicit preposition counts.
    for _, preposition in ipairs({ "at", "to", "with", "toward", "towards", "before", "for" }) do
        if action:find("%f[%a]" .. preposition .. " you%f[%A]") then return true end
        if action:find("%f[%a]" .. preposition .. " " .. escaped(player) .. "%f[%A]") then return true end
    end
    return false
end

local families = { greetings = "greeting", thanks = "gratitude", congratulations = "achievement", friendly = "friendly" }
local tokenFamilies = {
    HELLO = "greeting", WAVE = "greeting", SALUTE = "greeting", BOW = "greeting",
    THANK = "gratitude", WELCOME = "gratitude", BYE = "farewell",
    NOD = "friendly", LAUGH = "friendly", GUFFAW = "friendly", MOO = "friendly",
    WHISTLE = "friendly", SIGH = "friendly", YAWN = "friendly", BORED = "friendly",
    HUG = "affection", FLIRT = "affection", KISS = "affection",
}
function H:ConversationKey(sender, category, token)
    return self.NameKey(sender) .. ":" .. (tokenFamilies[token] or families[category] or category or "unknown")
end

function H:RecordManualSocialReply(recipient, token, category)
    local key, t = self.NameKey(recipient), now()
    if key == "" then return end
    self.state.reply.lastOutgoingAt[key] = t
    self.state.reply.lastOutgoingAt[self:ConversationKey(recipient, category, token)] = t
    -- A player-chosen answer completes the pending exchange even if they chose
    -- a different emote, such as /nod instead of the proposed /hug.
    for i = #self.state.reactionQueue, 1, -1 do
        local queued = self.state.reactionQueue[i]
        if (queued.scenario == "reply" or queued.scenario == "livingWorldResponse") and self.NameKey(queued.targetName) == key then
            if queued.conversationKey then self.state.reply.lastOutgoingAt[queued.conversationKey] = t end
            self:RecordDecision(queued, "skipped", "player already answered")
            table.remove(self.state.reactionQueue, i)
        end
    end
    local prompt = self.GUI and self.GUI.replyFrame and self.GUI.replyFrame.data
    if prompt and self.NameKey(prompt.sender) == key then
        self.state.reply.lastOutgoingAt[self:ConversationKey(recipient, prompt.category, prompt.incomingToken)] = t
        self.GUI:HideReplyPrompt()
    end
end

local ownVerbs = {
    hug = "hugs", embrace = "embraces", kiss = "kisses", flirt = "flirts",
    laugh = "laughs", chuckle = "chuckles", giggle = "giggles", joke = "jokes",
    wave = "waves", salute = "salutes", bow = "bows", nod = "nods",
    smile = "smiles", moo = "moos", whistle = "whistles", sigh = "sighs", yawn = "yawns",
    thank = "thanks", welcome = "welcomes", greet = "greets", congratulate = "congratulates",
}

local function ownRecipient(action)
    for _, verb in ipairs({ "hug", "embrace", "kiss", "thank", "welcome", "greet", "salute", "congratulate", "insult", "mock", "taunt", "tell" }) do
        local recipient = action:match("^" .. verb .. " ([^%s%.!,]+)")
        if recipient and recipient ~= "a" and recipient ~= "an" and recipient ~= "the" then return recipient end
    end
    for _, preposition in ipairs({ "at", "to", "with", "toward", "towards", "before", "for" }) do
        local recipient = action:match("%f[%a]" .. preposition .. " ([^%s%.!,]+)")
        if recipient then return recipient end
    end
end

function H:HandleIncomingTextEmote(message, sender, language, channel, targetName, flags, zone, channelNumber, baseName, languageID, lineID, guid, custom)
    if not self.db or not self.db.enabled then return end
    sender = self.NormalizeName(sender)
    if not sender or sender == "" then return end
    local senderKey = self.NameKey(sender)
    local classification = self:ClassifyIncomingEmote(message, sender, custom)
    if (guid and guid ~= "" and guid == UnitGUID("player")) or senderKey == self.NameKey(UnitName("player")) then
        -- Own visible emotes are also a pause for the automatic director.
        self.state.lastAnyEmoteAt = now()
        local action = self:EmoteAction(message, sender)
        local recipient = targetName and targetName ~= "" and targetName or ownRecipient(action)
        local ownAction = action:gsub("^([%a]+)", function(verb) return ownVerbs[verb] or verb end)
        classification = self:ClassifyIncomingEmote(ownAction, nil, custom)
        if recipient then
            self:RecordManualSocialReply(recipient, classification.incomingToken, classification.category)
        end
        if self.LivingWorld then
            local state = self.state.livingWorld
            if state then state.recentTokens[classification.incomingToken] = now() end
        end
        return
    end
    local key = guid and guid ~= "" and guid or senderKey
    if self.state.reply.ignored[key] or self.state.reply.ignored[senderKey] then return end
    local directed = self:IsEmoteDirectedAtPlayer(message, targetName, sender)
    local data = { message = message, sender = sender, targetName = targetName, guid = guid, lineID = lineID, directed = directed, classification = classification, custom = custom }
    if self.LivingWorld and self.LivingWorld:HandleVisibleEmote(data) then return end
    local reply = self.db.reply
    if not reply.enabled or reply.mode == "off" or not directed or not reply.categories[classification.category] then return end
    local signature = tostring(lineID or "") .. ":" .. tostring(message)
    if self.state.reply.lastIncomingSignature[key] == signature and now() - (self.state.reply.lastIncomingAt[key] or 0) < 2 then return end
    self.state.reply.lastIncomingSignature[key], self.state.reply.lastIncomingAt[key] = signature, now()
    local options = self:GetContextualReplyOptions(classification, sender, key)
    self:TouchSocialEncounter(key, sender, "incoming-emote")
    local dungeon = self:IsInDungeon()
    if not classification.safe and not dungeon then
        self:OfferReplyPrompt({ kind = "reply", sender = sender, playerKey = key, message = message, category = classification.category, incomingToken = classification.incomingToken, options = options, needsSuggestion = true, expiresAt = now() + reply.popupSeconds })
        return
    end
    -- Dungeon replies need no UI, but free-form or unrecognized text has no
    -- reliable automatic meaning. It stays silent instead of opening a choice.
    if dungeon and (custom or classification.incomingToken == "UNKNOWN") then return end
    local token = options[1]
    if not token then return end
    local conversation = self:ConversationKey(sender, classification.category, classification.incomingToken)
    if now() - (self.state.reply.lastOutgoingAt[conversation] or -math.huge) <= reply.conversationSeconds then return end
    if not dungeon and math.random() * 100 > reply.autoChance then return end
    local state = self.state
    self:EnqueueReaction({
        scenario = "reply", token = token, targetName = sender, targetKey = key, dungeonReply = dungeon,
        priority = 50, category = classification.category, conversationKey = conversation, incomingToken = classification.incomingToken,
        expiresAt = now() + 5,
        validate = function()
            if dungeon then
                if not self:IsInDungeon() then return false end
                -- Recheck readiness and intimate recipient eligibility at playback.
                local currentOptions = self:GetContextualReplyOptions(classification, sender, key)
                if currentOptions[1] ~= token then return false end
            end
            return self.state == state and now() - (state.reply.lastOutgoingAt[conversation] or -math.huge) > self.db.reply.conversationSeconds
        end,
    })
end

function H:IsPromptValid(data)
    if self:IsInDungeon() then return false end
    if not self.db.enabled or not self.db.reply.enabled or self.db.reply.mode == "off" then return false end
    if not data or data.kind ~= "reply" or data.needsSuggestion ~= true then return false end
    if data.expiresAt and data.expiresAt < now() then return false end
    if not self.db.reply.categories[data.category] then return false end
    return not self.state.reply.ignored[data.playerKey] and not self.state.reply.ignored[self.NameKey(data.sender)]
end

function H:HandleSocialEvent(event, message, sender, language, channel, target, flags, zone, number, base, languageID, lineID, guid)
    return self:HandleIncomingTextEmote(message, sender, language, channel, target, flags, zone, number, base, languageID, lineID, guid, event == "CHAT_MSG_EMOTE")
end
