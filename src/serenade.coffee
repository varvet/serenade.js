Serenade = (wrapped) ->
  object = Object.create(wrapped)
  defineProperty(object, key, value: value) for key, value of wrapped
  object

extend Serenade,
  VERSION: '0.5.0'
  views: {}
  templates: {}
  controllers: {}

  document: window?.document

  defineProperty: defineProperty
  defineEvent: defineEvent

  view: (name, generator) ->
    @views[name] = generator

  renderView: (name, args...) ->
    new @views[name](args...)

  template: (nameOrTemplate, template) ->
    if template
      @templates[nameOrTemplate] = new Template(nameOrTemplate, template)
    else
      new Template(undefined, nameOrTemplate)

  render: (name, model, controller) ->
    @templates[name].render(model, controller)

  controller: (name, klass) ->
    @controllers[name] = klass
  clearIdentityMap: -> Cache._identityMap = {}
  clearCache: ->
    Serenade.clearIdentityMap()
  unregisterAll: ->
    Serenade.templates = {}
    Serenade.controllers = {}

  Model: Model
  Collection: Collection
  Cache: Cache
  Template: Template
  View: View
  Element: Element
  CollectionView: CollectionView
  Helpers: {}

def Serenade, "async",
  get: -> settings.async
  set: (value) -> settings.async = value
