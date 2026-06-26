-- luau-lang/luau/Common/include/Luau/Common.h
local Common = {}

export type AssertHandler = {
  expr: string,
  file: string,
  func: string
}

local Luau = {} -- namespace

local FValue = (function()
  local module = {}
  local metatable = {
    __metatable = "The metatable is locked",
    __index = module,
    __tostring = function(t)
      return "FValue"
    end
  }
  
  type FValueType<T> = {
    name: string,
    dynamic: boolean,
    value: T,
    next: FValueType<any>?
  }
  
  module.list = {
    boolean = nil,
    number = nil
  }
  module.version = 0
  
  function module.new<T>(name: string, def: T, dynamic: boolean)
    local self = setmetatable({}, nil)
    
    self.value = def
    self.dynamic = dynamic
    self.name = name
    local head = module.list[typeof(def)]
    self.next = head
    module.list[typeof(def)] = self
    
    setmetatable(self, metatable)
    return self
  end
  
  setmetatable(module, metatable)
  return module
end)()

local FValueVersionSetter = (function()
  local module = {}
  local metatable = {
    __metatable = "The metatable is locked",
    __index = module,
    __tostring = function(t)
      return "FValue"
    end
  }
  
  local function createInstanceMetatable()
    local mtc = table.clone(metatable)
    mtc.__newindex = function() return nil end
    return mtc
  end
  
  function module.new(name: string, version: number)
    local self = setmetatable({}, nil)
    
    local found = false
    
    local fbool = FValue.list.boolean
    while fbool do
      if fbool.name == name then
        fbool.version = version
        found = true
      end
      fbool = fbool.next
    end
    
    local fint = FValue.list.number
    while fint do
      if fint.name == name then
        fint.version = version
        found = true
      end
      fint = fint.next
    end
    
    setmetatable(self, createInstanceMetatable())
    return self
  end
  
  setmetatable(module, metatable)
  return module
end)()

-- FFlags
local function DefineFlag<T>(params: {name: string, def: boolean, dynamic: boolean})
  return FValue.new<params.def>(params.name, params.def, params.dynamic)
end

return Common