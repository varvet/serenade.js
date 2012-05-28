{Events} = require './events'
{extend, serializeObject, get} = require './helpers'

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
  pop: -> @deleteAt(@length-1)
  unshift: (item) -> @insertAt(0, item)
  shift: -> @deleteAt(0)
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
    if typeof(Array.prototype.forEach) is 'function'
      Array.prototype.forEach.call(@, fun)
    else
      @map(fun)
      undefined
  map: (fun) ->
    if typeof(Array.prototype.map) is 'function'
      new Collection(Array.prototype.map.call(@, fun))
    else
      new Collection(fun(element, index) for element, index in @)
  indexOf: (search) ->
    if typeof(Array.prototype.indexOf) is "function"
      Array.prototype.indexOf.call(@, search)
    else
      return index for item, index in @ when item is search
      return -1
  lastIndexOf: (search) ->
    if typeof(Array.prototype.lastIndexOf) is "function"
      Array.prototype.lastIndexOf.call(@, search)
    else
      last = (index for item, index in @ when item is search).pop()
      if last? then last else -1
  includes: (item) -> @indexOf(item) >= 0
  find: (fun) ->
    return item for item in @ when fun(item)
  insertAt: (index, value) ->
    @_in(value)
    Array.prototype.splice.call(@, index, 0, value)
    @trigger("insert", index, value)
    @trigger("change", @)
    value
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
  filter: (fun) ->
    if typeof(Array.prototype.filter) is "function"
      new Collection(Array.prototype.filter.call(@, fun))
    else
      new Collection(item for item in @ when fun(item))

  join: (args...) -> Array.prototype.join.apply(@, args)
  reverse: -> new Collection(Array.prototype.reverse.apply(@))
  toString: -> @toArray().toString()
  toLocaleString: -> @toArray().toLocaleString()
  concat: (args...) -> new Collection(@toArray().concat(args...))
  slice: (args...) -> new Collection(@toArray().slice(args...))
  every: (fun) ->
    if typeof Array.prototype.every is "function"
      Array.prototype.every.call(@, fun)
    else
      for item in @
        return false unless fun(item)
      return true
  some: (fun) ->
    if typeof Array.prototype.some is "function"
      Array.prototype.some.call(@, fun)
    else
      for item in @
        return true if fun(item)
      return false
  reduce: (fun) ->
    if typeof Array.prototype.reduce is "function"
      Array.prototype.reduce.call(@, fun)
    else
      carry = @[0]
      for item, index in @ when index isnt 0
        carry = fun(carry, item, index, @)
      carry

  toArray: ->
    array = []
    array[index] = val for index, val of @ when isArrayIndex(index)
    array

  _in: (item) ->
    if item?._useDefer
      item._inCollections or= {}
      item._inCollections[this] = this

  _notIn: (item) ->
    delete item._inCollections[this] if item?._inCollections

  _useDefer: true
