{Events} = require './events'
{indexOf, extend, serializeObject, get} = require './helpers'

isArrayIndex = (index) -> "#{index}".match(/^\d+$/)

class exports.Collection
  extend(@prototype, Events)
  constructor: (list) ->
    @[index] = val for val, index in list
    @length = list?.length or 0
  get: (index) -> @[index]
  set: (index, value) ->
    @[index] = value
    @length = Math.max(@length, index + 1) if isArrayIndex(index)
    @trigger("change:#{index}", value)
    @trigger("set", index, value)
    @trigger("change", @)
    value
  push: (element) ->
    @[@length++] = element
    @trigger("add", element)
    @trigger("change", @)
    element
  pop: -> @deleteAt(@length-1)
  unshift: (item) -> @insertAt(0, item)
  shift: -> @deleteAt(0)
  update: (list) ->
    old = @clone()
    delete @[index] for index, _ of @ when isArrayIndex(index)
    @[index] = val for val, index in list
    @length = list?.length or 0
    @trigger("update", old, @)
    @trigger("change", @)
    list
  splice: (start, deleteCount, list...) ->
    old = @clone()
    deleted = Array.prototype.splice.apply(@, [start, deleteCount, list...])
    @trigger("update", old, @)
    @trigger("change", @)
    new Collection(deleted)
  sort: (fun) ->
    old = @clone()
    Array.prototype.sort.call(@, fun)
    @trigger("update", old, @)
    @trigger("change", @)
    @
  sortBy: (attribute) ->
    @sort((a, b) -> if get(a, attribute) < get(b, attribute) then -1 else 1)
  reverse: ->
    old = @clone()
    Array.prototype.reverse.call(@)
    @trigger("update", old, @)
    @trigger("change", @)
    @
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
  indexOf: (search) -> indexOf @, search
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
    Array.prototype.splice.call(@, index, 0, value)
    @trigger("insert", index, value)
    @trigger("change", @)
    value
  deleteAt: (index) ->
    value = @[index]
    Array.prototype.splice.call(@, index, 1)
    @trigger("delete", index, value)
    @trigger("change", @)
    value
  delete: (item) ->
    index = @indexOf(item)
    @deleteAt(index) if index isnt -1
  serialize: ->
    serializeObject(@toArray())
  filter: (fun) ->
    if typeof(Array.prototype.filter) is "function"
      new Collection(Array.prototype.filter.call(@, fun))
    else
      new Collection(item for item in @ when fun(item))

  join: (args...) -> Array.prototype.join.apply(@, args)
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
  reduce: (fun, initial) ->
    if typeof Array.prototype.reduce is "function"
      Array.prototype.reduce.apply(@, arguments)
    else
      carry = if initial then initial else @[0]
      for item, index in @ when initial or index isnt 0
        carry = fun(carry, item, index, @)
      carry
  reduceRight: (fun, initial) ->
    if typeof Array.prototype.reduceRight is "function"
      Array.prototype.reduceRight.apply(@, arguments)
    else
      traversed = @toArray().reverse()
      carry = if initial then initial else traversed[0]
      for item, index in traversed when initial or index isnt 0
        carry = fun(carry, item, traversed.length - index - 1, @)
      carry

  first: -> @[0]
  last: -> @[@length-1]

  toArray: ->
    array = []
    array[index] = val for index, val of @ when isArrayIndex(index)
    array

  toJSON: -> @serialize()

  clone: -> new Collection(@toArray())
