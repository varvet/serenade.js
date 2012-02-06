{Collection} = require './collection'

class AssociationCollection extends Collection
  constructor: (@ctor, @list) ->
    super(@_convert(item) for item in list)

  set: (index, item) ->
    super(index, @_convert(item))

  push: (item) ->
    super(@_convert(item))

  update: (list) ->
    super(@_convert(item) for item in list)

  _convert: (item) ->
    if item.constructor is Object and @ctor
      new (@ctor())(item)
    else
      item

exports.AssociationCollection = AssociationCollection
