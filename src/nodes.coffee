{Monkey} = require './monkey'

class Monkey.Element
  constructor: (@name, @attributes, @children) ->
    @attributes or= []
    @children or= []

class Monkey.Attribute
  constructor: (@name, @value, @bound) ->

class Monkey.TextNode
  constructor: (@value, @bound) ->
  name: 'text'
