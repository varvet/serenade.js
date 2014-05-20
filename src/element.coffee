class Element extends View
  defineEvent(@prototype, "load", async: false)
  defineEvent(@prototype, "unload", async: false)

  constructor: (@ast, @element) ->

  addBoundClass: (className) ->
    @boundClasses or= new Collection()
    unless @boundClasses?.includes(className)
      @boundClasses.push(className)
      @updateClass()

  removeBoundClass: (className) ->
    if @boundClasses
      index = @boundClasses.indexOf(className)
      @boundClasses.delete(className)
      @updateClass()

  setAttributeClass: (name="__self__", value) ->
    @attributeClasses or= {}
    @attributeClasses[name] = value
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
    if event
      @boundEvents or= new Collection()
      @boundEvents.push({ event, fun })
      event.bind(fun)

  unbindEvent: (event, fun) ->
    if event
      @boundEvents or= new Collection()
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
    if @attributeClasses
      classes = classes.concat(value) for own _, value of @attributeClasses
    classes = classes.concat(@boundClasses.toArray()) if @boundClasses?.length
    classes.sort()
    if classes.length
      assignUnlessEqual(@element, "className", classes.join(' '))
    else
      @element.removeAttribute("class")
