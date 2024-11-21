function ViewRunModal.Create(parentFrame, addItemCallback, runID)
    local modalFrame = CreateFrame("Frame", "AAA_AddRunModal", UIParent, "BasicFrameTemplateWithInset")
    modalFrame:SetSize(550, 400)
    modalFrame:SetPoint("CENTER", UIParent, "CENTER")
    modalFrame:SetFrameStrata("DIALOG") -- Ensure it renders above other frames
    modalFrame:SetFrameLevel(100) -- Set a high level to be above child elements
    modalFrame:Hide()

    modalFrame.title = modalFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    modalFrame.title:SetPoint("TOP", modalFrame, "TOP", 0, -5)
    modalFrame.title:SetText("Run Details")

    -- Scroll Frame for Details Text
    local scrollFrame = CreateFrame("ScrollFrame", nil, modalFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(520, 300)
    scrollFrame:SetPoint("TOP", modalFrame, "TOP", 0, -40)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(500, 1) -- Width should match the modal content
    scrollFrame:SetScrollChild(content)

    local detailsTextBox = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    detailsTextBox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    detailsTextBox:SetWidth(500) -- Ensure text wraps within the scroll frame width
    detailsTextBox:SetJustifyH("LEFT")

    -- Retrieve the run data using the runID
    local run = GetRunByID(runID)

    if run then
        local detailsText = ViewRunModal.GetDetails( run )
        detailsTextBox:SetText(detailsText)

        -- Buttons
        local deleteButton = CreateFrame("Button", nil, modalFrame, "GameMenuButtonTemplate")
        deleteButton:SetPoint("BOTTOMRIGHT", modalFrame, "BOTTOM", -5, 10)
        deleteButton:SetSize(100, 30)
        deleteButton:SetText("Delete")
        deleteButton:SetScript("OnClick", function()
            DeleteRunByID(runID)
            modalFrame:Hide()
        end)

        local editButton = CreateFrame("Button", nil, modalFrame, "GameMenuButtonTemplate")
        editButton:SetPoint("BOTTOMLEFT", modalFrame, "BOTTOM", 5, 10)
        editButton:SetSize(100, 30)
        editButton:SetText("Edit")
        editButton:SetScript("OnClick", function()
            local editModal = EditRunModal.Create( modalFrame, runID, detailsTextBox )
            if editModal then
                editModal:Show()
            end
        end)

    else
        -- Handle case where no run data is found
        modalFrame.details = modalFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        modalFrame.details:SetPoint("TOPLEFT", modalFrame, "TOPLEFT", 10, -40)
        modalFrame.details:SetJustifyH("LEFT")
        modalFrame.details:SetWidth(280)
        modalFrame.details:SetText("No run data found for ID: " .. run)
    end

    return modalFrame
end

function ViewRunModal.GetDetails( run )
    -- Display the retrieved run data
    local headerColor = "|cffFFD700"  -- Gold color
    local resetColor = "|r"  -- Resets to default text color
    local dungeonName = GetDungeonNameByMapID(run.dungeonName)
    local detailsText = ""

    detailsText = detailsText .. headerColor .. "Dungeon: " .. resetColor .. (dungeonName or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Character: " .. resetColor .. (run.character or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Spec: " .. resetColor .. (run.spec or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Time: " .. resetColor .. (run.currentTimer or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Date: " .. resetColor .. (run.runDate or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Role: " .. resetColor .. (run.role or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Level: " .. resetColor .. (run.level or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Status: " .. resetColor .. (run.status or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Season: " .. resetColor .. (run.season or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Affixes:\n" .. resetColor .. (GetAffixNamesFromString(run.affixes) or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Notes:\n" .. resetColor .. (run.note or "Unknown") .. "\n"
    detailsText = detailsText .. headerColor .. "Party:\n" .. resetColor 
    if run.party and next(run.party) then
        for name, member in pairs(run.party) do
            detailsText = detailsText ..
                string.format(
                    "  - %s: %s (%s, %s)\n",
                    name,
                    member.class or "Unknown Class",
                    member.role or "Unknown Role",
                    member.spec or "Unknown Spec"
                )
        end
    else
        detailsText = detailsText .. "  No party data available\n"
    end

    detailsText = detailsText .. headerColor ..  "Deaths:\n" .. resetColor
    if run.deaths and next(run.deaths) then
        for name, death in pairs(run.deaths) do
            -- Get the last log entry if available
            local lastLogEntry = nil
            if death.log and #death.log > 0 then
                lastLogEntry = death.log[#death.log]
            end
            
            -- Format the death log details
            local logDetails = ""
            if lastLogEntry then
                logDetails = string.format(
                    "killed by %s%s|r using %s%s|r for %s%s|r damage",
                    "|cffFFA500", lastLogEntry.killer or "Unknown killer",  -- Orange
                    "|cff0000FF", lastLogEntry.damageType or "Unknown damage type",  -- Blue
                    "|cffFF0000", lastLogEntry.amount or "Unknown amount"  -- Red
                )
            else
                logDetails = "No log data available"
            end

            -- Add the death details to the text
            detailsText = detailsText ..
                string.format(
                    "%s%s|r - %s%s|r: %s\n",
                    "|cffFFFF00", death.time or "Unknown time",  -- Yellow
                    "|cff00FF00", death.player or "Unknown player",  -- Green
                    logDetails
                )
        end
    else
        detailsText = detailsText .. "  No death data available\n"
    end

    return detailsText
end
