local ADDON_NAME, addonTable = ...

local HCVoice = _G.HCVoice or addonTable or {}
_G.HCVoice = HCVoice

HCVoice.name = ADDON_NAME or "HCVoice"
HCVoice.displayName = "HCVoice – RP Reactions"
HCVoice.version = "1.7.3"
HCVoice.schemaVersion = 170

local frame = CreateFrame("Frame")
HCVoice.frame = frame

local OFFICIAL_SPEECH = {
    { token = "HELPME", label = "Help Me", category = "Official speech" },
    { token = "INCOMING", label = "Incoming", category = "Official speech" },
    { token = "CHARGE", label = "Charge", category = "Official speech" },
    { token = "FLEE", label = "Flee", category = "Official speech" },
    { token = "ATTACKMYTARGET", label = "Attack My Target", category = "Official speech" },
    { token = "OOM", label = "Out of Mana", category = "Official speech" },
    { token = "FOLLOW", label = "Follow Me", category = "Official speech" },
    { token = "WAIT", label = "Wait", category = "Official speech" },
    { token = "HEALME", label = "Heal Me", category = "Official speech" },
    { token = "CHEER", label = "Cheer", category = "Official speech" },
    { token = "OPENFIRE", label = "Open Fire", category = "Official speech" },
    { token = "RASP", label = "Raspberry", category = "Official speech" },
    { token = "HELLO", label = "Hello", category = "Official speech" },
    { token = "BYE", label = "Goodbye", category = "Official speech" },
    { token = "NOD", label = "Yes / Nod", category = "Official speech" },
    { token = "NO", label = "No", category = "Official speech" },
    { token = "THANK", label = "Thank You", category = "Official speech" },
    { token = "WELCOME", label = "Welcome", category = "Official speech" },
    { token = "CONGRATULATE", label = "Congratulations", category = "Official speech" },
    { token = "FLIRT", label = "Flirt", category = "Official speech" },
    { token = "JOKE", label = "Silly / Joke", category = "Official speech" },
    { token = "TRAIN", label = "Train", category = "Official speech" },
}

local VOCAL_REACTIONS = {
    { token = "CRY", label = "Cry", category = "Vocal reaction" },
    { token = "MOURN", label = "Mourn", category = "Vocal reaction" },
    { token = "SIGH", label = "Sigh", category = "Vocal reaction" },
    { token = "YAWN", label = "Yawn", category = "Vocal reaction" },
    { token = "BORED", label = "Bored", category = "Vocal reaction" },
    { token = "WHISTLE", label = "Whistle", category = "Vocal reaction" },
    { token = "MOO", label = "Moo (Tauren)", category = "Vocal reaction", race = "Tauren" },
    { token = "GASP", label = "Gasp", category = "Vocal reaction" },
    { token = "LAUGH", label = "Laugh", category = "Vocal reaction" },
    { token = "CACKLE", label = "Cackle", category = "Vocal reaction" },
    { token = "GIGGLE", label = "Giggle", category = "Vocal reaction" },
    { token = "GUFFAW", label = "Guffaw", category = "Vocal reaction" },
    { token = "ROAR", label = "Roar", category = "Vocal reaction" },
    { token = "KISS", label = "Kiss", category = "Vocal reaction" },
    { token = "APPLAUD", label = "Applaud", category = "Animated reaction" },
    { token = "SALUTE", label = "Salute", category = "Animated reaction" },
    { token = "WAVE", label = "Wave", category = "Animated reaction" },
    { token = "VICTORY", label = "Victory", category = "Animated reaction" },
    { token = "BOW", label = "Bow", category = "Animated reaction" },
    { token = "HUG", label = "Hug", category = "RP interaction" },
}

-- Voice Lab explains intent, not just slash-command names. Keep this text
-- character-neutral so the same addon package works for every class and race.
local VOICE_GUIDANCE = {
    HELPME = { usage = "Rapidly worsening combat, your pet in real danger, or a direct request for help.", mode = "Automatic in a confirmed fight; contextual reply" },
    INCOMING = { usage = "A second attacker joins, or a rare or elite truly attacks you.", mode = "Automatic only after confirmed danger" },
    CHARGE = { usage = "Send your pet into a confirmed attack, or deliberately call for a pull.", mode = "Automatic pet command; manual or tactical reply" },
    FLEE = { usage = "Your health reaches the emergency threshold during combat.", mode = "Automatic, highest danger priority" },
    ATTACKMYTARGET = { usage = "A deliberate focus-target command from a group leader.", mode = "Manual or tactical reply" },
    OOM = { usage = "Mana reaches the configured warning level while fighting or grouped.", mode = "Automatic" },
    FOLLOW = { usage = "A deliberate request for the group to follow.", mode = "Manual or tactical reply" },
    WAIT = { usage = "You start a needed drink in a party, or a distant party member needs to catch up.", mode = "Automatic mana break; contextual reply; party-leader waiting" },
    HEALME = { usage = "Health reaches the configured healing threshold in combat.", mode = "Automatic" },
    CHEER = { usage = "A level, difficult victory, or other clear success.", mode = "Automatic in confirmed success scenes" },
    OPENFIRE = { usage = "A deliberate ranged attack command.", mode = "Manual or tactical reply" },
    RASP = { usage = "A chosen answer to a directed insult or taunt.", mode = "Reply-only; hostile replies require your choice" },
    HELLO = { usage = "A friendly player is deliberately targeted or greets you directly.", mode = "Automatic encounter opener or safe reply" },
    BYE = { usage = "A party member leaves, or an established social encounter ends.", mode = "Always on party departure; contextual elsewhere" },
    NOD = { usage = "Acknowledge a direct interaction, answer ready, or finish an announced mana break.", mode = "Contextual reply; confirmed readiness" },
    NO = { usage = "Answer not-ready or reject a directed request.", mode = "Contextual reply" },
    THANK = { usage = "Another player meaningfully heals, buffs, gifts, or congratulates you.", mode = "Automatic only when the helper is known" },
    WELCOME = { usage = "A player joins the party or thanks you for helping.", mode = "Automatic party greeting or safe reply" },
    CONGRATULATE = { usage = "A party member gains a level or reaches a clear achievement.", mode = "Automatic when the recipient is known" },
    FLIRT = { usage = "A chosen response to affection from a verified friendly female player.", mode = "Reply choice; never proactive" },
    JOKE = { usage = "A safe humorous reply or low-frequency downtime variation.", mode = "Reply, manual, or rare idle variation" },
    TRAIN = { usage = "A deliberate train or transport joke.", mode = "Manual" },
    CRY = { usage = "Grief after a confirmed party or pet death, or theatrical disappointment.", mode = "Automatic mourning; manual RP" },
    MOURN = { usage = "A known party member or your pet dies.", mode = "Automatic after a confirmed death, when combat allows it" },
    SIGH = { usage = "Relief after a near-death fight or wipe, or a chosen reply to a directed sigh.", mode = "Automatic relief; chosen social reply" },
    YAWN = { usage = "A long safe wait, or a chosen reply to a directed yawn.", mode = "Rare idle variation; chosen social reply" },
    BORED = { usage = "A long, quiet wait, alone or in a party; never directed at someone.", mode = "Rare automatic idle variation" },
    WHISTLE = { usage = "Call your pet back, whistle during a safe pause, or answer a directed whistle.", mode = "Automatic pet recall; rare idle variation; contextual reply" },
    MOO = { usage = "A Tauren's playful party joke or answer to someone mooing directly at you.", mode = "Rare party joke or directed reply; Tauren only" },
    GASP = { usage = "A huge opening hit or genuinely surprising danger.", mode = "Contextual automatic" },
    LAUGH = { usage = "A direct joke, silly emote, or clearly comic interaction.", mode = "Reply or manual" },
    CACKLE = { usage = "An intentionally villainous RP moment.", mode = "Manual" },
    GIGGLE = { usage = "A deliberately playful social response.", mode = "Manual" },
    GUFFAW = { usage = "A strong response to a directed joke.", mode = "Safe reply or manual" },
    ROAR = { usage = "An extreme theatrical victory or intimidation scene.", mode = "Manual" },
    KISS = { usage = "A chosen intimate response to a verified friendly player.", mode = "Reply choice" },
    APPLAUD = { usage = "A performance or clear achievement happens in front of you.", mode = "Suggested reply or manual" },
    SALUTE = { usage = "Return a salute or give a formal greeting or farewell.", mode = "Safe reply or manual" },
    WAVE = { usage = "Return a wave or use a visual greeting or farewell.", mode = "Safe reply or manual" },
    VICTORY = { usage = "A deliberate animation after a truly difficult victory.", mode = "Manual" },
    BOW = { usage = "Return a bow or show respect after a formal meeting.", mode = "Reply or manual" },
    HUG = { usage = "Return a directed hug from a verified friendly player. Kept for RP despite being text-only.", mode = "Reply choice; never proactive" },
}

for _, item in ipairs(OFFICIAL_SPEECH) do
    local guidance = VOICE_GUIDANCE[item.token]
    item.usage = guidance and guidance.usage or "Manual RP use only."
    item.mode = guidance and guidance.mode or "Manual"
end
for _, item in ipairs(VOCAL_REACTIONS) do
    local guidance = VOICE_GUIDANCE[item.token]
    item.usage = guidance and guidance.usage or "Manual RP use only."
    item.mode = guidance and guidance.mode or "Manual"
end

