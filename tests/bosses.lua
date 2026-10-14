-- Appended to behavior.lua by run.cjs so all tests share the real director fixture.
do
local B = H.Bosses
local mapID, hardcore, control = 36, true, true
WOW_PROJECT_CLASSIC, WOW_PROJECT_ID = 2, 2
C_GameRules = { IsHardcoreActive = function() return hardcore end }
function HasFullControl() return control end
function GetInstanceInfo() return "Dungeon", instanceType, 1, "Normal", 5, false, false, mapID end

local function dungeon(map, kind)
    mapID, hardcore, control = map or 36, true, true
    WOW_PROJECT_ID = WOW_PROJECT_CLASSIC
    instanceType = kind or "party"
    grouped = true
    friend("party1", "Zoe")
    H:RefreshRoster(true)
    B:Reset()
    -- Cosmetic tests isolate boss output; survival priority is explicitly tested below.
    for _, key in ipairs({"hardAggro","firstDamage","extraEnemy","welcomeParty","nearDeath"}) do H:SetScenarioValue(key,"mode","off") end
end

local function enemy(id, unit, spawn)
    local guid = "Creature-0-1-1-1-" .. id .. "-" .. (spawn or "00001")
    units[unit or "target"] = { name = "NPC " .. id, guid = guid, hp = 1000, npc = true, hostile = true, classification = "elite" }
    return guid
end

local function log(event, source, dest, spell)
    combatInfo = { [2]=event, [4]=source, [5]="NPC " .. tostring(B:NPCID(source)), [6]=4,
        [8]=dest, [9]="NPC " .. tostring(B:NPCID(dest)), [10]=4, [12]=spell or 100, [13]="Spell", [15]=10 }
    H:HandleCombatLog()
end

local function engage(id, unit)
    local guid = enemy(id, unit)
    H:StartCombat(); units.player.fighting=true
    log("SWING_DAMAGE", guid, UnitGUID("player"))
    return guid
end

local function die(guid)
    log("UNIT_DIED", nil, guid)
    for _, data in pairs(units) do if data.guid==guid then data.hp=0 end end
end

local function leaveCombat()
    units.player.fighting=false
    for _, unit in ipairs(H:GroupUnits()) do if units[unit] then units[unit].fighting=false end end
    H:HandleEvent("PLAYER_REGEN_ENABLED")
end

local function bossCalls(token)
    local n=0
    for _, call in ipairs(calls) do if not token or call.token==token then n=n+1 end end
    return n
end

