class CollectionView extends View
  constructor: (@ast, @model, @controller) ->
    @anchor = Serenade.document.createTextNode('')
    @items = []
    @children = new Collection()

  replace: (items) ->
    for operation in Transform(@items, items)
      switch operation.type
        when "insert"
          @_insertView(operation.index, new TemplateView(@ast.children or [], operation.value, @controller))
        when "remove"
          @_deleteView(operation.index)
        when "swap"
          @_swapViews(operation.index, operation.with)
    @items = items?.map((a) -> a) or []

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
    super
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

  _deleteView: (index) ->
    @children[index].remove()
    @children.deleteAt(index)

  _insertView: (index, view) ->
    if @anchor.parentNode # don't do this if this collection view hasn't been inserted
      last = @children[index-1]?.lastElement or @anchor
      view.insertAfter(last)
    @children.insertAt(index, view)

  _swapViews: (fromIndex, toIndex) ->
    if @anchor.parentNode # don't do this if this collection view hasn't been inserted
      last = @children[fromIndex-1]?.lastElement or @anchor
      @children[toIndex].insertAfter(last)

      last = @children[toIndex-1]?.lastElement or @anchor
      @children[fromIndex].insertAfter(last)

    [@children[fromIndex], @children[toIndex]] = [@children[toIndex], @children[fromIndex]]

