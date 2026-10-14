local clock, timers, calls, messages, units, grouped, raid, lockdown, combatInfo, incomingMoney, instanceType
local petControls, petCommandDelay, petCommandBlocked, petCommandCalls
local petHookRegistrations = {}
local createdFrames = {}
local function frame()
    local f = { scripts = {}, shown = false, TitleText = { SetText = function() end } }
    f.CloseButton = f
    function f:SetScript(k, v) self.scripts[k] = v end
    function f:Show() self.shown = true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
    function f:Hide() self.shown = false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
    function f:IsShown() return self.shown end
    function f:SetText(t) self.text = t end
    function f:GetText() return self.text or "" end
    function f:SetChecked(v) self.checked = v end
    function f:GetChecked() return self.checked end
    function f:GetWidth() return 1600 end
    function f:GetHeight() return 1000 end
    function f:GetFrameLevel() return 1 end
    function f:GetCenter() return 600, 350 end
    function f:GetPoint() return "CENTER", UIParent, "CENTER", 0, 0 end
    function f:CreateFontString() return frame() end
    function f:CreateTexture() return frame() end
    return setmetatable(f, { __index = function(_, key) if key:match("^[A-Z]") then return function() end end end })
end
function CreateFrame(_, name) local f = frame(); createdFrames[#createdFrames+1] = f; if name then _G[name] = f end; return f end
UIParent, DEFAULT_CHAT_FRAME = frame(), frame()
function DEFAULT_CHAT_FRAME:AddMessage() end
SlashCmdList, UISpecialFrames = {}, {}
function GetTime() return clock end
function GetServerTime() return 100000 + math.floor(clock) end
function GetLocale() return "enUS" end
function GetNormalizedRealmName() return "TestRealm" end
function UnitExists(u) return units[u] ~= nil end
function UnitGUID(u) return units[u] and units[u].guid end
function UnitName(u) return units[u] and units[u].name end
GetUnitName = UnitName
function UnitHealth(u) return units[u] and units[u].hp or 0 end
function UnitHealthMax() return 1000 end
function UnitPower() return units.player.mana end
function UnitPowerMax() return units.player.manaMax or 1000 end
function UnitIsDeadOrGhost(u)
    if units[u] and units[u].dead ~= nil then return units[u].dead end
    return units[u] and units[u].hp <= 0 or false
end
function UnitIsPlayer(u) return units[u] and not units[u].npc or false end
function UnitIsFriend(_, u) return units[u] and not units[u].hostile or false end
function UnitCanAttack(_,u) return units[u] and units[u].hostile or false end
function UnitClassification(u) return units[u] and units[u].classification or "normal" end
function UnitLevel(u) return units[u] and units[u].level or 20 end
function UnitClass() return "Mage", "MAGE" end
function UnitSex() return 3 end
function UnitRace(u) return "Localized race", units[u] and units[u].race or "Human" end
function UnitCastingInfo(u) return units[u] and units[u].casting end
function UnitChannelInfo(u) return units[u] and units[u].channeling end
function UnitAffectingCombat(u) return units[u] and units[u].fighting or false end
function UnitInParty(u) return grouped and u:match("^party") ~= nil end
function UnitInRaid(u) return raid and u:match("^raid") ~= nil end
function IsInGroup() return grouped end
function IsInRaid() return raid end
function IsInInstance() return instanceType ~= "none", instanceType end
function UnitIsGroupLeader() return grouped end
function UnitGroupRolesAssigned() return "DAMAGER" end
function GetUnitSpeed(u) return units[u] and units[u].speed or 0 end
function UnitInRange(u) return units[u] and units[u].far ~= true end
function GetTargetTradeMoney() return incomingMoney or 0 end
function GetTradeTargetItemInfo() return nil end
ERR_TRADE_COMPLETE = "Trade complete."
COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY = 1, 2
COMBATLOG_OBJECT_REACTION_HOSTILE = 4
bit = { band = function(a,b)
    local result, value = 0, 1
    while a > 0 and b > 0 do if a % 2 == 1 and b % 2 == 1 then result = result + value end; a = math.floor(a/2); b = math.floor(b/2); value = value*2 end
    return result
end }
function CombatLogGetCurrentEventInfo() return table.unpack(combatInfo, 1, 20) end
function wipe(t) for k in pairs(t) do t[k] = nil end end
C_Timer = {
    After = function(delay, fn) timers[#timers + 1] = { at = clock + delay, fn = fn } end,
    NewTicker = function() return { Cancel = function() end } end,
}
C_ChatInfo = {
    InChatMessagingLockdown = function() return lockdown end,
    PerformEmote = function(token, target) calls[#calls+1] = { token = token, target = target, at = clock }; return false end,
    RegisterAddonMessagePrefix = function() return 0 end,
    SendAddonMessage = function(prefix, payload, channel, target) messages[#messages+1] = { prefix=prefix,payload=payload,channel=channel,target=target }; return 0 end,
}
C_UnitAuras = { GetAuraDataByIndex = function(u, index) return units[u] and units[u].auras and units[u].auras[index] end }
function UnitBuff(u, index)
    local aura=units[u] and units[u].auras and units[u].auras[index]
    if aura then return aura.name, nil, nil, nil, nil, nil, nil, nil, nil, aura.spellId end
end
function PetHasActionBar() return units.pet ~= nil and petControls.available end
function GetPetActionInfo(slot)
    local token = petControls.slots[slot]
    if not token then return end
    local active = token == "PET_ACTION_ATTACK" and petControls.attack
        or token == "PET_ACTION_FOLLOW" and petControls.mode == "follow"
        or token == "PET_ACTION_WAIT" and petControls.mode == "stay"
    return token, "Texture", token:match("^PET_") ~= nil, active
end
function IsPetAttackAction(slot) return petControls.slots[slot] == "PET_ACTION_ATTACK" end
local function applyPetCommand(kind, unit)
    if petCommandBlocked or not UnitExists("pet") or UnitIsDeadOrGhost("pet") then return end
    if kind == "attack" then
        unit = unit or "target"
        if not UnitExists(unit) or not UnitCanAttack("player", unit) or UnitIsDeadOrGhost(unit) then return end
        petControls.attack = true; units.pettarget = units[unit]; units.pet.fighting = true
    else
        petControls.attack = false; petControls.mode = "follow"; units.pettarget = nil
    end
    -- Test the client ordering where the state update happens before post-hooks.
    HCVoice:HandleEvent("PET_BAR_UPDATE")
    HCVoice:HandleEvent("UNIT_TARGET", "pet")
end
function PetAttack(unit)
    petCommandCalls = petCommandCalls + 1
    if petCommandDelay > 0 then C_Timer.After(petCommandDelay, function() applyPetCommand("attack", unit) end)
    else applyPetCommand("attack", unit) end
end
function PetFollow()
    petCommandCalls = petCommandCalls + 1
    if petCommandDelay > 0 then C_Timer.After(petCommandDelay, function() applyPetCommand("recall") end)
    else applyPetCommand("recall") end
end
function CastPetAction(slot, unit)
    local token = GetPetActionInfo(slot)
    if token == "PET_ACTION_ATTACK" then PetAttack(unit)
    elseif token == "PET_ACTION_FOLLOW" then PetFollow() end
end
function hooksecurefunc(name, callback)
    petHookRegistrations[name] = (petHookRegistrations[name] or 0) + 1
    local original = _G[name]
    _G[name] = function(...) original(...); callback(...) end
end
for _, file in ipairs(FILES) do
    assert(loadfile(ROOT .. "/" .. file))("HCVoice", {})
end
local H = HCVoice
local function advance(seconds)
    local limit, count = clock + seconds, 0
    while true do
        table.sort(timers, function(a,b) return a.at < b.at end)
        if not timers[1] or timers[1].at > limit then break end
        local timer = table.remove(timers, 1); clock = timer.at; timer.fn()
        count = count + 1; assert(count < 2000, "timer loop")
    end
    clock = limit
end
local function reset()
    clock, timers, calls, messages = 1000, {}, {}, {}
    createdFrames = {}
    units = { player = { name = "PlayerOne", guid = "Player-1", hp = 1000, mana = 1000, level = 20 } }
    grouped, raid, lockdown, incomingMoney, instanceType = false, false, false, 0, "none"
    petControls = { available=true, attack=false, mode="follow", slots={"PET_ACTION_ATTACK","PET_ACTION_FOLLOW","PET_ACTION_WAIT"} }
    petCommandDelay, petCommandBlocked, petCommandCalls = 0, false, 0
    H.GUI.replyFrame = nil
    HCVoiceCharDB, HCVoiceDB = nil, nil
    H:Initialize()
    H.db.frequency, H.db.reply.autoChance, H.db.livingWorld.frequency = 100, 100, 100
    math.randomseed(42)
end
local function friend(unit, name)
    units[unit] = { name = name or "Alice", guid = "Player-" .. (name or "Alice"), hp = 1000, mana = 1000, level = 20 }
end
local function emote(text, name, custom, target)
    H:HandleSocialEvent(custom and "CHAT_MSG_EMOTE" or "CHAT_MSG_TEXT_EMOTE", text, name or "Alice", nil, nil, target, nil, nil, nil, nil, nil, math.floor(clock*100), "Player-" .. (name or "Alice"))
end
local function expect(v, msg) assert(v, msg or "expectation failed") end
local total = 0
local function test(name, fn)
    reset()
    local ok, err = xpcall(fn, debug.traceback)
    if not ok then error(name .. ": " .. tostring(err)) end
    total = total + 1; print("PASS " .. name)
end
local function buff(source, dest, spell)
    combatInfo = { [2]="SPELL_AURA_APPLIED", [4]=source, [5]=source == "Player-1" and "PlayerOne" or "Alice", [6]=3, [8]=dest, [9]=dest == "Player-1" and "PlayerOne" or "Alice", [10]=3, [12]=1459, [13]=spell or "Arcane Intellect" }
    H:HandleCombatLog()
end
test("outgoing buffs never create an emote or encounter", function()
    buff("Player-1","Player-Alice"); advance(20)
    expect(#calls==0); expect(next(H.state.social.encounters)==nil)
    expect(H.scenarioByKey.buffPlayer==nil and H.db.scenarios.buffPlayer==nil)
end)
test("received buff series produces one targeted THANK", function()
    H.db.frequency = 0 -- Explicit buff thanks must not be reduced by general frequency.
    buff("Player-Alice","Player-1","Blessing of Might"); buff("Player-Alice","Player-1","Power Word: Fortitude")
    advance(20); expect(#calls==1 and calls[1].token=="THANK" and calls[1].target=="Alice")
end)
test("buffing a selected player cancels a pending greeting", function()
    friend("target","Alice"); H:HandleTargetChanged()
    buff("Player-1","Player-Alice"); advance(20); expect(#calls==0)
end)
test("buffing also cancels a greeting that already reached the queue", function()
    H:PlayVoice("NOD"); friend("target","Alice"); H:HandleTargetChanged(); advance(2)
    buff("Player-1","Player-Alice"); advance(20); expect(#calls==1)
end)
test("self buffs and passive auras stay silent", function()
    buff("Player-1","Player-1"); buff("Player-Alice","Player-1","Devotion Aura"); advance(20); expect(#calls==0)
end)
test("urgent FLEE does not wait behind social spacing", function()
    H:PlayVoice("HELLO"); H:StartCombat(); units.player.hp=100; H:HandlePlayerHealth(); advance(2)
    expect(#calls==2 and calls[2].token=="FLEE" and calls[2].at-calls[1].at<2)
end)
test("simultaneous damage and health alerts choose one strongest call", function()
    H:StartCombat(); units.player.hp=100
    H:RequestReaction("firstDamage"); H:HandlePlayerHealth(); advance(5)
    expect(#calls==1 and calls[1].token=="FLEE")
end)
test("recovered health removes a queued healing warning", function()
    H:PlayVoice("HELLO"); H:StartCombat(); units.player.hp=300; H:HandlePlayerHealth()
    units.player.hp=900; advance(5); expect(#calls==1)
end)
test("recovered mana removes queued OOM", function()
    grouped=true; units.player.mana=100; H:HandleMana("player","MANA"); units.player.mana=900
    advance(10); expect(#calls==0)
end)
test("off then on invalidates delayed buff and old queue", function()
    buff("Player-Alice","Player-1"); H:RequestReaction("playerLevel")
    H:SetEnabled(false); H:SetEnabled(true); advance(20); expect(#calls==0)
end)
test("false emote result is counted once without retries", function()
    H:RequestReaction("playerLevel"); advance(20); expect(#calls==1)
end)
test("client lockdown stays silent and never creates a popup", function()
    lockdown=true; H:RequestReaction("playerLevel"); advance(20)
    expect(#calls==0 and H.GUI.replyFrame==nil)
end)
test("a clear directed greeting is delayed and answered once", function()
    emote("Alice waves at you."); expect(#calls==0); advance(2)
    expect(#calls==1 and calls[1].token=="WAVE")
    emote("Alice waves at you."); advance(10); expect(#calls==1)
end)
test("a later different exchange can receive a reply", function()
    emote("Alice waves at you."); advance(10)
    emote("Alice thanks you."); advance(3)
    expect(#calls==2 and calls[2].token=="WELCOME")
end)
test("an ordinary congratulation receives THANK", function()
    emote("Alice congratulates you."); advance(3)
    expect(#calls==1 and calls[1].token=="THANK")
end)
test("a player's manual reply cancels a pending automatic answer", function()
    emote("Alice waves at you.")
    emote("You wave at Alice.","PlayerOne",false,"Alice")
    advance(10); expect(#calls==0)
end)
test("a name containing HELLO cannot turn a flirt into a greeting", function()
    emote("Hellohero flirts with you.","Hellohero"); advance(2)
    expect(#calls==0 and H.GUI.replyFrame:IsShown())
    expect(H.GUI.replyFrame.data.category=="affection")
end)
test("hostile meaning beats friendly words", function()
    emote("Alice smiles at you and insults you."); advance(2)
    expect(#calls==0 and H.GUI.replyFrame.data.category=="hostile")
end)
test("custom friendly prose is never automatically executed", function()
    emote("waves at you.","Alice",true); advance(2); expect(#calls==0)
end)
test("emotes aimed at somebody else do not prompt or answer", function()
    emote("Alice flirts with Edinor.","Alice",false,"Edinor"); advance(2)
    expect(#calls==0 and H.GUI.replyFrame==nil)
end)
test("a new sender cannot replace a visible choice", function()
    emote("Alice flirts with you."); local original=H.GUI.replyFrame.data
    emote("Bob insults you.","Bob"); expect(H.GUI.replyFrame.data==original)
end)
test("turning off a reply category invalidates its visible choice", function()
    emote("Alice flirts with you."); H.db.reply.categories.affection=false
    H.GUI.replyFrame.replyButtons[1].scripts.OnClick(H.GUI.replyFrame.replyButtons[1])
    expect(#calls==0)
end)
test("flirt choices are available and clickable without separate activation", function()
    friend("target","Alice")
    emote("Alice flirts with you.")
    expect(H.GUI.replyFrame.data.options[1]=="FLIRT" and H.GUI.replyFrame.data.options[2]=="KISS")
    expect(#calls==0)
    H.GUI.replyFrame.replyButtons[1].scripts.OnClick(H.GUI.replyFrame.replyButtons[1])
    expect(#calls==1 and calls[1].token=="FLIRT" and calls[1].target=="Alice")
end)
test("a kiss can be chosen without separate activation", function()
    friend("target","Alice"); emote("Alice kisses you.")
    H.GUI.replyFrame.replyButtons[2].scripts.OnClick(H.GUI.replyFrame.replyButtons[2])
    expect(#calls==1 and calls[1].token=="KISS" and calls[1].target=="Alice")
end)
test("a hug can be chosen without separate activation", function()
    friend("target","Alice"); emote("Alice hugs you.")
    expect(H.GUI.replyFrame.data.options[1]=="HUG" and #calls==0)
    H.GUI.replyFrame.replyButtons[1].scripts.OnClick(H.GUI.replyFrame.replyButtons[1])
    expect(#calls==1 and calls[1].token=="HUG" and calls[1].target=="Alice")
end)
test("an intimate option still checks the recipient when clicked", function()
    friend("target","Alice"); emote("Alice flirts with you.")
    units.target.hostile=true
    H.GUI.replyFrame.replyButtons[1].scripts.OnClick(H.GUI.replyFrame.replyButtons[1])
    expect(#calls==0)
end)
test("session ignores survive toggling the addon and changing profiles", function()
    H:IgnoreReplyPlayer("Player-Alice","Alice"); H:SaveProfile("saved")
    H:SetEnabled(false); H:SetEnabled(true); H:LoadProfile("saved")
    emote("Alice flirts with you."); expect(H.GUI.replyFrame==nil)
end)
test("NPC and group targeting never greet", function()
    friend("target"); units.target.npc=true; H:HandleTargetChanged(); advance(10)
    friend("party1"); grouped=true; units.target=units.party1; H:HandleTargetChanged(); advance(10)
    expect(#calls==0)
end)
test("a deliberate neutral player target uses HELLO", function()
    friend("target"); local startedAt=clock; local delay=H.db.advanced.greetingDelaySeconds
    H:HandleTargetChanged(); advance(delay-0.01); expect(#calls==0, "greeting played before the configured wait")
    advance(0.11)
    expect(#calls==1 and calls[1].token=="HELLO" and calls[1].target=="Alice")
    expect(calls[1].at-startedAt <= delay+0.1, "greeting added a second delay after the configured wait")
end)

test("target greetings still respect social voice spacing", function()
    H.db.globalCooldown=10; H:PlayVoice("NOD",false)
    friend("target"); H:HandleTargetChanged(); advance(9.9)
    expect(#calls==1, "greeting bypassed social voice spacing")
    advance(0.2)
    expect(#calls==2 and calls[2].token=="HELLO" and calls[2].target=="Alice")
    expect(calls[2].at-calls[1].at >= 10)
end)
test("a short target switch does not say BYE and HELLO", function()
    friend("target"); local target=units.target
    H:HandleTargetChanged(); advance(6); units.target=nil; H:HandleTargetChanged()
    advance(0.5); units.target=target; H:HandleTargetChanged(); advance(12)
    expect(#calls==1 and calls[1].token=="HELLO")
end)
test("a newly joined member leaving immediately always gets BYE", function()
    grouped=true; friend("party1","Alice"); H:RefreshRoster(false)
    H.db.frequency=0; H.db.globalCooldown=60; H:PlayVoice("HELLO",false)
    units.party1=nil; H:RefreshRoster(false)
    expect(#calls==2 and calls[2].token=="BYE" and calls[2].target=="Alice")
    H:RefreshRoster(false); expect(#calls==2, "duplicate roster update repeated BYE")
end)
test("leaving before the welcome cancels that pending greeting", function()
    grouped=true; friend("party1","Alice"); H:RefreshRoster(false)
    units.party1=nil; H:RefreshRoster(false); advance(20)
    expect(#calls==1 and calls[1].token=="BYE" and calls[1].target=="Alice")
end)
test("every member leaving at once gets exactly BYE even in combat", function()
    grouped=true
    for i=1,4 do friend("party"..i,"Member"..i) end
    H:RefreshRoster(true); H:StartCombat()
    for i=1,4 do units["party"..i]=nil end
    grouped=false; H:RefreshRoster(false)
    local recipients={}
    for _, call in ipairs(calls) do expect(call.token=="BYE"); recipients[call.target]=true end
    expect(#calls==4)
    for i=1,4 do expect(recipients["Member"..i]) end
end)
test("a member rejoining and leaving again gets a new BYE without cooldown", function()
    grouped=true; friend("party1","Alice"); H:RefreshRoster(true)
    units.party1=nil; H:RefreshRoster(false)
    friend("party1","Alice"); H:RefreshRoster(false)
    units.party1=nil; H:RefreshRoster(false)
    expect(#calls==2 and calls[1].token=="BYE" and calls[2].token=="BYE")
end)
test("quiet and old disabled farewell settings cannot suppress party BYE", function()
    grouped=true; friend("party1","Alice"); H:ApplyPreset("quiet")
    H.db.scenarios.farewellParty={mode="off",enabled=false,chance=0}
    H:IgnoreReplyPlayer("Player-Alice","Alice")
    units.party1=nil; H:RefreshRoster(false)
    expect(#calls==1 and calls[1].token=="BYE")
end)
test("a real departure during greeting suppression still gets BYE", function()
    grouped=true; friend("party1","Alice"); H:RefreshRoster(true)
    H.state.suppressRosterUntil=clock+4
    units.party1=nil; H:RefreshRoster(false)
    expect(#calls==1 and calls[1].token=="BYE")
end)
test("initial roster reads and explicit resets never invent a departure", function()
    grouped=true; friend("party1","Alice"); H:Initialize(); H:RefreshRoster(false)
    units.party1=nil; H:RefreshRoster(true); H:RefreshRoster(false)
    expect(#calls==0)
end)
test("master off still disables party BYE", function()
    grouped=true; friend("party1","Alice"); H:SetEnabled(false)
    units.party1=nil; H:RefreshRoster(false); expect(#calls==0)
end)
test("blocked party BYE is not retried or converted to a popup", function()
    grouped=true; friend("party1","Alice"); H:RefreshRoster(true)
    lockdown=true; units.party1=nil; H:RefreshRoster(false)
    lockdown=false; H:RefreshRoster(false); advance(10)
    expect(#calls==0 and H.GUI.replyFrame==nil)
end)
test("healing attribution uses effective totals per healer", function()
    H:StartCombat(); H:RecordExternalHealing("Player-A","Alice",500,490)
    H:RecordExternalHealing("Player-B","Bob",100,0); H:RecordExternalHealing("Player-B","Bob",100,0)
    H:EndCombat(); advance(10)
    expect(#calls==1 and calls[1].target=="Bob")
end)
test("sorrow supersedes celebration and humor", function()
    H:RequestReaction("playerLevel"); H:RequestReaction("partyDeath","Alice","Player-Alice")
    H:RequestReaction("partyJoke"); advance(20)
    expect(#calls==1 and (calls[1].token=="MOURN" or calls[1].token=="CRY" or calls[1].token=="SALUTE"))
end)
test("death reactions wait until combat ends", function()
    H:StartCombat(); H:RequestReaction("partyDeath","Alice","Player-Alice"); advance(3); expect(#calls==0)
    H:EndCombat(); advance(3); expect(#calls==1)
end)
test("quiet switches off direct replies and Living World", function()
    H:ApplyPreset("quiet"); emote("Alice waves at you."); emote("Alice flirts with you."); advance(10)
    expect(not H.db.reply.enabled and not H.db.livingWorld.enabled and #calls==0 and H.GUI.replyFrame==nil)
end)
test("presets preserve explicit reply category exclusions", function()
    H.db.reply.categories.affection=false
    H:ApplyPreset("fullRP")
    expect(not H.db.reply.categories.affection)
end)
test("upgrading removes both obsolete gates from character and saved profiles", function()
    HCVoiceCharDB={schemaVersion=160,scenarios={intimateReplies={mode="off",enabled=false},farewellParty={mode="off",chance=0}}}
    H:Initialize(); H:SaveProfile("old")
    H.accountDB.profiles.old.schemaVersion=160
    H.accountDB.profiles.old.scenarios.intimateReplies={mode="off",enabled=false}
    H.accountDB.profiles.old.scenarios.farewellParty={mode="off",chance=0}
    expect(H:LoadProfile("old"))
    expect(H.db.scenarios.intimateReplies==nil and H.db.scenarios.farewellParty==nil)
    expect(not H:ExportProfile():find("intimateReplies") and not H:ExportProfile():find("farewellParty"))
    friend("target","Alice"); emote("Alice flirts with you.")
    expect(H.GUI.replyFrame.data.options[1]=="FLIRT")
end)
test("old profiles preserve thresholds and remove the outgoing buff setting", function()
    local old={schemaVersion=150, thresholds={mana=22}, scenarios={buffPlayer={mode="automatic"}},reply={categories={affection=false}},livingWorld={}}
    HCVoiceCharDB=old; H:Initialize()
    expect(H.db.thresholds.mana==22 and H.db.scenarios.buffPlayer==nil and not H.db.reply.categories.affection)
end)
test("profile export import round trip keeps the three frequency controls", function()
    H.db.frequency=31; H.db.reply.autoChance=42; H.db.livingWorld.frequency=53
    local text=H:ExportProfile(); expect(H:ImportProfile(text))
    expect(H.db.frequency==31 and H.db.reply.autoChance==42 and H.db.livingWorld.frequency==53)
end)
test("trade closed without completion does not thank the current target", function()
    friend("target","Wrong"); friend("NPC","Alice"); incomingMoney=100
    H:HandleTradeShow(); H:HandleTradeAccept(1,1); H:HandleTradeClosed(); advance(10); expect(#calls==0)
end)
test("confirmed trade thanks the verified partner once after close", function()
    friend("target","Wrong"); friend("NPC","Alice"); incomingMoney=100
    H:HandleTradeShow(); H:HandleTradeAccept(1,1); H:HandleTradeClosed()
    H:HandleTradeInfo(ERR_TRADE_COMPLETE); H:HandleTradeInfo(ERR_TRADE_COMPLETE); advance(10)
    expect(#calls==1 and calls[1].target=="Alice")
end)
test("raid level events are tracked for the correct member", function()
    grouped,raid=true,true; friend("raid1","Alice"); H:RefreshRoster(true)
    units.raid1.level=21; H:HandleUnitLevel("raid1"); advance(10)
    expect(#calls==1 and calls[1].target=="Alice")
end)
local function scene(key, sender, target, id)
    return {id=id or "test.scene",key=key,sender=sender or "Alice",targetName=target,channel="PARTY",sourceToken=key=="partyLevel" and "CONGRATULATE" or "CHEER",depth=0,sentAt=GetServerTime()}
end
test("local and synced levels merge into a single response", function()
    grouped=true; friend("party1","Alice"); H:RefreshRoster(true)
    units.party1.level=21; H:HandleUnitLevel("party1")
    H.LivingWorld:HandleScene(scene("partyLevel","Bob","Alice"),true); advance(20)
    expect(#calls==1)
end)
test("a pending Living World reaction obeys a later switch-off", function()
    H.LivingWorld:HandleScene(scene("hardVictory","Alice","Boss"),true)
    H.db.livingWorld.enabled=false; advance(10); expect(#calls==0)
end)
test("visible greeting then structured greeting produces one response", function()
    grouped=true; friend("party1","Alice")
    emote("Alice greets you with a hearty hello!")
    local s=scene("greetPlayer","Alice","PlayerOne"); s.sourceToken="HELLO"
    H.LivingWorld:HandleAddonMessage("HCVLW1",H.LivingWorld:BuildMessage("S",s),"PARTY","Alice")
    advance(20); expect(#calls==1)
end)
test("structured greeting then visible greeting produces one response", function()
    grouped=true; friend("party1","Alice")
    local s=scene("greetPlayer","Alice","PlayerOne"); s.sourceToken="HELLO"
    H.LivingWorld:HandleAddonMessage("HCVLW1",H.LivingWorld:BuildMessage("S",s),"PARTY","Alice")
    emote("Alice greets you with a hearty hello!"); advance(20); expect(#calls==1)
end)
test("a delayed reaction is cancelled by profile load", function()
    H:SaveProfile("saved"); H:RequestReactionAfter("playerLevel",nil,nil,1,1)
    H:LoadProfile("saved"); advance(10); expect(#calls==0)
end)
test("new protocol round trips and accepts old scenes", function()
    local s=scene("hardVictory","Alice","Boss"); s.responder="PlayerOne"
    local parsed=H.LivingWorld:ParseMessage(H.LivingWorld:BuildMessage("S",s))
    expect(parsed and parsed.responder=="PlayerOne")
    expect(H.LivingWorld:ParseMessage("S~1~old~hardVictory~CHEER~Boss~0~"..GetServerTime()))
    expect(not H.LivingWorld:ParseMessage("S~2~bad~hardVictory~CHEER~Boss~0~0~~"))
end)
test("a simulated scene never transmits a response to the real group", function()
    grouped=true; friend("party1","Alice")
    local before=#messages
    H.LivingWorld:HandleScene(scene("hardVictory","Alice","Boss"),true); advance(10)
    expect(#calls==1 and #messages==before)
end)
test("structured response markers stop visible answer chains", function()
    grouped=true; friend("party1","Alice")
    emote("Alice laughs at you.")
    local s=scene("partyJoke","Alice",nil); s.sourceToken="LAUGH"; s.depth=1
    H.LivingWorld:HandleAddonMessage("HCVLW1",H.LivingWorld:BuildMessage("R",s),"PARTY","Alice")
    advance(10); expect(#calls==0)
end)
test("banter chooses only a known compatible peer", function()
    grouped=true; friend("party1","Alice"); friend("party2","Bob")
    H.LivingWorld:HandleAddonMessage("HCVLW1","H~2~1~R","PARTY","Alice")
    expect(H.LivingWorld:ChooseResponder("scene")=="alice")
    H.LivingWorld:HandleAddonMessage("HCVLW1","H~2~0~R","PARTY","Alice")
    expect(H.LivingWorld:ChooseResponder("scene")==nil)
end)
test("an unrelated structured scene does not swallow a flirt", function()
    grouped=true; friend("party1","Alice")
    local s=scene("hardVictory","Alice","Boss")
    H.LivingWorld:HandleAddonMessage("HCVLW1",H.LivingWorld:BuildMessage("S",s),"PARTY","Alice")
    emote("Alice flirts with you."); expect(H.GUI.replyFrame and H.GUI.replyFrame:IsShown())
end)
test("history is bounded and explains recovered warnings", function()
    for i=1,70 do H:RecordDecision("test"..i,"skipped","reason") end
    expect(#H.state.decisions==50)
    H:StartCombat(); units.player.hp=300; H:HandlePlayerHealth(); units.player.hp=900; advance(2)
    expect(H:GetDecisionText():find("health recovered",1,true))
end)
test("settings pages and persisted popup position build", function()
    H.GUI:CreateMainFrame()
    for _,key in ipairs({"general","reactions","replies","profiles","voices","advanced","history"}) do H.GUI:SelectPage(key) end
    emote("Alice flirts with you."); H.GUI.replyFrame.scripts.OnDragStop(H.GUI.replyFrame)
    expect(H.db.ui.replyPosition.x==600)
end)
test("long solo waits use only boredom, yawning or whistling without a target", function()
    H.db.scenarios.idleYawn.chance=100
    local seen={}
    for i=1,60 do
        advance(601); H:OnTick(); advance(2)
        local call=calls[#calls]
        expect(#calls==i and call.target==nil)
        expect(call.token=="BORED" or call.token=="YAWN" or call.token=="WHISTLE")
        seen[call.token]=true
    end
    expect(seen.BORED and seen.YAWN and seen.WHISTLE)
end)

test("idle waits respect the delay and give recent speech space", function()
    H.db.scenarios.idleYawn.chance=100
    advance(299); H:OnTick(); advance(2); expect(#calls==0)
    H:PlayVoice("HELLO"); H:OnTick(); advance(2); expect(#calls==1)
    advance(300); H:OnTick(); advance(2); expect(#calls==2)
end)

test("stationary party waiting can idle without immediately adding a joke or shared scene", function()
    grouped=true; friend("party1","Alice"); H:RefreshRoster(true)
    H.db.scenarios.idleYawn.chance=100
    H.state.nextPartyJokeAt=clock
    advance(301); H:OnTick(); advance(2)
    expect(#calls==1 and calls[1].target==nil)
    expect(H.state.nextPartyJokeAt>clock)
    for _,msg in ipairs(messages) do expect(not msg.payload:find("~idleYawn~",1,true)) end
end)

test("idle cooldown still prevents repeated automatic reactions", function()
    H.db.scenarios.idleYawn.chance=100
    advance(301); H:OnTick(); advance(2); expect(#calls==1)
    advance(301); H:OnTick(); advance(2); expect(#calls==1)
end)

test("movement, spells and channels reset the idle wait", function()
    H.db.scenarios.idleYawn.chance=100
    for _,activity in ipairs({"speed","casting","channeling"}) do
        advance(301); units.player[activity]=activity=="speed" and 7 or "Busy"
        H:OnTick(); advance(2); expect(#calls==0)
        units.player[activity]=nil; H:OnTick(); advance(2); expect(#calls==0)
    end
end)

test("idle is cancelled when movement or spellcasting starts before playback", function()
    H.db.scenarios.idleYawn.chance=100
    for _,activity in ipairs({"speed","casting","channeling"}) do
        advance(301); H:OnTick(); expect(#H.state.reactionQueue==1)
        units.player[activity]=activity=="speed" and 7 or "Busy"
        advance(2); expect(#calls==0); units.player[activity]=nil
    end
end)

test("party fighting and death prevent idle and jokes", function()
    grouped=true; friend("party1","Alice")
    H.db.scenarios.idleYawn.chance=100
    for _,situation in ipairs({"fight","death"}) do
        units.party1.fighting=situation=="fight"
        units.party1.hp=situation=="death" and 0 or 1000
        H.state.nextPartyJokeAt=clock
        advance(301); H:OnTick(); advance(2); expect(#calls==0)
    end
end)

test("new party combat cancels a queued idle", function()
    grouped=true; friend("party1","Alice"); H.db.scenarios.idleYawn.chance=100
    advance(301); H:OnTick(); units.party1.fighting=true
    advance(2); expect(#calls==0)
end)

test("raids never start idle or party jokes", function()
    grouped,raid=true,true; H.db.scenarios.idleYawn.chance=100
    H.state.nextPartyJokeAt=clock
    advance(301); H:OnTick(); advance(2); expect(#calls==0)
end)

test("Tauren party humor can MOO but never targets another player", function()
    grouped=true; units.player.race="Tauren"
    local seen={}
    for i=1,100 do
        expect(H:RequestReaction("partyJoke","Alice",nil,{force=true}))
        advance(2)
        local call=calls[#calls]
        expect(call.target==nil and (call.token=="JOKE" or call.token=="MOO"))
        seen[call.token]=true
    end
    expect(seen.JOKE and seen.MOO)
end)

test("non-Tauren party humor keeps its voiced joke and never emits text-only MOO", function()
    grouped=true
    for i=1,100 do
        expect(H:RequestReaction("partyJoke",nil,nil,{force=true})); advance(2)
        expect(#calls==i and calls[i].token=="JOKE")
    end
    expect(not H:PlayVoice("MOO") and not H:PlayResponse("MOO","Alice"))
    expect(not H:PerformToken("MOO",nil,true))
    expect(#calls==100)
end)

test("queued race-specific emotes recheck the player race", function()
    grouped=true; units.player.race="Tauren"
    expect(H:EnqueueReaction({scenario="partyJoke",token="MOO",priority=12}))
    units.player.race="Human"; advance(2); expect(#calls==0)
    units.player.race="Tauren"; expect(H:PlayVoice("MOO"))
    expect(#calls==1 and calls[1].token=="MOO")
end)

test("MOO jokes are cancelled if the party disbands before playback", function()
    grouped=true; units.player.race="Tauren"
    expect(H:EnqueueReaction({scenario="partyJoke",token="MOO",priority=12}))
    grouped=false; advance(2); expect(#calls==0)
end)

test("new playful voices stay quiet during a serious moment", function()
    H.state.seriousUntil=clock+30
    for _,token in ipairs({"BORED","WHISTLE","YAWN","MOO"}) do
        units.player.race="Tauren"
        expect(not H:EnqueueReaction({scenario="idleYawn",token=token,priority=10}))
    end
    expect(H:RequestReaction("nearDeath",nil,nil,{force=true})); advance(2)
    expect(#calls==1 and calls[1].token=="SIGH")
end)

test("other players' idle scenes do not cause answer chains", function()
    grouped=true; friend("party1","Alice")
    local s=scene("idleYawn","Alice",nil); s.sourceToken="BORED"
    H.LivingWorld:HandleAddonMessage("HCVLW1",H.LivingWorld:BuildMessage("S",s),"PARTY","Alice")
    advance(10); expect(#calls==0 and not H.GUI.replyFrame)
end)

test("upgrading preserves existing idle preferences and RP choices", function()
    HCVoiceCharDB={schemaVersion=161,scenarios={idleYawn={mode="off",enabled=false,chance=7}},advanced={idleMinutes=9}}
    H:Initialize()
    expect(H.db.schemaVersion==H.schemaVersion and H.db.advanced.idleMinutes==9)
    expect(H.db.scenarios.idleYawn.mode=="off" and H.db.scenarios.idleYawn.chance==7)
    expect(H:IsVoiceAvailable("HUG") and H:IsVoiceAvailable("SIGH") and H:IsVoiceAvailable("YAWN"))
end)

test("Voice Lab keeps HUG and filters MOO by race", function()
    local function buttonExists(text)
        for _,f in ipairs(createdFrames) do if f.text==text then return true end end
        return false
    end
    H.GUI:BuildVoicePage(frame())
    expect(buttonExists("Hug  /hug") and buttonExists("Bored  /bored") and buttonExists("Whistle  /whistle"))
    expect(not buttonExists("Moo (Tauren)  /moo"))
    createdFrames={}; units.player.race="Tauren"
    H.GUI:BuildVoicePage(frame()); expect(buttonExists("Moo (Tauren)  /moo"))
end)

test("a directed MOO gets one Tauren reply and cannot start a loop", function()
    units.player.race="Tauren"
    emote("Alice moos at you. Mooooooooooo."); advance(2)
    expect(#calls==1 and calls[1].token=="MOO" and calls[1].target=="Alice")
    emote("Alice moos at you. Mooooooooooo."); advance(10)
    expect(#calls==1 and not H.GUI.replyFrame)
end)

test("other races laugh at directed MOO without emitting text-only MOO", function()
    emote("Alice moos at you. Mooooooooooo."); advance(2)
    expect(#calls==1 and calls[1].token=="LAUGH" and calls[1].target=="Alice")
end)

test("directed whistles, sighs, yawns and boredom offer fitting choices", function()
    local examples={
        {"Alice whistles at you.","WHISTLE"},
        {"Alice sighs at you.","SIGH"},
        {"Alice yawns sleepily at you.","YAWN"},
        {"Alice is terribly bored with you.","BORED"},
    }
    for _,example in ipairs(examples) do
        reset(); emote(example[1]); advance(2)
        local popup=H.GUI.replyFrame
        expect(#calls==0 and popup and popup:IsShown() and popup.data.incomingToken==example[2])
        local button=popup.replyButtons[1]; local token=button.token
        button.scripts.OnClick(button)
        expect(#calls==1 and calls[1].token==token and calls[1].target=="Alice")
    end
end)

test("new ambient emotes and actions aimed at other players stay silent", function()
    for _,message in ipairs({"Alice moos. Mooooooooooo.","Alice lets forth a sharp whistle.",
        "Alice lets out a long, drawn-out sigh.","Alice yawns sleepily.","Alice is overcome with boredom.  Oh the drudgery!",
        "Alice moos at Bob. Mooooooooooo.","Alice whistles at Bob.","Alice is terribly bored with Bob."}) do
        emote(message); advance(2)
        expect(#calls==0 and not H.GUI.replyFrame)
    end
end)

test("custom MOO prose never becomes an automatic reply", function()
    emote("Alice moos at you. Mooooooooooo.","Alice",true); advance(2)
    expect(#calls==0 and H.GUI.replyFrame and H.GUI.replyFrame:IsShown())
end)

test("a manually typed MOO cancels a queued playful answer", function()
    units.player.race="Tauren"
    emote("Alice moos at you. Mooooooooooo.")
    emote("You moo at Alice. Mooooooooooo.","PlayerOne")
    advance(10); expect(#calls==0)
end)

local function party()
    grouped=true; friend("party1","Alice"); H:RefreshRoster(true)
end
local function drink(mana, spellID)
    units.player.mana=mana
    units.player.auras={{name="Localized drink",spellId=spellID or 1137}}
    H:HandleEvent("UNIT_AURA","player")
end
local function stopDrink(mana)
    units.player.mana=mana; units.player.auras={}; H:HandleEvent("UNIT_AURA","player")
end

test("a real mana break replaces queued OOM with WAIT and finishes with one NOD", function()
    party(); units.player.mana=200; H:HandleMana("player","MANA")
    drink(200); advance(2)
    expect(#calls==1 and calls[1].token=="WAIT" and calls[1].target==nil)
    for _,mana in ipairs({250,450,700,950}) do
        units.player.mana=mana; H:HandleEvent("UNIT_POWER_UPDATE","player","MANA")
        H:HandleEvent("UNIT_AURA","player"); advance(2)
    end
    expect(#calls==1)
    stopDrink(950); advance(10); H:HandleEvent("UNIT_AURA","player"); advance(10)
    expect(#calls==2 and calls[2].token=="NOD" and calls[2].target==nil)
end)

test("mana regeneration, food and unrelated auras never announce a drink", function()
    party(); units.player.mana=400
    units.player.auras={{name="Drink",spellId=999999}}
    H:HandleEvent("UNIT_AURA","player"); H:HandleMana("player","MANA"); advance(10)
    expect(#calls==0)
    units.player.mana=1000; H:HandleMana("player","MANA"); advance(10); expect(#calls==0)
end)

test("a high-mana drink, solo drink, raid or manaless character stays quiet", function()
    for _,kind in ipairs({"high","solo","raid","manaless","off"}) do
        reset(); party()
        if kind=="solo" then grouped=false elseif kind=="raid" then raid=true
        elseif kind=="manaless" then units.player.manaMax=0 elseif kind=="off" then H:SetEnabled(false) end
        drink(kind=="high" and 800 or 400); advance(5); stopDrink(1000); advance(10)
        expect(#calls==0,kind)
    end
end)

test("an unfinished mana break never signals ready after later regeneration", function()
    party(); drink(300); advance(4); stopDrink(500); advance(10)
    units.player.mana=1000; H:HandleMana("player","MANA"); advance(10)
    expect(#calls==1 and calls[1].token=="WAIT")
end)

test("movement, combat or a fighting party member cancels the ready signal", function()
    for _,kind in ipairs({"movement","combat","partyCombat"}) do
        reset(); party(); drink(300); advance(4)
        if kind=="movement" then H:HandleEvent("PLAYER_STARTED_MOVING")
        elseif kind=="combat" then H:HandleEvent("PLAYER_REGEN_DISABLED")
        else units.party1.fighting=true; H:HandleManaBreak() end
        units.party1.fighting=false; H.state.inCombat=false
        stopDrink(1000); advance(10)
        expect(#calls==1 and calls[1].token=="WAIT",kind)
    end
end)

test("walking away after recovering mana finishes the announced break", function()
    party(); drink(300); advance(4)
    units.player.mana=950; units.player.speed=7
    H:HandleEvent("PLAYER_STARTED_MOVING"); advance(2); expect(#calls==1)
    stopDrink(950); advance(10)
    expect(#calls==2 and calls[2].token=="NOD")
end)

test("a completed break can signal ready while the player resumes walking", function()
    party(); drink(300); advance(4); stopDrink(950)
    units.player.speed=7; H:HandleEvent("PLAYER_STARTED_MOVING"); advance(10)
    expect(#calls==2 and calls[2].token=="NOD")
end)

test("a queued WAIT cannot play after the drink is interrupted", function()
    party(); drink(300); stopDrink(400); advance(20); expect(#calls==0)
end)

test("a blocked WAIT never produces a later unannounced NOD", function()
    party(); lockdown=true; drink(300); advance(4)
    lockdown=false; stopDrink(1000); advance(10); expect(#calls==0)
end)

test("a drink already active at reload is a silent baseline", function()
    party(); units.player.mana=300; units.player.auras={{spellId=430}}
    H:Initialize(); advance(4); stopDrink(1000); advance(10); expect(#calls==0)
end)

test("a pending ready signal is cancelled by a new drink or spent mana", function()
    for _,kind in ipairs({"drink","mana"}) do
        reset(); party(); drink(300); advance(4); stopDrink(1000)
        if kind=="drink" then drink(500)
        else units.player.mana=800; H:HandleMana("player","MANA"); units.player.mana=1000 end
        advance(10); expect(#calls==1,kind)
    end
end)

test("a mana break cannot carry its ready signal into another party", function()
    party(); drink(300); advance(4)
    friend("party1","Bob"); H:HandleManaBreak()
    stopDrink(1000); advance(10); expect(#calls==1)
end)

test("mana-break settings, master off and profiles cancel pending signals", function()
    for _,kind in ipairs({"waitOff","readyOff","masterOff","profile"}) do
        reset(); party(); H:SaveProfile("saved"); drink(300); advance(4)
        if kind=="waitOff" then H:SetScenarioValue("manaBreak","mode","off")
        elseif kind=="readyOff" then H:SetScenarioValue("manaReady","mode","off")
        elseif kind=="masterOff" then H:SetEnabled(false)
        else H:LoadProfile("saved") end
        stopDrink(1000); advance(10); expect(#calls==1,kind)
    end
end)

test("drinking suppresses idle and party-joke reactions", function()
    party(); drink(500); advance(4)
    H.db.scenarios.idleYawn.chance=100; H.state.nextPartyJokeAt=clock
    advance(601); H:OnTick(); advance(4)
    expect(#calls==1 and calls[1].token=="WAIT")
end)

test("a mana break does not add a second WAIT for a distant party member", function()
    party(); units.party1.far=true; drink(300); advance(4)
    H.state.partyFarSince=clock-30; H:HandlePartyDistance(); advance(10)
    expect(#calls==1 and calls[1].token=="WAIT")
end)

test("legacy UnitBuff detection uses the spell ID rather than localized text", function()
    local modern=C_UnitAuras; C_UnitAuras=nil
    party(); drink(300,430); advance(4)
    C_UnitAuras=modern
    expect(#calls==1 and calls[1].token=="WAIT")
end)

local function pet()
    units.pet={name="Wolf",guid="Pet-1",hp=1000,npc=true}
    H:HandleEvent("UNIT_PET","player")
end
local function petHealth(hp)
    units.pet.hp=hp; H:HandleEvent("UNIT_HEALTH","pet")
end

test("pet danger warns once per drop and rearms after real recovery", function()
    pet(); H:StartCombat(); petHealth(200); advance(2)
    expect(#calls==1 and calls[1].token=="HELPME" and calls[1].target=="Wolf")
    petHealth(100); advance(100); petHealth(200); advance(2); expect(#calls==1)
    petHealth(700); petHealth(200); advance(2); expect(#calls==2)
end)

test("the player's emergency outranks a simultaneous pet warning", function()
    pet(); H:StartCombat(); petHealth(200)
    units.player.hp=100; H:HandlePlayerHealth(); advance(2)
    expect(#calls==1 and calls[1].token=="FLEE")
end)

test("healed, dismissed or replaced pets cancel a queued warning", function()
    for _,kind in ipairs({"healed","dismissed","replaced"}) do
        reset(); pet(); H:StartCombat(); petHealth(200)
        if kind=="healed" then petHealth(900)
        elseif kind=="dismissed" then units.pet=nil; H:HandleEvent("UNIT_PET","player")
        else units.pet.guid="Pet-2"; H:HandleEvent("UNIT_PET","player") end
        advance(10); expect(#calls==0,kind)
    end
end)

test("pet health outside combat and low-health initialization are silent", function()
    pet(); petHealth(200); advance(5); expect(#calls==0)
    H:InitializeUnitState(); H:StartCombat(); petHealth(150); advance(5); expect(#calls==0)
end)

test("confirmed pet death is mourned once after combat", function()
    pet(); H:StartCombat(); petHealth(0); advance(3); expect(#calls==0)
    combatInfo={[2]="UNIT_DIED",[8]="Pet-1"}; H:HandleCombatLog()
    H:HandleEvent("UNIT_HEALTH","pet"); H:EndCombat(); advance(10)
    expect(#calls==1 and (calls[1].token=="MOURN" or calls[1].token=="CRY") and calls[1].target=="Wolf")
    H:HandleCombatLog(); advance(10); expect(#calls==1)
end)

test("combat-log pet death stays silent when its recipient has disappeared", function()
    pet(); friend("target"); units.pet=nil; H:HandleEvent("UNIT_PET","player")
    combatInfo={[2]="UNIT_DIED",[8]="Pet-1"}; H:HandleCombatLog(); advance(10)
    expect(#calls==0 and units.target.name=="Alice")
end)

test("dismissal, missing health and an unrelated death are not pet death", function()
    pet(); units.pet.dead=false; petHealth(0); advance(2)
    units.pet=nil; H:HandleEvent("UNIT_PET","player")
    combatInfo={[2]="UNIT_DIED",[8]="Other-Pet"}; H:HandleCombatLog(); advance(10)
    expect(#calls==0)
end)

test("reviving or replacing a pet cancels pending mourning", function()
    for _,kind in ipairs({"revived","replaced"}) do
        reset(); pet(); H:StartCombat(); petHealth(0); advance(2)
        if kind=="replaced" then units.pet.guid="Pet-2" end
        petHealth(1000); H:EndCombat(); advance(10); expect(#calls==0,kind)
    end
end)

test("pet death does not cause emotes while the owner is dead", function()
    pet(); units.player.hp=0; petHealth(0); advance(10); expect(#calls==0)
end)

test("off and manual pet scenarios remain silent", function()
    for _,mode in ipairs({"off","manual"}) do
        reset(); pet(); H:SetScenarioValue("petDanger","mode",mode); H:SetScenarioValue("petDeath","mode",mode)
        H:StartCombat(); petHealth(200); advance(2); petHealth(0); H:EndCombat(); advance(10)
        expect(#calls==0,mode)
    end
end)

test("upgrades keep Quiet quiet and export all four new scenario choices", function()
    HCVoiceCharDB={schemaVersion=162,preset="quiet",scenarios={}}
    H:Initialize()
    for _,key in ipairs({"manaBreak","manaReady","petDanger","petDeath"}) do expect(H.db.scenarios[key].mode=="off",key) end
    H:ApplyPreset("classicRP"); H:SetScenarioValue("petDeath","mode","manual")
    local exported=H:ExportProfile(); expect(H:ImportProfile(exported))
    expect(H.db.scenarios.manaBreak.mode=="automatic" and H.db.scenarios.petDeath.mode=="manual")
end)

test("dungeons automatically answer directed emotes without popup choices", function()
    local cases = {
        { "Alice waves at you.", "WAVE" },
        { "Alice flirts with you.", "FLIRT" },
        { "Alice hugs you.", "HUG" },
        { "Alice insults you.", "NO" },
        { "Alice cries out for healing.", "NOD" },
        { "Alice asks you to wait.", "NOD" },
        { "Alice is out of mana.", "WAIT" },
        { "Alice whistles at you.", "WHISTLE" },
        { "Alice sighs at you.", "SIGH" },
        { "Alice yawns at you.", "WAIT" },
        { "Alice is terribly bored with you.", "JOKE" },
    }
    for _, item in ipairs(cases) do
        reset(); instanceType="party"; friend("target", "Alice"); H.db.reply.autoChance=0
        emote(item[1], "Alice", false, "PlayerOne"); advance(3)
        expect(#calls==1 and calls[1].token==item[2] and calls[1].target=="Alice", item[1])
        expect(H.GUI.replyFrame==nil, item[1] .. " opened a popup")
    end
end)

test("dungeon replies work during combat despite the outdoor combat preference", function()
    instanceType="party"; H:StartCombat()
    expect(H.db.reply.disableAutoInCombat)
    emote("Alice cries out for healing.", "Alice", false, "PlayerOne"); advance(3)
    expect(#calls==1 and calls[1].token=="NOD" and H.GUI.replyFrame==nil)
end)

test("automatic dungeon requests choose WAIT when casting or low on mana", function()
    for _, busy in ipairs({ "casting", "mana" }) do
        reset(); instanceType="party"
        if busy=="casting" then units.player.casting="Heal" else units.player.mana=100 end
        emote("Alice cries out for healing.", "Alice", false, "PlayerOne"); advance(3)
        expect(#calls==1 and calls[1].token=="WAIT", busy)
    end
end)

test("dungeon reply choices are rechecked before a delayed answer", function()
    instanceType="party"
    emote("Alice cries out for healing.", "Alice", false, "PlayerOne"); units.player.mana=100; advance(3)
    expect(#calls==0 and H.GUI.replyFrame==nil, "sent a stale ready answer")
    reset(); instanceType="party"; friend("target", "Alice")
    emote("Alice flirts with you."); units.target=nil; advance(3)
    expect(#calls==0 and H.GUI.replyFrame==nil, "sent an unverified intimate reply")
end)

test("dungeons keep conversation cooldowns and stop reply chains", function()
    instanceType="party"
    emote("Alice asks you to wait."); advance(3)
    emote("Alice nods at you."); advance(10)
    emote("Alice asks you to wait."); advance(35)
    emote("Alice asks you to wait."); advance(3)
    expect(#calls==1 and calls[1].token=="NOD" and H.GUI.replyFrame==nil)
end)

test("dungeon emergencies keep priority over automatic social answers", function()
    instanceType="party"; H:StartCombat()
    emote("Alice cries out for healing.", "Alice", false, "PlayerOne")
    units.player.hp=100; H:HandlePlayerHealth(); advance(3)
    expect(calls[1] and calls[1].token=="FLEE" and H.GUI.replyFrame==nil)
end)

test("dungeon automation honors explicit off settings and ignored players", function()
    for _, setting in ipairs({ "master", "replies", "mode", "category", "ignored" }) do
        reset(); instanceType="party"
        if setting=="master" then H:SetEnabled(false)
        elseif setting=="replies" then H.db.reply.enabled=false
        elseif setting=="mode" then H.db.reply.mode="off"
        elseif setting=="category" then H.db.reply.categories.hostile=false
        else H:IgnoreReplyPlayer("Player-Alice", "Alice") end
        emote("Alice insults you."); advance(10)
        expect(#calls==0 and H.GUI.replyFrame==nil, setting)
    end
end)

test("blocked dungeon replies stay silent without a fallback popup", function()
    instanceType="party"; lockdown=true
    emote("Alice insults you."); advance(10)
    expect(#calls==0 and H.GUI.replyFrame==nil)
end)

test("custom, unknown and non-directed dungeon emotes stay silent", function()
    instanceType="party"; H.db.reply.categories.unknown=true
    emote("Alice flirts with you.", "Alice", true)
    emote("Alice puzzles at you."); emote("Alice whistles.")
    emote("Alice flirts with Bob.", "Alice", false, "Bob"); advance(10)
    expect(#calls==0 and H.GUI.replyFrame==nil)
end)

test("entering a dungeon closes a visible outdoor reply without answering it", function()
    emote("Alice flirts with you."); expect(H.GUI.replyFrame:IsShown())
    instanceType="party"; H:HandleEvent("PLAYER_ENTERING_WORLD"); advance(15)
    expect(not H.GUI.replyFrame:IsShown() and H.GUI.replyFrame.data==nil and #calls==0)
end)

test("dungeons block direct and preview popup calls", function()
    instanceType="party"
    H.GUI:ShowReplyPrompt({kind="reply",sender="Alice",playerKey="Player-Alice",category="hostile",needsSuggestion=true,options={"NO"}})
    H.GUI:ShowReplyPrompt({kind="reply",sender="Alice",needsSuggestion=true,options={"NO"},test=true})
    expect(H.GUI.replyFrame==nil and #calls==0)
end)

test("leaving a dungeon cancels queued replies even before the world event", function()
    instanceType="party"; emote("Alice insults you.")
    instanceType="none"; advance(10)
    expect(#calls==0 and H.GUI.replyFrame==nil)
end)

test("leaving a dungeon restores outdoor popup and combat behavior", function()
    instanceType="party"; emote("Alice insults you.")
    instanceType="none"; H:HandleEvent("PLAYER_ENTERING_WORLD"); advance(10)
    expect(#calls==0 and H.GUI.replyFrame==nil)
    emote("Alice flirts with you."); expect(H.GUI.replyFrame:IsShown())
    H.GUI:HideReplyPrompt(); H:StartCombat()
    emote("Bob waves at you.", "Bob"); advance(3); expect(#calls==0)
end)

test("raid and battleground instances retain the existing reply choices", function()
    for _, kind in ipairs({ "none", "raid", "pvp", "arena", "scenario" }) do
        reset(); instanceType=kind
        emote("Alice flirts with you."); advance(3)
        expect(#calls==0 and H.GUI.replyFrame:IsShown(), kind)
    end
end)

local function petEnemy(unit, guid)
    units[unit or "target"] = {name="Enemy",guid=guid or "Creature-Enemy",hp=1000,hostile=true,npc=true}
end

test("a pet attack command produces one prompt CHARGE without issuing commands", function()
    pet(); petEnemy(); PetAttack(); advance(0.8)
    expect(#calls==1 and calls[1].token=="CHARGE" and calls[1].target=="Wolf")
    expect(petCommandCalls==1 and H.GUI.replyFrame==nil and #messages==0)
end)

test("pet commands work through moved pet-bar slots without double hooks", function()
    pet(); petEnemy()
    petControls.slots={[6]="PET_ACTION_ATTACK",[8]="PET_ACTION_FOLLOW",[3]="PET_ACTION_WAIT"}
    CastPetAction(6); advance(3); CastPetAction(8); advance(3)
    expect(#calls==2 and calls[1].token=="CHARGE" and calls[2].token=="WHISTLE")
    expect(petCommandCalls==2 and H.GUI.replyFrame==nil)
    H:Initialize(); H:Initialize()
    expect(petHookRegistrations.PetAttack==1 and petHookRegistrations.PetFollow==1 and petHookRegistrations.CastPetAction==1)
end)

test("pet attack accepts an explicit mouseover target and ignores later player targets", function()
    pet(); petEnemy("mouseover"); friend("target")
    PetAttack("mouseover"); petEnemy("target", "Creature-Other"); advance(1)
    expect(#calls==1 and calls[1].token=="CHARGE")
end)

test("pet command confirmation tolerates short server delay", function()
    pet(); petEnemy(); petCommandDelay=0.35
    PetAttack(); advance(0.2); expect(#calls==0)
    advance(0.8); expect(#calls==1 and calls[1].token=="CHARGE")
end)

test("rejected commands and friendly, dead or missing targets do not shout", function()
    for _,kind in ipairs({"blocked","friendly","dead","missing"}) do
        reset(); pet(); petEnemy()
        if kind=="blocked" then petCommandBlocked=true
        elseif kind=="friendly" then units.target.hostile=false
        elseif kind=="dead" then units.target.hp=0
        else units.target=nil end
        PetAttack(); advance(5); expect(#calls==0 and H.GUI.replyFrame==nil,kind)
    end
end)

test("automatic pet defense and an enemy dying do not create command voices", function()
    pet(); petEnemy(); applyPetCommand("attack"); advance(3)
    petControls.attack=false; units.pettarget=nil; units.pet.fighting=false
    H:HandleEvent("PET_BAR_UPDATE"); advance(3)
    expect(#calls==0 and H.GUI.replyFrame==nil)
end)

test("calling back a defending pet or a pet on Stay whistles once", function()
    for _,kind in ipairs({"defending","stay"}) do
        reset(); pet(); petEnemy()
        if kind=="defending" then applyPetCommand("attack")
        else petControls.mode="stay"; H:HandleEvent("PET_BAR_UPDATE") end
        PetFollow(); advance(1)
        expect(#calls==1 and calls[1].token=="WHISTLE" and calls[1].target=="Wolf",kind)
        PetFollow(); advance(12); PetFollow(); advance(2); expect(#calls==1,kind)
    end
end)

test("Follow beside the player and other pet abilities stay silent", function()
    pet(); petControls.slots[4]="Bite"
    PetFollow(); CastPetAction(4); advance(4)
    expect(#calls==0)
end)

test("repeated attacks and target changes during one fight do not spam CHARGE", function()
    pet(); petEnemy(); H:StartCombat()
    for i=1,5 do PetAttack(); advance(0.1) end
    advance(12); petEnemy("target","Creature-Other"); PetAttack(); advance(3)
    expect(#calls==1 and calls[1].token=="CHARGE")
    PetFollow(); advance(3); PetAttack(); advance(3)
    expect(#calls==2 and calls[2].token=="WHISTLE")
end)

test("pet attack rearms for a later fight with an eight-second cooldown", function()
    pet(); petEnemy(); PetAttack(); advance(1)
    petControls.attack=false; units.pettarget=nil; units.pet.fighting=false
    H:HandleEvent("PET_BAR_UPDATE"); PetAttack(); advance(1); expect(#calls==1)
    petControls.attack=false; units.pettarget=nil; units.pet.fighting=false
    H:HandleEvent("PET_BAR_UPDATE"); advance(9); PetAttack(); advance(1)
    expect(#calls==2)
end)

test("recalling the pet cancels a CHARGE that has not played", function()
    pet(); petEnemy(); PetAttack(); advance(0.12); PetFollow(); advance(3)
    expect(#calls==1 and calls[1].token=="WHISTLE")
end)

test("a new attack cancels an obsolete queued recall", function()
    pet(); petEnemy(); applyPetCommand("attack")
    PetFollow(); advance(0.12); PetAttack(); advance(3)
    expect(#calls==1 and calls[1].token=="CHARGE")
end)

test("pet recall works in dungeon combat during serious danger", function()
    instanceType="party"; pet(); petEnemy(); H:StartCombat(); applyPetCommand("attack")
    H.state.seriousUntil=clock+30; PetFollow(); advance(2)
    expect(#calls==1 and calls[1].token=="WHISTLE" and H.GUI.replyFrame==nil)
end)

test("urgent danger outranks pet command audio", function()
    pet(); petEnemy(); H:StartCombat(); PetAttack()
    units.player.hp=100; H:HandlePlayerHealth(); advance(0.8)
    expect(#calls==1 and calls[1].token=="FLEE")
end)

test("dead, dismissed and replaced pets cancel pending pet voices", function()
    for _,kind in ipairs({"dead","dismissed","replaced","owner-dead"}) do
        reset(); pet(); petEnemy(); PetAttack(); advance(0.12)
        if kind=="dead" then units.pet.hp=0
        elseif kind=="dismissed" then units.pet=nil
        elseif kind=="replaced" then units.pet.guid="Pet-Other"
        else units.player.hp=0 end
        advance(3); expect(#calls==0,kind)
    end
end)

test("an ended attack or changed pet target cancels queued CHARGE", function()
    for _,kind in ipairs({"ended","target-changed","enemy-dead"}) do
        reset(); pet(); petEnemy(); PetAttack(); advance(0.12)
        if kind=="ended" then petControls.attack=false
        elseif kind=="target-changed" then petEnemy("pettarget","Creature-Other")
        else units.pettarget.hp=0 end
        advance(3); expect(#calls==0,kind)
    end
end)

test("off, manual, Quiet, reload and profile changes cancel pet voices", function()
    for _,kind in ipairs({"off","manual","quiet","reload","profile"}) do
        reset(); pet(); petEnemy(); PetAttack(); advance(0.12)
        if kind=="off" then H:SetEnabled(false)
        elseif kind=="manual" then H:SetScenarioValue("petAttack","mode","manual")
        elseif kind=="quiet" then H:ApplyPreset("quiet")
        elseif kind=="reload" then H:HandleEvent("PLAYER_ENTERING_WORLD")
        else H:ApplyPreset("balanced") end
        advance(3); expect(#calls==0,kind)
    end
end)

test("pet command client restrictions never fall back to a popup", function()
    pet(); petEnemy(); lockdown=true; PetAttack(); advance(3); PetFollow(); advance(3)
    expect(#calls==0 and H.GUI.replyFrame==nil)
end)

test("pet command upgrades preserve preferences and populate both new scenarios", function()
    HCVoiceCharDB={schemaVersion=163,preset="quiet",scenarios={petDeath={mode="manual"}}}
    H:Initialize()
    expect(H.db.schemaVersion==170 and H.db.scenarios.petAttack.mode=="off" and H.db.scenarios.petRecall.mode=="off")
    expect(H.db.scenarios.petDeath.mode=="manual")
    H:ApplyPreset("classicRP"); H:SetScenarioValue("petRecall","mode","manual")
    expect(H:ImportProfile(H:ExportProfile()))
    expect(H.db.scenarios.petAttack.mode=="automatic" and H.db.scenarios.petRecall.mode=="manual")
    expect(#H.scenarioDefinitions==36)
end)

local petReactionKeys = {"petAttack", "petRecall", "petDanger", "petDeath"}
local function queuePetReaction(key)
    pet()
    if key=="petAttack" then
        petEnemy("mouseover"); PetAttack("mouseover")
    elseif key=="petRecall" then
        petControls.mode="stay"; H:HandleEvent("PET_BAR_UPDATE"); PetFollow()
    elseif key=="petDanger" then
        H:StartCombat(); petHealth(200)
    else
        H:StartCombat(); petHealth(0); H:EndCombat()
    end
end

test("all pet reactions keep the pet recipient when selected players change", function()
    for _,key in ipairs(petReactionKeys) do
        reset(); friend("target", "Alice"); queuePetReaction(key); advance(0.12)
        friend("target", "Bob"); advance(5)
        expect(#calls==1 and calls[1].target=="Wolf",key)
        expect(units.target.name=="Bob" and #messages==0,key)
        expect(next(H.state.social.encounters)==nil,key)
    end
end)

test("pet recipients use the current name of the verified pet", function()
    for _,key in ipairs(petReactionKeys) do
        reset(); friend("target"); queuePetReaction(key); advance(0.12)
        units.pet.name="Snowfang"; advance(5)
        expect(#calls==1 and calls[1].target=="Snowfang",key)
    end
end)

test("missing pet names never fall back to a selected player", function()
    for _,key in ipairs(petReactionKeys) do
        for _,missingName in ipairs({false, ""}) do
            reset(); friend("target"); queuePetReaction(key); advance(0.12)
            units.pet.name=missingName or nil; advance(5)
            expect(#calls==0,key)
        end
    end
end)

test("all pet reactions cancel if the pet disappears or its identity changes", function()
    for _,key in ipairs(petReactionKeys) do
        for _,change in ipairs({"missing", "replaced"}) do
            reset(); friend("target"); queuePetReaction(key); advance(0.12)
            if change=="missing" then units.pet=nil
            else units.pet.guid="Pet-Replacement" end
            advance(5); expect(#calls==0,key .. ": " .. change)
        end
    end
end)

test("legacy emotes receive the pet unit for every pet reaction", function()
    local modern, legacy = C_ChatInfo.PerformEmote, DoEmote
    C_ChatInfo.PerformEmote=nil
    DoEmote=function(token, unit)
        calls[#calls+1]={token=token,target=unit,guid=UnitGUID(unit),at=clock}
        return false
    end
    for _,key in ipairs(petReactionKeys) do
        reset(); friend("target"); queuePetReaction(key); advance(5)
        expect(#calls==1 and calls[1].target=="pet" and calls[1].guid=="Pet-1",key)
        expect(units.target.name=="Alice",key)
    end
    C_ChatInfo.PerformEmote, DoEmote = modern, legacy
end)

print("Behavior tests passed: " .. total)
