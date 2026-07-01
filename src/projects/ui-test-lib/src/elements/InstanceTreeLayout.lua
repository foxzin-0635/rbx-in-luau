local CR = getModule("CreateRecursive")
local InstanceTreeLayout = {}
export type TreeInstanceData = {
  {
    Inst: Instance | { [string]: any },
    Childs: TreeInstanceData?
  }
}

local metatable = {
  __index = InstanceTreeLayout
}

function InstanceTreeLayout.new()
  local self = setmetatable({}, InstanceTreeLayout)
  
  self.Elements = {} :: TreeInstanceData
  
  return self
end

function InstanceTreeLayout:GetInstanceByIndex(...)
  local args = {...}
  local inst = nil
  
  for _, i in ipairs(args) do
    if not inst then
      if self.Elements[i] then
        inst = self.Elements[i]
      else
        return nil
      end
    else
      if inst.Childs and inst.Childs[i] then
        inst = inst.Childs[i]
      else
        return nil
      end
    end
  end
  
  return if inst and inst.Inst then inst.Inst else nil
end

return InstanceTreeLayout