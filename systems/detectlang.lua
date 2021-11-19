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

return detectFileTypeSystem