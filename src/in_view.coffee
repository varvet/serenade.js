class InView extends DynamicView
  constructor: ->
    super

    @_bindToModel @ast.argument, (value) =>
      if value
        @replace([new TemplateView(@ast.children, value, @controller)])
      else
        @clear()
