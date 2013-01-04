exports.NodeEvents =
  bindEvent: (event, fun) ->
    if event
      @boundEvents or= []
      @boundEvents.push({ event, fun })
      event.bind(fun)

  unbindEvents: ->
    # trigger unload callbacks
    @unload.trigger()
    # recursively unbind events on children
    node.unbindEvents() for node in @nodes()
    # remove events
    event.unbind(fun) for {event, fun} in @boundEvents if @boundEvents
