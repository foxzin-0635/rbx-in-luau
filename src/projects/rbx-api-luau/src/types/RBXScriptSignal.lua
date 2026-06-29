local Runtime = getModule("Runtime")

local RBXScriptConnection = getRbxClass("RBXScriptConnection")

local __api_info = {
  Members = {
    {
      Category = "Function",
      Name = "Connect",
      Parameters = {
        {
          Name = "func",
          Type = {
            Category = "DataType",
            Name = "Function"
          }
        }
      },
      ReturnType = {
        Category = "DataType",
        Name = "RBXScriptConnection"
      },
      Security = "None",
      ThreadSafety = "Unsafe"
    }
  },
  Category = "DataType",
  Name = "RBXScriptSignal",
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

local RBXScriptSignal = {}
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

RBXScriptSignal.gettype = gettype
RBXScriptSignal.getApiInfo = getApiInfo

function RBXScriptSignal.new()
  local self = {}
  
  local __connections = {}
  
  self.Connect = function(self, func: (...) -> any) 
    local connection = RBXScriptConnection.new(func)
    
    table.insert(__connections, connection)
  end
  
  self.Fire = function()
    for i, c in ipairs(__connections) do
      if c.Disconnected then
        table.remove(__connections, i)
      end
    end 
    for _, c in ipairs(__connections) do
      c.func()
    end
  end
  
  self.__clearConnections = function(self)
    table.clear(__connections)
  end
  
  setmetatable(self, metatable)
  return self
end

function RBXScriptSignal:Destroy()
  self.Fire = nil
  self.Connect = nil
  self:__clearConnections()
end

setmetatable(RBXScriptSignal, metatable)
return RBXScriptSignal