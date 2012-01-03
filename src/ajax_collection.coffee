{Collection} = require('./collection')

# This class is used by Monkey.Model
class exports.AjaxCollection extends Collection
  constructor: (@constructor, @url, @list=[]) ->
    @expires = new Date(new Date().getTime() + @constructor._storeOptions?.expires)
    super(@list)
  refresh: ->

  isStale: ->
    @expires < new Date()
