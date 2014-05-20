Serenade = (wrapped) ->
  object = Object.create(wrapped)
  defineProperty(object, key, value: value) for key, value of wrapped
  object

extend Serenade,
  VERSION: '0.5.0'
  views: {}
  controllers: {}

  document: window?.document
  format: format

  defineProperty: defineProperty
  defineEvent: defineEvent

  view: (nameOrTemplate, template) ->
    if template
      @views[nameOrTemplate] = new Template(nameOrTemplate, template)
    else
      new Template(undefined, nameOrTemplate)

  render: (name, model, controller, parent, skipCallback) ->
    @views[name].render(model, controller, parent, skipCallback)

  controller: (name, klass) ->
    @controllers[name] = klass
  clearIdentityMap: -> Cache._identityMap = {}
  clearCache: ->
    Serenade.clearIdentityMap()
  unregisterAll: ->
    Serenade.views = {}
    Serenade.controllers = {}

  Model: Model
  Collection: Collection
  Cache: Cache
  Template: Template
  Helpers: {}

def Serenade, "async",
  get: -> settings.async
  set: (value) -> settings.async = value
