class BoundViewView extends DynamicView
  constructor: ->
    super

    @_bindToModel @ast.argument, (value) =>
      view = Serenade.templates[value].render(@model, @controller).view
      @replace([view])
