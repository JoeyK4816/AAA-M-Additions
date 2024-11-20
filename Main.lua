frame = MainModal.Create()
listFrame = MainModal.CreateList()
currentSeasonID = GetCurrentSeason()
killerDamage = {}
activeRunID = 0

-- Add a button to open the modal
addRunButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
addRunButton:SetSize(120, 25)
addRunButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
addRunButton:SetText("Add Run")

-- Create the modal and connect it to the button
AddRunModal.Create(frame, addRunButton)

addRunButton:SetScript("OnClick", function()
    AddRunModal:Show()
end)

Icon = LibStub("LibDBIcon-1.0")
Icon:Register("AAA_Additions", LDB, {})

-- Register event to listen for timer start in Mythic+
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
frame:RegisterEvent("CHALLENGE_MODE_START")
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

function frame:OnEvent (event, arg1)
    if event == "ADDON_LOADED" and arg1 == "AAA_Additions" then
        print("AAA: AAA M+ Additions Addon loaded! Type /AAA to view runs or /CCC to open settings.")

        -- Initial sort and display of the list
        MainModal.sortItems()
        MainModal.updateList()
        playerName, playerRealm = UnitName("player")

        -- Register category under the AddOn section
        loadSettings()
        category.ID = MainModal.AddonName
        Settings.RegisterAddOnCategory(category)
    end

    if event == "GROUP_ROSTER_UPDATE" and partyMembers then
        if not C_ChallengeMode.IsChallengeModeActive() then
            return
        end

        if not activeRunID then
            return
        end
        
        if not AAASettings["TrackIncomplete"] then
            removeRun(activeRunID)
        end

        local status = "incomplete"
        local note = ""
        local formattedTime = nil
        local unknown, timeElapsed, type = GetWorldElapsedTime(1)
        
        if timeElapsed then
            formattedTime = convertSecondsToString(timeElapsed)
        end

        local currentPartyMembers = GetCurrentPartyMembers()

        -- Detect who left
        for name in pairs(partyMembers) do
            if not currentPartyMembers[name] then
                note = string.format("%s has left the party.", name)
            end
        end
        
        updateRun( status, formattedTime, note )
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
        local _ = addRun()
    end

    if event == "CHALLENGE_MODE_COMPLETED" then
        if not activeRunID then
            return
        end

        -- Retrieve details about the completed dungeon
        local mapID, level, timeElapsed, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo()

        -- Get dungeon name
        local dungeonName = C_ChallengeMode.GetMapUIInfo(mapID)

        if AAASettings["OnlyTrackTimed"] and not onTime then
            removeRun(activeRunID)
            return
        end

        -- Determine result
        local result = onTime and "on time!" or "but not on time."
        local formattedTime = convertSecondsToString( timeElapsed )

        -- Construct chat message
        local message = string.format(
            "AAA: %s (Level %d) completed in %s %s",
            dungeonName, level, formattedTime, result
        )

        -- Add keystone upgrades if applicable
        if keystoneUpgradeLevels and keystoneUpgradeLevels > 0 then
            message = message .. string.format(" Keystone upgraded by +%d!", keystoneUpgradeLevels)
        end

        -- Send the message to the chat
        SendChatMessage(message, "PARTY")
        
        updateRun("timed", formattedTime, "Run Completed Successfully")
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not C_ChallengeMode.IsChallengeModeActive() then
            return
        end
        if not activeRunID then
            return
        end

        local _, subevent, _, _, sourceName, _, _, _, destName, _, _, amount, spellName, spellSchool, spellAmount = CombatLogGetCurrentEventInfo()

        if subevent == "UNIT_DIED" then
            if AAASettings["HideDeathMessage"] == true then
                return
            end

            local isPartyUnit = isPartyUnit(destName)

            if not isPartyUnit then
                return
            end

            local formattedTime, timeElapsed, type = GetWorldElapsedTime(1)
            if timeElapsed then
                formattedTime = convertSecondsToString( timeElapsed )
            end

            if killerDamage[destName] then
                print("AAA: Death log for " .. (destName or "Unknown") .. ":")
                for _, combatLog in ipairs(killerDamage[destName]) do
                    print(combatLog.message)
                end
    
                table.insert(partyMemberDeaths, {
                    time = formattedTime,
                    player = destName,
                    log = killerDamage[destName]
                })

                killerDamage[destName] = nil
            else
                print("AAA: No recorded damage for " .. (destName or "Unknown") .. ".")
            end
        end

        if subevent == "SWING_DAMAGE" or subevent == "SPELL_DAMAGE" then
            local isPartyUnit = isPartyUnit(destName)

            if not isPartyUnit then
                return
            end
            local damageType = "Melee"
            local hitAmount
            if subevent == "SPELL_DAMAGE" then
                hitAmount = spellAmount
                damageType = string.format(
                    "%s [%s]",
                    spellName,
                    amount
                )
            else
                hitAmount = amount
            end
            -- Format the damage hitAmount with commas
            local formattedAmount = BreakUpLargeNumbers(hitAmount)

            -- Construct the message
            local deathMessage = string.format(
                "%s was hit by %s's %s hit for %s",
                destName or "Unknown",
                sourceName or "Unknown",
                damageType or "Melee",
                formattedAmount
            )

            if not killerDamage[destName] then
                killerDamage[destName] = {}
            end

            table.insert(killerDamage[destName], {
                player = destName,
                killer = sourceName,
                damageType = damageType,
                amount = formattedAmount,
                message = deathMessage
            })

            if #killerDamage[destName] > 5 then
                table.remove(killerDamage[destName], 1) -- Remove the oldest entry
            end
        end
    end
end

frame:SetScript("OnEvent", frame.OnEvent);

if not runsDB then
    print("AAA: No existing runs were loaded.")
    runsDB = {}
else
    print("AAA: Loaded with " .. #runsDB .. " tracked runs.")
end

if not AAASettings then
    AAASettings = {}
    print("AAA: No existing Settings were loaded.")
end