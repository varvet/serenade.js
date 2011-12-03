fs = require 'fs'
path = require 'path'
CoffeeScript = require 'coffee-script'

task 'build', 'build Monkey.js from source', build = (cb) ->
  files = fs.readdirSync 'src'
  for file in files when file.match(/\.coffee$/)
    path = 'src/' + file
    newPath = 'lib/' + file.replace(/\.coffee$/, '.js')
    fs.writeFile newPath, CoffeeScript.compile(fs.readFileSync(path).toString(), bare: false)

task 'build:parser', 'rebuild the Jison parser (run build first)', ->
  extend global, require('util')
  require 'jison'
  parser = require('./lib/coffee-script/grammar').parser
  fs.writeFile 'lib/coffee-script/parser.js', parser.generate()
