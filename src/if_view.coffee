class IfView extends BoundView
  update: (value) ->
    if value
      @replace([new TemplateView(@ast.children, @model, @controller)])
    else if @ast.else
      @replace([new TemplateView(@ast.else.children, @model, @controller)])
    else
      @clear()

