local printChangedSystem = tiny.processingSystem()
printChangedSystem.filter = tiny.requireAll('filename', 'changed')

function printChangedSystem:process(e)
  print(e.filename, e.changed, "changed", e.contentlang)
  e.changed = nil
  world:add(e)
end

return printChangedSystem