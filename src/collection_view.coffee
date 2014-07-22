class CollectionView extends Element
  constructor: (@ast) ->
    @anchor = Serenade.document.createTextNode('')
    @renderedCollection = []
    @views = new Collection()

  update: =>
    for operation in Transform(@renderedCollection, @views)
      switch operation.type
        when "insert"
          @_insertView(operation.index, new TemplateView(@ast.children or [], operation.value, @controller))
        when "remove"
          @_deleteView(operation.index)
        when "swap"
          @_swapViews(operation.index, operation.with)
    @renderedCollection = @views.map((a) -> a)

  rebuild: ->
    last = @anchor
    for view in @views
      view.insertAfter(last)
      last = view.lastElement
    @renderedCollection = @views.map((a) -> a)

  replace: (views) ->
    @clear()
    @views.update(views)
    @rebuild()

  clear: ->
    view.remove() for view in @views
    @views.update([])

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
    @views.last?.lastElement or @anchor

  _deleteView: (index) ->
    @views[index].remove()
    @views.deleteAt(index)

  _insertView: (index, view) ->
    if @anchor.parentNode # don't do this if this collection view hasn't been inserted
      last = @views[index-1]?.lastElement or @anchor
      view.insertAfter(last)
    @views.insertAt(index, view)

  _swapViews: (fromIndex, toIndex) ->
    if @anchor.parentNode # don't do this if this collection view hasn't been inserted
      last = @views[fromIndex-1]?.lastElement or @anchor
      @views[toIndex].insertAfter(last)

      last = @views[toIndex-1]?.lastElement or @anchor
      @views[fromIndex].insertAfter(last)

    [@views[fromIndex], @views[toIndex]] = [@views[toIndex], @views[fromIndex]]

