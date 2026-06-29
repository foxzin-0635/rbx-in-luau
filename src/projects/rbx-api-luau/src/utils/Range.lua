local Range = {}
Range.lo = 0
Range.hi = 0

function Range.new(lo: number?, hi: number?)
  if lo > hi then error("Lower value is higher than Higher value!") end
  if hi < lo then error("Higher value is lower than Lower value!") end
  local self = setmetatable({lo = lo or Range.lo, hi = hi or Range.hi}, {
    __metatable = "The metatable is locked",
    __index = Range,
    __newindex = function()
      return nil -- read-only
    end,
    __tostring = "Range",
  })
  return self
end

function Range:IsInRange(v: number)
  return v >= self.lo and v <= self.hi
end

function Range:gettype()
  return "UtilityModule"
end

setmetatable(Range, {
  __metatable = "The metatable is locked",
  __index = Range,
  __newindex = function()
    return nil -- read-only
  end,
  __tostring = "Range",
})

return Range