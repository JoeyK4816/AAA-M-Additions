function ViewRunModal.Create(parentFrame, addItemCallback, runID)
    local modalFrame = CreateFrame("Frame", "AAA_AddRunModal", UIParent, "BasicFrameTemplateWithInset")
    modalFrame:SetSize(300, 300)
    modalFrame:SetPoint("CENTER", UIParent, "CENTER")
    modalFrame:SetFrameStrata("DIALOG") -- Ensure it renders above other frames
    modalFrame:SetFrameLevel(100) -- Set a high level to be above child elements
    modalFrame:Hide()

    modalFrame.title = modalFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    modalFrame.title:SetPoint("TOP", modalFrame, "TOP", 0, -5)
    modalFrame.title:SetText("Run Details")

    -- Retrieve the run data using the runID
    local run = GetRunByID(runID)

    if run then
        -- Display the retrieved run data
        local detailsText = ""
        local dungeonName = GetDungeonNameByMapID(run.dungeonName)
        detailsText = detailsText .. "Dungeon: " .. (dungeonName or "Unknown") .. "\n"
        detailsText = detailsText .. "Character: " .. (run.character or "Unknown") .. "\n"
        detailsText = detailsText .. "Spec: " .. (run.spec or "Unknown") .. "\n"
        detailsText = detailsText .. "Time: " .. (run.currentTimer or "Unknown") .. "\n"
        detailsText = detailsText .. "Date: " .. (run.runDate or "Unknown") .. "\n"
        detailsText = detailsText .. "Role: " .. (run.role or "Unknown") .. "\n"
        detailsText = detailsText .. "Level: " .. (run.level or "Unknown") .. "\n"
        detailsText = detailsText .. "Status: " .. (run.status or "Unknown") .. "\n"
        detailsText = detailsText .. "Season: " .. (run.season or "Unknown") .. "\n"
        detailsText = detailsText .. "Affixes: " .. (GetAffixNamesFromString(run.affixes) or "Unknown") .. "\n"
        
        detailsText = detailsText .. "Party:\n"
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

        detailsText = detailsText .. "Deaths:\n"
        if run.deaths and next(run.deaths) then
            for name, member in pairs(run.deaths) do
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
            detailsText = detailsText .. "  No death data available\n"
        end

        detailsText = detailsText .. "Note: " .. (run.note or "Unknown") .. "\n"

        modalFrame.details = modalFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        modalFrame.details:SetPoint("TOPLEFT", modalFrame, "TOPLEFT", 10, -40)
        modalFrame.details:SetJustifyH("LEFT")
        modalFrame.details:SetWidth(280) -- Ensure text wraps within the modal width
        modalFrame.details:SetText(detailsText)
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