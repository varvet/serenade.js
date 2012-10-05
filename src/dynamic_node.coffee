{Serenade} = require './serenade'
{Collection} = require './collection'
{extend} = require './helpers'
{NodeEvents} = require './events'

class DynamicNode
  extend(@prototype, NodeEvents)

  constructor: (@ast) ->
    @anchor = Serenade.document.createTextNode('')
    @nodeSets = new Collection([])

  nodes: ->
    nodes = []
    for set in @nodeSets
      nodes.push(node) for node in set
    nodes

  rebuild: ->
    if @anchor.parentNode
      last = @anchor
      for node in @nodes()
        node.insertAfter(last)
        last = node.lastElement()

  replace: (sets) ->
    @clear()
    @nodeSets.update(new Collection(set) for set in sets)
    @rebuild()

  appendNodeSet: (nodes) ->
    @insertNodeSet(@nodeSets.length, nodes)

  deleteNodeSet: (index) ->
    node.remove() for node in @nodeSets[index]
    @nodeSets.deleteAt(index)

  insertNodeSet: (index, nodes) ->
    last = @nodeSets[index-1]?.last()?.lastElement() or @anchor
    for node in nodes
      node.insertAfter(last)
      last = node.lastElement()
    @nodeSets.insertAt(index, new Collection(nodes))

  clear: ->
    node.remove() for node in @nodes()
    @nodeSets.update([])

  remove: ->
    @unbindEvents()
    @clear()
    @anchor.parentNode.removeChild(@anchor)

  append: (inside) ->
    inside.appendChild(@anchor)
    @rebuild()

  insertAfter: (after) ->
    after.parentNode.insertBefore(@anchor, after.nextSibling)
    @rebuild()

  lastElement: ->
    @nodeSets.last()?.last()?.lastElement() or @anchor

exports.DynamicNode = DynamicNode
