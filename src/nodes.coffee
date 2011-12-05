{Monkey} = require './monkey'

EVENTS = ['click', 'blur', 'focus', 'change', 'mouseover', 'mouseout']

extract_from_model = (model, value, bound) ->
  if bound and model.get
    model.get(value)
  else if bound
    model[value]
  else
    value

class Monkey.Element
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
      childNode = child.compile(document, model, controller)
      if childNode.nodeName
        element.appendChild(childNode)
      else
        element.appendChild(node) for node in childNode
    element

class Monkey.Attribute
  constructor: (@name, @value, @bound) ->
  compile: (element, model, constructor) ->
    computed = @compute(model)
    unless computed is undefined
      element.setAttribute(@name, computed)
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
  compute: (model) -> extract_from_model(model, @value, @bound)

class Monkey.TextNode
  constructor: (@value, @bound) ->
  name: 'text'
  compile: (document, model, controller) ->
    textNode = document.createTextNode(@compute(model) or '')
    if @bound
      model.bind? "change:#{@value}", (value) =>
        textNode.nodeValue = value or ''
    textNode
  compute: (model) -> extract_from_model(model, @value, @bound)

class Monkey.Instruction
  constructor: (@command, @arguments, @children) ->
  compile: (document, model, controller) ->
    @[@command](document, model, controller)

  collection: (document, model, controller) ->
    elements = []
    for item in @compute(model)
      for child in @children
        elements.push child.compile(document, item, controller)
    elements

  compute: (model) -> extract_from_model(model, @arguments[0], true)

