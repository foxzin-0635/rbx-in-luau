local Security = GetModule("Security")
local Runtime = {}

function Runtime:SetIdentityLevel(idl: number)
  getfenv().set_thread_identity(idl)
end

function Runtime:GetIdentityLevel()
  return getfenv().get_thread_identity()
end

function Runtime:SetIdentityLevelByContext(context: string)
  local identityLevel = Security:GetIdentityLevelByContext(context)
  
  if identityLevel then self:SetIdentityLevel(identityLevel) return end
  if context == "RobloxSecurity" then
    if not rbx_api_config.SimulatedIdentityHacks.RobloxSecurity.CanUse then error("Hack for RobloxSecurity was not set! Please configure the module.") end
    self:SetIdentityLevel(rbx_api_config.SimulatedIdentityHacks.RobloxSecurity.IdentityLevel)
    return
  end
  if context == "NotAccessibleSecurity" then
    if not rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse then error("Hack for NotAccessibleSecurity was not set! Please configure the module.") end
    self:SetIdentityLevel(rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.IdentityLevel)
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

function Runtime:IsRobloxScript()
  if not rbx_api_config.SimulatedIdentityHacks.RobloxSecurity.CanUse then warn("Hack for RobloxSecurity was not set! Please configure the module.") return false end
  return self:GetIdentityLevel() == rbx_api_config.SimulatedIdentityHacks.RobloxSecurity.IdentityLevel
end

function Runtime:IsEngineScript()
  if not rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse then warn("Hack for NotAccessibleSecurity was not set! Please configure the module.") return false end
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