function GetCurrentSeason()
    local seasonID = C_MythicPlus.GetCurrentSeason()
    if seasonID then
        -- print("Current Mythic+ Season ID:", C_MythicPlus.GetCurrentAffixes)
        return seasonID
    else
        -- print("No active Mythic+ season.")
        return nil
    end
end

function GetPartyMemberSpec(unit)
    if not UnitExists(unit) then
        return "No Unit", "No Unit"
    end

    local specID = GetInspectSpecialization(unit)
    if specID and specID > 0 then
        local _, specName, _, _, role = GetSpecializationInfoByID(specID)
        return specName, role
    else
        return "Unknown", "Unknown Role"
    end
end

function GetPartyMemberSpecs()
    local partyMembers = {}
    local numGroupMembers = GetNumGroupMembers()
    for i = 1, numGroupMembers + 1 do
        local unitID = IsInRaid() and "raid" .. i or (i == numGroupMembers and "player" or "party" .. i)
        local name = UnitName(unitID)
        local class = UnitClass(unitID) -- Retrieves the player's class
        local specID = GetInspectSpecialization(unitID) -- Retrieves the player's spec ID
        local role = UnitGroupRolesAssigned(unitID) 
        local specName
        
        if specID and specID > 0 then
            local _, ttt = GetSpecializationInfoByID(specID)
            specName = ttt -- Spec name, e.g., "Restoration"
        end
        -- table.insert(partyMembers, name)

        if name then
            partyMembers[name] = {
                class = class,           -- Human-readable class name
                role = role,           -- Human-readable class name
                spec = specName or "Unknown", -- Spec name or "Unknown" if unavailable
            }
        end
    end
    return partyMembers
end

function CheckGroupStatus()
    -- Check if the player is in a group
    local inGroup = IsInGroup()
    print("Group: " .. (inGroup and "Yes" or "No"))

    if not inGroup then return end

    -- Check if the player is in a dungeon
    local inInstance, instanceType, _, _, _, _, _, instanceMapID = IsInInstance()
    local inDungeon = (inInstance and instanceType == "party")
    print("Dungeon: " .. (inDungeon and "Yes" or "No"))

    -- If the player is in a dungeon, get the dungeon name
    if inDungeon then
        local dungeonName = GetInstanceInfo()  -- GetInstanceInfo() gives the dungeon name directly
        print("Dungeon Name: " .. dungeonName)
    end

    -- Get party members
    local partyMembers = {}
    for i = 1, GetNumGroupMembers() + 1 do
        local name = GetRaidRosterInfo(i)
        table.insert(partyMembers, name)
    end
    print("Party: " .. table.concat(partyMembers, ", "))

    if not inDungeon then return end

    -- Check dungeon difficulty
    local difficultyID = select(3, GetInstanceInfo())
    local isMythic = (difficultyID == 23) -- Mythic difficulty ID
    print("Mythic: " .. (isMythic and "Yes" or "No"))

    if not isMythic then return end

    -- Player role, class, and spec
    local role = UnitGroupRolesAssigned("player")
    local _, class = UnitClass("player")
    local specID = GetSpecialization()
    local specName = specID and select(2, GetSpecializationInfo(specID)) or "Unknown"

    print("Role: " .. role)
    print("Class: " .. class)
    print("Specialization: " .. specName)

    local keystoneLevel, keystoneAffixes, keystoneDungeonID = C_ChallengeMode.GetActiveKeystoneInfo()
    
    if keystoneLevel and keystoneDungeonID then
        local dungeonName = C_ChallengeMode.GetMapInfo(keystoneDungeonID)
        print("Keystone Level: " .. keystoneLevel)

        -- List the affixes (if applicable)
        if keystoneAffixes then
            local affixNames = {}
            for i = 1, #keystoneAffixes do
                local affixName = C_ChallengeMode.GetAffixInfo(keystoneAffixes[i])
                table.insert(affixNames, affixName)
            end
            print("Affixes: " .. table.concat(affixNames, ", "))
        end
    else
        print("No active keystone found.")
    end
end

function PrintTable(t, indent)

    if type(t) ~= "table" then
        print("Not a table:", tostring(t))
        return
    end


    indent = indent or 0
    local indentStr = string.rep("  ", indent) -- Indentation for readability


    for key, value in pairs(t) do
        local valueType = type(value)
        if valueType == "table" then
            print(indentStr .. tostring(key) .. ":")
            PrintTable(value, indent + 1) -- Recursive call for subtables
        else
            print(indentStr .. tostring(key) .. ": " .. tostring(value))
        end
    end


