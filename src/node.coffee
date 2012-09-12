{Serenade} = require './serenade'
{Events} = require './events'
{extend} = require './helpers'

class Node
  extend(@prototype, Events)

  constructor: (@ast, @element) ->

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

  remove: ->
    @element.parentNode?.removeChild(@element)

  lastElement: ->
    @element

exports.Node = Node
