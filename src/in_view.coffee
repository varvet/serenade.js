class InView extends BoundView
  update: (value) ->
    if value
      @replace([new TemplateView(@ast.children, value, @controller)])
    else
      @clear()
