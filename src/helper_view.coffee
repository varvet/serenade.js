class HelperView extends CollectionView
  constructor: (@ast, @model, @controller, @helper) ->

  def @prototype, "context", get: ->
    context = { model, controller, render: @render }

  render: =>
    new Template(null, ast.children).render(model, blockController, controller)
