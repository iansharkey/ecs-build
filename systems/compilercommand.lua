local identifyCompilerSystem = tiny.processingSystem()
identifyCompilerSystem.filter = tiny.filter('filename&old_md5&contentlang&!compilercommand')


local compiler_commands = {
  C = "cc -c -o $FILEPREFIX.o $FILENAME",
  ["Object file"] = "cc -o $FILEPREFIX $FILENAME"
  }


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


return identifyCompilerSystem