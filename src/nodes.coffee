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
      if attribute.name in EVENTS
        attribute.event(element, model, controller)
      else
        attribute.compile(element, model, controller)

    for child in @children
      if child.type is 'instruction'
        child.execute(element, document, model, controller)
      else
        childNode = child.compile(document, model, controller)
        element.appendChild(childNode)
    element

class Monkey.Attribute
  type: 'attribute'
  constructor: (@name, @value, @bound) ->
  compile: (element, model, constructor) ->
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

  event: (element, model, controller) ->
    callback = (e) => controller[@value](e)
    element.addEventListener(@name, callback, false)
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
  get: (model) -> Monkey.get(model, @value, @bound)

class Monkey.Instruction
  type: 'instruction'
  constructor: (@command, @arguments, @children) ->

  execute: (element, document, model, controller) ->
    @[@command](element, document, model, controller)

  collection: (element, document, model, controller) ->
    collection = @get(model)
    anchor = document.createTextNode('')
    element.appendChild(anchor)
    new Monkey.ViewCollection(anchor, document, collection, controller, @children)

  get: (model) -> Monkey.get(model, @arguments[0])

class Monkey.ViewCollection
  constructor: (@anchor, @document, @collection, @controller, @children) ->
    @build()

  build: ->
    parent = @anchor.parentNode
    sibling = @anchor.nextSibling

    Monkey.each @collection, (item) =>
      for child in @children
        newElement = child.compile(@document, item, @controller)
        parent.insertBefore(newElement, sibling)
