{Cache} = require './cache'
{extend} = require './helpers'
{Properties, globalDependencies} = require("./properties")

Serenade = (attributes) ->
  return new Serenade(attributes) if this is root
  @set(attributes)
  this

# IE7 (minimum IE supported version) demands lots of special cases
Serenade.isIE7 = /MSIE 7/.test navigator.userAgent if (ua = window?.navigator?.userAgent)

extend Serenade.prototype, Properties
extend Serenade,
  VERSION: '0.2.1'
  _views: {}
  _controllers: {}

  document: window?.document

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
  bindEvent: (element, event, callback) ->
    if typeof element.addEventListener is 'function'
      element.addEventListener(event, callback, false)
    else
      element.attachEvent('on' + event, callback)
  useJQuery: ->
    @bindEvent = (element, event, callback) ->
      jQuery(element).bind(event, callback)

  Events: require('./events').Events
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
