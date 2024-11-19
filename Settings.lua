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
    local variableKey = "toggle"
    local name = "Only Track my Keys"
    local variable = "OnlyTrackMine"

    -- print("AAASettings loaded with " .. variable .. ":" .. tostring(AAASettings[variable]) .. " status.")
    local tooltip = "Whether or not the addon should track only runs where it is your key, or if it should track all mythic runs you participate in."
    local savedValue = AAASettings[variable] or false
    -- print("AAASettings loaded with " .. variable .. ":" .. tostring(savedValue) .. " status.")

    local setting = Settings.RegisterAddOnSetting(category, variable, variable .. variableKey, AAASettings, type(savedValue), name, savedValue)
    setting:SetValueChangedCallback(OnSettingChanged)
    Settings.CreateCheckbox(category, setting, tooltip)

    local name = "Only Track Timed Keys"
    local variable = "OnlyTrackTimed"
    local tooltip = "Whether or not the addon should track only runs where the key is completed in time."

    -- print("AAASettings loaded with " .. variable .. ":" .. tostring(AAASettings[variable]) .. " status.")
    local savedValue = AAASettings[variable] or false
    -- print("AAASettings loaded with " .. variable .. ":" .. tostring(savedValue) .. " status.")

    local setting = Settings.RegisterAddOnSetting(category, variable, variable .. variableKey, AAASettings, type(savedValue), name, savedValue)
    setting:SetValueChangedCallback(OnSettingChanged)
    Settings.CreateCheckbox(category, setting, tooltip)

    local name = "Track Incomplete Keys"
    local variable = "TrackIncomplete"
    local tooltip = "Whether or not the addon should also track keys that deplete without finishing."
    
    -- print("AAASettings loaded with " .. variable .. ":" .. tostring(AAASettings[variable]) .. " status.")
    local savedValue = AAASettings[variable] or true
    -- print("AAASettings loaded with " .. variable .. ":" .. tostring(savedValue) .. " status.")
    
    local setting = Settings.RegisterAddOnSetting(category, variable, variable .. variableKey, AAASettings, type(savedValue), name, savedValue)
    setting:SetValueChangedCallback(OnSettingChanged)
    Settings.CreateCheckbox(category, setting, tooltip)
end