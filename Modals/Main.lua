function MainModal.Create()
    local frame = CreateFrame("Frame", "AAA_AdditionsFrame", UIParent, "BasicFrameTemplateWithInset")

    -- Create the main frame
    frame:SetSize(600, 600) -- Adjusted height for tabs
    frame:SetPoint("CENTER", UIParent, "CENTER") -- Position in the center of the screen
    frame:SetFrameStrata("DIALOG") -- Ensure it renders above other frames
    frame:SetFrameLevel(50) -- Set a high level to be above child elements
    frame:Hide() -- Start hidden

    -- Add a title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -5)
    frame.title:SetText(MainModal.AddonName)

    -- Create tab buttons
    MainModal.CreateTabs(frame)
    MainModal.prevPageButton, MainModal.nextPageButton = MainModal.CreatePagination(frame)

    return frame
end

function MainModal.CreateTabs(frame)
    -- Create container for tabs
    frame.tabs = {}

    local tabs = { "Timed", "Un-Timed", "Incomplete", "Started" }
    local tabWidth = 80
    local tabHeight = 22
    local tabSpacing = 10 -- Space between tabs
    local totalWidth = (#tabs * tabWidth) + ((#tabs - 1) * tabSpacing)
    local startX = (frame:GetWidth() - totalWidth) / 2 -- Center the tabs horizontally

    for i, tabName in ipairs(tabs) do
        local tab = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        tab:SetSize(tabWidth, tabHeight)
        tab:SetPoint("TOPLEFT", frame, "TOPLEFT", startX + (i - 1) * (tabWidth + tabSpacing), -30)
        tab:SetText(tabName)

        tab:SetScript("OnClick", function()
            MainModal.currentTab = tabName
            MainModal.updateList()
        end)

        frame.tabs[tabName] = tab
    end
end

function MainModal.CreateList()
    -- Create a container for the list
    local listFrame = CreateFrame("Frame", nil, frame)
    listFrame:SetSize(360, 150) -- Adjust size for content
    listFrame:SetPoint("TOP", frame, "TOP", -60, -60)

    -- Add column headers with sorting functionality
    for i, headerData in ipairs(MainModal.listHeaders) do
        local headerText, column = unpack(headerData)
        local header = CreateFrame("Button", nil, listFrame)
        header:SetSize(100, 20) -- Width, Height
        header:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 10 + (i - 1) * 120, 0)

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
        local filteredRuns = MainModal.filterRunsByTab()
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
    local filteredRuns = MainModal.filterRunsByTab()
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

        -- Name column
        local name = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local dungeonName = GetDungeonNameByMapID(item.dungeonName)
        name:SetText(dungeonName)
        name:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, -20 - (i - 1) * 30)
        table.insert(row, name)

        -- Time column
        local time = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        time:SetText(item.currentTimer)
        time:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 130, -20 - (i - 1) * 30)
        table.insert(row, time)

        -- Date column
        local runDate = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        runDate:SetText(item.runDate)
        runDate:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 250, -20 - (i - 1) * 30)
        table.insert(row, runDate)

        -- View button
        local viewButton = CreateFrame("Button", nil, listFrame, "UIPanelButtonTemplate")
        viewButton:SetSize(50, 20) -- Width, Height
        viewButton:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 390, -17 - (i - 1) * 30)
        viewButton:SetText("View")
        viewButton:SetScript("OnClick", function()
            -- print("Viewing run:", item.name)
            local modalFrame = ViewRunModal.Create(frame, addRun, item.id)
            modalFrame:Show()
        end)
        table.insert(row, viewButton)

        -- Delete button
        local deleteButton = CreateFrame("Button", nil, listFrame, "UIPanelButtonTemplate")
        deleteButton:SetSize(50, 20)
        deleteButton:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 450, -17 - (i - 1) * 30)
        deleteButton:SetText("Delete")
        deleteButton:SetScript("OnClick", function()
            -- print("Deleting run:", item.name)
            DeleteRunByID(item.id)
            MainModal.updateList()
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

function MainModal.filterRunsByTab()
    local tab = MainModal.currentTab
    local filtered = {}

    for _, run in ipairs(runsDB or {}) do
        if tab == "Timed" and run.status == "timed" then
            table.insert(filtered, run)
        elseif tab == "Un-Timed" and run.status == "complete" then
            table.insert(filtered, run)
        elseif tab == "Started" and run.status == "started" then
            table.insert(filtered, run)
        elseif tab == "Incomplete" and run.status == "incomplete" then
            table.insert(filtered, run)
        end
    end

    return filtered
end