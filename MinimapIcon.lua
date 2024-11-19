LDB = LibStub("LibDataBroker-1.1"):NewDataObject("AAA_Additions", {
    type = "launcher",
    text = MainModal.AddonName,
    icon = "Interface\\Icons\\Ability_hunter_snipershot",
    OnClick = function(_, button)
        if button == "LeftButton" then
            -- Call the /aaa action directly
            if SlashCmdList["AAA"] then
                SlashCmdList["AAA"]()
            else
                print("AAA: Runs interface missing.")
            end
        elseif button == "RightButton" then
            if Settings then
                SlashCmdList["CCC"]()
            else
                print("AAA: Settings interface missing.")
            end
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(MainModal.AddonName)
        tooltip:AddLine("|cffffff00Left Click|r to view runs.")
        tooltip:AddLine("|cffffff00Right Click|r to open settings")
    end,
})