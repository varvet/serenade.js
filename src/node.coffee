{Serenade} = require './serenade'
{defineEvent} = require './event2'
{NodeEvents} = require './events'
{extend} = require './helpers'
{Collection} = require './collection'

class Node
  extend(@prototype, NodeEvents)
  defineEvent(@prototype, "load")
  defineEvent(@prototype, "unload")

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
