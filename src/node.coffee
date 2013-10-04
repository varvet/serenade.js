class Node
  defineEvent(@prototype, "load", async: false)
  defineEvent(@prototype, "unload", async: false)

  constructor: (@ast, @element) ->

  addBoundClass: (className) ->
    @boundClasses or= []
    if @boundClasses?.indexOf(className) is -1
      @boundClasses.push(className)
    @updateClass()

  removeBoundClass: (className) ->
    @boundClasses.splice(@boundClasses.indexOf(className), 1) if @boundClasses
    @updateClass()

  addChildren: (children) ->
    @children = children

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
    @children or []

  bindEvent: (event, fun) ->
    @boundEvents or= []
    if event
      @boundEvents.push({ event, fun })
      event.bind(fun)

  unbindEvent: (event, fun) ->
    @boundEvents or= []
    if event
      @boundEvents.splice(@boundEvents.indexOf(fun), 1)
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
    classes = classes.concat(@boundClasses) if @boundClasses?.length
    classes.sort()
    if classes.length
      assignUnlessEqual(@element, "className", classes.join(' '))
    else
      @element.removeAttribute("class")
