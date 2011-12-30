{Build} = require './build'

task 'build:files', 'build Serenade.js from source', ->
  Build.files()

task 'build:parser', 'rebuild the Jison parser (run build:files first)', ->
  Build.parser()

task 'build:browser', 'rebuild the merged script for inclusion in the browser', ->
  Build.browser()

task 'build', 'build the whole thing', ->
  Build.all()
