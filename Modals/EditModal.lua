function EditRunModal.Create(parentFrame, runID)
    -- Get the run data
    local runData = GetRunByID(runID)
    if not runData then
        print("AAA: Error: No run found with runID:", runID)
        return nil
    end
    PrintTable(runData)
    print(runData.note)

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

    -- Add a text field for editing notes
    local notesBox = CreateFrame("EditBox", nil, modalFrame, "InputBoxTemplate")
    notesBox:SetMultiLine(true)
    notesBox:SetSize(360, 200)
    notesBox:SetPoint("TOP", modalFrame, "TOP", 0, -40)
    notesBox:SetText(runData.note or "")
    notesBox:SetAutoFocus(false) -- Prevent auto-focus
    notesBox:SetMaxLetters(1000)

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
                print("AAA: Notes updated for Run ID:", runID)
                break
            end
        end

        -- Hide the modal after saving
        modalFrame:Hide()
    end)

    return modalFrame
end