test("boss catalogue has 230 authored cards and only registered voices or animations", function()
    local n=0
    for key, card in pairs(B.cards) do
        n=n+1
        expect(key==card.key and #card.npcs>0 and #card.rationale>20)
        expect(H:IsVoiceAvailable(card.open) and H:IsVoiceAvailable(card.victory))
        expect(card.open~="HUG" and card.victory~="HUG")
        for _, id in ipairs(card.npcs) do expect(B.byNPC[id]==card) end
    end
    expect(n==230 and #B.dungeonOrder==26)
end)

test("boss opener is automatic targeted and never a popup", function()
    dungeon(); engage(639); advance(1)
    expect(#calls==1 and calls[1].token=="RASP" and calls[1].target=="NPC 639")
    expect(H.GUI.replyFrame==nil)
    log("SWING_DAMAGE",UnitGUID("target"),UnitGUID("player")); advance(20)
    expect(#calls==1)
end)

test("boss target glance does not taunt and sustained attention does", function()
    dungeon(); enemy(639); H:HandleEvent("PLAYER_TARGET_CHANGED"); advance(1)
    enemy(644); H:HandleEvent("PLAYER_TARGET_CHANGED"); advance(3); expect(#calls==0)
    enemy(639); H:HandleEvent("PLAYER_TARGET_CHANGED"); advance(3)
    expect(#calls==1 and calls[1].token=="RASP")
end)

test("opening target changes and movement cancel the queued cosmetic gesture", function()
    for _, kind in ipairs({"target", "movement", "friendly", "casting", "channeling", "control"}) do
        reset(); dungeon(); enemy(639); H:HandleEvent("PLAYER_TARGET_CHANGED"); advance(1.6)
        if kind=="target" then enemy(644)
        elseif kind=="movement" then units.player.speed=5
        elseif kind=="friendly" then units.target.hostile=false
        elseif kind=="casting" then units.player.casting="Fireball"
        elseif kind=="channeling" then units.player.channeling="Drink"
        else control=false end
        advance(4); expect(#calls==0,kind)
    end
    control=true
end)

test("bosses require Era Hardcore and their own map", function()
    for _, kind in ipairs({"era", "hardcore", "wrongmap", "raid", "outside"}) do
        reset(); dungeon()
        if kind=="era" then WOW_PROJECT_ID=1
        elseif kind=="hardcore" then hardcore=false
        elseif kind=="wrongmap" then mapID=43
        elseif kind=="raid" then mapID=409; instanceType="raid"
        else mapID=0; instanceType="none" end
        engage(639); advance(3); expect(#calls==0,kind)
    end
end)

test("unknown NPCs and nearby outsiders do not start boss scenes", function()
    dungeon(); enemy(639)
    log("SWING_DAMAGE",UnitGUID("target"),"Player-Stranger"); advance(3); expect(#calls==0)
    engage(999999); advance(3); expect(#calls==0)
end)

test("group pet participation is recognized and unrelated pets are ignored", function()
    dungeon(); local guid=enemy(639)
    units.partypet1={guid="Pet-0-1-1-1-123-1",name="Pet",hp=1000,npc=true}
    log("SPELL_DAMAGE",guid,"Pet-Stranger"); advance(1); expect(#calls==0)
    log("SPELL_DAMAGE",guid,UnitGUID("partypet1")); advance(1); expect(#calls==1)
end)

test("Sneed's shredder does not produce premature victory", function()
    dungeon(); local shredder=engage(642); advance(13); die(shredder)
    leaveCombat(); advance(5); expect(bossCalls("CHEER")==0)
    local pilot=engage(643); advance(1)
    expect(bossCalls("GASP")==1)
    advance(13); die(pilot); leaveCombat(); advance(6)
    expect(bossCalls("CHEER")==1)
    advance(10); expect(bossCalls("CHEER")==1)
end)

test("bosses wait for the entire group to leave combat before a victory", function()
    dungeon(); local guid=engage(639); advance(13); die(guid)
    units.party1.fighting=true; units.player.fighting=false; H:EndCombat(); B:Tick()
    advance(7); expect(bossCalls("VICTORY")==0)
    units.party1.fighting=false; advance(6); expect(bossCalls("VICTORY")==1)
end)

test("a group pet still fighting postpones the boss conclusion", function()
    dungeon(); local guid=engage(639); advance(13)
    units.partypet1={name="Wolf",guid="Pet-Zoe",hp=1000,fighting=true}
    die(guid); leaveCombat(); advance(6); expect(bossCalls("VICTORY")==0)
    units.partypet1.fighting=false; advance(6); expect(bossCalls("VICTORY")==1)
end)

test("boss combat drop and despawn never prove a kill", function()
    dungeon(); engage(639); advance(13)
    units.target=nil; leaveCombat(); advance(20)
    expect(bossCalls("VICTORY")==0)
end)

test("unobserved deaths never count as the group's boss kill", function()
    dungeon(); local guid=enemy(639); die(guid); advance(20)
    expect(#calls==0)
end)

test("party death suppresses boss celebration even when mourning is off", function()
    dungeon(); local guid=engage(639); advance(13)
    H:SetScenarioValue("partyDeath","mode","off")
    log("UNIT_DIED",nil,UnitGUID("party1")); units.party1.hp=0
    die(guid); leaveCombat(); advance(45)
    expect(bossCalls("VICTORY")==0)
end)

test("urgent survival voice cancels cosmetic boss work", function()
    dungeon(); H:SetScenarioValue("fleeDanger","mode","automatic")
    engage(639); units.player.hp=100; H:HandlePlayerHealth(); advance(3)
    expect(bossCalls("RASP")==0 and bossCalls("FLEE")==1)
end)

test("master off and per-dungeon off cancel already queued boss gestures", function()
    for _, kind in ipairs({"master","dungeon","scenario"}) do
        reset(); dungeon(); engage(639)
        if kind=="master" then H:SetEnabled(false)
        elseif kind=="dungeon" then H.db.bossDungeons.deadmines=false
        else H:SetScenarioValue("bossReactions","mode","off") end
        advance(4); expect(#calls==0,kind)
    end
end)

test("enabling or reloading mid-combat does not fabricate boss observations", function()
    dungeon(); units.player.fighting=true; H:ResetRuntimeState()
    engage(639); advance(4); expect(#calls==0)
    leaveCombat(); advance(16); B:Tick(); engage(639); advance(1)
    expect(bossCalls("RASP")==1)
end)

test("zone and actual roster changes cancel delayed boss reactions", function()
    for _, kind in ipairs({"zone","roster"}) do
        reset(); dungeon(); engage(639)
        if kind=="zone" then mapID=43; H:HandleEvent("PLAYER_ENTERING_WORLD")
        else friend("party2","Bob"); H:HandleEvent("GROUP_ROSTER_UPDATE") end
        advance(4); expect(bossCalls("RASP")==0,kind)
    end
end)

test("same-roster update does not cancel valid boss reactions", function()
    dungeon(); engage(639); H:HandleEvent("GROUP_ROSTER_UPDATE"); advance(1)
    expect(bossCalls("RASP")==1)
end)

test("boss voice lockdown stays silent without fallback popup or retry", function()
    dungeon(); lockdown=true; local guid=engage(639); advance(1); lockdown=false
    log("SWING_DAMAGE",guid,UnitGUID("player")); advance(5)
    expect(#calls==0 and H.GUI.replyFrame==nil)
end)

test("Mograine resurrection clears death evidence and blocks early success", function()
    dungeon(189); local mog=engage(3976); advance(13); die(mog)
    local white=engage(3977); advance(1)
    log("SPELL_CAST_SUCCESS",white,mog,9232); advance(1)
    die(white); leaveCombat(); advance(6); expect(bossCalls("CHEER")==0)
    local liveMog=engage(3976); advance(6); die(liveMog); leaveCombat(); advance(6)
    expect(bossCalls("CHEER")==1)
end)

test("Smite stomp reacts after own stun ends rather than on an estimated timer", function()
    dungeon(); local guid=engage(646); advance(13)
    control=false; log("SPELL_AURA_APPLIED",guid,UnitGUID("player"),6432); advance(10)
    expect(bossCalls("GASP")==0)
    control=true; log("SPELL_AURA_REMOVED",guid,UnitGUID("player"),6432); advance(1)
    expect(bossCalls("GASP")==1)
    log("SPELL_AURA_REMOVED",guid,UnitGUID("player"),6432); advance(15)
    expect(bossCalls("GASP")==1)
end)

test("Gordok victory does not require killing a surviving observer", function()
    dungeon(429); local king=engage(11501); advance(13); die(king); leaveCombat(); advance(6)
    expect(bossCalls("CHEER")==1)
end)

test("Thaurissan victory does not require Moira's death", function()
    dungeon(230); local emperor=engage(9019); advance(13); die(emperor); leaveCombat(); advance(6)
    expect(bossCalls("VICTORY")==1)
end)

test("Dathrohan's guise is not the final death proof", function()
    dungeon(329); local first=engage(10812); advance(13); die(first); leaveCombat(); advance(5)
    expect(bossCalls("VICTORY")==0)
    local demon=engage(10813); advance(13); die(demon); leaveCombat(); advance(6)
    expect(bossCalls("VICTORY")==1)
end)

test("Herod's aftermath gets a longer quiet period", function()
    dungeon(189); local guid=engage(3975); advance(13); die(guid); leaveCombat(); advance(5)
    expect(bossCalls("VICTORY")==0)
    units.party1.fighting=true; advance(4); units.party1.fighting=false; advance(14)
    expect(bossCalls("VICTORY")==1)
end)

test("shared claims elect one participant without creating remote reactions", function()
    dungeon(); units.party1.guid="Player-0"; B:Reset()
    local guid=engage(639)
    B:OnMessage("HCVB1","C|36|deadmines-08|"..guid.."|open","PARTY","Zoe")
    advance(1); expect(#calls==0)
    reset(); dungeon(); local other=enemy(639)
    B:OnMessage("HCVB1","P|36|deadmines-08|"..other.."|open","PARTY","Zoe")
    advance(3); expect(#calls==0)
end)

test("untrusted senders, wrong maps and oversized boss packets are ignored", function()
    dungeon(); local guid=engage(639)
    B:OnMessage("HCVB1","P|36|deadmines-08|"..guid.."|open","PARTY","Stranger")
    B:OnMessage("HCVB1","P|43|deadmines-08|"..guid.."|open","PARTY","Zoe")
    B:OnMessage("HCVB1",string.rep("x",256),"PARTY","Zoe")
    advance(1); expect(#calls==1)
end)

test("legacy hardVictory does not duplicate a registered boss conclusion", function()
    dungeon(); local guid=engage(639); advance(13)
    expect(not H:RequestReaction("hardVictory","NPC 639",guid))
    die(guid); leaveCombat(); advance(6)
    expect(#calls==2 and calls[2].token=="VICTORY")
end)

test("boss preferences migrate export import and preserve quiet", function()
    HCVoiceCharDB={schemaVersion=165,preset="quiet",scenarios={petDeath={mode="manual"}}}
    H:Initialize(); expect(H.db.scenarios.bossReactions.mode=="off")
    expect(H.db.scenarios.petDeath.mode=="manual")
    H:ApplyPreset("classicRP"); H.db.bossDungeons.deadmines=false
    local profile=H:ExportProfile(); expect(H:ImportProfile(profile))
    expect(H.db.bossDungeons.deadmines==false and H.db.bossDungeons.wc==true)
    expect(H.db.scenarios.bossReactions.mode=="automatic")
    H:ApplyPreset("quiet"); expect(H.db.scenarios.bossReactions.mode=="off")
end)

test("UBRS supports raid-sized groups without enabling actual raids", function()
    dungeon(229,"raid"); raid=true; friend("raid1","Zoe"); B:Reset()
    engage(10363); advance(1); expect(bossCalls("SALUTE")==1)
end)

test("Maraudon khans are individual encounters including the outer caves", function()
    dungeon(1,"none"); local guid=engage(13742); advance(13); die(guid); leaveCombat(); advance(6)
    expect(bossCalls("BOW")==2)
    reset(); dungeon(1,"none"); engage(639); advance(3); expect(#calls==0)
end)

test("an untargeted boss observer never claims another player's opening", function()
    dungeon(); engage(639,"party1target"); advance(3)
    expect(#calls==0)
    for _, packet in ipairs(messages) do expect(packet.prefix~="HCVB1") end
end)

test("actual default danger priority preserves the boss-specific conclusion", function()
    dungeon()
    H:SetScenarioValue("hardAggro","mode","automatic")
    H:SetScenarioValue("firstDamage","mode","automatic")
    local guid=engage(639); advance(13)
    expect(bossCalls("RASP")==0 and bossCalls("INCOMING")==1)
    die(guid); leaveCombat(); advance(6)
    expect(bossCalls("VICTORY")==1)
end)

test("new combat and boss speech cancel stale cosmetic output", function()
    dungeon(); local guid=engage(639); advance(13); die(guid); leaveCombat(); advance(4.6)
    units.party1.fighting=true; advance(3); expect(bossCalls("VICTORY")==0)
    reset(); dungeon(); guid=engage(639)
    H:HandleEvent("CHAT_MSG_MONSTER_YELL","Boss speech","NPC 639",nil,nil,nil,nil,nil,nil,nil,nil,nil,guid)
    advance(4); expect(#calls==0)
end)

test("nonexistent phase packets cannot allocate boss claims", function()
    dungeon(); local guid=enemy(639)
    B:OnMessage("HCVB1","C|36|deadmines-08|"..guid.."|phase999999","PARTY","Zoe")
    expect(next(H.state.bosses.claims)==nil)
end)

test("all catalogue encounter completion rules work with confirmed deaths", function()
    for _, card in pairs(B.cards) do
        reset(); dungeon(card.map)
        local guids={}
        for _,id in ipairs(card.npcs) do guids[id]=enemy(id); B:Engage(guids[id],"NPC "..id) end
        local e=B:Encounter(card,guids[card.npcs[1]],false)
        expect(e~=nil,card.key)
        expect(not B:Complete(e),card.key.." early")
        if card.independent then e.dead[card.npcs[1]]=true
        else for id in pairs(card.required) do e.dead[id]=true end end
        expect(B:Complete(e),card.key.." complete")
    end
end)

print("Total behavior tests passed: " .. total)
end
