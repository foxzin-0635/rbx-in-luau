local Runtime = githubRequire("src/utils/Runtime.lua")
local Security = githubRequire("src/utils/Security.lua")
local Object_metadata = {}

-- for typeof_hook(v)
local function gettype()
  return Object_metadata.ApiEquivalent.Name
end

-- Mimic the behavior of the original :IsA(className)
local function isA(self, className: string): boolean
  local it = Object_metadata.inheritTree
  local bt = string.split(it, ",")
  
  local v = false
  for i = 1, #bt do
    if className == bt[i] then v = true break end
  end
  
  return v
end

-- ReflectionMetadata like table.
Object_metadata = {
  ApiEquivalent = apidump.Classes[1],
  --[[members = {
    ClassName = {
      ApiEquivalent = apidump.Classes[1].Members[1],
      Value = "Object"
    },
    IsA = {
      ApiEquivalent = apidump.Classes[1].Members[4],
      Value = function(self, className: string)
        return isA(self, className)
      end
    }
  },]]
  members = autoGenerateMembersWithValues({
    {class = 1, member = 1, presetValue = "Object"}, -- ClassName
    {class = 1, member = 4, presetValue = function(self, className: string) return isA(self, className) end} -- :IsA(className: string)
  }),
  gettype = gettype -- for typeof_hook(v)
}

local Object = setmetatable({}, {
  __metatable = "The metatable is locked",
  __index = function(t,k)
    -- WARNING: executor level access!
    if Runtime:IsEngineScript() then
      if k ~= "members" then
        return Object_metadata[k]
      end
    end
    for mk,mt in pairs(Object_metadata.members) do
      if mk == k then
        return mt.Value
      end
    end
  end,
  __tostring = Object_metadata.ApiEquivalent.Name,
  __newindex = function(t, k, v)
    local mt = Object_metadata.members[k]
    
    if mt then
      if table.find(mt.ApiEquivalent.Tags, "NotScriptable") then error("Attempt to index nil with "+typeof(v)) end
      if table.find(mt.ApiEquivalent.Tags, "ReadOnly") then
        error("Unable to assign property "..k..". Property is read only")
      else
        if type(v) == mt.ApiEquivalent.ValueType.Name then
          mt.Value = v
        else
          error("Type '"..type(v).."' could not be converted into '"..mt.ValueType.."'")
        end
      end
    end
    
    error("Attempt to index nil with "+typeof(v))
  end
})

return Object