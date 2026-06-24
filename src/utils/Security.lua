local Range = githubRequire("src/utils/Range.lua")
local Security = {}
Security.Standard = Range.new(0,2)
Security.RobloxPlace = 3
Security.CommandBar = 4
Security.PluginSecurity = 5 -- not sure
Security.LocalUserSecurity = 6
Security.RobloxScriptSecurity = 7

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