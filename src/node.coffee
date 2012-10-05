{Serenade} = require './serenade'
{Events, NodeEvents} = require './events'
{extend} = require './helpers'
{Collection} = require './collection'

class Node
  extend(@prototype, Events)
  extend(@prototype, NodeEvents)

  constructor: (@ast, @element) ->
    @children = new Collection([])

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

  remove: ->
    @unbindEvents()
    @element.parentNode?.removeChild(@element)

  lastElement: ->
    @element

  nodes: ->
    @children

exports.Node = Node
