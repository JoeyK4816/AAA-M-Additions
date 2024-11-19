runID = runID or 1
partyMembers = partyMembers or {}
partyMemberDeaths = partyMemberDeaths or {}
AddRunModal = AddRunModal or {}
ViewRunModal = ViewRunModal or {}

if not runsDB then
    print("AAA: No existing runs were loaded.")
    runsDB = {}
else
    print("AAA: Loaded with " .. #runsDB .. " tracked runs.")
end

if not AAASettings then
    AAASettings = {}
    print("AAA: No existing Settings were loaded.")
else
    -- print("AAASettings loaded with OnlyTrackMine:" .. tostring(AAASettings["OnlyTrackMine"]) .. " status.")
end

-- Ensure Modal is initialized as a table
MainModal = MainModal or {}
MainModal.listHeaders = { { "Dungeon", "dungeonName" }, { "Time", "currentTimer" }, { "Date", "runDate" }, { "", "" }, { "", "" }  }
MainModal.sortColumn = "dungeonName"
MainModal.sortAscending = true
MainModal.currentTab = "Timed" -- Default tab
MainModal.AddonName = "AAA M+ Additions"

-- Register your settings category under the "AddOns" section
category = Settings.RegisterVerticalLayoutCategory(MainModal.AddonName)