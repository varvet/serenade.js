class Node extends View
  constructor: (@ast, @node) ->
    super

  append: (inside) ->
    inside.appendChild(@node)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@node, after.nextSibling)

  remove: ->
    super
    @node.parentNode?.removeChild(@node)


  def @prototype, "lastElement", configurable: true, get: ->
    @node
