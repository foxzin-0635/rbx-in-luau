--local Range = githubRequire("src/utils/Range.lua")
local Security = {}
Security.ContextsByIdentityLevel = {
  [0] = {},
  [1] = {},
  [2] = {"None"},
  [3] = {"RobloxPlaceSecurity"},
  [4] = {"RobloxWhitelistedPlaceSecurity", "BasicLocalUserSecurity"},
  [5] = {"BasicPluginSecurity"},
  [6] = {"ElevatedPluginSecurity", "ElevatedLocalUserSecurity"},
  [7] = {"RobloxScriptSecurity"}
}
--[[Security.ScriptSecurity = Range.new(0,2)
Security.RobloxPlaceSecurity = 3
Security.CommandBar = 4
Security.PluginSecurity = 5 -- not sure
Security.LocalUserSecurity = 6
Security.RobloxScriptSecurity = 7]]

function Security:GetIdentityLevelByContext(context: string)
  for l, a in ipairs(self.ContextsByIdentityLevel) do
    if table.find(a, context) then
      return l
    end
  end
  return nil
end

function Security:gettype()
  return "UtilityModule"
end

setmetatable(Security, {
  __metatable = "The metatable is locked",
  __index = Security,
  __newindex = function()
    return nil -- read-only
  end,
  __tostring = "Security",
})

return Security