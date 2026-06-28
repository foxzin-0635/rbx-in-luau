-- Roblox Luau port of "luau-lang/luau/Common/include/Luau/Common.h"
local Common = {}

local Luau = {} -- namespace

export type AssertHandler = (
  expr: string,
  file: string,
  line: number,
  func: string
) -> number

export type FValue<T> = {
  name: string,
  dynamic: boolean,
  value: T,
  next: FValue<any>?
}

local activeHandler: AssertHandler? = nil

local function assertHandler(newHandler: AssertHandler?): AssertHandler?
  if newHandler ~= nil then
    activeHandler = newHandler
  end
  return activeHandler
end

local function assertCallHandler(expr: string, file: string, line: number, func: string): number
  local handler = assertHandler()
  if handler then
    return handler(expr, file, line, number)
  end
  return 1
end

local LUAU_ASSERT
if not runVars.NDEBUG and runVars.LUAU_ENABLE_ASSERT then
  LUAU_ASSERT = function(expr: any, message: string, file: string, line: number, func: string)
    if not expr then
      assertCallHandler(message, file, line, func)
      
      error(string.format("Assertion Failed! %s:%d in function %s :%s", file, line, func, message), 2)
    end
  end
else
  LUAU_ASSERT = function(...) end
end

local FValueClass = (function()
  local module = {}
  local metatable = {
    __metatable = "The metatable is locked",
    __index = module,
    __tostring = function(t)
      return "FValue"
    end
  }
  
  module.list = {}
  module.type = "FValue"
  module.version = 0
  
  function module.new<T>(name: string, def: T, dynamic: boolean): FValue<T>
    local self: FValue<T> = {}
    
    self.value = def
    self.dynamic = dynamic
    self.name = name
    self.next = module.list
    module.list = self
    
    setmetatable(self, metatable)
    return self
  end
  
  setmetatable(module, metatable)
  return module
end)()

local FValueVersionSetterClass = (function()
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
  
  module.type = "FValueVersionSetter"
  
  function module.new(name: string, version: number)
    local self = {}
    
    local found = false
    
    local flag = FValueClass.list
    while flag do
      if flag.name == name then
        flag.version = version
        found = true
      end
      flag = flag.next
    end
    
    LUAU_ASSERT(found, "LUAU_FLAGVERSION must appear after the flag definition in the same source file", "Common/Common.lua", 123, "FValueVersionSetter.new");
    
    setmetatable(self, createInstanceMetatable())
    return self
  end
  
  setmetatable(module, metatable)
  return module
end)()

local FFlag = {} -- namespace

-- FFlags
local LUAU_FASTFLAG: FValue<<boolean>>
local function LUAU_FASTFLAGVARIABLE(flag: string): FValue<<boolean>>
  local fflag FValueClass.new<<boolean>>(flag, false, false)
  FFlag[flag] = fflag
  return fflag
end

local LUAU_FASTINT: FValue<<boolean>>
local function LUAU_FASTINTVARIABLE(flag: string, def: number)
  local fflag = FValueClass.new<<number>>(flag, def, false)
  FFlag[flag] = fflag
  return fflag
end

local LUAU_DYNAMICFASTFLAG: FValue<<boolean>>
local function LUAU_DYNAMICFASTFLAGVARIABLE(flag: string): FValue<<boolean>>
  local fflag = FValueClass.new<<boolean>>(flag, false, true)
  FFlag[flag] = fflag
  return fflag
end

local LUAU_DYNAMICFASTINT: FValue<<boolean>>
local function LUAU_DYNAMICFASTINTVARIABLE(flag: string, def: number)
  local fflag = FValueClass.new<<number>>(flag, def, true)
  FFlag[flag] = fflag
  return fflag
end

local function LUAU_FLAGVERSION(flag: string, version: number)
  assert(version ~= 0, "LUAU_FLAGVERSION version cannot be 0")
  FValueVersionSetterClass.new(flag, version)
end


-- Combine all
Luau.assertHandler = assertHandler
Luau.assertCallHandler = assertCallHandler
Luau.FValue = FValueClass
Luau.FValueVersionSetter = FValueVersionSetterClass

FFlag.LUAU_FASTFLAG = LUAU_FASTFLAG
FFlag.LUAU_FASTFLAGVARIABLE = LUAU_FASTFLAGVARIABLE

FFlag.LUAU_FASTINT = LUAU_FASTINT
FFlag.LUAU_FASTINTVARIABLE = LUAU_FASTINTVARIABLE

FFlag.LUAU_DYNAMICFASTFLAG = LUAU_DYNAMICFASTFLAG
FFlag.LUAU_DYNAMICFASTFLAGVARIABLE = LUAU_DYNAMICFASTFLAGVARIABLE

FFlag.LUAU_DYNAMICFASTINT = LUAU_DYNAMICFASTINT
FFlag.LUAU_DYNAMICFASTINTVARIABLE = LUAU_DYNAMICFASTINTVARIABLE

Common.Namespaces = {}
Common.Namespaces.Luau = Luau
Common.Namespaces.FFlag = FFlag

Common.Defines = {}
Common.Defines.LUAU_ASSERT = LUAU_ASSERT

-- Generate new env contents
local env = {}
env.Luau = Luau
env.FFlag = FFlag
env.LUAU_ASSERT = LUAU_ASSERT

return {
  Module = Common,
  NewEnv = env,
  NewEnvItemsNames = {
    "Luau",
    "FFlag",
    "LUAU_ASSERT"
  }
}