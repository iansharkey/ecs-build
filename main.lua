tiny = require "lib.tiny"


-- todo: handle destructive updates
--  maybe use metatables?
local file_entity_cache = {}
function add_file(e)
  -- locate an existing entity with this name
  local cached = file_entity_cache[e.filename]
  if cached then
   -- merge existing key/value pairs into cached entity
   for k,v in pairs(e) do
   
    cached[k] = v
   end
  else
   -- if no entity, create and cache
   cached = e
   file_entity_cache[e.filename] = cached
  end

  -- update world
  world:add(cached)
end


local detectChangeSystem = require "systems.contentchange"
local identifyCompilerSystem = require "systems.compilercommand"
local detectModificationTimeChangeSystem = require "systems.mtime"
local artifactPublishSystem = require "systems.publish"
local printChangedSystem = require "systems.debug"

world = tiny.world(detectChangeSystem,
      	           identifyCompilerSystem,
		   detectModificationTimeChangeSystem,
		   artifactPublishSystem,
	           printChangedSystem)

local file1 = { filename = "file1.c", old_md5 = '' }
local file2 = { filename = "file2.py", old_md5 = '' }

local file3 = { filename = "file1", artifact = true }

add_file(file1)
add_file(file2)
add_file(file3)

for i = 1,50 do
 world:update()
end