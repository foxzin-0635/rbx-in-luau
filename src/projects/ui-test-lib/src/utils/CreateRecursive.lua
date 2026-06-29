local CR = {}

type InstanceProps = {{[string]: any}}

function CR.Create(instanceContents: InstanceProps, inst: Instance?, initialParent: Instance?)
  local i
  for _,t in pairs(instanceContents) do
    i = Instance.new(t.ClassName)
    if inst then i.Parent = inst end
    if initialParent then i.Parent = initialParent end
    for k,v in pairs(t) do
      if k == "ClassName" then continue end
      if k == "Childs" then CR.Create(v, i) continue end
      if k == "Parent" then continue end
      i[k] = v
    end
  end
  return i
end

return CR