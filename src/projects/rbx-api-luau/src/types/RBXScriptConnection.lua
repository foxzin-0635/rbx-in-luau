local Runtime = getModule("Runtime")

local __api_info = {
  Members = {
    {
      Category = "Function",
      Name = "Disconnect",
      Parameters = {},
      ReturnType = {
        Category = "Primitive",
        Name = "null"
      },
      Security = "None",
      ThreadSafety = "Unsafe"
    }
  },
  Category = "DataType",
  Name = "RBXScriptConnection",
}
if not apidump.DataTypes then
  apidump.DataTypes = {}
end
table.insert(apidump.DataTypes, __api_info)

-- for typeof_hook(v)
local function gettype()
  return __api_info.Name
end

local function getApiInfo()
  if Runtime:IsEngineScript(true) then
    return __api_info
  end
end

local RBXScriptConnection = {}
local metatable = {
  __metatable = "The metatable is locked",
  __index = function(t,k)
    if Runtime:IsEngineScript(true) then return rawget(Example, k) end
    return rawget(t, k)
  end,
  __tostring = function(t)
    return __api_info.Name
  end,
  __newindex = function(t,k,v)
    return nil
  end
}

RBXScriptConnection.gettype = gettype
RBXScriptConnection.getApiInfo = getApiInfo

function RBXScriptConnection.new(func: (...) -> ())
  local self = {}
  
  self.func = func
  self.Disconnected = false
  self.Disconnect = function(self)
    self.func = nil
    self.Disconnect = nil
    self.Disconnected = true
  end
  
  setmetatable(self, metatable)
  return self
end

setmetatable(RBXScriptConnection, metatable)
return RBXScriptConnection