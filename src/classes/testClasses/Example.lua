local Runtime = getModule("Runtime")

-- Inherits from
local Object = githubRequire("src/classes/Object.lua")

-- Hook new custom class into API-Dump
local __api_info = {
  Members = {
    {
      Category = "Function",
      Name = "PrintHello",
      Parameters = {},
      ReturnType = {
        Category = "Primitive",
        Name = "null"
      },
      Security = "None",
      ThreadSafety = "Unsafe"
    }
  },
  MemoryCategory = "Instances",
  Name = "Example",
  Superclass = "Object",
  Tags = {"NotCreatable"}
}
table.insert(apidump.Classes, __api_info)

-- for typeof_hook(v)
local function gettype()
  return __api_info.Name
end

local function getApiInfo()
  if Runtime:IsEngineScript() then
    return __api_info
  end
end

local Example = {}
local metatable = {
  __metatable = "The metatable is locked",
  __index = function(t,k)
    if Runtime:IsEngineScript() then return rawget(Example, k) end
    return rawget(t, k)
  end,
  __tostring = function(t)
    return t.ClassName
  end,
  __newindex = function(t,k,v)
    return nil
  end
}

Example.PrintHello = function(self) print("Hello!") end

Example.__inheritIdxs = {1,888}
Example.gettype = gettype
Example.getApiInfo = getApiInfo

function Example.constructor()
  local self = Object.unprotectedconstructor()
  
  self.PrintHello = function() print("Hello") end
  
  setmetatable(self, metatable)
  return self
end

-- for inheritance
function Example.unprotectedconstructor()
  if not Runtime:IsEngineScript() then error("Attempt to use a protected constructor for "..__api_info.Name) return end
  local self = Object.unprotectedconstructor()
  
  self.PrintHello = function() print("Hello") end
  
  return self
end

function Example:destructor()
  self.PrintHello = nil
  Object.destructor(self)
end

setmetatable(Example, metatable)
return Example