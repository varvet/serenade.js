{Serenade} = require './serenade'
{Events} = require './events'
{extend} = require './helpers'
{Collection} = require './collection'

class Node
  extend(@prototype, Events)

  constructor: (@ast, @element) ->
    @boundEvents = new Collection([])
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

  bindEvent: (to, name, fun) ->
    if to?.bind
      @boundEvents.push({ to, name, fun })
      to.bind(name, fun)

  unbindEvents: ->
    child.unbindEvents() for child in @children
    to.unbind(name, fun) for {to, name, fun} in @boundEvents

exports.Node = Node
