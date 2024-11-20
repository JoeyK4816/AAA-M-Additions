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
    if not C_ChallengeMode.IsChallengeModeActive() then
        return
    end

    local unknown, timeElapsed, formattedTime = GetWorldElapsedTime(1)
    local status = "incomplete"
    local note = "\nmanually ended with ddd"
    
    if timeElapsed then
        -- Calculate hours, minutes, and seconds
        local hours = math.floor(timeElapsed / 3600)
        local minutes = math.floor((timeElapsed % 3600) / 60)
        local seconds = timeElapsed % 60
    
        -- Format the string as hh:mm:ss
        formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end

    updateRun( status, formattedTime, note )
end
