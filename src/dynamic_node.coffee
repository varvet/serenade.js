class DynamicNode extends Node
  constructor: (@ast) ->
    @anchor = Serenade.document.createTextNode('')
    @nodeSets = new Collection([])
    @boundEvents = new Collection([])

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
        last = node.lastElement

  replace: (sets) ->
    @clear()
    @nodeSets.update(new Collection(set) for set in sets)
    @rebuild()

  deleteNodeSet: (index) ->
    node.remove() for node in @nodeSets[index]
    @nodeSets.deleteAt(index)

  insertNodeSet: (index, nodes) ->
    last = @nodeSets[index-1]?.last?.lastElement or @anchor
    for node in nodes
      node.insertAfter(last) if @anchor.parentNode
      last = node.lastElement
    @nodeSets.insertAt(index, new Collection(nodes))

  swapNodeSet: (fromIndex, toIndex) ->
    last = @nodeSets[fromIndex-1]?.last?.lastElement or @anchor
    for node in @nodeSets[toIndex]
      node.insertAfter(last) if @anchor.parentNode
      last = node.lastElement

    last = @nodeSets[toIndex-1]?.last?.lastElement or @anchor
    for node in @nodeSets[fromIndex]
      node.insertAfter(last) if @anchor.parentNode
      last = node.lastElement

    [@nodeSets[fromIndex], @nodeSets[toIndex]] = [@nodeSets[toIndex], @nodeSets[fromIndex]]

  clear: ->
    node.remove() for node in @nodes()
    @nodeSets.update([])

  remove: ->
    @detach()
    @clear()
    @anchor.parentNode.removeChild(@anchor) if @anchor.parentNode

  append: (inside) ->
    inside.appendChild(@anchor)
    @rebuild()

  insertAfter: (after) ->
    after.parentNode.insertBefore(@anchor, after.nextSibling)
    @rebuild()

  def @prototype, "lastElement", configurable: true, get: ->
    @nodeSets.last?.last?.lastElement or @anchor
