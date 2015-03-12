Serenade = (wrapped) ->
  object = Object.create(wrapped)
  defineProperty(object, key, value: value) for key, value of wrapped
  object

extend Serenade,
  VERSION: '0.5.0'
  views: {}
  templates: {}

  document: window?.document

  defineProperty: defineProperty
  defineEvent: defineEvent

  view: (name, fn) ->
    @views[name] = (ast, model, controller) -> new fn(ast, model, controller)

  helper: (name, fn) ->
    @views[name] = (ast, model, controller) -> new HelperView(ast, model, controller, fn)

  renderView: (ast, model, controller) ->
    if @views[ast.name]
      @views[ast.name](ast, model, controller)
    else
      new Element(ast, model, controller)

  template: (nameOrTemplate, template) ->
    if template
      @templates[nameOrTemplate] = new Template(nameOrTemplate, template)
    else
      new Template(undefined, nameOrTemplate)

  render: (name, model, controller) ->
    @templates[name].render(model, controller)

  clearIdentityMap: -> Cache._identityMap = {}
  clearCache: ->
    Serenade.clearIdentityMap()
  unregisterAll: ->
    Serenade.views = {}
    Serenade.templates = {}

  Model: Model
  Collection: Collection
  Cache: Cache
  Template: Template
  View: View
  Element: Element
  CollectionView: CollectionView

def Serenade, "async",
  get: -> settings.async
  set: (value) -> settings.async = value
