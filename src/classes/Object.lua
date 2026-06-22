local Object_metadata = {
  inheritTree = "Object", -- for :IsA(className)
  members = {
    ClassName = {
      MemberType = "Property",
      ValueType = "string",
      ReadOnly = true,
      Value = "Object"
    },
    IsA = {
      MemberType = "Method",
      ValueType = "function",
      ReadOnly = true,
      Value = function(self, className: string)
        return isA(self, className)
      end
    }
  }
  
}

local function isA(self, className: string): boolean
  local it = self.inheritTree
  local bt = string.split(it, ",")
  
  local v = false
  for i = 1, #bt do
    if className == bt[i] then v = true break end
  end
  
  return v
end

local Object = {}

setmetatable(Object, {
  __metatable = "The metatable is locked.",
  __index = function(t,k)
    for mk,t in pairs(Object_metadata.members) do
      if mk == k then
        return t.Value
      end
    end
  end,
  __tostring = Object.ClassName,
  __newindex = function(t, k, v)
    for mk,t in pairs(Object_metadata.members) do
      if mk == k then
        if t.ReadOnly then
          error("Unable to assign property "..k..". Property is read only")
        else
          if type(v) == t.ValueType then
            t.Value = v
          else
            error("Type '"..type(v).."' could not be converted into '"..t.ValueType.."'")
          end
        end
      end
    end
  end
})

return Object