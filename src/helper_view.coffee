# turn a single element, document fragment, compiled view or string, or an
# array of any of these into views.
normalize = (ast, val) ->
  return [] unless val
  reduction = (aggregate, element) ->
    if typeof(element) is "string"
      div = Serenade.document.createElement("div")
      div.innerHTML = element
      aggregate.push(new Node(ast, child)) for child in div.childNodes
    else if element.nodeName is "#document-fragment"
      if element.view # rendered Serenade.template, clean up listeners!
        aggregate = aggregate.concat(element.view)
      else
        aggregate.push(new Node(ast, child)) for child in element.childNodes
    else
      aggregate.push(new Node(ast, element))
    aggregate
  new Collection([].concat(val).reduce(reduction, []))

class HelperView extends DynamicView
  constructor: (@ast, @model, @controller, @helper) ->
    super

    @context = { @model, @controller, @render }
    @update()

    for property in @ast.properties when property.bound is true
      @bindEvent(@model["#{property.value}_property"], @update)

  update: =>
    @clear()
    @children = normalize(@ast, @helper.call(@context, @arguments))
    @rebuild()

  def @prototype, "arguments", get: ->
    args = {}
    for property in @ast.properties
      if property.scope isnt "attribute"
        throw(new SyntaxError("scope '#{property.scope}' is not allowed for custom helpers"))

      args[property.name] = if property.static or property.bound
        @model[property.value]
      else
        property.value
    args

  render: (model, controller) =>
    new TemplateView(@ast.children, model, controller, @controller).fragment
