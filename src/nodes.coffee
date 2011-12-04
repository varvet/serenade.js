{Monkey} = require './monkey'

class Monkey.Element
  constructor: (@name, @attributes, @children) ->
    @attributes or= []
    @children or= []
  compile: (document, model, controller) ->
    element = document.createElement(@name)

    for attribute in @attributes
      attributeNode = attribute.compile(element, model, controller)

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
  compute: (model) ->
    if @bound
      model[@value]
    else
      @value

class Monkey.TextNode
  constructor: (@value, @bound) ->
  name: 'text'
  compile: (document, model, constructor) ->
    textNode = document.createTextNode(@compute(model))
  compute: (model) ->
    if @bound
      model[@value]
    else
      @value
