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
  next: FValue<any>?,
  version: number
}

export type FValueVersionSetter = {}

type FValueModule = {
  new: <T>(name: string, def: T, dynamic: boolean) -> FValue<T>,
  list: FValue<any>?,
  version: number,
  type: string
}

type FValueVersionSetterModule = {
  new: <T>(name: string, def: T, dynamic: boolean) -> FValueVersionSetter,
  type: string
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
    return handler(expr, file, line, func)
  end
  return 1
end

local LUAU_ASSERT
if not NDEBUG and LUAU_ENABLE_ASSERT then
  LUAU_ASSERT = function(expr: any, message: string, file: string, line: number, func: string)
    if not expr then
      assertCallHandler(message, file, line, func)
      
      error(string.format("Assertion Failed! %s:%d in function %s :%s", file, line, func, message), 2)
    end
  end
else
  LUAU_ASSERT = function(...) end
end

local FValueClass: FValueModule = (function()
  local module = {}
  local metatable = {
    __metatable = "The metatable is locked",
    __index = module,
    __tostring = function(t)
      return "FValue"
    end
  }
  
  module.list = {} :: FValue<any>?
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
  
  function module.dumpFlags()
    local current = module.list
    print("--- Current FValues Linked List ---")
    while current ~= nil and current.name ~= nil and current.value ~= nil do
        print(string.format("Flag: %s | Value: %s", current.name, tostring(current.value)))
        current = current.next -- Step to the next node in the chain
    end
  end
  
  setmetatable(module, metatable)
  return module
end)()

local FValueVersionSetterClass: FValueVersionSetterModule = (function()
  local module = {}
  local metatable = {
    __metatable = "The metatable is locked",
    __index = module,
    __tostring = function(t)
      return "FValueVersionSetter"
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
    
    LUAU_ASSERT(found, "LUAU_FLAGVERSION must appear after the flag definition in the same source file", "Common/Common.lua", 123, "FValueVersionSetterClass.new");
    
    setmetatable(self, createInstanceMetatable())
    return self
  end
  
  setmetatable(module, metatable)
  return module
end)()

local FFlag = {} -- namespace

-- FFlags
local LUAU_FASTFLAG: FValue<boolean>
local function LUAU_FASTFLAGVARIABLE(flag: string): FValue<boolean>
  local fflag = FValueClass.new(flag, false, false)
  FFlag[flag] = fflag
  return fflag
end

local FInt = {} -- namespace

local LUAU_FASTINT: FValue<number>
local function LUAU_FASTINTVARIABLE(flag: string, def: number): FValue<number>
  local fflag = FValueClass.new(flag, def, false)
  FFlag[flag] = fflag
  return fflag
end

local DFFlag = {} -- namespace

local LUAU_DYNAMICFASTFLAG: FValue<boolean>
local function LUAU_DYNAMICFASTFLAGVARIABLE(flag: string): FValue<boolean>
  local fflag = FValueClass.new(flag, false, true)
  FFlag[flag] = fflag
  return fflag
end

local DFInt = {} -- namespace

local LUAU_DYNAMICFASTINT: FValue<number>
local function LUAU_DYNAMICFASTINTVARIABLE(flag: string, def: number): FValue<number>
  local fflag = FValueClass.new(flag, def, true)
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

FInt.LUAU_FASTINT = LUAU_FASTINT
FInt.LUAU_FASTINTVARIABLE = LUAU_FASTINTVARIABLE

DFFlag.LUAU_DYNAMICFASTFLAG = LUAU_DYNAMICFASTFLAG
DFFlag.LUAU_DYNAMICFASTFLAGVARIABLE = LUAU_DYNAMICFASTFLAGVARIABLE

DFInt.LUAU_DYNAMICFASTINT = LUAU_DYNAMICFASTINT
DFInt.LUAU_DYNAMICFASTINTVARIABLE = LUAU_DYNAMICFASTINTVARIABLE

Common.Namespaces = {}
Common.Namespaces.Luau = Luau
Common.Namespaces.FFlag = FFlag
Common.Namespaces.FInt = FInt
Common.Namespaces.DFFlag = DFFlag
Common.Namespaces.DFInt = DFInt

Common.Defines = {}
Common.Defines.LUAU_ASSERT = LUAU_ASSERT

-- Generate new env contents
local env = {}
env.Luau = Luau
env.FFlag = FFlag
env.FInt = FInt
env.DFFlag = DFFlag
env.DFInt = DFInt
env.LUAU_ASSERT = LUAU_ASSERT

return {
  Module = Common,
  NewEnv = env,
  NewEnvItemsNames = {
    "Luau",
    "FFlag",
    "FInt",
    "DFFlag",
    "DFInt",
    "LUAU_ASSERT"
  }
}