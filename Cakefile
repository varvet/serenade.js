fs = require 'fs'
path = require 'path'
CoffeeScript = require 'coffee-script'
{Monkey} = require './src/monkey'

header = """
  /**
   * Monkey.js JavaScript Framework v#{Monkey.VERSION}
   * http://github.com/elabs/monkey.js
   *
   * Copyright 2011, Jonas Nicklas
   * Released under the MIT License
   */
"""

task 'build', 'build Monkey.js from source', build = (cb) ->
  files = fs.readdirSync 'src'
  for file in files when file.match(/\.coffee$/)
    unless file is 'parser.coffee'
      path = 'src/' + file
      newPath = 'lib/' + file.replace(/\.coffee$/, '.js')
      fs.writeFile newPath, CoffeeScript.compile(fs.readFileSync(path).toString(), bare: false)

task 'build:parser', 'rebuild the Jison parser (run build first)', ->
  {Parser} = require('./lib/grammar')
  fs.writeFile 'lib/parser.js', Parser.generate()

task 'build:browser', 'rebuild the merged script for inclusion in the browser', ->
  requires = ''
  for name in ['monkey', 'events', 'lexer', 'model', 'nodes', 'parser', 'properties', 'view']
    requires += """
      require['./#{name}'] = new function() {
        var exports = this;
        #{fs.readFileSync "lib/#{name}.js"}
      };
    """
  code = """
    (function(root) {
      var Monkey = function() {
        function require(path){ return require[path]; }
        #{requires}
        return require['./monkey'].Monkey
      }();

      if(typeof define === 'function' && define.amd) {
        define(function() { return Monkey });
      } else { root.Monkey = Monkey }
    }(this));
  """
  unless process.env.MINIFY is 'false'
    {parser, uglify} = require 'uglify-js'
    code = uglify.gen_code uglify.ast_squeeze uglify.ast_mangle parser.parse code
  fs.writeFileSync 'extras/monkey.js', header + '\n' + code
