local Object_metadata = {}

local function gettype()
  return Object_metadata.members.__type.Value
end

local function isA(self, className: string): boolean
  local it = Object_metadata.inheritTree
  local bt = string.split(it, ",")
  
  local v = false
  for i = 1, #bt do
    if className == bt[i] then v = true break end
  end
  
  return v
end

Object_metadata = {
  inheritTree = "Object", -- for :IsA(className)
  members = {
    ClassName = {
      MemberType = "Property",
      ValueType = "string",
      ReadOnly = true,
      Scriptable = true,
      Value = "Object"
    },
    IsA = {
      MemberType = "Method",
      ValueType = "function",
      ReadOnly = true,
      Scriptable = true,
      Value = function(self, className: string)
        return isA(self, className)
      end
    },
    __type = {
      MemberType = "PrivateMetamethod",
      ValueType = "metamethod",
      ReadOnly = true,
      Scriptable = false,
      Value = "Object"
    }
  },
  gettype = gettype
}

local Object = setmetatable({}, {
  __metatable = "The metatable is locked.",
  __index = function(t,k)
    -- WARNING: executor level access!
    if getfenv().get_thread_identity() >= 7 then
      if not k == "members" and not k == "inheritTree" then
        return Object_metadata[k]
      end
    end
    for mk,mt in pairs(Object_metadata.members) do
      if mk == k then
        return mt.Value
      end
    end
  end,
  __tostring = Object_metadata.members.ClassName.Value,
  __newindex = function(t, k, v)
    for mk,mt in pairs(Object_metadata.members) do
      if mk == k then
        if not mt.Scriptable then break end
        if mt.ReadOnly then
          error("Unable to assign property "..k..". Property is read only")
        else
          if type(v) == mt.ValueType then
            mt.Value = v
          else
            error("Type '"..type(v).."' could not be converted into '"..mt.ValueType.."'")
          end
        end
      end
    end
  end
})

return Object