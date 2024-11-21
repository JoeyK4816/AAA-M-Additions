function MainModal.Create()
    local frame = CreateFrame("Frame", "AAA_AdditionsFrame", UIParent, "BasicFrameTemplateWithInset")

    -- Create the main frame
    frame:SetSize(800, 600) -- Adjusted height for tabs
    frame:SetPoint("CENTER", UIParent, "CENTER") -- Position in the center of the screen
    frame:SetFrameStrata("DIALOG") -- Ensure it renders above other frames
    frame:SetFrameLevel(50) -- Set a high level to be above child elements
    frame:Hide() -- Start hidden

    -- Add a title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -5)
    frame.title:SetText(MainModal.AddonName)

    -- Create tab buttons
    MainModal.CreateFilterUI(frame)
    MainModal.prevPageButton, MainModal.nextPageButton = MainModal.CreatePagination(frame)

    return frame
end

function MainModal.CreateFilterUI(frame)
    -- Statuses Dropdown
    local dropdown = CreateFrame("Frame", "FilterDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
    UIDropDownMenu_SetWidth(dropdown, 150) -- Set dropdown width
    UIDropDownMenu_SetText(dropdown, "All Statuses") -- Default value
    local items = { "All Statuses", "Timed", "Un-Timed", "Incomplete", "Started" }
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for _, item in ipairs(items) do
            info.text = item
            info.checked = (item == UIDropDownMenu_GetText(dropdown))
            info.func = function()
                UIDropDownMenu_SetText(dropdown, item)
                MainModal.currentStatusFilter = item
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Levels Dropdown
    local dropdown = CreateFrame("Frame", "FilterDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 190, -30)
    UIDropDownMenu_SetWidth(dropdown, 150) -- Set dropdown width
    UIDropDownMenu_SetText(dropdown, "All Levels") -- Default value
    local items = { "All Levels", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19" }
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for _, item in ipairs(items) do
            info.text = item
            info.checked = (item == UIDropDownMenu_GetText(dropdown))
            info.func = function()
                UIDropDownMenu_SetText(dropdown, item)
                MainModal.currentLevelFilter = item
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Roles Dropdown
    local dropdown = CreateFrame("Frame", "FilterDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -65)
    UIDropDownMenu_SetWidth(dropdown, 150) -- Set dropdown width
    UIDropDownMenu_SetText(dropdown, "All Roles") -- Default value

    -- Map display names to internal role values
    local items = {
        { display = "All Roles", value = nil },
        { display = "Dps", value = "DAMAGER" },
        { display = "Healer", value = "HEALER" },
        { display = "Tank", value = "TANK" }
    }

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for _, item in ipairs(items) do
            info.text = item.display
            info.checked = (item.value == MainModal.currentRoleFilter)
            info.func = function()
                UIDropDownMenu_SetText(dropdown, item.display)
                MainModal.currentRoleFilter = item.value
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Dungeons Dropdown
    local dropdown = CreateFrame("Frame", "FilterDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 190, -65)
    UIDropDownMenu_SetWidth(dropdown, 150) -- Set dropdown width
    UIDropDownMenu_SetText(dropdown, "All Dungeons") -- Default value
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)


        local info = UIDropDownMenu_CreateInfo()
        info.text = "All Dungeons"
        info.arg1 = "All Dungeons"
        info.func = function()
            UIDropDownMenu_SetText(dropdown, "All Dungeons")
            MainModal.currentDungeonFilter = "All Dungeons"
        end
        UIDropDownMenu_AddButton(info)


        local chestTimeInfo = GetMythicPlusChestTimes()
        for mapID, dung in pairs(chestTimeInfo) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = dung.name
            info.arg1 = mapID
            info.func = function()
                UIDropDownMenu_SetText(dropdown, dung.name)
                MainModal.currentDungeonFilter = mapID
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Filter button
    local filterButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    filterButton:SetSize(80, 22)
    filterButton:SetText("Filter")
    filterButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -15, -35)
    filterButton:SetScript("OnClick", function()
        MainModal.updateList()
    end)

    -- Checkbox
    local checkbox = CreateFrame("CheckButton", "OnlyShowCharacterCheckbox", frame, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPRIGHT", filterButton, "TOPLEFT", 0, 5)
    checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkbox.text:SetPoint("RIGHT", checkbox, "LEFT", 0, 0)
    checkbox.text:SetText("Only show this character")
    checkbox:SetScript("OnClick", function(self)
        MainModal.onlyShowThisCharacter = self:GetChecked()
        MainModal.updateList()
    end)
end

-- function MainModal.CreateTabs(frame)
--     -- Create container for tabs
--     frame.tabs = {}

--     local tabs = { "Timed", "Un-Timed", "Incomplete", "Started" }
--     local tabWidth = 80
--     local tabHeight = 22
--     local tabSpacing = 10 -- Space between tabs
--     local totalWidth = (#tabs * tabWidth) + ((#tabs - 1) * tabSpacing)
--     local startX = (frame:GetWidth() - totalWidth) / 2 -- Center the tabs horizontally

--     for i, tabName in ipairs(tabs) do
--         local tab = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
--         tab:SetSize(tabWidth, tabHeight)
--         tab:SetPoint("TOPLEFT", frame, "TOPLEFT", startX + (i - 1) * (tabWidth + tabSpacing), -30)
--         tab:SetText(tabName)

--         tab:SetScript("OnClick", function()
--             MainModal.currentTab = tabName
--             MainModal.updateList()
--         end)

--         frame.tabs[tabName] = tab
--     end
-- end

function MainModal.CreateList()
    -- Create a container for the list
    local currentWidth = 0
    local listFrame = CreateFrame("Frame", nil, frame)
    listFrame:SetSize(750, 450) -- Adjust size for content
    listFrame:SetPoint("TOP", frame, "TOP", 0, -100)

    -- Add column headers with sorting functionality

    for _, column in ipairs(MainModal.listHeaders.order) do
        local headerData = MainModal.listHeaders.data[column]
        local width = headerData.width
        local headerText = headerData.prettyName
        local header = CreateFrame("Button", nil, listFrame)
        header:SetPoint("TOPLEFT", listFrame, "TOPLEFT", currentWidth, 0)
        header:SetSize(width, 20) -- Width, Height
        currentWidth = currentWidth + width

        header.text = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header.text:SetText(headerText)
        header.text:SetPoint("CENTER")

        header:SetScript("OnClick", function()
            if MainModal.sortColumn == column then
                MainModal.sortAscending = not MainModal.sortAscending
            else
                MainModal.sortColumn = column
                MainModal.sortAscending = true
            end
            MainModal.sortItems()
            MainModal.updateList()
        end)
    end

    return listFrame
end

function MainModal.CreatePagination(frame)
    -- Create pagination buttons
    local prevPageButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    prevPageButton:SetSize(80, 25)
    prevPageButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
    prevPageButton:SetText("Previous")
    prevPageButton:SetScript("OnClick", function()
        if MainModal.currentPage > 1 then
            MainModal.currentPage = MainModal.currentPage - 1
            MainModal.updateList()
        end
    end)

    local nextPageButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    nextPageButton:SetSize(80, 25)
    nextPageButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    nextPageButton:SetText("Next")
    nextPageButton:SetScript("OnClick", function()
        local filteredRuns = MainModal.filterRuns()
        local totalPages = math.ceil(#filteredRuns / MainModal.itemsPerPage)
        if MainModal.currentPage < totalPages then
            MainModal.currentPage = MainModal.currentPage + 1
            MainModal.updateList()
        end
    end)
    prevPageButton:Hide()
    nextPageButton:Hide()

    return prevPageButton, nextPageButton
end

function MainModal.sortItems()
    if not runsDB then
        return
    end

    table.sort(runsDB, function(a, b)
        local aValue = a[MainModal.sortColumn]
        local bValue = b[MainModal.sortColumn]

        -- Handle nil values: treat nil as less than any other value
        if aValue == nil and bValue == nil then
            return false -- Keep original order if both are nil
        elseif aValue == nil then
            return MainModal.sortAscending -- Place nils at the start or end based on sort direction
        elseif bValue == nil then
            return not MainModal.sortAscending -- Place nils at the start or end based on sort direction
        end

        -- Compare non-nil values
        if MainModal.sortAscending then
            return aValue < bValue
        else
            return aValue > bValue
        end
    end)
end

function MainModal.updateList()
    if MainModal.currentPage == 1 then
        MainModal.prevPageButton:Hide()
    else
        MainModal.prevPageButton:Show()
    end

    -- Clear existing rows
    if listFrame.rows then
        for _, row in ipairs(listFrame.rows) do
            for _, element in ipairs(row) do
                element:Hide()
            end
        end
    end

    -- Generate list rows based on the selected tab
    listFrame.rows = {}
    local filteredRuns = MainModal.filterRuns()
    local startIndex = (MainModal.currentPage - 1) * MainModal.itemsPerPage + 1
    local endIndex = math.min(startIndex + MainModal.itemsPerPage - 1, #filteredRuns)

    if endIndex >= #filteredRuns then
        MainModal.nextPageButton:Hide()
    else
        MainModal.nextPageButton:Show()
    end

    for i = startIndex, endIndex do
        local item = filteredRuns[i]
        local row = {}
        local dungeonName = GetDungeonNameByMapID(item.dungeonName)
        local currentX = 0

        -- Name column
        local name = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local nameHeader = MainModal.listHeaders.data['dungeonName']
        name:SetText(dungeonName)
        name:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, -25 - (i - 1) * 30)
        currentX = currentX + nameHeader.width
        table.insert(row, name)

        -- Time column
        local time = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local timeHeader = MainModal.listHeaders.data["currentTimer"]
        time:SetText(item.currentTimer)
        time:SetPoint("TOPLEFT", listFrame, "TOPLEFT", currentX, -25 - (i - 1) * 30)
        time:SetWidth( timeHeader.width )
        time:SetJustifyH("CENTER")
        currentX = currentX + timeHeader.width
        table.insert(row, time)

        -- Date column
        local runDate = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local runDateHeader = MainModal.listHeaders.data["runDate"]
        local dateOnly = string.match(item.runDate, "^%d%d%d%d%-%d%d%-%d%d")
        runDate:SetText( dateOnly)
        runDate:SetPoint("TOPLEFT", listFrame, "TOPLEFT", currentX, -25 - (i - 1) * 30)
        runDate:SetWidth( runDateHeader.width )
        runDate:SetJustifyH("CENTER")
        currentX = currentX + runDateHeader.width
        table.insert(row, runDate)

        -- Status column
        local status = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local statusHeader = MainModal.listHeaders.data["status"]
        local prettyStatus = GetPrettyStatus(item.status)
        status:SetText(prettyStatus)
        status:SetPoint("TOPLEFT", listFrame, "TOPLEFT", currentX, -25 - (i - 1) * 30)
        status:SetWidth( statusHeader.width )
        status:SetJustifyH("CENTER")
        currentX = currentX + statusHeader.width
        table.insert(row, status)

        -- Level column
        local level = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local levelHeader = MainModal.listHeaders.data["level"]
        level:SetText(item.level)
        level:SetPoint("TOPLEFT", listFrame, "TOPLEFT", currentX, -25 - (i - 1) * 30)
        level:SetWidth( levelHeader.width )
        level:SetJustifyH("CENTER")
        currentX = currentX + levelHeader.width
        table.insert(row, level)

        -- Role column
        local role = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local roleHeader = MainModal.listHeaders.data["role"]
        local prettyRole = GetPrettyRole(item.role)
        role:SetText(prettyRole)
        role:SetPoint("TOPLEFT", listFrame, "TOPLEFT", currentX, -25 - (i - 1) * 30)
        role:SetWidth( roleHeader.width )
        role:SetJustifyH("CENTER")
        currentX = currentX + roleHeader.width
        table.insert(row, role)

        -- View button
        local viewButton = CreateFrame("Button", nil, listFrame, "UIPanelButtonTemplate")
        local viewHeader = MainModal.listHeaders.data["view"]
        viewButton:SetSize(50, 20) -- Width, Height
        viewButton:SetPoint("TOPLEFT", listFrame, "TOPLEFT", currentX, -22 - (i - 1) * 30)
        currentX = currentX + viewHeader.width
        viewButton:SetText("View")
        viewButton:SetScript("OnClick", function()
            local modalFrame = ViewRunModal.Create(frame, addRun, item.id)
            modalFrame:Show()
        end)
        table.insert(row, viewButton)

        -- Delete button
        local deleteButton = CreateFrame("Button", nil, listFrame, "UIPanelButtonTemplate")
        local deleteHeader = MainModal.listHeaders.data["delete"]
        deleteButton:SetSize(50, 20)
        deleteButton:SetPoint("TOPLEFT", listFrame, "TOPLEFT", currentX, -22 - (i - 1) * 30)
        currentX = currentX + deleteHeader.width
        deleteButton:SetText("Delete")
        deleteButton:SetScript("OnClick", function()
            DeleteRunByID(item.id)
        end)
        table.insert(row, deleteButton)

        if MainModal.currentTab == "Started" then
            -- End button
            local abandonButton = CreateFrame("Button", nil, listFrame, "UIPanelButtonTemplate")
            abandonButton:SetSize(50, 20)
            abandonButton:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 510, -17 - (i - 1) * 30)
            abandonButton:SetText("Abandon")
            abandonButton:SetScript("OnClick", function()
                local status = "incomplete"
                local formattedTime = "00:00:00"
                local note = "Manually abandoned via button press."

                local unknown, timeElapsed, type = GetWorldElapsedTime(1)
                if timeElapsed then
                    formattedTime = convertSecondsToString( timeElapsed )
                end
        
                updateRun( status, formattedTime, note )

                MainModal.updateList()
            end)
            table.insert(row, abandonButton)
        end

        -- Store the row
        table.insert(listFrame.rows, row)
    end
end

function MainModal.filterRuns()
    local filtered = {}
    local statusFilter = MainModal.currentStatusFilter or "All Statuses"
    local levelFilter = MainModal.currentLevelFilter or "All Levels"
    local dungeonFilter = MainModal.currentDungeonFilter or "All Dungeons"
    local roleFilter = MainModal.currentRoleFilter or "All Roles"
    local onlyShowThisCharacter = MainModal.onlyShowThisCharacter

    for _, run in ipairs(runsDB or {}) do
        local matchesStatus = (statusFilter == "All Statuses" or run.status == statusFilter:lower())
        local matchesLevel = (levelFilter == "All Levels" or tostring(run.level) == levelFilter)
        local matchesDungeon = (dungeonFilter == "All Dungeons" or run.dungeonName == dungeonFilter)
        local matchesRole = (roleFilter == "All Roles" or run.role == roleFilter)
        local matchesCharacter = (not onlyShowThisCharacter or run.character == UnitName("player"))

        if matchesStatus and matchesLevel and matchesDungeon and matchesRole and matchesCharacter then
            table.insert(filtered, run)
        end
    end

    return filtered
end
