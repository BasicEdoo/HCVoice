local function refinementHostileHit(guid, amount)
    combatInfo = { [2] = "SWING_DAMAGE", [4] = guid, [5] = guid, [6] = 4,
        [8] = "Player-1", [9] = "PlayerOne", [10] = 3, [12] = amount }
    H:HandleCombatLog()
end

local function refinementEnemyDies(guid)
    combatInfo = { [2] = "UNIT_DIED", [8] = guid }
    H:HandleCombatLog()
end

test("ordinary opening damage stays calm", function()
    units.player.hp = 980
    refinementHostileHit("Creature-A", 20)
    advance(3)
    expect(#calls == 0)
end)

test("rapid hostile damage above healing danger calls for help once", function()
    units.player.hp = 880; refinementHostileHit("Creature-A", 120)
    advance(0.2)
    units.player.hp = 760; refinementHostileHit("Creature-A", 120)
    advance(0.2)
    units.player.hp = 700; refinementHostileHit("Creature-A", 60)
    advance(2)
    units.player.hp = 650; refinementHostileHit("Creature-A", 50)
    advance(2)
    expect(#calls == 1 and calls[1].token == "HELPME")
end)

test("danger burst works with health before or after the combat log", function()
    for _, healthFirst in ipairs({ true, false }) do
        reset(); H:StartCombat()
        if healthFirst then units.player.hp = 700; H:HandlePlayerHealth() end
        refinementHostileHit("Creature-A", 300)
        if not healthFirst then units.player.hp = 700; H:HandlePlayerHealth() end
        advance(2)
        expect(#calls == 1 and calls[1].token == "HELPME", tostring(healthFirst))
    end
end)

test("steady recovery prevents damage accumulation from becoming panic", function()
    units.player.hp = 750; H:StartCombat()
    for _ = 1, 5 do
        units.player.hp = 650; refinementHostileHit("Creature-A", 100)
        H:HandlePlayerHealth()
        units.player.hp = 750; H:HandlePlayerHealth()
        advance(0.2)
    end
    advance(2)
    expect(#calls == 0)
end)

test("meaningful recovery cancels a pending help call", function()
    H:SetScenarioValue("hugeHit", "mode", "off")
    H:PlayVoice("HELLO")
    units.player.hp = 650; refinementHostileHit("Creature-A", 350)
    advance(0.2)
    units.player.hp = 750; H:HandlePlayerHealth()
    advance(2)
    H:HandlePlayerHealth(); advance(1)
    expect(#calls == 1 and calls[1].token == "HELLO")
    expect(H:GetDecisionText():find("pressure eased", 1, true))
end)

test("old damage does not turn a slow fight into a damage burst", function()
    units.player.hp = 850; refinementHostileHit("Creature-A", 150)
    advance(4.1)
    units.player.hp = 700; refinementHostileHit("Creature-A", 150)
    advance(2)
    expect(#calls == 0)
end)

test("healing and emergency thresholds outrank the new help trigger", function()
    for _, case in ipairs({ { 400, "HEALME" }, { 100, "FLEE" } }) do
        reset(); H:StartCombat()
        units.player.hp = case[1]
        refinementHostileHit("Creature-A", 1000 - case[1])
        H:HandlePlayerHealth(); advance(3)
        expect(#calls == 1 and calls[1].token == case[2], case[2])
    end
end)

test("a canceled unplayed healing call does not consume the next drop", function()
    H:PlayVoice("HELLO"); H:StartCombat()
    units.player.hp = 300; H:HandlePlayerHealth()
    units.player.hp = 550; H:HandlePlayerHealth(); advance(0.1)
    units.player.hp = 300; H:HandlePlayerHealth(); advance(2)
    expect(#calls == 2 and calls[2].token == "HEALME")
end)

test("a canceled unplayed emergency call does not consume the next drop", function()
    H:PlayVoice("HELLO"); H:StartCombat()
    units.player.hp = 100; H:HandlePlayerHealth()
    units.player.hp = 250; H:HandlePlayerHealth(); advance(0.1)
    units.player.hp = 100; H:HandlePlayerHealth(); advance(2)
    expect(#calls == 2 and calls[2].token == "FLEE")
end)

test("partial emergency recovery restores an unplayed healing warning", function()
    H:StartCombat()
    units.player.hp = 150; H:HandlePlayerHealth()
    units.player.hp = 300; H:HandlePlayerHealth()
    advance(2)
    expect(#calls == 1 and calls[1].token == "HEALME")
end)

test("a played emergency retains its recovery hysteresis", function()
    H:StartCombat()
    units.player.hp = 150; H:HandlePlayerHealth(); advance(2)
    units.player.hp = 300; H:HandlePlayerHealth(); advance(2)
    units.player.hp = 150; H:HandlePlayerHealth(); advance(2)
    expect(#calls == 1 and calls[1].token == "FLEE")
end)

test("a dead enemy is not counted as a second attacker in a continuous fight", function()
    refinementHostileHit("Creature-A", 10)
    refinementEnemyDies("Creature-A")
    refinementHostileHit("Creature-B", 10)
    advance(2)
    expect(#calls == 0)
    expect(H:GetActiveCombatEnemyCount() == 1)
end)

test("a queued incoming call is canceled when the additional enemy dies", function()
    H:PlayVoice("HELLO")
    refinementHostileHit("Creature-A", 10)
    refinementHostileHit("Creature-B", 10)
    refinementEnemyDies("Creature-B")
    advance(2)
    expect(#calls == 1)
    expect(H:GetDecisionText():find("additional enemy gone", 1, true))
end)

test("a canceled incoming call can warn about the next living attacker", function()
    H:PlayVoice("HELLO")
    refinementHostileHit("Creature-A", 10)
    refinementHostileHit("Creature-B", 10)
    refinementEnemyDies("Creature-B"); advance(0.1)
    refinementHostileHit("Creature-C", 10); advance(2)
    expect(#calls == 2 and calls[2].token == "INCOMING")
end)

test("a canceled elite warning does not silence later living adds", function()
    units.target = { guid = "Creature-Elite", name = "Elite", hp = 1000,
        npc = true, hostile = true, classification = "elite" }
    H:StartCombat(); refinementHostileHit("Creature-Elite", 10)
    refinementEnemyDies("Creature-Elite"); advance(1)
    refinementHostileHit("Creature-A", 10)
    refinementHostileHit("Creature-B", 10); advance(2)
    expect(#calls == 1 and calls[1].token == "INCOMING")
end)
