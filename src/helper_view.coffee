class HelperView extends CollectionView
  constructor: (@ast, @model, @controller, @helper) ->

  def @prototype, "context", get: ->
    context = { model, controller, render: @render }

  render: (model, controller) =>
    new TemplateView(@ast.children, model, controller, @controller)
