function ShowPopupMessage(message)
    -- Create the popup frame if it doesn't exist
    if not MainModal.popupFrame then
        MainModal.popupFrame = CreateFrame("Frame", "PopupFrame", UIParent, "BasicFrameTemplateWithInset")
        MainModal.popupFrame:SetSize(300, 100) -- Width, Height
        MainModal.popupFrame:SetPoint("CENTER", UIParent, "CENTER") -- Centered on the screen
        MainModal.popupFrame:SetFrameStrata("DIALOG")
        MainModal.popupFrame:SetFrameLevel(100) -- Set a high level to be above child elements

        -- Add a title
        MainModal.popupFrame.title = MainModal.popupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        MainModal.popupFrame.title:SetPoint("TOP", MainModal.popupFrame, "TOP", 0, -3)
        MainModal.popupFrame.title:SetText("Error")

        -- Add the message text
        MainModal.popupFrame.text = MainModal.popupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        MainModal.popupFrame.text:SetPoint("CENTER", MainModal.popupFrame, "CENTER", 0, 0)
        MainModal.popupFrame.text:SetJustifyH("CENTER")
        MainModal.popupFrame.text:SetJustifyV("MIDDLE")
        MainModal.popupFrame.text:SetText(message)

        -- Add a close button
        MainModal.popupFrame.closeButton = CreateFrame("Button", nil, MainModal.popupFrame, "UIPanelButtonTemplate")
        MainModal.popupFrame.closeButton:SetSize(80, 22) -- Width, Height
        MainModal.popupFrame.closeButton:SetPoint("BOTTOM", MainModal.popupFrame, "BOTTOM", 0, 10)
        MainModal.popupFrame.closeButton:SetText("Close")

        -- Close button functionality
        MainModal.popupFrame.closeButton:SetScript("OnClick", function()
            MainModal.popupFrame:Hide()
        end)
    end

    -- Update the message text and show the popup
    MainModal.popupFrame.text:SetText(message)
    MainModal.popupFrame:Show()
end