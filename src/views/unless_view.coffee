class UnlessView extends DynamicView
  constructor: ->
    super

    @_bindToModel @ast.argument, (value) =>
      if value
        @clear()
      else
        @replace([new TemplateView(@ast.children, @context)])
