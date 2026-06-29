local Runtime = getModule("Runtime")
local __api_info = apidump.Classes[1]

local Object = {}
local metatable = {
  __metatable = "The metatable is locked",
  __index = function(t,k)
    if Runtime:IsEngineScript(true) then return rawget(Object, k) end
    return rawget(t, k)
  end,
  __tostring = function(t)
    return t.ClassName
  end,
  __newindex = function(t,k,v)
    return nil
  end
}

-- for typeof_hook(v)
local function gettype()
  return __api_info.Name
end

local function getApiInfo()
  if Runtime:IsEngineScript(true) then
    return __api_info
  end
end

-- Mimic the behavior of the original :IsA(className)
local function isA(self, className: string): boolean
  if not Runtime:IsEngineScript(true) then
    rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = true
    Runtime:SetIdentityLevelByContext("NotAccessibleSecurity")
  
    local v = false
    
    for i = 1, #self.__inheritIdxs do
      if className == apidump.Classes[tonumber(self.__inheritIdxs[i])].Name then v = true break end
    end
    
    return v
  end
  
  local v = false
  
  for i = 1, #self.__inheritIdxs do
    if className == apidump.Classes[tonumber(self.__inheritIdxs[i])].Name then v = true break end
  end
  
  rbx_api_config.SimulatedIdentityHacks.NotAccessibleSecurity.CanUse = false
  Runtime:SetIdentityLevelByContext("None")
  
  return v
end

Object.ClassName = __api_info.Name
Object.IsA = isA

Object.__inheritIdxs = {1}
Object.gettype = gettype
Object.getApiInfo = getApiInfo

function Object.constructor()
  if not Runtime:IsEngineScript(true) then error("Attempt to use a protected constructor for "..__api_info.Name) end
  local self = setmetatable({}, metatable)
  self.ClassName = __api_info.Name
  self.IsA = isA
  return self
end

-- for inheritance
function Object.unprotectedconstructor()
  if not Runtime:IsEngineScript(true) then error("Attempt to use a protected constructor for "..__api_info.Name) end
  local self = {}
  self.ClassName = __api_info.Name
  self.IsA = isA
  return self
end

function Object:destructor(self)
  self.ClassName = nil
  self.IsA = nil
  setmetatable(self, nil)
end

setmetatable(Object, metatable)
return Object