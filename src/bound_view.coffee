class BoundView extends DynamicView
  constructor: (@ast, @model, @controller) ->
    super @ast, @model, @controller

    value = @model[@ast.argument]

    property = @model["#{@ast.argument}_property"]
    property?.registerGlobal?(value)
    @_bindEvent(property, (_, value) => @update(value))

    @update(value)

  update: (value) ->
    notImplemeted()
