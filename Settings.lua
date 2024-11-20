function OnSettingChanged(setting, value)
    -- print("Setting changed:", setting:GetVariable(), value)
    local variableName = setting:GetVariable()

    if not AAASettings[variableName] then
        AAASettings[variableName] = {}
    end

    AAASettings[variableName] = value
    -- print("Saved setting:", variableName, AAASettings[variableName])
end

function loadSettings()
    local name = "Only Track my Keys"
    local variable = "OnlyTrackMine"
    local tooltip = "Whether or not the addon should track only runs where it is your key, or if it should track all mythic runs you participate in."
    local savedValue = AAASettings[variable] or false
    addCheckboxSetting( name, variable, tooltip, savedValue )

    local name = "Only Track Timed Keys"
    local variable = "OnlyTrackTimed"
    local tooltip = "Whether or not the addon should track only runs where the key is completed in time."
    local savedValue = AAASettings[variable] or false
    addCheckboxSetting( name, variable, tooltip, savedValue )

    local name = "Track Incomplete Keys"
    local variable = "TrackIncomplete"
    local tooltip = "Whether or not the addon should also track keys that deplete without finishing."
    local savedValue = AAASettings[variable] or true
    addCheckboxSetting( name, variable, tooltip, savedValue )

    local name = "Hide Death Messages"
    local variable = "HideDeathMessage"
    local tooltip = "Whether or not the addon should print a death message when a player dies."
    local savedValue = AAASettings[variable] or true
    addCheckboxSetting( name, variable, tooltip, savedValue )
end

function addCheckboxSetting( text, variableName, tooltip, savedValue )
    local variableKey = "toggle"
    local setting = Settings.RegisterAddOnSetting(category, variableName, variableName .. variableKey, AAASettings, type(savedValue), text, savedValue)
    setting:SetValueChangedCallback(OnSettingChanged)
    Settings.CreateCheckbox(category, setting, tooltip)
end