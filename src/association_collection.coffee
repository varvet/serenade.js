{Collection} = require './collection'

class AssociationCollection extends Collection
  constructor: (@ctor, @list) ->
    super(@list)
  set: (index, item) ->
    super(index, @_convert(item))

  push: (item) ->
    super(@_convert(item))

  update: (list) ->
    super(@_convert(item) for item in list)

  _convert: (item) ->
    ctor = @ctor()
    if item.constructor is ctor
      item
    else
      new ctor(item)

exports.AssociationCollection = AssociationCollection
