{Collection} = require './collection'

class AssociationCollection extends Collection
  constructor: (@owner, @options, list) ->
    super(@_convert(item) for item in list)

  set: (index, item) ->
    super(index, @_convert(item))

  push: (item) ->
    super(@_convert(item))

  update: (list) ->
    super(@_convert(item) for item in list)

  splice: (start, deleteCount, list...) ->
    list = (@_convert(item) for item in list)
    super(start, deleteCount, list...)

  insertAt: (index, item) ->
    super(index, @_convert(item))

  _convert: (item) ->
    if item.constructor is Object and @options.as
      item = new (@options.as())(item)
    if @options.inverseOf and item[@options.inverseOf] isnt @owner
      item[@options.inverseOf] = @owner
    item

exports.AssociationCollection = AssociationCollection
