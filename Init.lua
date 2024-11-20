runID = runID or 1
partyMembers = partyMembers or {}
partyMemberDeaths = partyMemberDeaths or {}
AddRunModal = AddRunModal or {}
ViewRunModal = ViewRunModal or {}
EditRunModal = EditRunModal or {}
runsDB = runsDB or {}
AAASettings = AAASettings or {}

-- Ensure Modal is initialized as a table
MainModal = MainModal or {}
MainModal.listHeaders = { { "Dungeon", "dungeonName" }, { "Time", "currentTimer" }, { "Date", "runDate" }, { "", "" }, { "", "" }  }
MainModal.sortColumn = "dungeonName"
MainModal.sortAscending = true
MainModal.currentTab = "Timed" -- Default tab
MainModal.AddonName = "AAA M+ Additions"
MainModal.currentPage = 1
MainModal.itemsPerPage = 10 -- Number of items to display per page

-- Register your settings category under the "AddOns" section
category = Settings.RegisterVerticalLayoutCategory(MainModal.AddonName)
