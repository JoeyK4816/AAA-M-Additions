function AddRunModal.Create(parentFrame, addItemCallback)
    -- Create the modal frame
    AddRunModal = CreateFrame("Frame", "AAA_AddRunModal", UIParent, "BasicFrameTemplateWithInset")
    AddRunModal:SetSize(300, 625)
    AddRunModal:SetPoint("CENTER", UIParent, "CENTER")
    AddRunModal:SetFrameStrata("DIALOG") -- Ensure it renders above other frames
    AddRunModal:SetFrameLevel(90) -- Set a high level to be above child elements
    AddRunModal:Hide()

    -- Modal title
    AddRunModal.title = AddRunModal:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    AddRunModal.title:SetPoint("TOP", AddRunModal, "TOP", 0, -5)
    AddRunModal.title:SetText("Add Run")

    -- Time input
    local timeInput = CreateFrame("EditBox", nil, AddRunModal, "InputBoxTemplate")
    timeInput:SetSize(180, 20)
    timeInput:SetPoint("TOP", AddRunModal, "TOP", 0, -50)
    timeInput:SetAutoFocus(false)
    timeInput:SetMaxLetters(8)
    timeInput:SetText("00:00:00.00")

    local timeLabel = AddRunModal:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timeLabel:SetText("Time (00:00:00.00):")
    timeLabel:SetPoint("BOTTOMLEFT", timeInput, "TOPLEFT", 0, 5)

    -- keystoneLevel input
    local levelInput = CreateFrame("EditBox", nil, AddRunModal, "InputBoxTemplate")
    levelInput:SetSize(180, 20)
    levelInput:SetPoint("TOP", timeInput, "BOTTOM", 0, -30)
    levelInput:SetAutoFocus(false)
    levelInput:SetMaxLetters(32)

    local levelLabel = AddRunModal:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    levelLabel:SetText("Keystone Level:")
    levelLabel:SetPoint("BOTTOMLEFT", levelInput, "TOPLEFT", 0, 5)

    -- Date input (Dropdown menu)
    local dateLabel = AddRunModal:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dateLabel:SetText("Date:")
    dateLabel:SetPoint("TOPLEFT", levelInput, "BOTTOMLEFT", -15, -30)

    local dateInput = CreateFrame("Button", nil, AddRunModal, "UIDropDownMenuTemplate")
    dateInput:SetPoint("LEFT", dateLabel, "RIGHT", 0, 0)
    UIDropDownMenu_SetWidth(dateInput, 150)
    UIDropDownMenu_SetText(dateInput, "Select Date")

    local function OnDateSelected(self, arg1, arg2, checked)
        selectedStatus = arg1 -- Update the selected value
        UIDropDownMenu_SetSelectedValue(dateInput, arg1)
        UIDropDownMenu_SetText(dateInput, self:GetText()) -- Update the dropdown display text
    end

    local function InitializeDateDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for i = 1, 30 do
            info.text = date("%Y-%m-%d", time() - (i - 1) * 86400)
            info.arg1 = info.text
            info.func = OnDateSelected
            UIDropDownMenu_AddButton(info, level)
        end
    end
    UIDropDownMenu_Initialize(dateInput, InitializeDateDropdown)

    -- Status dropdown
    local statusLabel = AddRunModal:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusLabel:SetText("Status:")
    statusLabel:SetPoint("TOPLEFT", dateLabel, "BOTTOMLEFT", -5, -30)

    local statusDropdown = CreateFrame("Frame", nil, AddRunModal, "UIDropDownMenuTemplate")
    statusDropdown:SetPoint("LEFT", statusLabel, "RIGHT", 0, 0) -- Adjust for dropdown alignment
    statusDropdown:SetSize(180, 20)

    local selectedStatus = "timed" -- Default selected value

    local function OnStatusSelected(self, arg1, arg2, checked)
        selectedStatus = arg1 -- Update the selected value
        UIDropDownMenu_SetSelectedValue(statusDropdown, arg1)
        UIDropDownMenu_SetText(statusDropdown, self:GetText()) -- Update the dropdown display text
    end
    UIDropDownMenu_Initialize(statusDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.func = OnStatusSelected

        -- Add dropdown options
        info.text, info.arg1 = "Timed", "timed"
        UIDropDownMenu_AddButton(info)
        info.text, info.arg1 = "Untimed", "complete"
        UIDropDownMenu_AddButton(info)
        info.text, info.arg1 = "Incomplete", "incomplete"
        UIDropDownMenu_AddButton(info)
    end)
    UIDropDownMenu_SetText(statusDropdown, selectedStatus)

    -- Specialization dropdown
    local specLabel = AddRunModal:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    specLabel:SetText("Spec:")
    specLabel:SetPoint("TOPLEFT", statusLabel, "BOTTOMLEFT", -5, -30)

    local specDropdown = CreateFrame("Frame", nil, AddRunModal, "UIDropDownMenuTemplate")
    specDropdown:SetPoint("LEFT", specLabel, "RIGHT", 0, 0) -- Adjust for dropdown alignment
    specDropdown:SetSize(180, 20)

    local selectedSpec = "Select Specialization" -- Variable to hold the selected specialization

    local function OnSpecSelected(self, specID, arg2, checked)
        selectedSpec = specID -- Update the selected specialization ID
        UIDropDownMenu_SetSelectedValue(specDropdown, specID)
        UIDropDownMenu_SetText(specDropdown, self:GetText()) -- Update the dropdown display text
    end

    local function GetPlayerSpecializations()
        local className, classFilename, classId = UnitClass("player")
        local specs = {}
        
        -- print("ClassID: " .. classId)
        for i = 1, 4 do
            local specID, specName = GetSpecializationInfoForClassID(classId, i)
            if not specName then break end
            table.insert(specs, { id = specID, name = specName })
        end
        return specs
    end

    UIDropDownMenu_Initialize(specDropdown, function(self, level, menuList)
        local specs = GetPlayerSpecializations()
        for _, spec in ipairs(specs) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = spec.name
            info.arg1 = spec.id
            info.func = OnSpecSelected
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(specDropdown, selectedSpec)

    -- dungeonName dropdown
    local dungeonNameLabel = AddRunModal:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dungeonNameLabel:SetText("Dungeon:")
    dungeonNameLabel:SetPoint("TOPLEFT", specLabel, "BOTTOMLEFT", -5, -30)

    local dungeonNameDropdown = CreateFrame("Frame", nil, AddRunModal, "UIDropDownMenuTemplate")
    dungeonNameDropdown:SetPoint("LEFT", dungeonNameLabel, "RIGHT", 0, 0) -- Adjust for dropdown alignment
    dungeonNameDropdown:SetSize(180, 20)

    local selectedDung = "Dungeon" -- Variable to hold the selected specialization

    local function OnDungSelected(self, specID, arg2, checked)
        selectedDung = specID -- Update the selected specialization ID
        
        UIDropDownMenu_SetSelectedValue(dungeonNameDropdown, specID)
        UIDropDownMenu_SetText(dungeonNameDropdown, self:GetText()) -- Update the dropdown display text
    end

    local function GetMythicPlusChestTimes()
        local dungeons = C_ChallengeMode.GetMapTable()
        local chestTimes = {}
    
        for _, mapID in ipairs(dungeons) do
            local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
            if name and timeLimit then
                local twoChestTime = math.floor(timeLimit * 0.6) -- 60% of the base time
                local threeChestTime = math.floor(timeLimit * 0.4) -- 40% of the base time
    
                chestTimes[mapID] = {
                    name = name,
                    timeLimit = timeLimit,
                    twoChest = twoChestTime,
                    threeChest = threeChestTime,
                }
            end
        end
    
        return chestTimes
    end

    UIDropDownMenu_Initialize(dungeonNameDropdown, function(self, level, menuList)
        local chestTimeInfo = GetMythicPlusChestTimes()
        for mapID, dung in pairs(chestTimeInfo) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = dung.name
            info.arg1 = mapID
            info.func = OnDungSelected
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(dungeonNameDropdown, selectedDung)

    -- Affixes input
    local affixLabel = AddRunModal:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    affixLabel:SetText("Select Affixes:")
    affixLabel:SetPoint("BOTTOMLEFT", dungeonNameLabel, "TOPLEFT", 0, -40)

    local allAffixes = { 148, 158, 159, 160, 9, 10, 152, 147 }
    -- local allAffixes = C_MythicPlus.GetCurrentAffixes

    local function CreateAffixCheckboxes(parentFrame)
        local affixCheckboxes = {}
    
        for i, affixID in ipairs(allAffixes) do
            -- Get affix name
            local name = select(1, C_ChallengeMode.GetAffixInfo(affixID))
            if name then
                -- Create checkbox
                local checkbox = CreateFrame("CheckButton", nil, parentFrame, "ChatConfigCheckButtonTemplate")
                checkbox:SetPoint("TOPLEFT", affixLabel, "TOPLEFT", 10, -30 * i) -- Adjust spacing dynamically
                checkbox.Text:SetText(name) -- Set the affix name as the label
    
                -- Optional: Store affix ID in the checkbox for later use
                checkbox.affixID = affixID
    
                -- Add to table for reference
                table.insert(affixCheckboxes, checkbox)
            end
        end
    
        return affixCheckboxes
    end
    
    local affixCheckboxes = CreateAffixCheckboxes(AddRunModal)
    
    -- Function to gather selected affixes
    local function GetSelectedAffixes()
        local selectedAffixes = {}
        for _, checkbox in ipairs(affixCheckboxes) do
            if checkbox:GetChecked() then
                table.insert(selectedAffixes, checkbox.affixID)
            end
        end
        return selectedAffixes
    end
    
    -- Confirm button
    local confirmButton = CreateFrame("Button", nil, AddRunModal, "GameMenuButtonTemplate")
    confirmButton:SetSize(100, 25)
    confirmButton:SetPoint("BOTTOMRIGHT", AddRunModal, "BOTTOM", -10, 10)
    confirmButton:SetText("Confirm")
    confirmButton:SetScript("OnClick", function()
        local dungeon = UIDropDownMenu_GetSelectedValue(dungeonNameDropdown)
        print( dungeon )
        local level = levelInput:GetText()
        print( level )
        local status = UIDropDownMenu_GetSelectedValue(statusDropdown)
        print( status )
        local affixes = table.concat(GetSelectedAffixes(), ", ")
        print( affixes )
        local time = timeInput:GetText()
        print( time )
        local runDate = UIDropDownMenu_GetSelectedValue(dateInput)
        print( runDate )
        local spec = UIDropDownMenu_GetSelectedValue(specDropdown)
        print( spec )

        -- print("Selected Affixes:", affixes)
        if not dungeon or dungeon == "" or not time or time == "" or not runDate or runDate == "Select Date" then
            -- print("All fields are required.")
            ShowPopupMessage("All fields are required.")
            return
        end

        
        addRun(dungeon, level, status, affixes, time, runDate, spec, __, __, __, __, notes)
        AddRunModal:Hide()
    end)

    -- Close button
    local closeButton = CreateFrame("Button", nil, AddRunModal, "GameMenuButtonTemplate")
    closeButton:SetSize(100, 25)
    closeButton:SetPoint("BOTTOMLEFT", AddRunModal, "BOTTOM", 10, 10)
    closeButton:SetText("Close")
    closeButton:SetScript("OnClick", function() AddRunModal:Hide() end)

    return AddRunModal
end