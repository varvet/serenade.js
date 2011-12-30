{Collection} = require('./collection')

# This class is used by Monkey.Model
class exports.AjaxCollection extends Collection
  constructor: (@constructor, @url) ->
    super([])
