local lfs = require "lfs"

local detectModificationTimeChangeSystem = tiny.processingSystem()
detectModificationTimeChangeSystem.filter = tiny.requireAll('filename')

function detectModificationTimeChangeSystem:process(e)
  if e.lastbuildtime == nil then
    e.lastbuildtime = 0
  end

  local mtime = lfs.attributes(e.filename, "modification")
  
  if mtime and mtime > e.lastbuildtime then
    print(e.filename, "mtime changed")
    e.changed = true
    e.lastbuildtime = mtime
  end
  world:add(e)
end

return detectModificationTimeChangeSystem