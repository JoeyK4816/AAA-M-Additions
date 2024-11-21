-- Slash command to show the frame
SLASH_AAA1 = "/aaa"
SlashCmdList["AAA"] = function(msg)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- SLASH_BBB1 = "/bbb"
-- SlashCmdList["BBB"] = CheckGroupStatus() -- Correctly reference the function here

SLASH_CCC1 = "/ccc"
SlashCmdList["CCC"] = function(msg)
	if Settings then
		Settings.OpenToCategory(MainModal.AddonName)
        -- print("OpenToCategory") -- Message if the player is the keyholder
    else
        print("AAA: Settings Api Unavailable") -- Message if the player is the keyholder
    end
end

SLASH_DDD1 = "/ddd"
SlashCmdList["DDD"] = function(msg)
    -- local formattedTime = convertSecondsToString( '444' )
    -- -- PrintTable( st )
    -- print( formattedTime )
end
