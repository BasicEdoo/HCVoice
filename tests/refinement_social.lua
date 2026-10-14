-- Appended to behavior.lua to exercise the real event handlers and director.
do
local function receivedBuff(name)
    combatInfo = { [2]="SPELL_AURA_APPLIED", [4]="Player-"..name, [5]=name, [6]=3,
        [8]="Player-1", [9]="PlayerOne", [10]=3, [12]=1459, [13]="Arcane Intellect" }
    H:HandleCombatLog()
end

test("each new buff giver can be thanked after another giver was thanked", function()
    receivedBuff("Alice"); advance(3)
    receivedBuff("Bob"); advance(10)
    receivedBuff("Clara"); advance(10)
    expect(#calls==3 and calls[1].target=="Alice" and calls[2].target=="Bob" and calls[3].target=="Clara")
end)

test("eight simultaneous buff givers survive default and maximum spacing", function()
    for _, spacing in ipairs({8,60}) do
        reset(); H.db.globalCooldown=spacing
        for index=1,8 do receivedBuff("Giver"..index) end
        advance(spacing*8+10)
        local thanked = {}
        for _, call in ipairs(calls) do
            expect(call.token=="THANK" and not thanked[call.target], "duplicate or unrelated response")
            thanked[call.target] = true
        end
        expect(#calls==8, "lost a distinct buff giver at spacing "..spacing)
    end
end)

test("buff gratitude has a bounded forty-recipient capacity", function()
    for index=1,45 do receivedBuff("Giver"..index) end
    advance(0.5)
    expect(#H.state.reactionQueue==40)
end)

test("ignoring one pending buff giver preserves other givers", function()
    receivedBuff("Alice"); receivedBuff("Bob"); advance(0.5)
    H:IgnoreReplyPlayer("Player-Alice","Alice"); advance(20)
    expect(#calls==1 and calls[1].target=="Bob")
end)

test("disabling the addon cancels the separate buff gratitude queue", function()
    for index=1,8 do receivedBuff("Giver"..index) end
    advance(0.5); H:SetEnabled(false); advance(100)
    expect(#calls==0 and #H.state.reactionQueue==0)
end)

test("repeated buffs from the same giver still produce only one thanks", function()
    receivedBuff("Alice"); receivedBuff("Alice"); advance(3)
    receivedBuff("Alice"); advance(70)
    expect(#calls==1 and calls[1].target=="Alice")
end)

test("pending buff thanks still cancel when combat starts", function()
    for index=1,8 do receivedBuff("Giver"..index) end
    advance(3); local before=#calls
    H:StartCombat(); advance(90)
    expect(#calls==before and #H.state.reactionQueue==0)
end)

test("buff thanks still honor an explicit scenario switch off", function()
    receivedBuff("Alice"); advance(3)
    H:SetScenarioValue("thankBuff","mode","off")
    receivedBuff("Bob"); advance(20)
    expect(#calls==1 and calls[1].target=="Alice")
end)

test("a typed hug or flirt cancels a queued dungeon reply at short spacing", function()
    for _, item in ipairs({ {"hugs","hug"}, {"flirts with","flirt with"} }) do
        reset(); H.db.globalCooldown=2; instanceType="party"; friend("target","Alice")
        emote("Alice "..item[1].." you.")
        emote("You "..item[2].." Alice.","PlayerOne")
        advance(10); expect(#calls==0, item[2].." was answered twice")
    end
end)

test("manual replies support accented recipients and same realm suffixes", function()
    H.db.globalCooldown=2; instanceType="party"; friend("target","Élodie")
    emote("Élodie hugs you.","Élodie-TestRealm")
    emote("You hug Élodie-TestRealm.","PlayerOne")
    advance(10); expect(#calls==0)
end)

test("answering one player leaves another player's pending answer intact", function()
    H.db.globalCooldown=2
    emote("Alice waves at you.")
    emote("Bob waves at you.","Bob")
    emote("You nod at Alice.","PlayerOne")
    advance(10)
    expect(#calls==1 and calls[1].target=="Bob")
end)

test("a manual hearty greeting resolves its recipient before descriptive text", function()
    H.db.globalCooldown=2
    emote("Alice waves at you.")
    emote("You greet Alice with a hearty hello!","PlayerOne")
    advance(10); expect(#calls==0)
end)

test("a new exchange can follow a manual answer to the same player", function()
    H.db.globalCooldown=2; instanceType="party"; friend("target","Alice")
    emote("Alice hugs you.")
    emote("You hug Alice.","PlayerOne")
    advance(3); emote("Alice thanks you."); advance(3)
    expect(#calls==1 and calls[1].token=="WELCOME")
end)

test("a typed answer closes only the matching player's suggestion", function()
    friend("target","Alice"); emote("Alice hugs you.")
    emote("You nod at Bob.","PlayerOne")
    expect(H.GUI.replyFrame:IsShown())
    emote("You hug Alice.","PlayerOne")
    expect(not H.GUI.replyFrame:IsShown() and H.GUI.replyFrame.data==nil)
end)

test("a chosen popup response cancels another queued answer to that player", function()
    H.db.globalCooldown=2; friend("target","Alice")
    emote("Alice waves at you."); emote("Alice hugs you.")
    local button=H.GUI.replyFrame.replyButtons[1]
    button.scripts.OnClick(button)
    advance(10)
    expect(#calls==1 and calls[1].token=="HUG")
end)

test("a targeted Voice Lab emote completes the pending social exchange", function()
    H.db.globalCooldown=2; friend("target","Alice")
    emote("Alice waves at you.")
    H:PlayVoice("BOW",true); advance(10)
    expect(#calls==1 and calls[1].token=="BOW")
end)

test("custom nearby joke prose never triggers an automatic Living World answer", function()
    H.db.livingWorld.mode="auto"
    local originalRandom=math.random
    math.random=function() return 0 end
    emote("Alice jokes about Bob.","Alice",true)
    advance(20)
    math.random=originalRandom
    expect(#calls==0 and not H.GUI.replyFrame)
end)

test("own emotes stay silent through social and Living World entry points", function()
    H.db.livingWorld.mode="auto"
    emote("You joke.","PlayerOne-TestRealm")
    H.LivingWorld:HandleVisibleEmote({sender="PlayerOne",message="PlayerOne jokes.",
        guid="Player-1",classification={incomingToken="LAUGH",safe=true},directed=false})
    advance(20); expect(#calls==0)
end)

test("the player's GUID prevents replies even if the sender name is unexpected", function()
    H:HandleSocialEvent("CHAT_MSG_TEXT_EMOTE","Alias waves at you.","Alias",nil,nil,"PlayerOne",
        nil,nil,nil,nil,nil,1,"Player-1")
    advance(10); expect(#calls==0)
end)
end
