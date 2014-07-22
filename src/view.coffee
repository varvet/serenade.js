class View
  constructor: ->
    @children = []

  append: (inside) ->

  insertAfter: (after) ->

  remove: ->
    @detach()

  detach: ->
    # recursively unbind events on children
    child.detach() for child in @children
    # remove events
    event.unbind(fun) for {event, fun} in @boundEvents if @boundEvents

  bindEvent: (event, fun) ->
    if event
      @boundEvents or= new Collection()
      @boundEvents.push({ event, fun })
      event.bind(fun)

  unbindEvent: (event, fun) ->
    if event
      @boundEvents or= new Collection()
      @boundEvents.delete(fun)
      event.unbind(fun)

