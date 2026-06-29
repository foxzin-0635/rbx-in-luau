local InsertionOrderedMap = {}

type InsertionOrderedMapModule<K, V> = {
  insert: (k: K, v:V) -> (),
  clear: () -> (),
  size: () -> number,
  contains: (k: K) -> boolean,
  get: (k: K) -> V?,
  begin: () -> K?,
  end_: () -> K?, -- end is a keyword, so add a random supported character for the identifier to change it to a identifier.
  -- find: (k: K) -> V?, -- it's the exact same as get() when simplified.
  erase: (k: K) -> ()
}

local InsertionOrderedMapClass: InsertionOrderedMapModule<any, any> = (function()
  local module = {}
  local metatable = {
    __metatable = "The metatable is locked",
    __index = module,
    __tostring = function(t)
      return "InsertionOrderedMap"
    end,
    __newindex = function() return nil end
  }
  
  module.type = "InsertionOrderedMap"
  
  local function size(self)
    return #self.__order
  end
  
  function module.new()
    local self = {}
    
    self.__order = {}
    self.__pairs = {}
    
    setmetatable(self, metatable)
    return self
  end
  
  function module:insert(k: K, v: V): ()
    local i = table.find(self.__order, k)
    if i then return end
    
    self.__pairs[k] = v
    table.insert(self.__order, k) -- "__order[i] = ..." was stupid, ngl.
  end
  
  function module:clear(): ()
    self.__pairs = {}
    self.__order = {}
  end
  
  function module:size(): number
    return size(self)
  end
  
  function module:contains(k: K): boolean
    return table.find(self.__order, k) ~= nil
  end
  
  function module:get(k: K): V?
    return self.__pairs[k]
  end
  
  function module:begin(): K?
    local key = self.__order[1]
    return key
  end
  
  function module:end_(): K?
    local key = self.__order[#self.__order]
    return key
  end
  
  function module:erase(k: K): ()
    local i = table.find(self.__order, k)
    if not i then return end
    self.__pairs[k] = nil
    table.remove(self.__order, i)
  end
  
  setmetatable(module, metatable)
  return module
end)()

-- Combine All
InsertionOrderedMap.InsertionOrderedMap = InsertionOrderedMapClass

return InsertionOrderedMap