class BoundViewView extends DynamicView
  constructor: ->
    super

    @_bindToModel @ast.argument, (value) =>
      view = Serenade.templates[value].render(@context).view
      @replace([view])
