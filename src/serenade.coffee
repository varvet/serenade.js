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
    @views[name] = (ast, context) -> new fn(ast, context)

  helper: (name, fn) ->
    @views[name] = (ast, context) -> new HelperView(ast, context, fn)

  renderView: (ast, context) ->
    if @views[ast.name]
      @views[ast.name](ast, context)
    else
      new Element(ast, context)

  template: (nameOrTemplate, template) ->
    if template
      @templates[nameOrTemplate] = new Template(nameOrTemplate, template)
    else
      new Template(undefined, nameOrTemplate)

  render: (name, context) ->
    @templates[name].render(context)

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
