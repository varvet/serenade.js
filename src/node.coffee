class Node
  defineEvent(@prototype, "load", async: false)
  defineEvent(@prototype, "unload", async: false)

  constructor: (@ast, @element) ->
    @children = new Collection([])
    @boundClasses = new Collection([])
    @boundEvents = new Collection([])

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

  remove: ->
    @detach()
    @element.parentNode?.removeChild(@element)

  def @prototype, "lastElement", configurable: true, get: ->
    @element

  nodes: ->
    @children

  bindEvent: (event, fun) ->
    if event
      @boundEvents.push({ event, fun })
      event.bind(fun)

  unbindEvent: (event, fun) ->
    if event
      @boundEvents.delete(fun)
      event.unbind(fun)

  detach: ->
    # trigger unload callbacks
    @unload.trigger()
    # recursively unbind events on children
    node.detach() for node in @nodes()
    # remove events
    event.unbind(fun) for {event, fun} in @boundEvents if @boundEvents

  updateClass: ->
    classes = @ast.classes
    classes = classes.concat(@attributeClasses) if @attributeClasses
    classes = classes.concat(@boundClasses.toArray()) if @boundClasses.length
    classes.sort()
    if classes.length
      assignUnlessEqual(@element, "className", classes.join(' '))
    else
      @element.removeAttribute("class")