end

function GetRunByID(runID)
    for _, run in ipairs(runsDB) do
        if run.id == runID then
            return run
        end
    end
    print("Run with ID " .. runID .. " not found.")
    return false
end

function DeleteRunByID(runID)
    for index, run in ipairs(runsDB) do
        if run.id == runID then
            table.remove(runsDB, index) -- Remove the run from the table
            print("Run with ID " .. runID .. " has been deleted.")
            return true
        end
    end
    print("Run with ID " .. runID .. " not found.")
    return false
end

function GetDungeonNameByID(dungeonID)
    -- Open the Encounter Journal (necessary for the API to work)
    EncounterJournal_LoadUI()

    -- Set the journal instance by ID
    local name = EJ_GetInstanceInfo(dungeonID)
    if name then
        return name
    else
        return "Unknown Dungeon"
    end
end

function GetDungeonNameByMapID(mapID)
    if not mapID then
        return "Unknown Dungeon"
    end

    -- Retrieve the dungeon name and icon using the map ID
    local name, _, _ = C_ChallengeMode.GetMapUIInfo(mapID)

    if name then
        return name
    else
        return "Unknown Dungeon"
    end
end

function GetPlayerSpecName()
    local specIndex = GetSpecialization()

    if not specIndex then
        return "No specialization"
    end

    local specID, specName, _, _, role = GetSpecializationInfo(specIndex)
    
    -- print( "specIndex: " )
    -- print( specIndex )
    -- print( "specID: " )
    -- print( specID )
    -- print( "specName: " )
    -- print( specName )

    return specName
end

function GetAffixNamesFromString(affixString)
    if not affixString or affixString == "" then
        return "None"
    end

    local affixNames = {}
    for affixID in string.gmatch(affixString, "%d+") do
        affixID = tonumber(affixID)
        if affixID then
            local name = C_ChallengeMode.GetAffixInfo(affixID)
            if name then
                table.insert(affixNames, name)
            else
                table.insert(affixNames, "Unknown Affix (" .. affixID .. ")")
            end
        end
    end

    return table.concat(affixNames, ", ")
end

function GetPlayerRoleFromSpec()
    
    local GroupRole = UnitGroupRolesAssigned("player")
    if not ( GroupRole == "NONE" ) then
        return GroupRole
    end

    local specIndex = GetSpecialization()
    if not specIndex then
        -- print( "No specIndex" )
        return "NONE"
    end

    local _, _, _, _, role = GetSpecializationInfo(specIndex)
    -- print("GetSpecializationInfo:")
    -- print(role)
    return role
end

function OnPlayerDeathEvent()
    local formattedTime, timeElapsed, type = GetWorldElapsedTime(1)

    if timeElapsed then
        -- Calculate hours, minutes, and seconds
        local hours = math.floor(timeElapsed / 3600)
        local minutes = math.floor((timeElapsed % 3600) / 60)
        local seconds = timeElapsed % 60
    
        -- Format the string as hh:mm:ss
        formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end

    -- Send the chat message
    local overkillText = overkill and overkill > 0 and (" (Overkill: " .. overkill .. ")") or ""
    local message = string.format(
        "%s was killed by %s (SpellID: %s) for %d damage%s.",
        destName or "Unknown",
        sourceName or "Unknown",
        spellID or "Unknown",
        amount or 0,
        overkillText
    )
    print("overkillText")
    print(overkillText)

    -- Print the message in chat
    -- SendChatMessage(message, "PARTY")
    
    table.insert(partyMemberDeaths, {
        time = formattedTime,
        player = destName,
        overkill = overkillText,
        source = sourceName,
        spell = spellID,
        amount = amount,
    })

    print( "partyMemberDeaths: " )
    PrintTable(partyMemberDeaths)
end

function OnDungeonResetEvent(self, event, ...)
    if event == "INSTANCE_RESET_FAILED" then
        SendChatMessage("Dungeon reset failed.", "PARTY")
    elseif event == "INSTANCE_RESET_SUCCESS" then
        SendChatMessage("Dungeon reset successful.", "PARTY")
    end
end