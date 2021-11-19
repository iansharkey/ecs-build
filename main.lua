local tiny = require "lib.tiny"
local io = require "io"
local md5 = require "md5"
local lfs = require "lfs"
local os = require "os"


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

local printChangedSystem = tiny.processingSystem()
printChangedSystem.filter = tiny.requireAll('filename', 'changed')

function printChangedSystem:process(e)
  print(e.filename, e.changed, "changed", e.contentlang)
  e.changed = nil
  world:add(e)
end


local detectFileTypeSystem = tiny.processingSystem()
detectFileTypeSystem.filter = tiny.filter('filename&!contentlang')

local ext_lang_map = {
 c = "C",
 cpp = "C++",
 py = "Python",
 pyc = "Python (compiled)",
 o = "Object file"
}

function detectFileTypeSystem:process(e)
  local fileext = e.filename:match(".*%.(.*)")
  if fileext then
    e.contentlang = ext_lang_map[fileext]
  else
    e.contentlang = "Binary"
  end
  world:add(e)
end



local identifyCompilerSystem = tiny.processingSystem()
identifyCompilerSystem.filter = tiny.filter('filename&old_md5&contentlang&!compilercommand')

function identifyCompilerSystem:process(e)
  print("identifying", e.filename, e.contentlang, e.compilercommand)
  local fileprefix = e.filename:match("^(.*)%.(.*)")
  local compiler_command_template = compiler_commands[e.contentlang]
  if compiler_command_template then
    e.compilercommand = compiler_command_template:gsub("%$FILENAME", e.filename):gsub("%$FILEPREFIX", fileprefix)
    if e.contentlang == "C" then
      e.creates = e.creates or {}

      local output_file = { filename = fileprefix .. ".o", old_md5 = '', intermediate = true }

      table.insert(e.creates,output_file)
      add_file(output_file)
    elseif e.contentlang == "Object file" then
      e.creates = e.creates or {}
      local output_file = { filename = fileprefix, old_md5 = '', intermediate = true }

      table.insert(e.creates,output_file)
      add_file(output_file)
    end
  else
    e.compilercommand = ''
  end
  world:add(e)
end


local artifactPublishSystem = tiny.processingSystem()
artifactPublishSystem.filter = tiny.requireAll("filename", "artifact", "changed")

function artifactPublishSystem:process(e)
  print("publishing", e.filename)
end


compiler_commands = {
  C = "cc -c -o $FILEPREFIX.o $FILENAME",
  ["Object file"] = "cc -o $FILEPREFIX $FILENAME"
  }


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