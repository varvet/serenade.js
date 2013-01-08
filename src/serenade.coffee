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
  defineEvent: defineEvent
  asyncEvents: false

  view: (nameOrTemplate, template) ->
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

  Model: Model
  Collection: Collection
  Cache: Cache
  View: View
  Helpers: {}
