class DynamicView extends View
  constructor: (@ast, @context) ->
    @anchor = Serenade.document.createTextNode('')
    @items = []
    @children = new Collection()

  replace: (children) ->
    @clear()
    @children = new Collection(children)
    @rebuild()

  rebuild: ->
    if @anchor.parentNode
      last = @anchor
      for view in @children
        view.insertAfter(last)
        last = view.lastElement

  clear: ->
    view.remove() for view in @children
    @children.update([])

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
    @children.last?.lastElement or @anchor
