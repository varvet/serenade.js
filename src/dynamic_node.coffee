{Serenade} = require './serenade'
{Collection} = require './collection'

class DynamicNode
  constructor: (@ast) ->
    @anchor = Serenade.document.createTextNode('')
    @nodeSets = new Collection([])
    @boundEvents = new Collection([])

  eachNode: (fun) ->
    for set in @nodeSets
      fun(node) for node in set

  rebuild: ->
    if @anchor.parentNode
      last = @anchor
      @eachNode (node) ->
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
    @eachNode (node) -> node.remove()
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

  bindEvent: (to, name, fun) ->
    if to?.bind
      @boundEvents.push({ to, name, fun })
      to.bind(name, fun)

  unbindEvents: ->
    @eachNode (node) -> node.unbindEvents()
    to.unbind(name, fun) for {to, name, fun} in @boundEvents

exports.DynamicNode = DynamicNode
