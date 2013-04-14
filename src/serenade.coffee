Serenade = (wrapped) ->
  object = Object.create(wrapped)
  defineProperty(object, key, value: value) for key, value of wrapped
  object

extend Serenade,
  VERSION: '0.4.1'
  _views: {}
  _controllers: {}

  document: window?.document
  format: format

  defineProperty: defineProperty
  defineEvent: defineEvent
  asyncEvents: false

  view: (nameOrTemplate, template) ->
    if template
      @_views[nameOrTemplate] = new View(nameOrTemplate, template)
    else
      new View(undefined, nameOrTemplate)

  render: (name, model, controller, parent, skipCallback) ->
    @_views[name].render(model, controller, parent, skipCallback)

  compile: (name, model, controller, parent, skipCallback) ->
    @_views[name].compile(model, controller, parent, skipCallback)

  controller: (name, klass) ->
    @_controllers[name] = klass
  controllerFor: (name) -> @_controllers[name]
  clearIdentityMap: -> Cache._identityMap = {}
  clearCache: ->
    Serenade.clearIdentityMap()
  unregisterAll: ->
    Serenade._views = {}
    Serenade._controllers = {}

  Promise: Promise
  Model: Model
  Collection: Collection
  Cache: Cache
  View: View
  Helpers: {}

def Serenade, "async",
  get: -> settings.async
  set: (value) -> settings.async = value
