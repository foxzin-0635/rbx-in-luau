local Runtime = getModule("Runtime")

local RBXScriptConnection = getRbxClass("data-types/RBXScriptConnection")

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
    },
    {
      Category = "Function",
      Name = "Once",
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
    },
    {
      Category = "Function",
      Name = "Wait",
      Parameters = {},
      ReturnType = {
        Category = "Group",
        Name = "Variant"
      },
      Security = "None",
      ThreadSafety = "Unsafe"
    },
    {
      Category = "Function",
      Name = "Fire",
      Parameters = {
        {
          Name = "args",
          Type = {
            Category = "Group",
            Name = "Variant"
          }
        }
      },
      ReturnType = {
        Category = "Primitive",
        Name = "null"
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
  
  local __yieldingThreads = {}
  local __connections = {}
  
  self.Connect = function(self, func: (...: any) -> any) 
    local connection = RBXScriptConnection.new(func)
    
    table.insert(__connections, {
      type = "default",
      connection = connection
    })
  end
  
  self.Once = function(self, func: (...: any) -> any)
    local connection = RBXScriptConnection.new(func)
    
    table.insert(__connections, {
      type = "once",
      connection = connection
    })
  end
  
  self.Wait = function(self)
    local thread = coroutine.running()

    table.insert(__yieldingThreads, thread)
    
    return coroutine.yield()
  end
  
  self.Fire = function(self, ...: any)
    for i, t in ipairs(__connections) do
      if t.connection.Disconnected then
        table.remove(__connections, i)
      end
      
      local v: any = t.connection.func(...)
      
      if t.type == "once" then
        t.connection:Disconnect()
        table.remove(__connections, i)
      end
      
      if #__yieldingThreads > 0 then
      for _i, _t in ipairs(__yieldingThreads) do
        coroutine.resume(_t, v)
        table.remove(__yieldingThreads, _i)
      end
    end
    end
  end
  
  self.__clearConnections = function(self)
    for _, t in ipairs(__connections) do
      t.connection:Disconnect()
    end
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