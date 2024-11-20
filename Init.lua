runID = runID or 1
partyMembers = partyMembers or {}
partyMemberDeaths = partyMemberDeaths or {}
AddRunModal = AddRunModal or {}
ViewRunModal = ViewRunModal or {}
runsDB = runsDB or {}
AAASettings = AAASettings or {}

-- Ensure Modal is initialized as a table
MainModal = MainModal or {}
MainModal.listHeaders = { { "Dungeon", "dungeonName" }, { "Time", "currentTimer" }, { "Date", "runDate" }, { "", "" }, { "", "" }  }
MainModal.sortColumn = "dungeonName"
MainModal.sortAscending = true
MainModal.currentTab = "Timed" -- Default tab
MainModal.AddonName = "AAA M+ Additions"

-- Register your settings category under the "AddOns" section
category = Settings.RegisterVerticalLayoutCategory(MainModal.AddonName)
