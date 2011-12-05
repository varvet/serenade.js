{Monkey} = require './monkey'

EVENTS = ['click', 'blur', 'focus', 'change', 'mouseover', 'mouseout']

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
      element.appendChild(childNode)
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
  compute: (model) ->
    if @bound and model.get
      model.get(@value)
    else if @bound
      model[@value]
    else
      @value

class Monkey.TextNode
  constructor: (@value, @bound) ->
  name: 'text'
  compile: (document, model, constructor) ->
    textNode = document.createTextNode(@compute(model) or '')
    if @bound
      model.bind? "change:#{@value}", (value) =>
        textNode.nodeValue = value or ''
    textNode
  compute: (model) ->
    if @bound and model.get
      model.get(@value)
    else if @bound
      model[@value]
    else
      @value
