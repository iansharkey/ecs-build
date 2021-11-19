local md5 = require "md5"
local io = require "io"


local detectContentChangeSystem = tiny.processingSystem()
detectContentChangeSystem.filter = tiny.requireAll('filename', 'changed', 'old_md5')

function detectContentChangeSystem:process(e)
  if e.changed then -- early out if already known to be changed
    return
  end

  local fp = io.open(e.filename, "rb")
  local new_hash
  if fp then
    new_hash = md5.sum(fp:read("*a"))
    if new_hash ~= e.old_md5 then
      e.changed = true
    end
  else
   new_hash = e.old_md5
  end
  e.old_md5 = new_hash
  world:add(e)
end

return detectContentChangeSystem