class CollectionView extends DynamicView
  constructor: (@ast, @model, @controller) ->
    super

    items = @model[ast.argument] or []
    @lastItems = items.map((i) -> i)
    @children = for item in items
        new TemplateView(@ast.children or [], item, @controller)
    @children = new Collection(@children)

    @cb = (_, after) => @replace(after)
    @bindEvent(model["#{ast.argument}_property"], @update)
    @bindEvent(items.change, @cb)

  update: (before, after) =>
    @unbindEvent(before?.change, @cb)
    @bindEvent(after?.change, @cb)
    @replace(after)

  replace: (items) ->
    for operation in Transform(@lastItems, items)
      switch operation.type
        when "insert"
          @_insertChild(operation.index, new TemplateView(@ast.children or [], operation.value, @controller))
        when "remove"
          @_deleteChild(operation.index)
        when "swap"
          @_swapChildren(operation.index, operation.with)
    @lastItems = items?.map((a) -> a) or []

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

