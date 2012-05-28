{Events} = require './events'
{extend, forEach, serializeObject, deleteItem, indexOf, get} = require './helpers'

class exports.Collection
  extend(@prototype, Events)
  constructor: (@list) ->
    @length = @list.length
    @[index] = val for val, index in @list
    @bind "change", =>
      indices = (parseInt(index, 10) for index, val of @ when index.match(/^\d+$/))
      @length = Math.max(indices...) + 1
  get: (index) -> @list[index]
  set: (index, value) ->
    @_notIn(@list[index])
    @list[index] = value
    @[index] = value
    @_in(value)
    @trigger("change:#{index}", value)
    @trigger("set", index, value)
    @trigger("change", @list)
    value
  push: (element) ->
    @list.push(element)
    @[@length] = element
    @_in(element)
    @trigger("add", element)
    @trigger("change", @list)
    element
  update: (list) ->
    @_notIn(element) for element in @list
    @list = list
    delete @[index] for index, _ of @ when index.match(/^\d+$/)
    @[index] = val for val, index in @list
    @_in(element) for element in list
    @trigger("update", list)
    @trigger("change", @list)
    list
  sort: (fun) ->
    @list.sort(fun)
    @trigger("update", @list)
  sortBy: (attribute) ->
    @sort((a, b) -> if get(a, attribute) < get(b, attribute) then -1 else 1)
  forEach: (fun) ->
    forEach(@list, fun)
  map: (fun) ->
    fun(item) for item in @list
  indexOf: (search) -> indexOf(@list, search)
  includes: (item) -> @indexOf(item) >= 0
  find: (fun) ->
    return item for item in @list when fun(item)
  deleteAt: (index) ->
    value = @list[index]
    @_notIn(value)
    @list.splice(index, 1)
    Array.prototype.splice.call(@, index, 1)
    @trigger("delete", index, value)
    @trigger("change", @list)
    value
  delete: (item) ->
    @deleteAt(@indexOf(item))
  serialize: ->
    serializeObject(@list)
  select: (fun) ->
    item for item in @list when fun(item)

  _in: (item) ->
    if item?._useDefer
      item._inCollections or= []
      item._inCollections?.push(this)

  _notIn: (item) ->
    deleteItem(item._inCollections, this) if item?._inCollections

  _useDefer: true
