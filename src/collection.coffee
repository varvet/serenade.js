isArrayIndex = (index) -> "#{index}".match(/^\d+$/)

class Collection
  defineEvent @prototype, "change_set"
  defineEvent @prototype, "change_add"
  defineEvent @prototype, "change_update"
  defineEvent @prototype, "change_insert"
  defineEvent @prototype, "change_delete"
  defineEvent @prototype, "change"

  constructor: (list=[]) ->
    @[index] = val for val, index in list
    @length = list?.length or 0

  # Custom Collection methods

  get: (index) ->
    @[index]

  set: (index, value) ->
    @[index] = value
    @length = Math.max(@length, index + 1) if isArrayIndex(index)
    @change_set.trigger(index, value)
    @change.trigger(@)
    value

  update: (list) ->
    old = @clone()
    delete @[index] for index, _ of @ when isArrayIndex(index)
    @[index] = val for val, index in list
    @length = list?.length or 0
    @change_update.trigger(old, @)
    @change.trigger(@)
    list

  sortBy: (attribute) ->
    @sort((a, b) -> if a[attribute] < b[attribute] then -1 else 1)

  includes: (item) ->
    @indexOf(item) >= 0

  find: (fun) ->
    return item for item in @ when fun(item)

  insertAt: (index, value) ->
    Array::splice.call(@, index, 0, value)
    @change_insert.trigger(index, value)
    @change.trigger(@)
    value

  deleteAt: (index) ->
    value = @[index]
    Array::splice.call(@, index, 1)
    @change_delete.trigger(index, value)
    @change.trigger(@)
    value

  delete: (item) ->
    index = @indexOf(item)
    @deleteAt(index) if index isnt -1

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
    @change_add.trigger(element)
    @change.trigger(@)
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
    @change_update.trigger(old, @)
    @change.trigger(@)
    new Collection(deleted)

  sort: (fun) ->
    old = @clone()
    Array::sort.call(@, fun)
    @change_update.trigger(old, @)
    @change.trigger(@)
    @

  reverse: ->
    old = @clone()
    Array::reverse.call(@)
    @change_update.trigger(old, @)
    @change.trigger(@)
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
    serializeObject(@toArray())
