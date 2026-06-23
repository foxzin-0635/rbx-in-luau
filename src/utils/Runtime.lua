local Runtime = {}

function Runtime:IsStandardScript()
  return getfenv().get_thread_identity() == 2
end

function Runtime:IsReservedCoreScript()
  return getfenv().get_thread_identity() == 3
end

function Runtime:IsCommandBarScript()
  return getfenv().get_thread_identity() == 4
end

function Runtime:IsStandardPluginScript()
  return getfenv().get_thread_identity() == 5
end

function Runtime:IsElevatedPluginScript()
  return getfenv().get_thread_identity() == 6
end

function Runtime:IsCoreScript()
  return getfenv().get_thread_identity() >= 7
end

function Runtime:gettype()
  return "UtilityModule"
end

setmetatable(Runtime, {
  __metatable = "The metatable is locked",
  __index = Runtime,
  __newindex = function()
    return nil -- read-only
  end,
  __tostring = "Runtime",
})

return Runtime