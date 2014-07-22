class View
  constructor: (@node) ->
    @children = []

  append: (inside) ->
    inside.appendChild(@node)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@node, after.nextSibling)

  remove: ->
    @node.parentNode?.removeChild(@node)
    @detach()

  detach: ->
    # recursively unbind events on children
    child.detach() for child in @children
    # remove events
    event.unbind(fun) for {event, fun} in @boundEvents if @boundEvents

  def @prototype, "lastElement", configurable: true, get: ->
    @node

  _bindEvent: (event, fun) ->
    if event
      @boundEvents or= new Collection()
      @boundEvents.push({ event, fun })
      event.bind(fun)

  _unbindEvent: (event, fun) ->
    if event
      @boundEvents or= new Collection()
      @boundEvents.delete(fun)
      event.unbind(fun)

  _bindToModel: (name, fun) ->
    value = @model[name]
    property = @model["#{name}_property"]
    property?.registerGlobal?(value)
    @_bindEvent(property, (_, value) -> fun(value))
    fun(value)