HCVoice.voiceOptions = {}
HCVoice.voiceByToken = {}
for _, item in ipairs(OFFICIAL_SPEECH) do
    HCVoice.voiceOptions[#HCVoice.voiceOptions + 1] = item
    HCVoice.voiceByToken[item.token] = item
end
for _, item in ipairs(VOCAL_REACTIONS) do
    HCVoice.voiceOptions[#HCVoice.voiceOptions + 1] = item
    HCVoice.voiceByToken[item.token] = item
end

function HCVoice:IsVoiceAvailable(token)
    local item = self.voiceByToken[token]
    if not item then return false end
    if not item.race then return true end
    if not UnitRace then return false end
    local _, race = UnitRace("player")
    return race == item.race
end

local scenarioDefinitions = {
    { key = "bossReactions", page = "bosses", label = "Automatic boss reactions", description = "Boss-specific Blizzard voices and animations in Classic Era Hardcore. No popups or custom dialogue.", emote = "RASP", enabled = true, chance = 100, priority = 24, cooldown = 12, quiet = false },
    -- Survival: each voice has one unambiguous meaning.
    { key = "firstDamage", page = "survival", label = "Fight turning dangerous", description = "Calls HELPME as health falls quickly. Small hits stay calm; recovery cancels queued help.", emote = "HELPME", enabled = true, chance = 100, priority = 100, cooldown = 2, essential = true },
    { key = "needHealing", page = "survival", label = "Need healing", description = "Calls HEALME once when health crosses the configured combat threshold.", emote = "HEALME", enabled = true, chance = 100, priority = 110, cooldown = 45, essential = true },
    { key = "fleeDanger", page = "survival", label = "Flee danger", description = "Calls FLEE once when health crosses the emergency combat threshold.", emote = "FLEE", enabled = true, chance = 100, priority = 120, cooldown = 90, essential = true },
    { key = "lowMana", page = "survival", label = "Low mana", description = "Calls OOM below the selected threshold while fighting or grouped, then rearms after mana recovery.", emote = "OOM", enabled = true, chance = 100, priority = 105, cooldown = 60, essential = true },
    { key = "nearDeath", page = "survival", label = "Survived near death", description = "Releases the tension after surviving below the FLEE threshold, usually with a voice line.", emote = "SIGH", variants = { { token = "SIGH", weight = 100 } }, variantLabel = "SIGH", enabled = true, chance = 100, priority = 70, cooldown = 120, essential = true },
    { key = "partyDeath", page = "survival", label = "Party member dies", description = "Mourns a fallen party member with restrained voice-first variation.", emote = "MOURN", variants = { { token = "MOURN", weight = 65 }, { token = "CRY", weight = 20 }, { token = "SALUTE", weight = 15 } }, variantLabel = "MOURN / CRY / SALUTE", enabled = true, chance = 100, priority = 115, cooldown = 45, targetCooldown = 60, essential = true },
    { key = "wipeRecovery", page = "survival", label = "Recover from a party wipe", description = "Reacts after your character returns from a confirmed full-party wipe, when voices make sense again.", emote = "SIGH", variants = { { token = "SIGH", weight = 65 }, { token = "CRY", weight = 35 } }, variantLabel = "SIGH / CRY", enabled = true, chance = 100, priority = 80, cooldown = 180, essential = true },
    { key = "playerLevel", page = "survival", label = "You gain a level", description = "Celebrates your level with a voiced reaction or a fitting victory animation.", emote = "CHEER", variants = { { token = "CHEER", weight = 75 }, { token = "VICTORY", weight = 15 }, { token = "APPLAUD", weight = 10 } }, variantLabel = "CHEER / VICTORY / APPLAUD", enabled = true, chance = 100, priority = 60, cooldown = 10, essential = true },
    { key = "petDanger", page = "survival", label = "Pet in danger", description = "Calls HELPME when your living pet falls to 25% health during a fight. Your own emergency takes priority. Rearms at 60% pet health.", emote = "HELPME", enabled = true, chance = 100, priority = 92, cooldown = 90, essential = true, quiet = false },
    { key = "petDeath", page = "survival", label = "Your pet dies", description = "Mourns a confirmed pet death once, after combat. Dismissal, replacement and a missing pet never count as death.", emote = "MOURN", variants = { { token = "MOURN", weight = 65 }, { token = "CRY", weight = 35 } }, variantLabel = "MOURN / CRY", enabled = true, chance = 100, priority = 65, cooldown = 90, essential = true, quiet = false },

    -- Social: automatic only after a real interaction; ambiguous replies use buttons.
    { key = "greetPlayer", page = "social", label = "Deliberate player greeting", description = "Always says HELLO after you deliberately target a friendly or neutral non-attackable player who is not already in your party or raid. This includes neutral opposite-faction players in Hardcore.", emote = "HELLO", enabled = true, chance = 100, priority = 30, cooldown = 8, targetCooldown = 1800, essential = true },
    { key = "socialFarewell", page = "social", label = "Farewell after interaction", description = "Ends an established encounter with a voiced goodbye or suitable body language.", emote = "BYE", variants = { { token = "BYE", weight = 70 }, { token = "WAVE", weight = 20 }, { token = "SALUTE", weight = 10 } }, variantLabel = "BYE / WAVE / SALUTE", enabled = true, chance = 65, priority = 25, cooldown = 30, targetCooldown = 900 },
    { key = "welcomeParty", page = "social", label = "Welcome new party members", description = "Welcomes a player after they actually join, with voice-first variation.", emote = "WELCOME", variants = { { token = "WELCOME", weight = 65 }, { token = "NOD", weight = 15 }, { token = "WAVE", weight = 12 }, { token = "SALUTE", weight = 8 } }, variantLabel = "WELCOME / NOD / WAVE / SALUTE", enabled = true, chance = 100, priority = 50, cooldown = 15, targetCooldown = 120, essential = true },
    { key = "partyLevel", page = "social", label = "Party member levels", description = "Congratulates the correct party member with a varied celebration.", emote = "CONGRATULATE", variants = { { token = "CONGRATULATE", weight = 60 }, { token = "CHEER", weight = 20 }, { token = "APPLAUD", weight = 10 }, { token = "VICTORY", weight = 10 } }, variantLabel = "CONGRATULATE / CHEER / APPLAUD / VICTORY", enabled = true, chance = 100, priority = 55, cooldown = 10, targetCooldown = 120, essential = true },
    { key = "thankHealer", page = "social", label = "Thank meaningful healing", description = "Thanks the player who provides substantial healing or helps rescue your character during combat.", emote = "THANK", variants = { { token = "THANK", weight = 85 }, { token = "SALUTE", weight = 15 } }, variantLabel = "THANK / SALUTE", enabled = true, chance = 100, priority = 85, cooldown = 60, targetCooldown = 600, essential = true },
    { key = "thankBuff", page = "social", label = "Thank important buffs", description = "Thanks the player who applies a recognized long-term class buff to your character outside combat.", emote = "THANK", enabled = true, chance = 100, priority = 35, cooldown = 60, targetCooldown = 900, essential = true },
    { key = "thankAssist", page = "social", label = "Thank a stranger who helps fight", description = "Thanks a non-group player who meaningfully helps with your current enemy. Passing nearby or merely targeting you never counts.", emote = "THANK", variants = { { token = "THANK", weight = 58 }, { token = "SALUTE", weight = 20 }, { token = "NOD", weight = 14 }, { token = "CHEER", weight = 8 } }, variantLabel = "THANK / SALUTE / NOD / CHEER", enabled = true, chance = 85, priority = 48, cooldown = 45, targetCooldown = 300 },
    { key = "thankResurrection", page = "social", label = "Thank a resurrection", description = "Thanks the friendly player who resurrects your character after you return to life.", emote = "THANK", variants = { { token = "THANK", weight = 85 }, { token = "SALUTE", weight = 15 } }, variantLabel = "THANK / SALUTE", enabled = true, chance = 100, priority = 88, cooldown = 30, targetCooldown = 900, essential = true },
    { key = "thankTrade", page = "social", label = "Thank gifts in trade", description = "Thanks the other player only when a completed trade gives your character an item or money.", emote = "THANK", enabled = true, chance = 100, priority = 45, cooldown = 30, targetCooldown = 300 },
    { key = "readyCheckYes", page = "social", label = "Ready-check: ready", description = "Nods after you explicitly answer ready.", emote = "NOD", enabled = true, chance = 100, priority = 40, cooldown = 10, essential = true },
    { key = "readyCheckNo", page = "social", label = "Ready-check: not ready", description = "Says NO after you explicitly answer not ready.", emote = "NO", enabled = true, chance = 100, priority = 40, cooldown = 10, essential = true },

    -- Combat: threat must be real, never inferred from target selection alone.
    { key = "extraEnemy", page = "combat", label = "Additional enemy joins", description = "Calls INCOMING when a second hostile enemy damages you or your pet during the same combat.", emote = "INCOMING", enabled = true, chance = 100, priority = 95, cooldown = 45, essential = true },
    { key = "hardAggro", page = "combat", label = "Rare or elite actually aggros", description = "Calls INCOMING only after a targeted rare, elite or boss attacks you or your pet.", emote = "INCOMING", enabled = true, chance = 100, priority = 100, cooldown = 45, targetCooldown = 1800, essential = true },
    { key = "hugeHit", page = "combat", label = "Huge opening hit", description = "Contextual GASP after an opening hostile hit removes at least 35% of maximum health.", emote = "GASP", enabled = true, chance = 45, priority = 90, cooldown = 120 },
    { key = "hardVictory", page = "combat", label = "Difficult victory", description = "Celebrates a tracked elite or boss kill with stagger-friendly voice-first variation.", emote = "CHEER", variants = { { token = "CHEER", weight = 65 }, { token = "ROAR", weight = 10 }, { token = "VICTORY", weight = 15 }, { token = "APPLAUD", weight = 10 } }, variantLabel = "CHEER / ROAR / VICTORY / APPLAUD", enabled = true, chance = 100, priority = 75, cooldown = 30, essential = true },
    { key = "partyWait", page = "combat", label = "Wait for distant member", description = "Hybrid WAIT: may trigger while you lead and stand still before a pull with a living member out of range.", emote = "WAIT", enabled = true, chance = 100, priority = 25, cooldown = 120, targetCooldown = 300 },
    { key = "manaBreak", page = "combat", label = "Drinking for mana", description = "Says WAIT once when you start drinking at 60% mana or less in a safe party. Does not add OOM during the same drink.", emote = "WAIT", enabled = true, chance = 100, priority = 45, cooldown = 90, essential = true, quiet = false },
    { key = "manaReady", page = "combat", label = "Mana break finished", description = "Nods once after an announced drink ends with at least 90% mana. An interrupted or unannounced break never gives a ready signal.", emote = "NOD", enabled = true, chance = 100, priority = 25, cooldown = 90, essential = true, quiet = false },
    { key = "petAttack", page = "combat", label = "Send pet to attack", description = "Calls CHARGE after your attack command is confirmed against a living enemy. Once per fight, with an 8-second cooldown. Automatic pet defense stays silent.", emote = "CHARGE", enabled = true, chance = 100, priority = 70, cooldown = 8, essential = true, quiet = false },
    { key = "petRecall", page = "combat", label = "Call pet back", description = "Whistles when you call back an attacking or waiting pet with Follow. Repeated commands while it is already following stay silent. Works during combat, with an 8-second cooldown.", emote = "WHISTLE", enabled = true, chance = 100, priority = 85, cooldown = 8, essential = true, quiet = false },

    -- Safe ambience only; low chance is intentional rather than arbitrary mapping.
    { key = "sillyLoot", page = "world", label = "Silly grey loot", description = "Very rarely turns your own ridiculous grey loot into a party joke.", emote = "JOKE", variants = { { token = "JOKE", weight = 60 }, { token = "LAUGH", weight = 20 }, { token = "SIGH", weight = 15 }, { token = "CRY", weight = 5 } }, variantLabel = "JOKE / LAUGH / SIGH / CRY", enabled = true, chance = 15, priority = 10, cooldown = 120, targetCooldown = 600 },
    { key = "greatLoot", page = "world", label = "Rare-quality loot", description = "Voice-first celebration after your own blue-quality loot.", emote = "CHEER", variants = { { token = "CHEER", weight = 55 }, { token = "CONGRATULATE", weight = 20 }, { token = "APPLAUD", weight = 15 }, { token = "VICTORY", weight = 10 } }, variantLabel = "CHEER / CONGRATULATE / APPLAUD / VICTORY", enabled = true, chance = 100, priority = 35, cooldown = 45, targetCooldown = 900 },
    { key = "exceptionalLoot", page = "world", label = "Epic-quality loot", description = "Astonished celebration after your own epic or better loot.", emote = "GASP", variants = { { token = "GASP", weight = 45 }, { token = "CHEER", weight = 30 }, { token = "ROAR", weight = 10 }, { token = "VICTORY", weight = 10 }, { token = "APPLAUD", weight = 5 } }, variantLabel = "GASP / CHEER / ROAR / VICTORY / APPLAUD", enabled = true, chance = 100, priority = 45, cooldown = 45, targetCooldown = 1800 },
    { key = "partyJoke", page = "world", label = "Occasional party joke", description = "Occasionally uses JOKE/SILLY during safe party travel or downtime. Tauren can sometimes MOO instead. Never starts in combat, raids or while casting, or when a party member is dead.", emote = "JOKE", variants = { { token = "JOKE", weight = 95 }, { token = "MOO", weight = 5 } }, variantLabel = "JOKE / MOO (Tauren)", enabled = true, chance = 100, priority = 12, cooldown = 180 },
    { key = "idleYawn", page = "world", label = "Safe idle variation", description = "Very rarely uses BORED, YAWN or WHISTLE after a long, stationary, safe wait, solo or in a party. Always untargeted; does not invite group replies. Never in raids or while casting.", emote = "YAWN", variants = { { token = "BORED", weight = 40 }, { token = "YAWN", weight = 40 }, { token = "WHISTLE", weight = 20 } }, variantLabel = "BORED / YAWN / WHISTLE", enabled = true, chance = 15, priority = 10, cooldown = 600 },
}

HCVoice.scenarioDefinitions = scenarioDefinitions
HCVoice.scenarioByKey = {}
for _, def in ipairs(scenarioDefinitions) do
    HCVoice.scenarioByKey[def.key] = def
end

local function buildScenarioDefaults()
    local scenarios = {}
    for _, def in ipairs(scenarioDefinitions) do
        local mode = def.defaultMode or (def.enabled and "automatic" or "off")
        scenarios[def.key] = {
            enabled = mode ~= "off",
            mode = mode,
            chance = def.chance,
            emote = def.emote,
        }
    end
    return scenarios
end

local defaults = {
    schemaVersion = HCVoice.schemaVersion,
    enabled = true,
    frequency = 70,
    globalCooldown = 8,
    debug = false,
    announceLoaded = true,
    preset = "classicRP",
    thresholds = {
        mana = 30,
        manaRearm = 60,
        healing = 45,
        healingRearm = 70,
        flee = 20,
        fleeRearm = 45,
    },
    advanced = {
        idleMinutes = 5,
        partyWaitSeconds = 15,
        healerThanksPercent = 15,
        hardFightSeconds = 8,
        hardLevelDelta = 3,
        socialTargetCooldownMinutes = 30,
        greetingDelaySeconds = 1.5,
        minimumEncounterSeconds = 4,
        farewellDelaySeconds = 0.8,
        encounterMemorySeconds = 180,
    },
    reply = {
        enabled = true,
        mode = "hybrid",
        directedOnly = true,
        disableAutoInCombat = true,
        autoChance = 100,
        samePlayerCooldown = 300,
        promptCooldown = 6,
        popupSeconds = 12,
        conversationSeconds = 30,
        categories = {
            greetings = true,
            thanks = true,
            congratulations = true,
            friendly = true,
            requests = true,
            tactical = true,
            affection = true,
            hostile = true,
            unknown = false,
        },
    },
    livingWorld = {
        enabled = true,
        group = true,
        nearby = true,
        mode = "hybrid",
        frequency = 70,
    },
    ui = {},
    bossDungeons = {},
    scenarios = buildScenarioDefaults(),
}
HCVoice.defaults = defaults

local damageSubEvents = {
    SWING_DAMAGE = true,
    RANGE_DAMAGE = true,
    SPELL_DAMAGE = true,
    SPELL_PERIODIC_DAMAGE = true,
    DAMAGE_SHIELD = true,
    DAMAGE_SPLIT = true,
}

local directDamageSubEvents = {
    SWING_DAMAGE = true,
    RANGE_DAMAGE = true,
    SPELL_DAMAGE = true,
}

local importantBuffNames = {
    "arcane intellect", "arcane brilliance", "blessing of kings", "blessing of might",
    "blessing of salvation", "blessing of sanctuary", "blessing of wisdom", "divine spirit",
    "mark of the wild", "gift of the wild", "power word: fortitude", "prayer of fortitude",
    "prayer of spirit", "thorns", "water breathing", "water walking",
}

local combatOnlyScenarios = {
    firstDamage = true, needHealing = true, fleeDanger = true, lowMana = true,
    extraEnemy = true, hardAggro = true, hugeHit = true,
}

local socialOutgoingScenarios = {
    greetPlayer = true, socialFarewell = true, welcomeParty = true,
    farewellParty = true, thankHealer = true, thankBuff = true,
    thankAssist = true, thankResurrection = true,
    thankTrade = true, partyLevel = true,
}

local function now()
    return GetTime and GetTime() or 0
end

local function shallowCopy(source)
    local result = {}
    for key, value in pairs(source or {}) do result[key] = value end
    return result
end

local function deepCopy(source)
    if type(source) ~= "table" then return source end
    local result = {}
    for key, value in pairs(source) do result[key] = deepCopy(value) end
    return result
end

local function deepMerge(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then target[key] = {} end
            deepMerge(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
    return target
end

local function clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function round(value)
    return math.floor((tonumber(value) or 0) + 0.5)
end

local function percent(current, maximum)
    if not maximum or maximum <= 0 then return 1 end
    return current / maximum
end

local function getUnitName(unit)
    if GetUnitName then
        local value = GetUnitName(unit, false)
        if value and value ~= "" then return value end
    end
    if UnitName then
        local name = UnitName(unit)
        return name
    end
end

local function targetIdentity(unit)
    if not UnitExists or not UnitExists(unit) then return nil, nil end
    return UnitGUID and UnitGUID(unit) or getUnitName(unit), getUnitName(unit)
end

local function isPlayerGroupUnit(unit)
    if not unit or not UnitExists or not UnitExists(unit) then return false end
    if UnitInParty and UnitInParty(unit) then return true end
    if UnitInRaid and UnitInRaid(unit) then return true end
    local guid = UnitGUID and UnitGUID(unit) or nil
    if not guid then return false end
    for index = 1, 4 do
        if UnitExists("party" .. index) and UnitGUID("party" .. index) == guid then return true end
    end
    for index = 1, 40 do
        if UnitExists("raid" .. index) and UnitGUID("raid" .. index) == guid then return true end
    end
    return false
end

local function guidIsGroupMember(guid)
    if not guid then return false end
    if UnitGUID and UnitGUID("player") == guid then return true end
    for index = 1, 4 do
        if UnitExists("party" .. index) and UnitGUID("party" .. index) == guid then return true end
    end
    for index = 1, 40 do
        if UnitExists("raid" .. index) and UnitGUID("raid" .. index) == guid then return true end
    end
    return false
end

local function isAlive(unit)
    return UnitExists(unit) and not UnitIsDeadOrGhost(unit) and (UnitHealth(unit) or 0) > 0
end

local function isHardClassification(classification)
    return classification == "elite" or classification == "rare" or classification == "rareelite" or classification == "worldboss"
end

local function flagsHave(flags, mask)
    local bitLibrary = bit or bit32
    if not flags or not mask or not bitLibrary or not bitLibrary.band then return false end
    return bitLibrary.band(flags, mask) ~= 0
end

local function isFriendlyPlayerFlags(flags)
    return flagsHave(flags, COMBATLOG_OBJECT_TYPE_PLAYER) and flagsHave(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY)
end

local function isHostileNPCFlags(flags)
    return flagsHave(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) and not flagsHave(flags, COMBATLOG_OBJECT_TYPE_PLAYER)
end

local function isHostilePlayerFlags(flags)
    return flagsHave(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) and flagsHave(flags, COMBATLOG_OBJECT_TYPE_PLAYER)
end

local passiveAuraMarkers = { "aura", "totem", "stance", "presence", "aspect" }

local function hasPassiveAuraMarker(spellName)
    local lowerName = string.lower(tostring(spellName or ""))
    for _, marker in ipairs(passiveAuraMarkers) do
        if lowerName:find(marker, 1, true) then return true end
    end
    return false
end

local function isImportantDirectBuff(spellName)
    local lowerName = string.lower(tostring(spellName or ""))
    if hasPassiveAuraMarker(lowerName) then return false end
    for _, name in ipairs(importantBuffNames) do
        if lowerName == name or lowerName:find(name, 1, true) == 1 then return true end
    end
    return false
end

local function normalizeSocialName(name)
    if not name or name == "" then return nil end
    local value = tostring(name)
    local short, realm = value:match("^([^-]+)%-(.+)$")
    local ownRealm = GetNormalizedRealmName and GetNormalizedRealmName() or nil
    if short and ownRealm and string.lower(realm:gsub("%s", "")) == string.lower(ownRealm:gsub("%s", "")) then return short end
    return value
end

local function socialNameKey(name)
    return string.lower(tostring(normalizeSocialName(name) or ""))
end
HCVoice.NormalizeName = normalizeSocialName
HCVoice.NameKey = socialNameKey

function HCVoice:GroupUnits()
    local units = {}
    local raid = IsInRaid and IsInRaid()
    for i = 1, raid and 40 or 4 do units[#units + 1] = (raid and "raid" or "party") .. i end
    return units
end

local function lowerPlain(value)
    return string.lower(tostring(value or ""))
end



local function scenarioConfig(db, key)
    return db and db.scenarios and db.scenarios[key]
end

function HCVoice:Message(text)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00HCVoice:|r " .. tostring(text))
    end
end

function HCVoice:Debug(text)
    if self.db and self.db.debug then
        self:Message("|cff8888ffDEBUG|r " .. tostring(text))
    end
end

function HCVoice:CreateState()
    self._stateGeneration = (self._stateGeneration or 0) + 1
    return {
        generation = self._stateGeneration,
        initialized = false,
        manaArmed = true,
        healthArmed = { healing = true, flee = true },
        roster = {},
        rosterInitialized = false,
        suppressRosterUntil = 0,
        reactionQueue = {},
        lastAnyEmoteAt = -math.huge,
        lastScenarioAt = {},
        lastTargetAt = {},
        reply = {
            lastReplyAt = {},
            lastOutgoingAt = {},
            lastPromptAt = {},
            lastIncomingSignature = {},
            lastIncomingAt = {},
            ignored = {},
        },
        social = {
            encounters = {},
            targetSession = nil,
            targetGeneration = 0,
        },
        inCombat = false,
        combat = {},
        trade = nil,
        loot = { lastSignature = nil },
        lastActivityAt = now(),
        partyFarSince = nil,
        wipePending = false,
        moments = {},
        decisions = {},
        ticker = nil,
    }
end

function HCVoice:MigrateDatabase(db)
    if type(db) ~= "table" then return {} end
    if db.schemaVersion and db.schemaVersion >= self.schemaVersion then return db end

    local migrated = deepCopy(db)
    migrated.thresholds = migrated.thresholds or {}
    migrated.advanced = migrated.advanced or {}
    migrated.reply = migrated.reply or {}
    migrated.livingWorld = migrated.livingWorld or {}

    if (db.schemaVersion or 0) < 150 then
        migrated.scenarios = migrated.scenarios or {}
        migrated.scenarios.eliteCharge = nil
        migrated.reply.directedOnly = true
        migrated.reply.autoChance = 100
        migrated.reply.categories = migrated.reply.categories or {}
        if migrated.reply.categories.affection == nil then migrated.reply.categories.affection = true end
        if migrated.reply.categories.hostile == nil then migrated.reply.categories.hostile = true end
        if migrated.reply.mode ~= "off" then migrated.reply.mode = "hybrid" end
        if migrated.livingWorld.mode == "suggest" then migrated.livingWorld.mode = "hybrid" end
    end

    -- Schemas before 1.2 used unrelated event-to-random-emote mappings. Version
    -- 1.2 and later already use semantic scenarios, so preserve those choices.
    if (db.schemaVersion or 0) < 120 then
        migrated.scenarios = buildScenarioDefaults()
        migrated.thresholds.mana = 30
        migrated.thresholds.manaRearm = 60
        migrated.thresholds.healing = 45
        migrated.thresholds.healingRearm = 70
        migrated.thresholds.flee = 20
        migrated.thresholds.fleeRearm = 45
        migrated.preset = "classicRP"
    else
        migrated.scenarios = migrated.scenarios or {}
        for _, def in ipairs(self.scenarioDefinitions) do
            local cfg = migrated.scenarios[def.key]
            if type(cfg) ~= "table" then
                local mode = def.defaultMode or (def.enabled and "automatic" or "off")
                if db.preset == "quiet" and def.quiet == false then mode = "off" end
                cfg = { enabled = mode ~= "off", mode = mode, chance = def.chance, emote = def.emote }
                migrated.scenarios[def.key] = cfg
            end
            if cfg.mode == nil then cfg.mode = cfg.enabled == false and "off" or (def.defaultMode or "automatic") end
        end
        local direct = migrated.scenarios.directReplies
        if direct and direct.enabled == false and migrated.reply.enabled == nil then migrated.reply.enabled = false end
    end

    migrated.scenarios.buffPlayer = nil
    migrated.scenarios.directReplies = nil
    migrated.scenarios.intimateReplies = nil
    migrated.scenarios.farewellParty = nil
    migrated.schemaVersion = self.schemaVersion
    return migrated
end

function HCVoice:SanitizeDatabase()
    local db = self.db
    if self.Bosses then self.Bosses:Sanitize() end
    db.schemaVersion = self.schemaVersion
    db.enabled = db.enabled ~= false
    db.debug = db.debug == true
    db.announceLoaded = db.announceLoaded ~= false
    db.scenarios.buffPlayer = nil
    db.scenarios.directReplies = nil
    db.scenarios.intimateReplies = nil
    db.scenarios.farewellParty = nil
    db.frequency = round(clamp(db.frequency, 0, 100))
    db.globalCooldown = clamp(db.globalCooldown, 2, 60)

    local t = db.thresholds
    t.mana = round(clamp(t.mana, 5, 90))
    t.manaRearm = round(clamp(t.manaRearm, t.mana + 5, 100))
    t.healing = round(clamp(t.healing, 10, 80))
    t.healingRearm = round(clamp(t.healingRearm, t.healing + 5, 100))
    t.flee = round(clamp(t.flee, 1, t.healing))
    t.fleeRearm = round(clamp(t.fleeRearm, t.flee + 5, 100))

    local a = db.advanced
    a.idleMinutes = round(clamp(a.idleMinutes, 1, 30))
    a.partyWaitSeconds = round(clamp(a.partyWaitSeconds, 5, 60))
    a.healerThanksPercent = round(clamp(a.healerThanksPercent, 5, 75))
    a.hardFightSeconds = round(clamp(a.hardFightSeconds, 3, 60))
    a.hardLevelDelta = round(clamp(a.hardLevelDelta, 0, 10))
    a.socialTargetCooldownMinutes = round(clamp(a.socialTargetCooldownMinutes, 1, 180))
    a.greetingDelaySeconds = clamp(a.greetingDelaySeconds, 0.5, 4)
    a.minimumEncounterSeconds = clamp(a.minimumEncounterSeconds, 1, 20)
    a.farewellDelaySeconds = clamp(a.farewellDelaySeconds, 0.2, 4)
    a.encounterMemorySeconds = round(clamp(a.encounterMemorySeconds, 30, 900))

    local r = db.reply
    if type(r) ~= "table" then r = deepCopy(self.defaults.reply); db.reply = r end
    r.enabled = r.enabled ~= false
    local validReplyModes = { off = true, hybrid = true }
    if not validReplyModes[r.mode] then r.mode = r.mode == "off" and "off" or "hybrid" end
    r.directedOnly = true
    r.disableAutoInCombat = r.disableAutoInCombat ~= false
    r.autoChance = round(clamp(r.autoChance, 0, 100))
    r.samePlayerCooldown = round(clamp(r.samePlayerCooldown, 10, 1800))
    r.promptCooldown = round(clamp(r.promptCooldown, 2, 60))
    r.popupSeconds = round(clamp(r.popupSeconds, 5, 30))
    r.conversationSeconds = round(clamp(r.conversationSeconds, 5, 120))
    if type(r.categories) ~= "table" then r.categories = deepCopy(self.defaults.reply.categories) end
    for category, defaultValue in pairs(self.defaults.reply.categories) do
        if r.categories[category] == nil then r.categories[category] = defaultValue end
        r.categories[category] = r.categories[category] == true
    end

    local living = db.livingWorld
    if type(living) ~= "table" then living = deepCopy(self.defaults.livingWorld); db.livingWorld = living end
    living.enabled = living.enabled ~= false
    living.group = living.group ~= false
    living.nearby = living.nearby ~= false
    living.frequency = round(clamp(living.frequency == nil and db.frequency or living.frequency, 0, 100))
    if type(db.ui) ~= "table" then db.ui = {} end
    local validLivingModes = { off = true, hybrid = true, auto = true }
    if not validLivingModes[living.mode] then living.mode = "hybrid" end

    local validScenarioModes = { automatic = true, manual = true, off = true }
    for _, def in ipairs(self.scenarioDefinitions) do
        local cfg = db.scenarios[def.key]
        if type(cfg) ~= "table" then
            local mode = def.defaultMode or (def.enabled and "automatic" or "off")
            cfg = { enabled = mode ~= "off", mode = mode, chance = def.chance, emote = def.emote }
            db.scenarios[def.key] = cfg
        end
        if cfg.enabled == nil then cfg.enabled = def.enabled end
        if not validScenarioModes[cfg.mode] then cfg.mode = cfg.enabled == false and "off" or "automatic" end
        cfg.enabled = cfg.mode ~= "off"
        cfg.chance = round(clamp(cfg.chance == nil and def.chance or cfg.chance, 0, 100))
        -- Scenario meanings are fixed in 1.1. Voice Lab remains fully manual.
        cfg.emote = def.emote
    end
end

function HCVoice:Initialize()
    -- Version 1.2 uses per-character settings. A legacy account-wide database is
    -- copied once as a migration seed so existing users keep a sensible upgrade.
    local source = _G.HCVoiceCharDB
    if type(source) ~= "table" then
        local legacy = _G.HCVoiceDB
        source = type(legacy) == "table" and type(legacy.profiles) ~= "table" and legacy or {}
    end
    local migrated = self:MigrateDatabase(source)
    _G.HCVoiceCharDB = deepMerge(migrated, deepCopy(self.defaults))
    self.db = _G.HCVoiceCharDB
    if type(_G.HCVoiceDB) ~= "table" then _G.HCVoiceDB = {} end
    if type(_G.HCVoiceDB.profiles) ~= "table" then _G.HCVoiceDB.profiles = {} end
    self.accountDB = _G.HCVoiceDB
    self:SanitizeDatabase()
    self.state = self:CreateState()
    self:InitializeUnitState()
    self:RefreshRoster(true)
    self.state.initialized = true
    if self.LivingWorld and self.LivingWorld.Initialize then self.LivingWorld:Initialize() end
    if self.Bosses then self.Bosses:Reset() end
    if self.InstallPetCommandHooks then self:InstallPetCommandHooks() end
    self:StartTicker()
    if self.GUI and self.GUI.Refresh then self.GUI:Refresh() end
    return self
end

function HCVoice:ResetRuntimeState()
    local ticker = self.state and self.state.ticker or nil
    local ignored = self.state and self.state.reply and self.state.reply.ignored
    self.state = self:CreateState()
    if ignored then self.state.reply.ignored = ignored end
    self.state.ticker = ticker
    self:InitializeUnitState()
    self:RefreshRoster(true)
    self.state.initialized = true
    if self.GUI and self.GUI.HideReplyPrompt then self.GUI:HideReplyPrompt() end
    if self.Bosses then self.Bosses:Reset() end
end

function HCVoice:ResetDefaults()
    _G.HCVoiceCharDB = deepCopy(self.defaults)
    self.db = _G.HCVoiceCharDB
    self:SanitizeDatabase()
    self:ResetRuntimeState()
    if self.GUI and self.GUI.Refresh then self.GUI:Refresh() end
    self:Message("settings reset to defaults")
end

local function cleanProfileName(name)
    name = tostring(name or ""):gsub("[%c;=]", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if #name > 32 then name = name:sub(1, 32) end
    return name
end

function HCVoice:NormalizeProfileName(name)
    return cleanProfileName(name)
end

function HCVoice:GetProfileNames()
    local names = {}
    local profiles = self.accountDB and self.accountDB.profiles or nil
    for name in pairs(profiles or {}) do names[#names + 1] = name end
    table.sort(names, function(a, b) return string.lower(a) < string.lower(b) end)
    return names
end

function HCVoice:SaveProfile(name)
    name = cleanProfileName(name)
    if name == "" then return false, "Enter a profile name." end
    self.accountDB.profiles[name] = deepCopy(self.db)
    self.accountDB.profiles[name].schemaVersion = self.schemaVersion
    return true, name
end

function HCVoice:LoadProfile(name)
    local source = self.accountDB and self.accountDB.profiles and self.accountDB.profiles[name]
    if type(source) ~= "table" then return false, "Profile not found." end
    local migrated = self:MigrateDatabase(deepCopy(source))
    _G.HCVoiceCharDB = deepMerge(migrated, deepCopy(self.defaults))
    self.db = _G.HCVoiceCharDB
    self:SanitizeDatabase()
    self:ResetRuntimeState()
    if self.GUI and self.GUI.Refresh then self.GUI:Refresh() end
    return true, name
end

function HCVoice:DeleteProfile(name)
    if not self.accountDB or not self.accountDB.profiles or not self.accountDB.profiles[name] then
        return false, "Profile not found."
    end
    self.accountDB.profiles[name] = nil
    return true, name
end

local exportedNumberFields = {
    { "frequency", "frequency" }, { "globalCooldown", "globalCooldown" },
    { "living.frequency", "livingWorld", "frequency" },
    { "thresholds.mana", "thresholds", "mana" }, { "thresholds.manaRearm", "thresholds", "manaRearm" },
    { "thresholds.healing", "thresholds", "healing" }, { "thresholds.healingRearm", "thresholds", "healingRearm" },
    { "thresholds.flee", "thresholds", "flee" }, { "thresholds.fleeRearm", "thresholds", "fleeRearm" },
    { "advanced.idleMinutes", "advanced", "idleMinutes" }, { "advanced.partyWaitSeconds", "advanced", "partyWaitSeconds" },
    { "advanced.healerThanksPercent", "advanced", "healerThanksPercent" }, { "advanced.hardFightSeconds", "advanced", "hardFightSeconds" },
    { "advanced.hardLevelDelta", "advanced", "hardLevelDelta" }, { "advanced.socialTargetCooldownMinutes", "advanced", "socialTargetCooldownMinutes" },
    { "advanced.greetingDelaySeconds", "advanced", "greetingDelaySeconds" }, { "advanced.minimumEncounterSeconds", "advanced", "minimumEncounterSeconds" },
    { "advanced.farewellDelaySeconds", "advanced", "farewellDelaySeconds" }, { "advanced.encounterMemorySeconds", "advanced", "encounterMemorySeconds" },
    { "reply.autoChance", "reply", "autoChance" }, { "reply.samePlayerCooldown", "reply", "samePlayerCooldown" },
    { "reply.promptCooldown", "reply", "promptCooldown" }, { "reply.popupSeconds", "reply", "popupSeconds" },
    { "reply.conversationSeconds", "reply", "conversationSeconds" },
}

function HCVoice:ExportProfile()
    local parts = { "HCVOICE_PROFILE_V1", "enabled=" .. (self.db.enabled and "1" or "0") }
    for key, enabled in pairs(self.db.bossDungeons or {}) do
        parts[#parts + 1] = "boss.dungeon." .. key .. "=" .. (enabled and "1" or "0")
    end
    for _, field in ipairs(exportedNumberFields) do
        local value = field[3] and self.db[field[2]][field[3]] or self.db[field[2]]
        parts[#parts + 1] = field[1] .. "=" .. tostring(value)
    end
    local reply = self.db.reply
    parts[#parts + 1] = "reply.enabled=" .. (reply.enabled and "1" or "0")
    parts[#parts + 1] = "reply.mode=" .. reply.mode
    parts[#parts + 1] = "reply.directedOnly=" .. (reply.directedOnly and "1" or "0")
    parts[#parts + 1] = "reply.disableAutoInCombat=" .. (reply.disableAutoInCombat and "1" or "0")
    for category, enabled in pairs(reply.categories) do
        parts[#parts + 1] = "reply.category." .. category .. "=" .. (enabled and "1" or "0")
    end
    local living = self.db.livingWorld
    parts[#parts + 1] = "living.enabled=" .. (living.enabled and "1" or "0")
    parts[#parts + 1] = "living.group=" .. (living.group and "1" or "0")
    parts[#parts + 1] = "living.nearby=" .. (living.nearby and "1" or "0")
    parts[#parts + 1] = "living.mode=" .. living.mode
    for _, def in ipairs(self.scenarioDefinitions) do
        local cfg = self.db.scenarios[def.key]
        parts[#parts + 1] = "scenario." .. def.key .. ".mode=" .. cfg.mode
        parts[#parts + 1] = "scenario." .. def.key .. ".chance=" .. tostring(cfg.chance)
    end
    return table.concat(parts, ";")
end

function HCVoice:ImportProfile(text)
    text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #text > 16000 then return false, "Profile text is too long." end
    if not text:find("^HCVOICE_PROFILE_V1;") then return false, "Not an HCVoice profile string." end
    local fieldTypes = {
        enabled = "boolean",
        ["reply.enabled"] = "boolean", ["reply.directedOnly"] = "boolean", ["reply.disableAutoInCombat"] = "boolean",
        ["living.enabled"] = "boolean", ["living.group"] = "boolean", ["living.nearby"] = "boolean",
        ["reply.mode"] = { off = true, hybrid = true, auto = true, suggest = true },
        ["living.mode"] = { off = true, hybrid = true, auto = true, suggest = true },
    }
    for _, field in ipairs(exportedNumberFields) do fieldTypes[field[1]] = "number" end
    for category in pairs(self.defaults.reply.categories) do fieldTypes["reply.category." .. category] = "boolean" end
    if self.Bosses then
        for key in pairs(self.Bosses.dungeons) do fieldTypes["boss.dungeon." .. key] = "boolean" end
    end
    for _, def in ipairs(self.scenarioDefinitions) do
        fieldTypes["scenario." .. def.key .. ".mode"] = { automatic = true, manual = true, off = true, suggest = true }
        fieldTypes["scenario." .. def.key .. ".chance"] = "number"
    end

    -- Validate before changing either character settings or pending reactions.
    -- Older exports may omit new settings or contain retired scenario fields.
    local values = {}
    local recognized = 0
    local body = text:sub(#"HCVOICE_PROFILE_V1;" + 1)
    if body:sub(-1) == ";" then body = body:sub(1, -2) end
    for field in (body .. ";"):gmatch("(.-);") do
        local key, value = field:match("^([%w_.%-]+)=([^=;]+)$")
        if not key then return false, "Profile contains an incomplete or malformed setting." end
        if values[key] ~= nil then return false, "Profile contains a duplicate setting: " .. key end
        local kind = fieldTypes[key]
        if kind == "boolean" and value ~= "1" and value ~= "0" and value ~= "true" and value ~= "false" then
            return false, "Profile contains an invalid on/off setting: " .. key
        elseif kind == "number" then
            local number = tonumber(value)
            if not number or number ~= number or number == math.huge or number == -math.huge then
                return false, "Profile contains an invalid number: " .. key
            end
        elseif type(kind) == "table" and not kind[value] then
            return false, "Profile contains an invalid mode: " .. key
        end
        if kind then recognized = recognized + 1 end
        values[key] = value
    end
    if recognized == 0 then return false, "Profile contains no recognized behavior settings." end
    -- V1 has no completeness marker. Keep omitted settings so an older export
    -- or text cut at a field boundary cannot silently reset the character.
    -- Local window placement and diagnostic preferences are never exported.
    local imported = deepMerge(deepCopy(self.db), deepCopy(self.defaults))
    local function boolValue(key, fallback)
        if values[key] == nil then return fallback end
        return values[key] == "1" or values[key] == "true"
    end
    if self.Bosses then
        for key in pairs(self.Bosses.dungeons) do
            imported.bossDungeons[key] = boolValue("boss.dungeon." .. key, imported.bossDungeons[key] ~= false)
        end
    end
    imported.enabled = boolValue("enabled", imported.enabled)
    for _, field in ipairs(exportedNumberFields) do
        local value = tonumber(values[field[1]])
        if value then
            if field[3] then imported[field[2]][field[3]] = value else imported[field[2]] = value end
        end
    end
    imported.reply.enabled = boolValue("reply.enabled", imported.reply.enabled)
    imported.reply.directedOnly = boolValue("reply.directedOnly", imported.reply.directedOnly)
    imported.reply.disableAutoInCombat = boolValue("reply.disableAutoInCombat", imported.reply.disableAutoInCombat)
    if values["reply.mode"] then imported.reply.mode = values["reply.mode"] == "off" and "off" or "hybrid" end
    for category in pairs(imported.reply.categories) do
        imported.reply.categories[category] = boolValue("reply.category." .. category, imported.reply.categories[category])
    end
    imported.livingWorld.enabled = boolValue("living.enabled", imported.livingWorld.enabled)
    imported.livingWorld.group = boolValue("living.group", imported.livingWorld.group)
    imported.livingWorld.nearby = boolValue("living.nearby", imported.livingWorld.nearby)
    if values["living.mode"] then imported.livingWorld.mode = values["living.mode"] == "suggest" and "hybrid" or values["living.mode"] end
    for _, def in ipairs(self.scenarioDefinitions) do
        local cfg = imported.scenarios[def.key]
        local prefix = "scenario." .. def.key .. "."
        if values[prefix .. "mode"] then cfg.mode = values[prefix .. "mode"] == "suggest" and "automatic" or values[prefix .. "mode"] end
        if tonumber(values[prefix .. "chance"]) then cfg.chance = tonumber(values[prefix .. "chance"]) end
    end
    imported.schemaVersion = self.schemaVersion
    imported.preset = "imported"
    _G.HCVoiceCharDB = imported
    self.db = _G.HCVoiceCharDB
    self:SanitizeDatabase()
    self:ResetRuntimeState()
    if self.GUI and self.GUI.Refresh then self.GUI:Refresh() end
    return true, "Profile imported for this character."
end

local presetEnabled = {
    quiet = {
        firstDamage = true, lowMana = true, needHealing = true, fleeDanger = true,
        nearDeath = true, partyDeath = true, wipeRecovery = true, playerLevel = true,
        extraEnemy = true, hardAggro = true, hardVictory = true,
    },
    balanced = nil,
}

function HCVoice:ApplyPreset(name)
    local settings = {
        quiet = { frequency = 20, cooldown = 14, reply = false, living = false },
        balanced = { frequency = 45, cooldown = 8, reply = true, living = true },
        classicRP = { frequency = 70, cooldown = 8, reply = true, living = true },
        fullRP = { frequency = 100, cooldown = 6, reply = true, living = true },
    }
    local preset = settings[name]
    if not preset then return false end
    for _, def in ipairs(self.scenarioDefinitions) do
        local cfg = self.db.scenarios[def.key]
        cfg.mode = name == "quiet" and (presetEnabled.quiet[def.key] and "automatic" or "off") or (def.enabled and "automatic" or "off")
        cfg.enabled, cfg.chance, cfg.emote = cfg.mode ~= "off", def.chance, def.emote
    end
    self.db.frequency, self.db.globalCooldown = preset.frequency, preset.cooldown
    self.db.reply.enabled = preset.reply
    self.db.reply.mode = preset.reply and "hybrid" or "off"
    self.db.reply.autoChance = name == "balanced" and 80 or 100
    self.db.livingWorld.enabled = preset.living
    self.db.livingWorld.mode = preset.living and (name == "fullRP" and "auto" or "hybrid") or "off"
    self.db.livingWorld.group, self.db.livingWorld.nearby = preset.living, preset.living
    self.db.livingWorld.frequency = preset.frequency
    self.db.preset = name
    self:ResetRuntimeState()
    if self.LivingWorld then self.LivingWorld:OnWorldChanged() end
    if self.GUI then self.GUI:Refresh() end
    self:Message("preset applied: " .. name)
    return true
end

function HCVoice:GetScenarioDefinitions(page)
    local results = {}
    for _, def in ipairs(self.scenarioDefinitions) do
        if not page or def.page == page then results[#results + 1] = def end
    end
    return results
end

function HCVoice:GetScenarioConfig(key)
    return scenarioConfig(self.db, key)
end

function HCVoice:SetScenarioValue(key, field, value)
    local cfg = self:GetScenarioConfig(key)
    local def = self.scenarioByKey[key]
    if not cfg then return end
    if field == "enabled" then
        cfg.enabled = value == true
        cfg.mode = cfg.enabled and ((def and def.defaultMode) or "automatic") or "off"
    elseif field == "mode" and (value == "automatic" or value == "manual" or value == "off") then
        cfg.mode = value
        cfg.enabled = value ~= "off"
    elseif field == "chance" then cfg.chance = round(clamp(value, 0, 100))
    elseif field == "emote" and (value == "AUTO" or self.voiceByToken[value]) then cfg.emote = value end
end

function HCVoice:ResolveAutoEmote()
    return "CHARGE"
end

function HCVoice:GetEffectiveTargetCooldown(def)
    if def.key == "greetPlayer" then
        return self.db.advanced.socialTargetCooldownMinutes * 60
    end
    return def.targetCooldown or 0
end

function HCVoice:CanRequest(def, cfg, targetKey, context)
    if not self.db.enabled or not cfg or not cfg.enabled or cfg.mode == "off" or cfg.mode == "manual" then return false end
    context = context or {}
    local t = now()

    if not context.force then
        local lastScenario = self.state.lastScenarioAt[def.key] or -math.huge
        -- Each buff giver is a separate interaction; only that giver's repeat
        -- cooldown may suppress their thanks.
        if not (def.key == "thankBuff" and targetKey) and t - lastScenario < (def.cooldown or 0) then return false end

        if targetKey then
            local key = def.key .. ":" .. tostring(targetKey)
            local lastTarget = self.state.lastTargetAt[key] or -math.huge
            if t - lastTarget < self:GetEffectiveTargetCooldown(def) then return false end
        end

        local chance = cfg.chance or def.chance or 100
        if not def.essential then chance = chance * (self.db.frequency / 100) end
        if (math.random() * 100) > chance then return false end
    end
    return true
end

function HCVoice:RequestReaction(key, targetName, targetKey, context)
    if key == "hardVictory" and self.Bosses and self.Bosses:OwnsVictory(targetKey, targetName) then return false end
    local def = self.scenarioByKey[key]
    local cfg = self:GetScenarioConfig(key)
    if not def or not cfg then return false end
    context = context or {}
    if not self:CanRequest(def, cfg, targetKey, context) then
        self:RecordDecision(key, "skipped", "disabled, cooldown or frequency")
        return false
    end

    local token = cfg.emote == "AUTO" and self:ResolveAutoEmote() or cfg.emote
    if def.variants then
        if self.LivingWorld and self.LivingWorld.SelectVariant then
            token = self.LivingWorld:SelectVariant(def.variants, token)
        else
            local eligible, totalWeight = {}, 0
            for _, variant in ipairs(def.variants) do
                if self:IsVoiceAvailable(variant.token) and (not variant.groupOnly or (IsInGroup and IsInGroup())) then
                    local weight = math.max(0, tonumber(variant.weight) or 0)
                    totalWeight = totalWeight + weight
                    eligible[#eligible + 1] = { token = variant.token, ceiling = totalWeight }
                end
            end
            if totalWeight > 0 then
                local roll = math.random() * totalWeight
                for _, variant in ipairs(eligible) do
                    if roll <= variant.ceiling then token = variant.token; break end
                end
            end
        end
    end
    if not self:IsVoiceAvailable(token) then return false end

    local reaction = {
        scenario = key,
        token = token,
        targetName = targetName,
        targetKey = targetKey,
        targetUnit = context.targetUnit,
        priority = context.priority or def.priority or 0,
        requestedAt = now(),
        expiresAt = context.expiresIn and now() + context.expiresIn or nil,
        subjectName = context.subjectName,
        momentKey = context.momentKey,
        force = context.force == true,
        validate = context.validate,
        helpHealth = context.helpHealth,
    }

    if key == "hardVictory" then reaction.subjectName = targetName; reaction.targetName = nil end
    if key == "idleYawn" or key == "partyJoke" then reaction.targetName = nil end
    return self:EnqueueReaction(reaction)
end

function HCVoice:RequestReactionAfter(key, targetName, targetKey, minimumDelay, maximumDelay, context)
    if not C_Timer or not C_Timer.After then return self:RequestReaction(key, targetName, targetKey, context) end
    minimumDelay = math.max(0, tonumber(minimumDelay) or 0)
    maximumDelay = math.max(minimumDelay, tonumber(maximumDelay) or minimumDelay)
    local delay = minimumDelay + math.random() * (maximumDelay - minimumDelay)
    local state = self.state
    C_Timer.After(delay, function()
        if self.state == state then self:RequestReaction(key, targetName, targetKey, context) end
    end)
    return true
end



function HCVoice:MarkReactionPlayed(reaction)
    local t = now()
    if reaction.scenario == "manual" and reaction.targetName then
        self:RecordManualSocialReply(reaction.targetName, reaction.token, reaction.category)
    end
    self.state.lastAnyEmoteAt = t
    if reaction.momentKey then self.state.moments[reaction.momentKey] = t end
    if reaction.conversationKey then self.state.reply.lastReplyAt[reaction.conversationKey] = t end
    if reaction.targetName then
        self.state.reply.lastOutgoingAt[self:ConversationKey(reaction.targetName, reaction.category, reaction.token)] = t
    end
    if reaction.targetName and (reaction.scenario == "reply" or reaction.scenario == "manual" or reaction.suppressLivingWorld) then
        self.state.reply.lastOutgoingAt[socialNameKey(reaction.targetName)] = t
    end
    self.state.lastScenarioAt[reaction.scenario] = t
    if reaction.targetKey then
        self.state.lastTargetAt[reaction.scenario .. ":" .. tostring(reaction.targetKey)] = t
    end
    if reaction.targetName then self:MarkOutgoingSocial(reaction.targetName, reaction.scenario, reaction.targetKey) end
    if self.LivingWorld and self.LivingWorld.OnReactionPlayed then self.LivingWorld:OnReactionPlayed(reaction) end
    if self.OnSituationPlayed then self:OnSituationPlayed(reaction) end
    if self.Bosses then self.Bosses:OnPlayed(reaction) end
end

function HCVoice:PerformToken(token, targetName, allowRestricted, targetUnit)
    if not self:IsVoiceAvailable(token) then return false end
    if targetUnit then
        -- Resolve an explicit unit at playback; a missing pet must never use
        -- the player's selected target or a stale saved name.
        if not UnitExists(targetUnit) then return false end
        targetName = getUnitName(targetUnit)
        if not targetName or targetName == "" then return false end
    end
    local ok, result
    if not allowRestricted and C_ChatInfo and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown() then
        return false
    end
    if C_ChatInfo and C_ChatInfo.PerformEmote then
        ok, result = pcall(C_ChatInfo.PerformEmote, token, targetName, true)
        if not ok then return false end
        -- Classic Era can return false even though the emote was accepted and
        -- printed. Lockdown is checked above, so a successful call counts once.
        return true
    elseif DoEmote then
        local unit = targetUnit or (targetName and self:FindFriendlyPlayerUnit(targetName) or nil)
        ok, result = pcall(DoEmote, token, unit)
        if not ok then return false end
        -- DoEmote returns true when the token is restricted. False or nil means
        -- the normal emote path was accepted, so do not treat false as failure.
        return result ~= true
    else
        return false
    end
end



function HCVoice:PlayVoice(token, useTarget)
    token = string.upper(tostring(token or ""))
    if not self.voiceByToken[token] then
        self:Message("unknown voice: " .. token)
        return false
    end
    if not self:IsVoiceAvailable(token) then
        self:Message(token .. " has a voice only for " .. self.voiceByToken[token].race .. ".")
        return false
    end
    local targetName = useTarget and getUnitName("target") or nil
    local reaction = { scenario = "manual", token = token, targetName = targetName, requestedAt = now(), expiresAt = now() + 30, force = true }
    local success = self:PerformToken(token, targetName, true)
    if success then self:MarkReactionPlayed(reaction); self:RecordDecision(reaction, "attempted", "manual voice") end
    return success
end

function HCVoice:PlayResponse(token, targetName)
    token = string.upper(tostring(token or ""))
    if not self.voiceByToken[token] then return false end
    local reaction = { scenario = "reply", token = token, targetName = targetName, requestedAt = now(), expiresAt = now() + 30, force = true }
    local success = self:PerformToken(token, targetName, true)
    if success then
        self:MarkReactionPlayed(reaction)
    end
    return success
end

function HCVoice:PlayerManaPercent()
    local manaType = Enum and Enum.PowerType and Enum.PowerType.Mana or 0
    return percent(UnitPower("player", manaType), UnitPowerMax("player", manaType)) * 100
end

function HCVoice:UnitHealthPercent(unit)
    return percent(UnitHealth(unit), UnitHealthMax(unit)) * 100
end

function HCVoice:InitializeUnitState()
    if not self.state then return end
    local mana = self:PlayerManaPercent()
    local hp = self:UnitHealthPercent("player")
    local t = self.db and self.db.thresholds or defaults.thresholds
    self.state.manaArmed = mana > t.mana
    self.state.healthArmed.healing = hp > t.healing
    self.state.healthArmed.flee = hp > t.flee
    if self.HandlePetState then self:HandlePetState(true) end
    if self.RefreshPetCommandState then self:RefreshPetCommandState(true) end
    if self.HandleManaBreak then self:HandleManaBreak(true) end
end

function HCVoice:HandleMana(unit, powerType)
    if unit ~= "player" or (powerType and powerType ~= "MANA") then return end
    self:HandleManaBreak()
    local maximum = UnitPowerMax("player", Enum and Enum.PowerType and Enum.PowerType.Mana or 0)
    if not maximum or maximum <= 0 then return end
    local mana = self:PlayerManaPercent()
    local cfg = self:GetScenarioConfig("lowMana")

    local relevantContext = self.state.inCombat or (IsInGroup and IsInGroup())
    local detectable = cfg and cfg.mode == "automatic"
    if detectable and relevantContext and not self:IsAnnouncedManaBreak() and self.state.manaArmed and mana <= self.db.thresholds.mana then
        if self:RequestReaction("lowMana") then self.state.manaArmed = false end
    elseif not self.state.manaArmed and mana >= self.db.thresholds.manaRearm then
        self.state.manaArmed = true
    end
end

function HCVoice:HandlePlayerHealth()
    local current = UnitHealth("player")
    if not current or current <= 0 then return end
    local hp = self:UnitHealthPercent("player")
    local t = self.db.thresholds
    local healingCfg = self:GetScenarioConfig("needHealing")
    local fleeCfg = self:GetScenarioConfig("fleeDanger")
    local healingDetectable = healingCfg and healingCfg.mode == "automatic"
    local fleeDetectable = fleeCfg and fleeCfg.mode == "automatic"

    if self.state.inCombat then
        self.state.combat.lowestHealth = math.min(self.state.combat.lowestHealth or 100, hp)
        self:RecordCombatHealthRecovery()
    end

    if self.state.inCombat and healingDetectable and self.state.healthArmed.healing and hp <= t.healing then
        if self:RequestReaction("needHealing") then self.state.healthArmed.healing = false end
    elseif not self.state.healthArmed.healing and hp >= t.healingRearm then
        self.state.healthArmed.healing = true
    end

    if self.state.inCombat and fleeDetectable and self.state.healthArmed.flee and hp <= t.flee then
        if self:RequestReaction("fleeDanger") then self.state.healthArmed.flee = false end
    elseif not self.state.healthArmed.flee and hp >= t.fleeRearm then
        self.state.healthArmed.flee = true
    end
    if self.state.inCombat then self:TryCombatHelp() end
end

function HCVoice:BuildRosterSnapshot()
    local snapshot = {}
    for _, unit in ipairs(self:GroupUnits()) do
        if UnitExists(unit) and UnitGUID(unit) ~= UnitGUID("player") then
            local guid = UnitGUID(unit) or getUnitName(unit) or unit
            snapshot[guid] = {
                guid = guid,
                unit = unit,
                name = getUnitName(unit),
                level = UnitLevel(unit) or 0,
                alive = isAlive(unit),
                joinedAt = now(),
            }
        end
    end
    return snapshot
end

function HCVoice:SayPartyFarewell(member)
    if not self.db.enabled or not member or not member.name then return false end
    for i = #self.state.reactionQueue, 1, -1 do
        local pending = self.state.reactionQueue[i]
        if pending.scenario == "welcomeParty" and pending.targetKey == member.guid then
            table.remove(self.state.reactionQueue, i)
            self:RecordDecision(pending, "skipped", "member already left the party")
        end
    end
    -- Every observed departure gets exactly BYE. This event does not enter the
    -- social queue, roll chance, require encounter age or wait for cooldowns.
    local reaction = { scenario = "farewellParty", token = "BYE", targetName = member.name, targetKey = member.guid }
    local success = self:PerformToken("BYE", member.name)
    if success then self:MarkReactionPlayed(reaction) end
    self:RecordDecision(reaction, success and "attempted" or "blocked", success and "party departure; emote API call completed; audio unconfirmed" or "client did not allow the call")
    return success
end

function HCVoice:RefreshRoster(suppressReactions)
    local old = self.state.roster or {}
    local fresh = self:BuildRosterSnapshot()
    local mayReact = self.state.rosterInitialized and not suppressReactions and now() >= (self.state.suppressRosterUntil or 0)

    if mayReact then
        for guid, member in pairs(fresh) do
            if old[guid] then
                member.joinedAt = old[guid].joinedAt or now()
            else
                self:RequestReaction("welcomeParty", member.name, guid)
            end
        end
    else
        for guid, member in pairs(fresh) do
            if old[guid] then member.joinedAt = old[guid].joinedAt or now() end
        end
    end

    if self.state.rosterInitialized and not suppressReactions then
        for guid, member in pairs(old) do
            if not fresh[guid] then self:SayPartyFarewell(member) end
        end
    end

    self.state.roster = fresh
    self.state.rosterInitialized = true
end

function HCVoice:HandlePartyHealth(unit)
    if type(unit) ~= "string" or not (unit:match("^party%d+$") or unit:match("^raid%d+$")) or not UnitExists(unit) or UnitGUID(unit) == UnitGUID("player") then return end
    local guid = UnitGUID(unit) or getUnitName(unit) or unit
    local member = self.state.roster[guid]
    local alive = isAlive(unit)
    if member and member.alive and not alive then
        self.state.somberUntil = now() + 30
        self:RequestReactionAfter("partyDeath", member.name, guid, 0.25, 1.4)
    end
    if not member then
        member = { guid = guid, unit = unit, name = getUnitName(unit), level = UnitLevel(unit) or 0 }
        self.state.roster[guid] = member
    end
    member.alive = alive
    member.unit = unit
end

function HCVoice:IsFullPartyWipe()
    if not (IsInGroup and IsInGroup()) or not UnitIsDeadOrGhost or not UnitIsDeadOrGhost("player") then return false end
    local members = 0
    for _, unit in ipairs(self:GroupUnits()) do
        if UnitExists(unit) then
            members = members + 1
            if not UnitIsDeadOrGhost(unit) then return false end
        end
    end
    return members > 0
end

function HCVoice:HandlePlayerDeath()
    if not C_Timer or not C_Timer.After then return end
    local state = self.state
    C_Timer.After(1.2, function()
        if self.state == state and self:IsFullPartyWipe() then state.wipePending = true end
    end)
end

function HCVoice:HandlePlayerRecovered()
    if UnitIsDeadOrGhost("player") then return end
    local resurrection = self.state.pendingResurrection
    if resurrection then
        self.state.pendingResurrection = nil
        if now() - (resurrection.at or 0) <= 120 then
            self:RequestReactionAfter("thankResurrection", resurrection.name, resurrection.guid, 0.6, 1.6)
            self:EstablishSocialSession(resurrection.guid, resurrection.name, "resurrection")
        end
    end
    if not self.state.wipePending then return end
    self.state.wipePending = false
    local state = self.state
    C_Timer.After(2.0, function()
        if self.state == state and not UnitIsDeadOrGhost("player") then self:RequestReaction("wipeRecovery") end
    end)
end

function HCVoice:HandleUnitLevel(unit)
    if type(unit) ~= "string" or not (unit:match("^party%d+$") or unit:match("^raid%d+$")) or not UnitExists(unit) or UnitGUID(unit) == UnitGUID("player") then return end
    local guid = UnitGUID(unit) or getUnitName(unit) or unit
    local level = UnitLevel(unit) or 0
    local member = self.state.roster[guid]
    if member and level > (member.level or 0) then
        self:RequestReactionAfter("partyLevel", member.name, guid, 0.2, 1.5)
    end
    if not member then
        member = { guid = guid, name = getUnitName(unit), alive = isAlive(unit) }
        self.state.roster[guid] = member
    end
    member.level = level
    member.unit = unit
end

function HCVoice:IsHardTarget(unit)
    if not UnitExists(unit) or not UnitCanAttack("player", unit) then return false end
    local classification = UnitClassification(unit)
    if isHardClassification(classification) then return true end
    local targetLevel = UnitLevel(unit) or 0
    local playerLevel = UnitLevel("player") or 0
    return targetLevel > 0 and playerLevel > 0 and targetLevel >= playerLevel + self.db.advanced.hardLevelDelta
end

function HCVoice:IsEliteTarget(unit)
    if not UnitExists(unit) or not UnitCanAttack("player", unit) or UnitIsDeadOrGhost(unit) then return false end
    return isHardClassification(UnitClassification(unit))
end

function HCVoice:IsGreetingPlayerTarget(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) then return false end
    if UnitIsDeadOrGhost("player") or UnitIsDeadOrGhost(unit) then return false end
    if isPlayerGroupUnit(unit) then return false end
    if UnitCanAttack and UnitCanAttack("player", unit) then return false end
    return true
end

function HCVoice:GetSocialEncounter(targetKey, targetName, create)
    if not self.state or not self.state.social then return nil end
    local aliases = self.state.social.aliases or {}
    self.state.social.aliases = aliases
    local name = socialNameKey(targetName)
    local key = aliases[name] or targetKey or name
    if name ~= "" then aliases[name] = key end
    if not key or key == "" then return nil end
    local encounter = self.state.social.encounters[key]
    if not encounter and create then
        encounter = { key = key, name = normalizeSocialName(targetName), createdAt = now(), lastInteractionAt = now() }
        self.state.social.encounters[key] = encounter
    end
    if encounter and targetName then encounter.name = normalizeSocialName(targetName) or encounter.name end
    return encounter
end

function HCVoice:TouchSocialEncounter(targetKey, targetName, reason)
    local encounter = self:GetSocialEncounter(targetKey, targetName, true)
    if not encounter then return nil end
    encounter.established = true
    encounter.lastInteractionAt = now()
    encounter.lastReason = reason
    encounter.closed = false
    if reason == "greet" then encounter.greeted = true end
    return encounter
end

function HCVoice:EstablishSocialSession(guid, name, reason)
    return self:TouchSocialEncounter(guid, name, reason or "interaction")
end

function HCVoice:MarkOutgoingSocial(targetName, scenario, targetKey)
    local key = targetKey or socialNameKey(targetName)
    local replyKey = socialNameKey(targetName)
    if self.state.reply and socialOutgoingScenarios[scenario] and replyKey ~= "" then
        self.state.reply.lastOutgoingAt[replyKey] = now()
    end
    if scenario == "socialFarewell" then
        local encounter = self:GetSocialEncounter(key, targetName, false)
        if encounter then
            encounter.closed = true
            encounter.farewellAt = now()
            encounter.lastInteractionAt = now()
        end
    elseif socialOutgoingScenarios[scenario] then
        self:TouchSocialEncounter(key, targetName, scenario == "greetPlayer" and "greet" or scenario)
    end
end

function HCVoice:FindFriendlyPlayerUnit(targetName, targetKey)
    local candidates = { "target", "mouseover", "focus" }
    for i = 1, 4 do candidates[#candidates + 1] = "party" .. i end
    for i = 1, 40 do candidates[#candidates + 1] = "raid" .. i end
    local wantedName = socialNameKey(targetName)
    for _, unit in ipairs(candidates) do
        if UnitExists(unit) and UnitIsPlayer(unit) and UnitIsFriend("player", unit) then
            local guid = UnitGUID(unit)
            local name = socialNameKey(getUnitName(unit))
            if (targetKey and guid and tostring(guid) == tostring(targetKey)) or (wantedName ~= "" and name == wantedName) then
                return unit
            end
        end
    end
end

function HCVoice:IsFriendlyFemalePlayer(targetName, targetKey)
    local unit = self:FindFriendlyPlayerUnit(targetName, targetKey)
    return unit ~= nil and UnitSex and UnitSex(unit) == 3
end

function HCVoice:EndPlayerTargetSession()
    local social = self.state and self.state.social
    if not social or not social.targetSession then return end
    local state = self.state
    local session = social.targetSession
    social.targetSession = nil
    social.targetGeneration = (social.targetGeneration or 0) + 1

    local encounter = self:GetSocialEncounter(session.key, session.name, false)
    local heldSeconds = now() - (session.startedAt or now())
    if state.inCombat or UnitIsDeadOrGhost("player") or not encounter or not encounter.established or encounter.closed then return end
    if heldSeconds < self.db.advanced.minimumEncounterSeconds then return end
    if now() - (encounter.lastInteractionAt or 0) > self.db.advanced.encounterMemorySeconds then return end

    local generation = social.targetGeneration
    C_Timer.After(math.max(2, self.db.advanced.farewellDelaySeconds), function()
        if self.state ~= state or not state.social or state.social.targetGeneration ~= generation then return end
        if state.inCombat or UnitIsDeadOrGhost("player") then return end
        if UnitExists("target") and UnitGUID("target") == session.key then return end
        local current = self:GetSocialEncounter(session.key, session.name, false)
        if not current or current.closed or not current.established then return end
        if now() - (current.lastInteractionAt or 0) > self.db.advanced.encounterMemorySeconds then return end

        -- Close the encounter even when BYE loses its intentional chance roll;
        -- otherwise later target changes would repeatedly attempt the same farewell.
        current.closed = true
        current.endedAt = now()
        current.lastInteractionAt = now()
        self:RequestReaction("socialFarewell", session.name, session.key, {
            validate = function()
                if self.state ~= state or state.inCombat or UnitIsDeadOrGhost("player") then return false end
                if UnitExists("target") and UnitGUID("target") == session.key then return false end
                local active = self:GetSocialEncounter(session.key, session.name, false)
                return active ~= nil and active.established == true and active.closed == true and active.farewellAt == nil
            end,
        })
    end)
end

function HCVoice:CancelPlayerTargetSession()
    local social = self.state and self.state.social
    if not social then return end
    social.targetSession = nil
    social.targetGeneration = (social.targetGeneration or 0) + 1
end

function HCVoice:BeginPlayerTargetSession(targetKey, targetName)
    if isPlayerGroupUnit("target") then return end
    local social = self.state.social
    self:EndPlayerTargetSession()
    social.targetGeneration = (social.targetGeneration or 0) + 1
    local generation = social.targetGeneration
    local state = self.state
    social.targetSession = { key = targetKey, name = normalizeSocialName(targetName), startedAt = now(), generation = generation }

    C_Timer.After(self.db.advanced.greetingDelaySeconds, function()
        if self.state ~= state or not state.social then return end
        local session = state.social.targetSession
        if not session or session.generation ~= generation or session.key ~= targetKey then return end
        if state.inCombat or UnitIsDeadOrGhost("player") then return end
        if not UnitExists("target") or UnitGUID("target") ~= targetKey then return end
        if not self:IsGreetingPlayerTarget("target") then return end
        local encounter = self:GetSocialEncounter(targetKey, session.name, false)
        if encounter and encounter.established and not encounter.closed and now() - encounter.lastInteractionAt < self.db.advanced.encounterMemorySeconds then return end
        self:RequestReaction("greetPlayer", session.name, targetKey, {
            validate = function()
                return self.state == state
                    and not state.inCombat
                    and not UnitIsDeadOrGhost("player")
                    and UnitExists("target")
                    and UnitGUID("target") == targetKey
                    and self:IsGreetingPlayerTarget("target")
            end,
        })
    end)
end

function HCVoice:HandleTargetChanged()
    self.state.lastActivityAt = now()
    local guid = UnitExists("target") and UnitGUID("target") or nil
    local currentSession = self.state.social and self.state.social.targetSession or nil
    if currentSession and currentSession.key ~= guid then self:EndPlayerTargetSession() end
    if not UnitExists("target") or UnitIsDeadOrGhost("player") then return end

    local targetGUID, name = targetIdentity("target")
    if not targetGUID or not UnitIsPlayer("target") then return end
    if isPlayerGroupUnit("target") then
        if self.state.social.targetSession and self.state.social.targetSession.key == targetGUID then
            self:CancelPlayerTargetSession()
        end
        return
    end
    if self:IsGreetingPlayerTarget("target") and not self.state.inCombat then
        if not self.state.social.targetSession or self.state.social.targetSession.key ~= targetGUID then
            self:BeginPlayerTargetSession(targetGUID, name)
        end
    end
end

function HCVoice:StartCombat()
    if self.state.inCombat then return end
    self:EndPlayerTargetSession()
    self.state.inCombat = true
    self.state.lastActivityAt = now()
    local guid, name = targetIdentity("target")
    local hard = self:IsHardTarget("target")
    self.state.combat = {
        startedAt = now(),
        lowestHealth = self:UnitHealthPercent("player"),
        hardTargetGUID = hard and guid or nil,
        hardTargetName = hard and name or nil,
        hardTargetKilled = false,
        boss = UnitExists("target") and (UnitClassification("target") == "worldboss" or UnitLevel("target") == -1),
        enemies = {},
        incomingAnnounced = false,
        hardAggroAnnounced = false,
        firstDamageAnnounced = false,
        pressureEvents = {},
        observedHealth = UnitHealth("player"),
        externalHealing = 0,
        helperGUID = nil,
        helperName = nil,
    }
end

-- Keep a short damage/recovery history: steady healing must not make an
-- otherwise controlled fight look like an escalating damage burst.
function HCVoice:RecordCombatPressure(amount)
    local events = self.state.combat.pressureEvents
    events[#events + 1] = { at = now(), amount = amount }
    while #events > 64 do table.remove(events, 1) end
end

function HCVoice:RecordCombatHealthRecovery()
    local combat = self.state.combat
    local current = UnitHealth("player") or 0
    if combat.observedHealth and current > combat.observedHealth then
        self:RecordCombatPressure(-(current - combat.observedHealth))
    end
    combat.observedHealth = current
end

function HCVoice:GetRecentCombatPressure()
    local events = self.state.combat.pressureEvents or {}
    local pressure = 0
    for i = #events, 1, -1 do
        if now() - events[i].at > 4 then table.remove(events, i) end
    end
    for _, event in ipairs(events) do pressure = math.max(0, pressure + event.amount) end
    return pressure
end

function HCVoice:IsCombatHelpNeeded()
    if not self.state.inCombat then return false end
    local hp = self:UnitHealthPercent("player")
    return hp > self.db.thresholds.healing and hp <= 75
        and self:GetRecentCombatPressure() >= (UnitHealthMax("player") or 0) * 0.20
end

function HCVoice:TryCombatHelp()
    local combat = self.state.combat
    if combat.firstDamageAnnounced or not self:IsCombatHelpNeeded() then return end
    combat.firstDamageAnnounced = self:RequestReaction("firstDamage", nil, nil, {
        helpHealth = self:UnitHealthPercent("player"),
    })
end

function HCVoice:GetActiveCombatEnemyCount()
    local count = 0
    for _ in pairs(self.state.combat.enemies or {}) do count = count + 1 end
    return count
end

function HCVoice:RecordExternalHealing(sourceGUID, sourceName, amount, overhealing)
    if not self.state.inCombat or not sourceGUID or sourceGUID == UnitGUID("player") then return end
    amount = math.max(0, (tonumber(amount) or 0) - (tonumber(overhealing) or 0))
    if amount == 0 then return end
    local combat = self.state.combat
    combat.healers = combat.healers or {}
    local helper = combat.healers[sourceGUID] or { total = 0 }
    helper.total, helper.name = helper.total + amount, sourceName
    combat.healers[sourceGUID] = helper
    if not combat.helperGUID or helper.total > (combat.bestHealing or 0) then
        combat.helperGUID, combat.helperName, combat.bestHealing = sourceGUID, sourceName, helper.total
    end
end

function HCVoice:RecordCombatAssist(sourceGUID, sourceName, amount)
    if not self.state.inCombat or not sourceGUID or sourceGUID == UnitGUID("player") or guidIsGroupMember(sourceGUID) then return end
    amount = math.max(0, tonumber(amount) or 0)
    local combat = self.state.combat
    combat.externalAssist = combat.externalAssist or {}
    local helper = combat.externalAssist[sourceGUID]
    if not helper then
        helper = { guid = sourceGUID, name = sourceName, damage = 0, hits = 0 }
        combat.externalAssist[sourceGUID] = helper
    end
    helper.name = sourceName or helper.name
    helper.damage = helper.damage + amount
    helper.hits = helper.hits + 1
end

function HCVoice:GetMeaningfulCombatAssistant(combat, maxHealth)
    local best
    for _, helper in pairs(combat.externalAssist or {}) do
        local meaningful = helper.hits >= 2 or helper.damage >= math.max(5, (maxHealth or 0) * 0.10)
        if meaningful and helper.name and (not best or helper.damage > best.damage or (helper.damage == best.damage and helper.hits > best.hits)) then
            best = helper
        end
    end
    return best
end

function HCVoice:RecordEnemy(sourceGUID, sourceName)
    if not self.state.inCombat or not sourceGUID then return end
    local combat = self.state.combat
    local isNew = not combat.enemies[sourceGUID]
    if isNew then combat.enemies[sourceGUID] = sourceName or true end

    if not combat.hardTargetGUID and UnitExists("target") and UnitGUID("target") == sourceGUID and self:IsHardTarget("target") then
        combat.hardTargetGUID = sourceGUID
        combat.hardTargetName = sourceName
    end

    if not combat.hardAggroAnnounced and sourceGUID == combat.hardTargetGUID then
        local accepted = self:RequestReaction("hardAggro", sourceName, sourceGUID)
        combat.hardAggroAnnounced = accepted
        combat.incomingAnnounced = accepted
    end
    if combat.incomingAnnounced then return end
    local count = self:GetActiveCombatEnemyCount()
    if isNew and count >= 2 then
        combat.incomingAnnounced = self:RequestReaction("extraEnemy", sourceName, sourceGUID)
    end
end

function HCVoice:EndCombat()
    if not self.state.inCombat then return end
    local combat = self.state.combat
    local duration = now() - (combat.startedAt or now())
    local survived = UnitHealth("player") > 0
    self.state.inCombat = false

    for index = #self.state.reactionQueue, 1, -1 do
        if combatOnlyScenarios[self.state.reactionQueue[index].scenario] then
            table.remove(self.state.reactionQueue, index)
        end
    end

    if survived then
        local maxHealth = UnitHealthMax("player") or 0
        local healThreshold = maxHealth * (self.db.advanced.healerThanksPercent / 100)
        if combat.helperGUID and (combat.bestHealing or 0) >= healThreshold then
            self:RequestReaction("thankHealer", combat.helperName, combat.helperGUID)
        end
        local assistant = duration >= 2 and self:GetMeaningfulCombatAssistant(combat, maxHealth) or nil
        if assistant and assistant.guid ~= combat.helperGUID then
            self:RequestReactionAfter("thankAssist", assistant.name, assistant.guid, 0.5, 1.8)
            self:EstablishSocialSession(assistant.guid, assistant.name, "combat assist")
        end
        if combat.hardTargetKilled and (combat.boss or not (IsInInstance and IsInInstance()) or duration >= self.db.advanced.hardFightSeconds * 2 or (combat.lowestHealth or 100) <= self.db.thresholds.healing) then
            self:RequestReactionAfter("hardVictory", combat.hardTargetName, combat.hardTargetGUID, 0.2, 1.8)
        end
        if duration >= self.db.advanced.hardFightSeconds and (combat.lowestHealth or 100) <= self.db.thresholds.flee then
            self:RequestReaction("nearDeath")
        end
    end

    self.state.combat = {}
end

local function combatLogDamageAmount(info, subEvent)
    if subEvent == "SWING_DAMAGE" then return tonumber(info[12]) or 0 end
    if damageSubEvents[subEvent] then return tonumber(info[15]) or 0 end
    return 0
end

function HCVoice:HandleCombatLog()
    if not CombatLogGetCurrentEventInfo then return end
    local info = { CombatLogGetCurrentEventInfo() }
    if self.Bosses then self.Bosses:OnCombatLog(info) end
    local subEvent = info[2]
    local sourceGUID, sourceName, sourceFlags = info[4], info[5], info[6]
    local destGUID, destName, destFlags = info[8], info[9], info[10]
    local playerGUID = UnitGUID("player")
    local petGUID = UnitGUID("pet")
    if subEvent == "UNIT_DIED" then
        self:HandlePetDeath(destGUID)
        if self.state.inCombat and destGUID then self.state.combat.enemies[destGUID] = nil end
    end



    if subEvent == "SPELL_RESURRECT" and destGUID == playerGUID and sourceGUID ~= playerGUID and isFriendlyPlayerFlags(sourceFlags) then
        self.state.pendingResurrection = { guid = sourceGUID, name = sourceName, at = now() }
    end

    if (subEvent == "SPELL_HEAL" or subEvent == "SPELL_PERIODIC_HEAL") and destGUID == playerGUID and isFriendlyPlayerFlags(sourceFlags) then
        self:RecordExternalHealing(sourceGUID, sourceName, info[15], info[16])
    elseif subEvent == "SPELL_AURA_APPLIED" and destGUID == playerGUID and sourceGUID ~= playerGUID and isFriendlyPlayerFlags(sourceFlags) and not self.state.inCombat and isImportantDirectBuff(info[13]) then
        self:RequestReactionAfter("thankBuff", sourceName, sourceGUID, 0.5, 0.5)
        self:EstablishSocialSession(sourceGUID, sourceName, "buff")
    elseif subEvent == "SPELL_AURA_APPLIED" and sourceGUID == playerGUID and destGUID ~= playerGUID and isFriendlyPlayerFlags(destFlags) then
        -- A target selected for buffing is not an invitation to start talking.
        local session = self.state.social.targetSession
        if session and session.key == destGUID then self:CancelPlayerTargetSession() end
        for i = #self.state.reactionQueue, 1, -1 do
            local queued = self.state.reactionQueue[i]
            if queued.scenario == "greetPlayer" and queued.targetKey == destGUID then
                self:RecordDecision(queued, "skipped", "target selected for buffing")
                table.remove(self.state.reactionQueue, i)
            end
        end
    end

    local hostileNPC = isHostileNPCFlags(sourceFlags)
    local hostilePlayer = isHostilePlayerFlags(sourceFlags)
    local damagesPlayer = destGUID == playerGUID or (petGUID and destGUID == petGUID)
    local attacksGroup = (hostileNPC or hostilePlayer) and guidIsGroupMember(destGUID)
    if damageSubEvents[subEvent] and (damagesPlayer or attacksGroup) and (hostileNPC or hostilePlayer) then
        if not self.state.inCombat and damagesPlayer then self:StartCombat() end
        if self.state.inCombat then
            self:RecordEnemy(sourceGUID, sourceName)
            local amount = combatLogDamageAmount(info, subEvent)
            if destGUID == playerGUID and directDamageSubEvents[subEvent] then
                local maxHealth = UnitHealthMax("player") or 0
                local meaningful = amount >= math.max(1, maxHealth * 0.02)
                self:RecordCombatHealthRecovery()
                self:RecordCombatPressure(amount)
                self:TryCombatHelp()
                if meaningful and not self.state.combat.openingHitObserved then
                    self.state.combat.openingHitObserved = true
                    if maxHealth > 0 and amount >= maxHealth * 0.35 then
                        self:RequestReaction("hugeHit", sourceName, sourceGUID)
                    end
                end
            end
        end
    elseif damageSubEvents[subEvent] and self.state.inCombat and sourceGUID ~= playerGUID and isFriendlyPlayerFlags(sourceFlags) and isHostileNPCFlags(destFlags) then
        local combat = self.state.combat
        local currentTargetGUID = UnitExists("target") and UnitGUID("target") or nil
        if destGUID == combat.hardTargetGUID or destGUID == currentTargetGUID or combat.enemies[destGUID] then
            self:RecordCombatAssist(sourceGUID, sourceName, combatLogDamageAmount(info, subEvent))
        end
    elseif subEvent == "UNIT_DIED" and self.state.inCombat and destGUID and destGUID == self.state.combat.hardTargetGUID then
        self.state.combat.hardTargetKilled = true
    end
end

function HCVoice:ShowReplyPrompt(data)
    if self.GUI and self.GUI.ShowReplyPrompt then return self.GUI:ShowReplyPrompt(data) end
    return false
end

function HCVoice:OfferReplyPrompt(data, force)
    if not data or not data.playerKey or data.needsSuggestion ~= true then return false end
    local lastPrompt = self.state.reply.lastPromptAt[data.playerKey] or -math.huge
    if not force and now() - lastPrompt < self.db.reply.promptCooldown then return false end
    local shown = self:ShowReplyPrompt(data)
    if shown then self.state.reply.lastPromptAt[data.playerKey] = now() end
    return shown
end

function HCVoice:ExecuteSuggestedReply(token, sender, playerKey)
    token = string.upper(tostring(token or ""))
    if not self.voiceByToken[token] then return false end
    if token == "FLIRT" or token == "KISS" or token == "HUG" then
        if not self:FindFriendlyPlayerUnit(sender, playerKey) then return false end
        if token ~= "HUG" and not self:IsFriendlyFemalePlayer(sender, playerKey) then return false end
    end
    local success = self:PerformToken(token, sender, true)
    if success then
        self:RecordManualSocialReply(sender, token)
        local t = now()
        local nameKey = socialNameKey(sender)
        local key = playerKey or nameKey
        if key and key ~= "" then
            self.state.reply.lastReplyAt[key] = t
            self.state.reply.lastOutgoingAt[key] = t
        end
        if nameKey ~= "" then
            self.state.reply.lastReplyAt[nameKey] = t
            self.state.reply.lastOutgoingAt[nameKey] = t
        end
        self:TouchSocialEncounter(key, sender, "reply")
        self.state.lastAnyEmoteAt = t
        self:MarkReactionPlayed({ scenario = "reply", token = token, targetName = sender, targetKey = playerKey })
        self:RecordDecision("reply", "attempted", "player chose /" .. token:lower())
    else
        self:Message("Blizzard blocked /" .. string.lower(token) .. "; try again out of combat")
    end
    return success
end

function HCVoice:GetContextualReplyOptions(classification, sender, playerKey)
    local options = shallowCopy(classification.options or {})
    if classification.incomingToken == "WHISTLE" then
        options = { "WHISTLE", "LAUGH", "NOD", "NO" }
    elseif classification.category == "requests" then
        local lowMana = self:PlayerManaPercent() <= self.db.thresholds.mana
        local busy = (UnitCastingInfo and UnitCastingInfo("player")) or (UnitChannelInfo and UnitChannelInfo("player"))
        if lowMana or busy then options = { "WAIT", "NOD", "SALUTE", "HELPME" }
        else options = { "NOD", "WAIT", "SALUTE", "HELPME" } end
    elseif classification.category == "affection" then
        local friendlyUnit = self:FindFriendlyPlayerUnit(sender, playerKey)
        if classification.incomingToken == "HUG" and friendlyUnit then
            options = { "HUG", "NOD", "BOW", "SALUTE" }
        elseif self:IsFriendlyFemalePlayer(sender, playerKey) then
            options = { "FLIRT", "KISS", "NOD", "BOW" }
        else
            options = { "NOD", "BOW", "NO", "SALUTE" }
        end
    end
    local available = {}
    for _, token in ipairs(options) do
        if self:IsVoiceAvailable(token) then available[#available + 1] = token end
    end
    return available
end

function HCVoice:IgnoreReplyPlayer(playerKey, sender)
    if playerKey and playerKey ~= "" then self.state.reply.ignored[playerKey] = true end
    local nameKey = socialNameKey(sender)
    if nameKey ~= "" then self.state.reply.ignored[nameKey] = true end
end

function HCVoice:HandleTradeShow()
    local guid, name = targetIdentity("NPC")
    self.state.trade = guid and name and { guid = guid, name = name, accepted = false } or nil
    self.state.closedTrade = nil
end

function HCVoice:HandleTradeAccept(playerAccepted, targetAccepted)
    local trade = self.state.trade
    if not trade then return end
    trade.accepted = (playerAccepted == 1 or playerAccepted == true) and (targetAccepted == 1 or targetAccepted == true)
    trade.receivedGift = false
    if not trade.accepted then return end
    trade.receivedGift = GetTargetTradeMoney and GetTargetTradeMoney() > 0 or false
    for index = 1, 6 do
        if GetTradeTargetItemInfo and GetTradeTargetItemInfo(index) then trade.receivedGift = true end
    end
end

function HCVoice:HandleTradeClosed()
    local trade = self.state.trade
    if trade then trade.closedAt = now(); self.state.closedTrade = trade end
    self.state.trade = nil
end

function HCVoice:HandleTradeInfo(message)
    if not ERR_TRADE_COMPLETE or message ~= ERR_TRADE_COMPLETE then return end
    local trade = self.state.trade or self.state.closedTrade
    if not trade or trade.completed or not trade.accepted or not trade.receivedGift then return end
    if trade.closedAt and now() - trade.closedAt > 2 then return end
    trade.completed = true
    self:RequestReaction("thankTrade", trade.name, trade.guid)
    self:EstablishSocialSession(trade.guid, trade.name, "trade gift")
end

function HCVoice:HandleReadyCheck(unit, isReady)
    if unit ~= "player" then return end
    if isReady == true or isReady == 1 then self:RequestReaction("readyCheckYes") else self:RequestReaction("readyCheckNo") end
end

local SELF_LOOT_FORMAT_KEYS = {
    "LOOT_ITEM_SELF", "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_CREATED_SELF",
    "LOOT_ITEM_CREATED_SELF_MULTIPLE", "LOOT_ITEM_PUSHED_SELF", "LOOT_ITEM_PUSHED_SELF_MULTIPLE",
}

local function formatStringToPattern(formatString)
    if type(formatString) ~= "string" or formatString == "" then return nil end
    local pattern = formatString:gsub("%%s", "__HCVOICE_STRING__"):gsub("%%d", "__HCVOICE_NUMBER__")
    pattern = pattern:gsub("([%(%)%.%+%-%*%?%[%]%^%$%%])", "%%%1")
    pattern = pattern:gsub("__HCVOICE_STRING__", ".-"):gsub("__HCVOICE_NUMBER__", "%%d+")
    return "^" .. pattern .. "$"
end

function HCVoice:IsSelfLootMessage(message)
    local lower = lowerPlain(message)
    if lower:find("you receive loot", 1, true) or lower:find("you receive item", 1, true) or lower:find("you create", 1, true) then return true end
    for _, key in ipairs(SELF_LOOT_FORMAT_KEYS) do
        local pattern = formatStringToPattern(_G[key])
        if pattern and tostring(message or ""):match(pattern) then return true end
    end
    return false
end

local lootQualityByColor = {
    ["9d9d9d"] = 0, ["ffffff"] = 1, ["1eff00"] = 2,
    ["0070dd"] = 3, ["a335ee"] = 4, ["ff8000"] = 5, ["e6cc80"] = 6,
}

function HCVoice:HandleLootMessage(message)
    if not self:IsSelfLootMessage(message) then return end
    local link = tostring(message or ""):match("(|c%x+|Hitem:.-|h.-|h|r)")
    if not link then return end
    local signature = link .. ":" .. tostring(message)
    if self.state.loot.lastSignature == signature then return end
    self.state.loot.lastSignature = signature
    local color = string.lower(link:match("^|c%x%x(%x%x%x%x%x%x)") or "")
    local quality = lootQualityByColor[color]
    local itemKey = link:match("item:(%d+)") or link
    if quality == 0 then self:RequestReaction("sillyLoot", nil, itemKey)
    elseif quality == 3 then self:RequestReaction("greatLoot", nil, itemKey)
    elseif quality and quality >= 4 then self:RequestReaction("exceptionalLoot", nil, itemKey) end
end

function HCVoice:HandlePartyDistance()
    if not (IsInGroup and IsInGroup()) or not UnitIsGroupLeader or not UnitIsGroupLeader("player") or self.state.inCombat then
        self.state.partyFarSince = nil
        return
    end
    if GetUnitSpeed and GetUnitSpeed("player") > 0 then
        self.state.partyFarSince = nil
        return
    end

    local farName, farKey
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) and isAlive(unit) then
            local inRange
            if UnitInRange then inRange = UnitInRange(unit) end
            if inRange == nil and CheckInteractDistance then inRange = CheckInteractDistance(unit, 4) end
            if inRange == false then
                farKey, farName = targetIdentity(unit)
                break
            end
        end
    end

    if farName then
        self.state.partyFarSince = self.state.partyFarSince or now()
        if now() - self.state.partyFarSince >= self.db.advanced.partyWaitSeconds then
            self:RequestReaction("partyWait", farName, farKey or farName, { validate = function()
                local unit = self:FindFriendlyPlayerUnit(farName, farKey)
                return unit ~= nil and isAlive(unit) and UnitIsGroupLeader("player") and not self.state.inCombat and (not GetUnitSpeed or GetUnitSpeed("player") == 0) and UnitInRange and UnitInRange(unit) == false
            end })
            self.state.partyFarSince = now()
        end
    else
        self.state.partyFarSince = nil
    end
end

function HCVoice:PruneSocialEncounters()
    if not self.state.social then return end
    local cutoff = now() - math.max(600, self.db.advanced.encounterMemorySeconds * 2)
    local activeKey = self.state.social.targetSession and self.state.social.targetSession.key or nil
    for key, encounter in pairs(self.state.social.encounters) do
        if key ~= activeKey and (encounter.lastInteractionAt or encounter.createdAt or 0) < cutoff then
            self.state.social.encounters[key] = nil
        end
    end
end

-- Standing still while casting or while a party member fights is not downtime.
function HCVoice:IsRelaxedMoment(stationary)
    if self.state.inCombat or UnitIsDeadOrGhost("player") or (IsInRaid and IsInRaid()) then return false end
    if (UnitCastingInfo and UnitCastingInfo("player")) or (UnitChannelInfo and UnitChannelInfo("player")) then return false end
    if UnitAffectingCombat and UnitAffectingCombat("player") then return false end
    if stationary and GetUnitSpeed and GetUnitSpeed("player") > 0 then return false end
    if now() < math.max(self.state.somberUntil or 0, self.state.seriousUntil or 0) then return false end
    if IsInGroup and IsInGroup() then
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) and (UnitIsDeadOrGhost(unit) or (UnitAffectingCombat and UnitAffectingCombat(unit))) then return false end
        end
    end
    return true
end

function HCVoice:HandlePartyJoke()
    local inParty = IsInGroup and IsInGroup() and not (IsInRaid and IsInRaid())
    if not inParty or not self:IsRelaxedMoment(false) then
        if not inParty then self.state.nextPartyJokeAt = nil end
        return
    end
    local t = now()
    if not self.state.nextPartyJokeAt then
        self.state.nextPartyJokeAt = t + 300 + math.random() * 240
        return
    end
    if t < self.state.nextPartyJokeAt then return end
    self:RequestReaction("partyJoke")
    self.state.nextPartyJokeAt = t + 600 + math.random() * 300
end

function HCVoice:OnTick()
    if not self.db or not self.state.initialized then return end
    if self.Bosses then self.Bosses:Tick() end
    self:HandleManaBreak()
    self:HandlePetState()
    if self:HasDrinkAura() or not self:IsRelaxedMoment(true) then
        self.state.lastActivityAt = now()
    else
        local idleSeconds = now() - math.max(self.state.lastActivityAt or now(), self.state.lastAnyEmoteAt or 0)
        if idleSeconds >= self.db.advanced.idleMinutes * 60 then
            if self:RequestReaction("idleYawn") and IsInGroup and IsInGroup() then
                self.state.nextPartyJokeAt = math.max(self.state.nextPartyJokeAt or 0, now() + 300)
            end
            self.state.lastActivityAt = now()
        end
    end
    self:HandlePartyJoke()
    self:HandlePartyDistance()
    self:PruneSocialEncounters()
    self:PruneRuntimeHistory()
    if self.state.closedTrade and now() - (self.state.closedTrade.closedAt or 0) > 3 then self.state.closedTrade = nil end
    if self.LivingWorld and self.LivingWorld.OnTick then self.LivingWorld:OnTick() end
end

function HCVoice:StartTicker()
    if self.state.ticker or not C_Timer or not C_Timer.NewTicker then return end
    self.state.ticker = C_Timer.NewTicker(5, function() self:OnTick() end)
end

function HCVoice:SafeRegisterEvent(event)
    pcall(frame.RegisterEvent, frame, event)
end

function HCVoice:RegisterEvents()
    local events = {
        "ADDON_LOADED", "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED",
        "UNIT_POWER_UPDATE", "UNIT_HEALTH", "UNIT_AURA", "UNIT_PET", "UNIT_TARGET", "GROUP_ROSTER_UPDATE",
        "PET_BAR_UPDATE", "PET_UI_UPDATE",
        "UNIT_LEVEL", "PLAYER_LEVEL_UP", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
        "COMBAT_LOG_EVENT_UNFILTERED", "CHAT_MSG_TEXT_EMOTE", "CHAT_MSG_EMOTE", "TRADE_SHOW",
        "CHAT_MSG_ADDON", "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_MONSTER_SAY",
        "TRADE_ACCEPT_UPDATE", "TRADE_CLOSED", "READY_CHECK_CONFIRM", "UI_INFO_MESSAGE", "TRADE_REQUEST_CANCEL",
        "PLAYER_STARTED_MOVING", "PLAYER_STOPPED_MOVING",
        "CHAT_MSG_LOOT", "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST",
    }
    for _, event in ipairs(events) do self:SafeRegisterEvent(event) end
end

function HCVoice:HandleEvent(event, ...)
    local arg1, arg2 = ...
    if event == "ADDON_LOADED" then
        if arg1 ~= self.name then return end
        self:Initialize()
        if self.db.announceLoaded then self:Message("v" .. self.version .. " loaded. Type /hcv.") end
        return
    end

    if not self.db then return end

    if event == "PLAYER_ENTERING_WORLD" then
        self:ResetRuntimeState()
        self.state.suppressRosterUntil = now() + 4
        self:InitializeUnitState()
        self:RefreshRoster(true)
        if self.LivingWorld and self.LivingWorld.OnWorldChanged then self.LivingWorld:OnWorldChanged() end
    elseif event == "PLAYER_TARGET_CHANGED" then self:HandleTargetChanged()
    elseif event == "UNIT_POWER_UPDATE" then self:HandleMana(arg1, arg2)
    elseif event == "UNIT_AURA" then if arg1 == "player" then self:HandleManaBreak() end
    elseif event == "UNIT_PET" then if arg1 == "player" then self:HandlePetState(); self:RefreshPetCommandState() end
    elseif event == "PET_BAR_UPDATE" or event == "PET_UI_UPDATE" then self:RefreshPetCommandState()
    elseif event == "UNIT_TARGET" then if arg1 == "pet" then self:RefreshPetCommandState() end
    elseif event == "UNIT_HEALTH" then
        if arg1 == "player" then self:HandlePlayerHealth()
        elseif arg1 == "pet" then self:HandlePetState()
        elseif type(arg1) == "string" and (arg1:match("^party%d+$") or arg1:match("^raid%d+$")) then self:HandlePartyHealth(arg1) end
    elseif event == "GROUP_ROSTER_UPDATE" then self:RefreshRoster(false); self:HandleManaBreak()
    elseif event == "UNIT_LEVEL" then self:HandleUnitLevel(arg1)
    elseif event == "PLAYER_LEVEL_UP" then self:RequestReactionAfter("playerLevel", nil, nil, 0.1, 1.0)
    elseif event == "PLAYER_REGEN_DISABLED" then self:StartCombat(); self:HandleManaBreak()
    elseif event == "PLAYER_REGEN_ENABLED" then self:EndCombat()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then self:HandleCombatLog()
    elseif event == "CHAT_MSG_ADDON" then
        if self.LivingWorld and self.LivingWorld.HandleAddonMessage then self.LivingWorld:HandleAddonMessage(...) end
    elseif event == "CHAT_MSG_TEXT_EMOTE" or event == "CHAT_MSG_EMOTE" then
        self:HandleSocialEvent(event, ...)
    elseif event == "TRADE_SHOW" then self:HandleTradeShow()
    elseif event == "TRADE_ACCEPT_UPDATE" then self:HandleTradeAccept(arg1, arg2)
    elseif event == "TRADE_CLOSED" then self:HandleTradeClosed()
    elseif event == "TRADE_REQUEST_CANCEL" then self.state.trade = nil; self.state.closedTrade = nil
    elseif event == "UI_INFO_MESSAGE" then self:HandleTradeInfo(arg2)
    elseif event == "READY_CHECK_CONFIRM" then self:HandleReadyCheck(arg1, arg2)
    elseif event == "CHAT_MSG_LOOT" then self:HandleLootMessage(arg1)
    elseif event == "PLAYER_DEAD" then self:HandlePlayerDeath()
    elseif event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then self:HandlePlayerRecovered()
    elseif event == "PLAYER_STARTED_MOVING" or event == "PLAYER_STOPPED_MOVING" then
        self.state.lastActivityAt = now()
        if event == "PLAYER_STARTED_MOVING" then self:HandleManaBreakMovement() end
    end
    if self.Bosses then self.Bosses:OnEvent(event, ...) end
end

function HCVoice:OpenGUI()
    if self.GUI and self.GUI.Toggle then self.GUI:Toggle() else self:Message("GUI is not available.") end
end

function HCVoice:CloseGUI()
    if self.GUI and self.GUI.Close then self.GUI:Close() else self:Message("GUI is not available.") end
end

SLASH_HCVOICE1 = "/hcvoice"
SLASH_HCVOICE2 = "/hcv"
SlashCmdList.HCVOICE = function(input)
    input = strtrim(input or "")
    local command, rest = input:match("^(%S*)%s*(.-)$")
    command = string.lower(command or "")

    if command == "" or command == "gui" or command == "settings" then HCVoice:OpenGUI()
    elseif command == "close" then HCVoice:CloseGUI()
    elseif command == "on" then HCVoice:SetEnabled(true); HCVoice:Message("enabled")
    elseif command == "off" then
        HCVoice:SetEnabled(false)
        HCVoice:Message("disabled")
    elseif command == "history" then HCVoice:Message(HCVoice:GetDecisionText())

    elseif command == "reset" then HCVoice:ResetDefaults()
    elseif command == "preset" then
        if not HCVoice:ApplyPreset(rest) then HCVoice:Message("presets: quiet, balanced, classicRP, fullRP") end
    elseif command == "test" then HCVoice:PlayVoice(rest, false)
    elseif command == "targettest" then HCVoice:PlayVoice(rest, true)
    elseif command == "lwtest" or command == "livingtest" then
        if HCVoice.LivingWorld and HCVoice.LivingWorld.Simulate then HCVoice.LivingWorld:Simulate(rest) else HCVoice:Message("Living World is not available.") end
    elseif command == "status" then
        HCVoice:Message(string.format("%s, frequency %d%%, cooldown %ds, replies %s, Living World %s/%s, preset %s", HCVoice.db.enabled and "enabled" or "disabled", HCVoice.db.frequency, HCVoice.db.globalCooldown, HCVoice.db.reply.mode, HCVoice.db.livingWorld.enabled and "on" or "off", HCVoice.db.livingWorld.mode, HCVoice.db.preset or "custom"))
    else HCVoice:Message("commands: /hcvoice, close, on, off, status, preset <name>, reset, test <voice>, targettest <voice>, lwtest <scene>") end
end

HCVoice:RegisterEvents()
frame:SetScript("OnEvent", function(_, event, ...) HCVoice:HandleEvent(event, ...) end)
