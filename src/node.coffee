{Serenade} = require './serenade'
{defineEvent} = require './event'
{extend} = require './helpers'
{Collection} = require './collection'

class Node
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

  bindEvent: (event, fun) ->
    if event
      @boundEvents or= []
      @boundEvents.push({ event, fun })
      event.bind(fun)

  unbindEvents: ->
    # trigger unload callbacks
    @unload.trigger()
    # recursively unbind events on children
    node.unbindEvents() for node in @nodes()
    # remove events
    event.unbind(fun) for {event, fun} in @boundEvents if @boundEvents

exports.Node = Node
