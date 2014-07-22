class Node extends View
  constructor: (@ast, @node) ->
    super

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

  append: (inside) ->
    inside.appendChild(@node)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@node, after.nextSibling)

  remove: ->
    super
    @node.parentNode?.removeChild(@node)

  setAttribute: (property, value) ->
    if property is 'value'
      assignUnlessEqual(@node, "value", value or '')
    else if @ast.name is 'input' and property is 'checked'
      assignUnlessEqual(@node, "checked", !!value)
    else if property is 'class'
      @attributeClasses = value
      @updateClass()
    else if value is undefined
      @node.removeAttribute(property) if @node.hasAttribute(property)
    else
      value = "0" if value is 0
      unless @node.getAttribute(property) is value
        @node.setAttribute(property, value)

  def @prototype, "lastElement", configurable: true, get: ->
    @node

  nodes: ->
    @children or []

  updateClass: ->
    classes = @ast.classes
    classes = classes.concat(@attributeClasses) if @attributeClasses
    classes = classes.concat(@boundClasses.toArray()) if @boundClasses?.length
    classes.sort()
    if classes.length
      assignUnlessEqual(@node, "className", classes.join(' '))
    else
      @node.removeAttribute("class")
