local artifactPublishSystem = tiny.processingSystem()
artifactPublishSystem.filter = tiny.requireAll("filename", "artifact", "changed")

function artifactPublishSystem:process(e)
  if e.changed and e.artifact then
    print("publishing", e.filename)
  end
end


return artifactPublishSystem
