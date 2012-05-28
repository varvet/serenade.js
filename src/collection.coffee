{Events} = require './events'
{extend, forEach, serializeObject, deleteItem, indexOf, get} = require './helpers'

isArrayIndex = (index) -> index.match(/^\d+$/)

getLength = (arr) ->
  indices = (parseInt(index, 10) for index, val of arr when isArrayIndex(index))
  if indices.length then Math.max(indices...) + 1 else 0

class exports.Collection
  extend(@prototype, Events)
  constructor: (list) ->
    @[index] = val for val, index in list
    @length = getLength(@)
    @bind "change", => @length = getLength(@)
  get: (index) -> @[index]
  set: (index, value) ->
    @_notIn(@[index])
    @[index] = value
    @_in(value)
    @trigger("change:#{index}", value)
    @trigger("set", index, value)
    @trigger("change", @)
    value
  push: (element) ->
    @[@length] = element
    @_in(element)
    @trigger("add", element)
    @trigger("change", @)
    element
  update: (list) ->
    @_notIn(element) for element in @
    delete @[index] for index, _ of @ when isArrayIndex(index)
    @[index] = val for val, index in list
    @_in(element) for element in list
    @trigger("update", list)
    @trigger("change", @)
    list
  sort: (fun) ->
    Array.prototype.sort.call(@, fun)
    @trigger("update", @)
    @
  sortBy: (attribute) ->
    @sort((a, b) -> if get(a, attribute) < get(b, attribute) then -1 else 1)
  forEach: (fun) ->
    forEach(@, fun)
  map: (fun) ->
    fun(item) for item in @
  indexOf: (search) ->
    if Array.prototype.indexOf
      Array.prototype.indexOf.call(@, search)
    else
      return index for item, index in @ when item is search
      return -1
  includes: (item) -> @indexOf(item) >= 0
  find: (fun) ->
    return item for item in @ when fun(item)
  deleteAt: (index) ->
    value = @[index]
    @_notIn(value)
    Array.prototype.splice.call(@, index, 1)
    @trigger("delete", index, value)
    @trigger("change", @)
    value
  delete: (item) ->
    @deleteAt(@indexOf(item))
  serialize: ->
    serializeObject(@toArray())
  select: (fun) ->
    item for item in @ when fun(item)

  toArray: ->
    array = []
    array[index] = val for index, val of @ when isArrayIndex(index)
    array

  _in: (item) ->
    if item?._useDefer
      item._inCollections or= []
      item._inCollections?.push(this)

  _notIn: (item) ->
    deleteItem(item._inCollections, this) if item?._inCollections

  _useDefer: true
