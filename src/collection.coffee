{Events} = require './events'
{extend, serializeObject} = require './helpers'

isArrayIndex = (index) -> "#{index}".match(/^\d+$/)

class exports.Collection
  extend(@prototype, Events)

  constructor: (list) ->
    @[index] = val for val, index in list
    @length = list?.length or 0

  # Custom Collection methods

  get: (index) ->
    @[index]

  set: (index, value) ->
    @[index] = value
    @length = Math.max(@length, index + 1) if isArrayIndex(index)
    @trigger("change:#{index}", value)
    @trigger("set", index, value)
    @trigger("change", @)
    value

  update: (list) ->
    old = @clone()
    delete @[index] for index, _ of @ when isArrayIndex(index)
    @[index] = val for val, index in list
    @length = list?.length or 0
    @trigger("update", old, @)
    @trigger("change", @)
    list

  sortBy: (attribute) ->
    @sort((a, b) -> if a[attribute] < b[attribute] then -1 else 1)

  includes: (item) ->
    @indexOf(item) >= 0

  find: (fun) ->
    return item for item in @ when fun(item)

  insertAt: (index, value) ->
    Array::splice.call(@, index, 0, value)
    @trigger("insert", index, value)
    @trigger("change", @)
    value

  deleteAt: (index) ->
    value = @[index]
    Array::splice.call(@, index, 1)
    @trigger("delete", index, value)
    @trigger("change", @)
    value

  delete: (item) ->
    index = @indexOf(item)
    @deleteAt(index) if index isnt -1

  serialize: ->
    serializeObject(@toArray())

  first: ->
    @[0]

  last: ->
    @[@length-1]

  toArray: ->
    array = []
    array[index] = val for index, val of @ when isArrayIndex(index)
    array

  clone: ->
    new Collection(@toArray())

  # Standard Array methods

  push: (element) ->
    @[@length++] = element
    @trigger("add", element)
    @trigger("change", @)
    element

  pop: ->
    @deleteAt(@length-1)

  unshift: (item) ->
    @insertAt(0, item)

  shift: ->
    @deleteAt(0)

  splice: (start, deleteCount, list...) ->
    old = @clone()
    deleted = Array::splice.apply(@, [start, deleteCount, list...])
    @trigger("update", old, @)
    @trigger("change", @)
    new Collection(deleted)

  sort: (fun) ->
    old = @clone()
    Array::sort.call(@, fun)
    @trigger("update", old, @)
    @trigger("change", @)
    @

  reverse: ->
    old = @clone()
    Array::reverse.call(@)
    @trigger("update", old, @)
    @trigger("change", @)
    @

  for fun in ["forEach", "indexOf", "lastIndexOf", "join", "every", "some", "reduce", "reduceRight"]
    this::[fun] = Array::[fun]

  map: (args...) ->
    new Collection(Array::map.apply(@, args))

  filter: (args...) ->
    new Collection(Array::filter.apply(@, args))

  slice: (args...) ->
    new Collection(@toArray().slice(args...))

  concat: (args...) ->
    args = for arg in args
      if arg instanceof Collection then arg.toArray() else arg
    new Collection(@toArray().concat(args...))

  toString: ->
    @toArray().toString()

  toLocaleString: ->
    @toArray().toLocaleString()

  toJSON: ->
    @serialize()
