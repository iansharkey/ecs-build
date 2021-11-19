local artifactPublishSystem = tiny.processingSystem()
artifactPublishSystem.filter = tiny.requireAll("filename", "artifact", "changed")

function artifactPublishSystem:process(e)
  print("publishing", e.filename)
end


return artifactPublishSystem