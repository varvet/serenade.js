{Build} = require './build'
fs = require 'fs'

task 'build', 'build the whole thing', ->
  Build.unpacked (content) -> fs.writeFileSync "extras/serenade.js", content
  Build.minified (content) -> fs.writeFileSync "extras/serenade.min.js", content
  Build.gzipped  (content) -> fs.writeFileSync "extras/serenade.min.js.gz", content
