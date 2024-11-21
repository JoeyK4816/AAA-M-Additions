function EditRunModal.Create(parentFrame, runID, detailsTextBox)
    -- Get the run data
    local runData = GetRunByID(runID)
    if not runData then
        print("AAA: Error: No run found with runID:", runID)
        return nil
    end
    -- PrintTable(runData)
    -- print(runData.note)

    -- Create the modal frame
    local modalFrame = CreateFrame("Frame", nil, parentFrame, "BasicFrameTemplateWithInset")
    modalFrame:SetSize(400, 300)
    modalFrame:SetPoint("CENTER", UIParent, "CENTER")
    modalFrame:SetFrameStrata("DIALOG")
    modalFrame:SetFrameLevel(110)

    -- Add a title
    local title = modalFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", modalFrame, "TOP", 0, -5)
    title:SetText("Edit Run")

    -- Create a scrollable container for the edit box
    local scrollFrame = CreateFrame("ScrollFrame", nil, modalFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(360, 200)
    scrollFrame:SetPoint("TOP", modalFrame, "TOP", 0, -40)

    -- Add a text field for editing notes
    local notesBox = CreateFrame("EditBox", nil, scrollFrame)
    notesBox:SetMultiLine(true)
    notesBox:SetSize(340, 600) -- Allow space for scrolling
    notesBox:SetPoint("TOPLEFT")
    notesBox:SetPoint("TOPRIGHT")
    notesBox:SetText(runData.note or "")
    notesBox:SetAutoFocus(false) -- Prevent auto-focus
    notesBox:SetFontObject("GameFontHighlight")
    notesBox:SetMaxLetters(1000)

    scrollFrame:SetScrollChild(notesBox)

    -- Add a Save button
    local saveButton = CreateFrame("Button", nil, modalFrame, "GameMenuButtonTemplate")
    saveButton:SetPoint("BOTTOM", modalFrame, "BOTTOM", 0, 10)
    saveButton:SetSize(100, 30)
    saveButton:SetText("Save")
    saveButton:SetScript("OnClick", function()
        -- Update the note in runsDB
        for _, run in ipairs(runsDB) do
            if run.id == runID then
                run.note = notesBox:GetText()
                local detailsText = ViewRunModal.GetDetails( run )
                detailsTextBox:SetText(detailsText)
                print("AAA: Notes updated for Run ID:", runID)
                break
            end
        end

        -- Hide the modal after saving
        modalFrame:Hide()
    end)

    return modalFrame
end
