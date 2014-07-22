class BoundViewView extends BoundView
  update: (value) ->
    view = Serenade.templates[value].render(@model, @controller).view
    @replace([view])
