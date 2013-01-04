exports.Events =
  bind: (ev, callback) ->
    evs   = ev.split(' ')
    calls = @hasOwnProperty('_callbacks') and @_callbacks or= {}

    for name in evs
      calls[name] or= []
      calls[name].push(callback)
    @

  one: (ev, callback) ->
    @bind ev, ->
      @unbind(ev, arguments.callee)
      callback.apply(@, arguments)

  trigger: (args...) ->
    ev = args.shift()

    list = @hasOwnProperty('_callbacks') and @_callbacks?[ev]
    return false unless list

    for callback in list
      callback.apply(@, args)
    true

  unbind: (ev, callback) ->
    unless ev
      @_callbacks = {}
      return @

    list = @_callbacks?[ev]
    return @ unless list

    unless callback
      delete @_callbacks[ev]
      return @

    for cb, i in list when cb is callback
      list = list.slice()
      list.splice(i, 1)
      @_callbacks[ev] = list
      break
    @

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
