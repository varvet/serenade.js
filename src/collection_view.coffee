class CollectionView extends DynamicView
  constructor: (@ast, @model, @controller) ->
    super
    @items = []

  update: (items) ->
    for operation in Transform(@items, items)
      switch operation.type
        when "insert"
          @_insertChild(operation.index, new TemplateView(@ast.children or [], operation.value, @controller))
        when "remove"
          @_deleteChild(operation.index)
        when "swap"
          @_swapChildren(operation.index, operation.with)
    @items = items?.map((a) -> a) or []

  _deleteChild: (index) ->
    @children[index].remove()
    @children.deleteAt(index)

  _insertChild: (index, view) ->
    if @anchor.parentNode # don't do this if this collection view hasn't been inserted
      last = @children[index-1]?.lastElement or @anchor
      view.insertAfter(last)
    @children.insertAt(index, view)

  _swapChildren: (fromIndex, toIndex) ->
    if @anchor.parentNode # don't do this if this collection view hasn't been inserted
      last = @children[fromIndex-1]?.lastElement or @anchor
      @children[toIndex].insertAfter(last)

      last = @children[toIndex-1]?.lastElement or @anchor
      @children[fromIndex].insertAfter(last)

    [@children[fromIndex], @children[toIndex]] = [@children[toIndex], @children[fromIndex]]

