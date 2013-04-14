# We prioritize getting this to work in the browser over being a good node/commonjs citizen.
# To get this to work in commonjs anyway, we basically eval the whole thing. Sue me.

CoffeeScript = require 'coffee-script'
fs = require 'fs'
path = require 'path'
gzip = require 'gzip'

vm = require("vm")
fs = require("fs")

exec = require('child_process').exec

Build =
  header: (callback) ->
    exec "git rev-parse HEAD", (error, stdout, stderr) ->
      callback """
        /**
         * Serenade.js JavaScript Framework v#{Serenade.VERSION}
         * Revision: #{stdout.slice(0, 10)}
         * http://github.com/elabs/serenade.js
         *
         * Copyright 2011, Jonas Nicklas, Elabs AB
         * Released under the MIT License
         */
      """

  sourceFiles: [
    "helpers"
    "promise"
    "event"
    "cache"
    "collection"
    "association_collection"
    "property"
    "model"
    "lexer"
    "node"
    "dynamic_node"
    "compile"
    "view"
    "serenade"
  ]

  source: ->
    files = {}

    js = require('./grammar').Parser.generate()
    coffee = ""
    coffee += fs.readFileSync("./src/#{name}.coffee").toString() for name in @sourceFiles
    js += CoffeeScript.compile(coffee, bare: true)
    """
      (function(root) {
        #{js};
        root.Serenade = Serenade;
      }(this));
    """

  load: ->
    # unfortunately because vm is pretty broken we need to declare every single object/function we refer to here
    sandbox = { parser: require('./grammar').Parser, console, Object, SyntaxError, clearTimeout, setTimeout: -> setTimeout(arguments...) }

    context = vm.createContext(sandbox)
    for name in @sourceFiles
      path = "./src/#{name}.coffee"
      source = fs.readFileSync(path)
      data = CoffeeScript.compile(source.toString(), bare: true, filename: path)
      vm.runInContext(data, context, path)

    context

  unpacked: (callback) ->
    @header (header) =>
      callback(header + '\n' + @source())

  minified: (callback) ->
    @header (header) =>
      {parser, uglify} = require 'uglify-js'
      minified = uglify.gen_code uglify.ast_squeeze uglify.ast_mangle parser.parse @source()
      callback(header + "\n" + minified)

  gzipped: (callback) ->
    Build.minified (minified) ->
      gzip (minified), (err, data) ->
        callback(data)

build = Build.load()
build.Build = Build
Serenade = build.Serenade

module.exports = build
# Express.js support
module.exports.compile = ->
  document = require("jsdom").jsdom(null, null, {})
  fs = require("fs")
  window = document.createWindow()
  Serenade.document = document

  (env) ->
    model = env.model
    viewName = env.filename.split('/').reverse()[0].replace(/\.serenade$/, '')
    Serenade.view(viewName, fs.readFileSync(env.filename).toString())
    element = Serenade.render(viewName, model, {})
    document.body.appendChild(element)
    html = document.body.innerHTML
    html = "<!DOCTYPE html>\n" + html unless env.doctype is false
    html
