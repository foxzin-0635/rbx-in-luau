local Security = getModule("Security")
local Runtime = {}

function Runtime:SetIdentityLevel(idl: number)
  thread_identity.Value = idl
end

function Runtime:GetIdentityLevel()
  return thread_identity.Value
end

function Runtime:SetIdentityLevelByContext(context: string)
  local cur = self:GetIdentityLevel()
  local identityLevel = Security:GetIdentityLevelByContext(context)
  
  if identityLevel then
    self:SetIdentityLevel(identityLevel)
    return
  end
  if context == "RobloxSecurity" then
    if cur == 9 then
      rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = false
      rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.IdentityLevel = -1
    end
    rbx_api_config.SimulatedIdentityHacks.RobloxSecurity.CanUse = true
    rbx_api_config.SimulatedIdentityHacks.RobloxSecurity.IdentityLevel = 8
    self:SetIdentityLevel(8)
    return
  end
  if context == "NotAccessibleSecurity" then
    if cur == 8 then
      rbx_api_config.SimulatedIdentityHacks.RobloxSecurity.CanUse = false
      rbx_api_config.SimulatedIdentityHacks.RobloxSecurity.IdentityLevel = -1
    end
    rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = true
    rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.IdentityLevel = 9
    self:SetIdentityLevel(9)
    return
  end
  error("Unknown security context: "..context)
end

function Runtime:IsStandardScript()
  return self:GetIdentityLevel() == Security:GetIdentityLevelByContext("None")
end

function Runtime:IsRobloxPlaceScript()
  return self:GetIdentityLevel() == Security:GetIdentityLevelByContext("RobloxPlaceSecurity")
end

function Runtime:IsRobloxWhitelistedPlaceScript()
  return self:GetIdentityLevel() == Security:GetIdentityLevelByContext("RobloxWhitelistedPlaceSecurity")
end

function Runtime:IsStandardPluginScript()
  return self:GetIdentityLevel() == Security:GetIdentityLevelByContext("BasicPluginSecurity")
end

function Runtime:IsElevatedPluginScript()
  return self:GetIdentityLevel() == Security:GetIdentityLevelByContext("ElevatedPluginSecurity")
end

function Runtime:IsStandardLocalUserScript()
  return self:GetIdentityLevel() == Security:GetIdentityLevelByContext("BasicLocalUserSecurity")
end

function Runtime:IsElevatedLocalUserScript()
  return self:GetIdentityLevel() == Security:GetIdentityLevelByContext("ElevatedLocalUserSecurity")
end

function Runtime:IsCoreScript()
  return self:GetIdentityLevel() == Security:GetIdentityLevelByContext("RobloxScriptSecurity")
end

function Runtime:IsRobloxScript(silentWarning: boolean)
  if not rbx_api_config.SimulatedIdentityHacks.RobloxSecurity.CanUse then if not silentWarning then warn("Hack for RobloxSecurity was not set! Please configure the module.") end return false end
  return self:GetIdentityLevel() == rbx_api_config.SimulatedIdentityHacks.RobloxSecurity.IdentityLevel
end

function Runtime:IsEngineScript(silentWarning: boolean)
  if not rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse then if not silentWarning then warn("Hack for NotAccessibleSecurity was not set! Please configure the module.") end return false end
  return self:GetIdentityLevel() == rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.IdentityLevel
end

function Runtime:gettype()
  return "UtilityModule"
end

setmetatable(Runtime, {
  __metatable = "The metatable is locked",
  __index = Runtime,
  __newindex = function()
    return nil -- read-only
  end,
  __tostring = "Runtime",
})

return Runtime