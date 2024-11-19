frame = MainModal.Create()
listFrame = MainModal.CreateList()
currentSeasonID = GetCurrentSeason()

-- Add a button to open the modal
addRun = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
addRun:SetSize(120, 25)
addRun:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
addRun:SetText("Add Run")

-- Create the modal and connect it to the button
AddRunModal.Create(frame, addRun)

addRun:SetScript("OnClick", function()
    AddRunModal:Show()
end)

Icon = LibStub("LibDBIcon-1.0")
Icon:Register("AAA_Additions", LDB, {})

-- Register event to listen for timer start in Mythic+
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
frame:RegisterEvent("CHALLENGE_MODE_START")
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

function frame:OnEvent (event, arg1)
    if event == "ADDON_LOADED" and arg1 == "AAA_Additions" then
        print("AAA: M+ Additions Addon loaded! Type /AAA to view runs or /CCC to open settings.")

        -- Initial sort and display of the list
        MainModal.sortItems()
        MainModal.updateList()

        -- Register category under the AddOn section
        loadSettings()
        category.ID = MainModal.AddonName
        Settings.RegisterAddOnCategory(category)
    end

    if event == "PLAYER_LOGIN" then
        local rowCount = #runsDB
        if rowCount == 0 then
            print("AAA: No existing runs were loaded.")
            
            local playerName, playerRealm = UnitName("player")
            local character = playerRealm and (playerName .. "-" .. playerRealm) or playerName
            local specName = GetPlayerSpecName()

            runsDB = {
                {
                    id = runID,
                    dungeonName = 353,
                    currentTimer = "00:59:59.99",
                    runDate = date("%Y-%m-%d %H:%M:%S"),
                    level = "2",
                    affixes = "147",
                    status = "incomplete",
                    season = GetCurrentSeason() or 0,
                    party = GetPartyMemberSpecs(),
                    deaths = partyMemberDeaths,
                    role = GetPlayerRoleFromSpec(),
                    character = character,
                    spec = specName,
                    note = "Testing"
                },
            }
            runID = runID + 1
        end
    end

    if event == "GROUP_ROSTER_UPDATE" and partyMembers then
        if not C_ChallengeMode.IsChallengeModeActive() then
            return
        end

        local status = "incomplete"
        local formattedTime = "00:00:00"
        local note = ""
        local unknown, timeElapsed, type = GetWorldElapsedTime(1)
        
        if timeElapsed then
            -- Calculate hours, minutes, and seconds
            local hours = math.floor(timeElapsed / 3600)
            local minutes = math.floor((timeElapsed % 3600) / 60)
            local seconds = timeElapsed % 60
        
            -- Format the string as hh:mm:ss
            local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end

        local currentPartyMembers = GetCurrentPartyMembers()

        -- Detect who left
        for name in pairs(partyMembers) do
            if not currentPartyMembers[name] then
                note = string.format("%s has left the party.", name)
            end
        end

        abandonRun( status, formattedTime, note )
    end

    if event == "CHALLENGE_MODE_START" then
        local keystoneLevel, keystoneAffixes, keystoneDungeonID = C_ChallengeMode.GetActiveKeystoneInfo()
        if AAASettings["OnlyTrackMine"] then 
            if keystoneLevel and keystoneDungeonID then
                local currentDungeonID = C_ChallengeMode.GetActiveChallengeMapID()
                if not currentDungeonID == keystoneDungeonID then
                    return
                end
            end
        end
        partyMembers = GetPartyMemberSpecs()
        addRun()
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not C_ChallengeMode.IsChallengeModeActive() then
            return
        end
        local timestamp, subevent, _, sourceGUID, sourceName, _, _, _, destName, destFlags, _, amount, overkillOne, overkillOne, gggggg, fffffff, overkillTwo  = CombatLogGetCurrentEventInfo()
        -- print("-------------------")
        -- print("COMBAT_LOG_EVENT_UNFILTERED")
        -- print(subevent)
        -- print(sourceGUID)
        -- print(sourceName)
        -- print(destGUID)
        -- print(destFlags)
        -- print(recapID)
        -- print(GetDeathRecapLink(recapID))
        -- print("-------------------")
        -- Check if the subevent is a death event and if the destination is a player
        if subevent == "SWING_DAMAGE" then
            print("SWING_DAMAGE")
            print(destName)
            print("----")
            print(amount)
            print("----")
            print(overkillOne)
            print("----")
            print(gggggg)
            print("----")
            print(fffffff)
            print("----")
            print(overkillTwo)
            print("----")
            if overkillOne > 0  then
                -- Verify that the destination is a player (use destFlags)
                -- print("!!!!!!!!!!!!! KILLED !!!!!!!!!!!!!")
                -- print(amount)
            end
        end



        -- if subevent == "SPELL_DAMAGE" then
        --     print("SPELL_DAMAGE")
        --     if overkillTwo > 0  then
        --         -- Verify that the destination is a player (use destFlags)
        --         print("!!!!!!!!!!!!! KILLED !!!!!!!!!!!!!")
        --         print(overkillTwo)
        --     end
        -- end
        -- if subevent == "UNIT_DIED" then
        --     -- Verify that the destination is a player (use destFlags)
        --     if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
        --         print("!!!!!!!!!!!!! KILLED !!!!!!!!!!!!!")
        --         OnPlayerDeathEvent()
        --     end
        -- end
    end

    if event == "CHALLENGE_MODE_COMPLETED" then
        -- Retrieve details about the completed dungeon
        local mapID, level, time, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo()

        -- Get dungeon name
        local dungeonName = C_ChallengeMode.GetMapUIInfo(mapID)

        -- Determine result
        local result = onTime and "on time!" or "but not on time."

        -- Construct chat message
        local message = string.format(
            "Congratulations! You completed %s (Level %d) in %d seconds %s",
            dungeonName, level, time, result
        )

        -- Add keystone upgrades if applicable
        if keystoneUpgradeLevels and keystoneUpgradeLevels > 0 then
            message = message .. string.format(" Keystone upgraded by +%d!", keystoneUpgradeLevels)
        end

        -- Send the message to the chat
        SendChatMessage(message, "PARTY")
    end
end

frame:SetScript("OnEvent", frame.OnEvent);

