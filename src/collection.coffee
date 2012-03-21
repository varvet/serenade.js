{Events} = require './events'
{extend, forEach, serializeObject, deleteItem, indexOf} = require './helpers'

class exports.Collection
  extend(@prototype, Events)
  constructor: (@list) ->
    @length = @list.length
    @bind("change", => @length = @list.length)
  get: (index) -> @list[index]
  set: (index, value) ->
    @_notIn(@list[index])
    @list[index] = value
    @_in(value)
    @trigger("change:#{index}", value)
    @trigger("set", index, value)
    @trigger("change", @list)
  push: (element) ->
    @list.push(element)
    @_in(element)
    @trigger("add", element)
    @trigger("change", @list)
  update: (list) ->
    @_notIn(element) for element in @list
    @list = list
    @_in(element) for element in list
    @trigger("update", list)
    @trigger("change", @list)
  sort: (fun) ->
    @list.sort(fun)
    @trigger("update", @list)
  sortBy: (attribute) ->
    @sort((a, b) -> if a[attribute] < b[attribute] then -1 else 1)
  forEach: (fun) ->
    forEach(@list, fun)
  map: (fun) ->
    fun(item) for item in @list
  indexOf: (search) -> indexOf(@list, search)
  find: (fun) ->
    return item for item in @list when fun(item)
  deleteAt: (index) ->
    @_notIn(@list[index])
    @list.splice(index, 1)
    @trigger("delete", index)
    @trigger("change", @list)
  delete: (item) ->
    @deleteAt(@indexOf(item))
  serialize: ->
    serializeObject(@list)
  select: (fun) ->
    item for item in @list when fun(item)
  detect: (fun) ->
    return item for item in @list when fun(item)

  _in: (item) ->
    if item?._triggerChangesTo
      item._inCollections or= []
      item._inCollections?.push(this)

  _notIn: (item) ->
    deleteItem(item._inCollections, this) if item?._inCollections
