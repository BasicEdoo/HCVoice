-- Appended to behavior.lua by run.cjs; uses the real profile and director fixture.
do
local before = total

test("invalid profile imports preserve settings and pending runtime state", function()
    H.db.enabled = false
    H.db.frequency = 5
    H.db.thresholds.healing = 39
    H.db.ui.replyPosition = { point = "TOPLEFT", x = 12, y = 34 }
    local originalDB, originalState = H.db, H.state
    local originalQueue = H.state.reactionQueue
    originalQueue[1] = { scenario = "greetPlayer", token = "HELLO" }
    local invalid = {
        "HCVOICE_PROFILE_V1;",
        "HCVOICE_PROFILE_V1;unrecognized=value",
        "HCVOICE_PROFILE_V1;frequency=25;broken",
        "HCVOICE_PROFILE_V1;frequency=25;;enabled=1",
        "HCVOICE_PROFILE_V1;frequency=25;enabled=",
        "HCVOICE_PROFILE_V1;frequency=25;enabled=yes",
        "HCVOICE_PROFILE_V1;frequency=invalid",
        "HCVOICE_PROFILE_V1;frequency=1e999",
        "HCVOICE_PROFILE_V1;frequency=-1e999",
        "HCVOICE_PROFILE_V1;reply.mode=unknown",
        "HCVOICE_PROFILE_V1;living.mode=unknown",
        "HCVOICE_PROFILE_V1;scenario.greetPlayer.mode=unknown",
        "HCVOICE_PROFILE_V1;scenario.greetPlayer.chance=invalid",
        "HCVOICE_PROFILE_V1;reply.category.greetings=invalid",
        "HCVOICE_PROFILE_V1;enabled=invalid;enabled=1",
        "HCVOICE_PROFILE_V1;frequency=invalid;frequency=25",
        "HCVOICE_PROFILE_V1;frequency=25;frequency=30",
        "HCVOICE_PROFILE_V1;frequency=25=30",
    }
    for _, text in ipairs(invalid) do
        local ok, message = H:ImportProfile(text)
        expect(not ok and type(message) == "string", text)
        expect(H.db == originalDB and HCVoiceCharDB == originalDB, "replaced settings: " .. text)
        expect(H.state == originalState and H.state.reactionQueue == originalQueue and #originalQueue == 1, "cancelled runtime: " .. text)
        expect(not H.db.enabled and H.db.frequency == 5 and H.db.thresholds.healing == 39, "changed settings: " .. text)
        expect(H.db.ui.replyPosition.x == 12 and H.db.ui.replyPosition.y == 34, "lost position: " .. text)
    end
end)

test("profile imports validate known dungeon switches before replacing settings", function()
    local key = H.Bosses.dungeonOrder[1]
    local originalDB = H.db
    expect(not H:ImportProfile("HCVOICE_PROFILE_V1;frequency=25;boss.dungeon." .. key .. "=invalid"))
    expect(H.db == originalDB)
    expect(H:ImportProfile("HCVOICE_PROFILE_V1;boss.dungeon." .. key .. "=false"))
    expect(H.db.bossDungeons[key] == false)
end)

test("behavior profile round trips preserve local window and diagnostic preferences", function()
    H.db.ui.replyPosition = { point = "TOPLEFT", x = 12, y = 34 }
    H.db.debug = true
    H.db.announceLoaded = false
    H.db.frequency = 35
    H:SetScenarioValue("greetPlayer", "mode", "manual")
    local exported = H:ExportProfile()
    expect(not exported:find("replyPosition", 1, true) and not exported:find("debug", 1, true))
    H.db.frequency = 85
    expect(H:ImportProfile(exported))
    expect(H.db.frequency == 35 and H.db.scenarios.greetPlayer.mode == "manual")
    expect(H.db.ui.replyPosition.point == "TOPLEFT" and H.db.ui.replyPosition.x == 12 and H.db.ui.replyPosition.y == 34)
    expect(H.db.debug == true and H.db.announceLoaded == false)
end)

test("older partial profiles preserve supported values and retain newer settings", function()
    H:SetScenarioValue("petRecall", "mode", "off")
    local text = "HCVOICE_PROFILE_V1;enabled=false;frequency=25;thresholds.healing=40;reply.mode=auto;living.mode=suggest;scenario.greetPlayer.mode=manual;scenario.socialFarewell.mode=suggest;scenario.buffPlayer.mode=off;future.option=value;"
    expect(H:ImportProfile(text))
    expect(not H.db.enabled and H.db.frequency == 25 and H.db.thresholds.healing == 40)
    expect(H.db.reply.mode == "hybrid" and H.db.livingWorld.mode == "hybrid")
    expect(H.db.scenarios.greetPlayer.mode == "manual")
    expect(H.db.scenarios.socialFarewell.mode == "automatic")
    expect(H.db.scenarios.petRecall.mode == "off")
    expect(H.db.scenarios.buffPlayer == nil)
end)

test("profiles cut at a field boundary cannot reset omitted behavior", function()
    H.db.frequency = 15
    H.db.globalCooldown = 19
    H.db.reply.enabled = false
    H.db.reply.mode = "off"
    H.db.livingWorld.enabled = false
    H.db.livingWorld.mode = "off"
    H.db.thresholds.healing = 37
    H:SetScenarioValue("greetPlayer", "mode", "manual")
    local dungeon = H.Bosses.dungeonOrder[1]
    H.db.bossDungeons[dungeon] = false
    expect(H:ImportProfile("HCVOICE_PROFILE_V1;enabled=1"))
    expect(H.db.enabled and H.db.frequency == 15 and H.db.globalCooldown == 19)
    expect(not H.db.reply.enabled and H.db.reply.mode == "off")
    expect(not H.db.livingWorld.enabled and H.db.livingWorld.mode == "off")
    expect(H.db.thresholds.healing == 37 and H.db.scenarios.greetPlayer.mode == "manual")
    expect(H.db.bossDungeons[dungeon] == false)
end)

test("valid profile imports cancel queued work and retain session ignores", function()
    H:IgnoreReplyPlayer("Player-Alice", "Alice")
    H.state.reactionQueue[1] = { scenario = "greetPlayer", token = "HELLO" }
    local originalState = H.state
    expect(H:ImportProfile("HCVOICE_PROFILE_V1;frequency=20"))
    expect(H.state ~= originalState and #H.state.reactionQueue == 0)
    expect(H.state.reply.ignored["Player-Alice"] and H.state.reply.ignored[H.NameKey("Alice")])
end)

print("Profile refinement tests passed: " .. (total - before))
end
