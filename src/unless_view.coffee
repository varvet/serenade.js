class UnlessView extends BoundView
  update: (value) ->
    if value
      @clear()
    else
      @replace([new TemplateView(@ast.children, @model, @controller)])
