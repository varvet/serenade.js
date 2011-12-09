{Monkey} = require './monkey'

EVENTS = ['click', 'blur', 'focus', 'change', 'mouseover', 'mouseout', 'submit']


class Monkey.Element
  type: 'element'
  constructor: (@name, @attributes, @children) ->
    @attributes or= []
    @children or= []
  compile: (document, model, controller) ->
    element = document.createElement(@name)

    for attribute in @attributes
      attribute.append(element, document, model, controller)

    for child in @children
      child.append(element, document, model, controller)
    element

  append: (element, args...) ->
    element.appendChild(@compile(args...))

  insertAfter: (element, args...) ->
    newEl = @compile(args...)
    element.parentNode.insertBefore(newEl, element.nextSibling)
    -> [newEl]

class Monkey.Attribute
  type: 'attribute'
  constructor: (@name, @value, @bound) ->

  attribute: (element, document, model, constructor) ->
    value = @get(model)
    unless value is undefined
      element.setAttribute(@name, value)
    if @bound
      model.bind? "change:#{@value}", (value) =>
        if @name is 'value'
          element.value = value or ''
        else if value is undefined
          element.removeAttribute(@name)
        else
          element.setAttribute(@name, value)

  event: (element, document, model, controller) ->
    callback = (e) => controller[@value](e)
    element.addEventListener(@name, callback, false)

  append: (args...) ->
    if @name in EVENTS
      @event(args...)
    else
      @attribute(args...)

  get: (model) -> Monkey.get(model, @value, @bound)

class Monkey.TextNode
  type: 'text'
  constructor: (@value, @bound) ->
  name: 'text'
  compile: (document, model, controller) ->
    textNode = document.createTextNode(@get(model) or '')
    if @bound
      model.bind? "change:#{@value}", (value) =>
        textNode.nodeValue = value or ''
    textNode
  append: (element, args...) ->
    element.appendChild(@compile(args...))
  get: (model) -> Monkey.get(model, @value, @bound)

  insertAfter: (element, args...) ->
    newEl = @compile(args...)
    element.parentNode.insertBefore(newEl, element.nextSibling)
    -> [newEl]

class Monkey.Instruction
  type: 'instruction'
  constructor: (@command, @arguments, @children) ->

  append: (element, document, model, controller) ->
    anchor = document.createTextNode('')
    element.appendChild(anchor)
    @[@command](anchor, document, model, controller)

  insertAfter: (element, document, model, controller) ->
    anchor = document.createTextNode('')
    element.parentNode.insertBefore(anchor, element.nextSibling)
    @[@command](anchor, document, model, controller)

  collection: (anchor, document, model, controller) ->
    collection = @get(model)
    vc = new Monkey.ViewCollection(anchor, document, collection, controller, @children)
    -> [anchor, vc.roots...]

  view: (anchor, document, model, controller) ->
    newController = Monkey.controllerFor(@arguments[0])
    newController.parent = controller
    view = Monkey._views[@arguments[0]].compile(document, model, newController)
    anchor.parentNode.insertBefore(view, anchor.nextSibling)
    -> [anchor, view]

  get: (model) -> Monkey.get(model, @arguments[0])

class Monkey.ViewCollection
  constructor: (@anchor, @document, @collection, @controller, @children) ->
    @roots = []
    @build()
    if @collection.bind
      @collection.bind('update', => @rebuild())
      @collection.bind('set', => @rebuild())
      @collection.bind('add', (item) => @appendItem(item))

  rebuild: ->
    for root in @roots
      for element in root()
        element.parentNode.removeChild(element)
    @roots = []
    @build()

  build: ->
    Monkey.each @collection, (item) =>
      @appendItem(item)

  lastNode: ->
    nodes = @nodesFor(@roots.length - 1)
    nodes[nodes.length - 1] or @anchor

  nodesFor: (index) ->
    @roots[index]?() or []

  appendItem: (item) ->
    last = @lastNode()
    for node in @children
      nodes = node.insertAfter(last, @document, item, @controller)
      last = nodes()[nodes().length-1]
      @roots.push(nodes)

