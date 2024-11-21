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
MainModal.listHeaders = {
    order = { "dungeonName", "currentTimer", "runDate", "status", "level", "role", "view", "delete" },
    data = {
        dungeonName = {
            prettyName = "Dungeon",
            width = 160
        },
        currentTimer = {
            prettyName = "Time",
            width = 90
        },
        runDate = {
            prettyName = "Date",
            width = 90
        },
        status = {
            prettyName = "Status",
            width = 90
        },
        level = {
            prettyName = "Level",
            width = 60
        },
        role = {
            prettyName = "Role",
            width = 90
        },
        view = {
            prettyName = "",
            width = 60
        },
        delete = {
            prettyName = "",
            width = 60
        }
    }
}

MainModal.sortColumn = "dungeonName"
MainModal.sortAscending = true
MainModal.currentTab = "Timed" -- Default tab
MainModal.AddonName = "AAA M+ Additions"
MainModal.currentPage = 1
MainModal.itemsPerPage = 10 -- Number of items to display per page

-- Register your settings category under the "AddOns" section
category = Settings.RegisterVerticalLayoutCategory(MainModal.AddonName)
