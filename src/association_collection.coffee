{Collection} = require './collection'

class AssociationCollection extends Collection
  constructor: (@owner, @options, list) ->
    @_convert list..., (items...) =>
      super(items)

  set: (index, item) ->
    @_convert item, (item) =>
      super(index, item)

  push: (item) ->
    @_convert item, (item) =>
      super(item)

  update: (list) ->
    @_convert list..., (items...) =>
      super(items)

  splice: (start, deleteCount, list...) ->
    @_convert list..., (items...) =>
      super(start, deleteCount, items...)

  insertAt: (index, item) ->
    @_convert item, (item) =>
      super(index, item)

  _convert: (items..., fn) ->
    items = for item in items
      if item?.constructor is Object and @options.as
        item = new (@options.as())(item)
      else
        item
    returnValue = fn(items...)
    for item in items
      if @options.inverseOf and item[@options.inverseOf] isnt @owner
        item[@options.inverseOf] = @owner
    returnValue

exports.AssociationCollection = AssociationCollection
