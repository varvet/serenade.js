class Node
  defineEvent(@prototype, "load")
  defineEvent(@prototype, "unload")

  constructor: (@ast, @element) ->
    @children = new Collection([])
    @boundClasses = new Collection([])

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

  remove: ->
    @unbindEvents()
    @element.parentNode?.removeChild(@element)

  lastElement: ->
    @element

  nodes: ->
    @children

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

  updateClass: ->
    classes = @ast.classes
    classes = classes.concat(@attributeClasses) if @attributeClasses
    classes = classes.concat(@boundClasses.toArray()) if @boundClasses.length
    if classes.length
      @element.className = classes.join(' ')
    else
      @element.removeAttribute("class")
