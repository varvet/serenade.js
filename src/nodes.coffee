{Monkey} = require './monkey'

class Monkey.Element
  constructor: (@name, @attributes, @children) ->
    @attributes or= []
    @children or= []
  compile: (document, model, controller) ->
    element = document.createElement(@name)

    for attribute in @attributes
      attributeNode = attribute.compile(document, model, controller)
      element.setAttributeNode(attributeNode)

    for child in @children
      childNode = child.compile(document, model, controller)
      element.appendChild(childNode)

    element

class Monkey.Attribute
  constructor: (@name, @value, @bound) ->
  compile: (document, model, constructor) ->
    attribute = document.createAttribute(@name)
    attribute.nodeValue = @value
    attribute

class Monkey.TextNode
  constructor: (@value, @bound) ->
  name: 'text'
  compile: (document, model, constructor) ->
    textNode = document.createTextNode(@value)
