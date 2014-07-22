class IfView extends DynamicView
  constructor: ->
    super

    @_bindToModel @ast.argument, (value) =>
      if value
        @replace([new TemplateView(@ast.children, @model, @controller)])
      else if @ast.else
        @replace([new TemplateView(@ast.else.children, @model, @controller)])
      else
        @clear()
