{Monkey} = require './monkey'

EVENTS = ['click', 'blur', 'focus', 'change', 'mouseover', 'mouseout']


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
    element.parentNode.insertBefore(@compile(args...), element.nextSibling)

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
    element.parentNode.insertBefore(@compile(args...), element.nextSibling)

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
    new Monkey.ViewCollection(anchor, document, collection, controller, @children)

  view: (anchor, document, model, controller) ->
    newController = Monkey.controllerFor(@arguments[0])
    newController.parent = controller
    view = Monkey._views[@arguments[0]].compile(document, model, newController)
    anchor.parentNode.insertBefore(view, anchor.nextSibling)

  get: (model) -> Monkey.get(model, @arguments[0])

class Monkey.ViewCollection
  constructor: (@anchor, @document, @collection, @controller, @children) ->
    @build()

  build: ->
    parent = @anchor.parentNode
    sibling = @anchor.nextSibling

    Monkey.each @collection, (item) =>
      child.insertAfter(@anchor, @document, item, @controller) for child in @children
