{Cache} = require './cache'
{extend, format} = require './helpers'
{Property, defineProperty, globalDependencies} = require("./property")

Serenade = (wrapped) ->
  object = Object.create(wrapped)
  defineProperty(object, key) for key in Object.keys(wrapped)
  object

extend Serenade,
  VERSION: '0.3.0'
  _views: {}
  _controllers: {}

  document: window?.document
  format: format

  defineProperty: defineProperty

  view: (nameOrTemplate, template) ->
    {View} = require('./view')
    if template
      @_views[nameOrTemplate] = new View(nameOrTemplate, template)
    else
      new View(undefined, nameOrTemplate)

  render: (name, model, controller, parent, skipCallback) ->
    @_views[name].render(model, controller, parent, skipCallback)

  controller: (name, klass) ->
    @_controllers[name] = klass
  controllerFor: (name) -> @_controllers[name]
  clearIdentityMap: -> Cache._identityMap = {}
  clearLocalStorage: -> Cache._storage.clear()
  clearCache: ->
    Serenade.clearIdentityMap()
    Serenade.clearLocalStorage()
    delete globalDependencies[key] for value, key in globalDependencies
  unregisterAll: ->
    Serenade._views = {}
    Serenade._controllers = {}

  Model: require('./model').Model
  Collection: require('./collection').Collection
  Helpers: {}

exports.Serenade = Serenade

# Express.js support
exports.compile = ->
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
