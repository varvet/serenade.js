class Collection
  defineEvent @prototype, "change"

  def @prototype, "first", get: ->
    @[0]

  def @prototype, "last", get: ->
    @[@length-1]

  constructor: (list) ->
    if list
      @[index] = val for val, index in list
      @length = list.length
    else
      @length = 0

  get: (index) ->
    @[index]

  set: (index, value) ->
    Array::splice.call(this, index, 1, value)
    value

  update: (list) ->
    Array::splice.apply(this, [0, @length].concat(Array::slice.call(list)))
    this

  sortBy: (attribute) ->
    @sort((a, b) -> if a[attribute] < b[attribute] then -1 else 1)

  includes: (item) ->
    @indexOf(item) >= 0

  find: (fun) ->
    return item for item in @ when fun(item)

  insertAt: (index, value) ->
    Array::splice.call(@, index, 0, value)
    value

  deleteAt: (index) ->
    value = @[index]
    Array::splice.call(@, index, 1)
    value

  delete: (item) ->
    index = @indexOf(item)
    @deleteAt(index) if index isnt -1

  concat: (args...) ->
    args = for arg in args
      if arg instanceof Collection then arg.toArray() else arg
    new Collection(@toArray().concat(args...))

  toArray: ->
    Array::slice.call(this)

  clone: ->
    new Collection(@toArray())

  toString: ->
    @toArray().toString()

  toLocaleString: ->
    @toArray().toLocaleString()

  toJSON: ->
    serializeObject(@toArray())

  Object.getOwnPropertyNames(Array.prototype).forEach (fun) =>
    this::[fun] or= Array::[fun]

  ["splice", "map", "filter", "slice"].forEach (fun) =>
    original = this::[fun]
    this::[fun] = ->
      new Collection(original.apply(@, arguments))

  ["push", "pop", "unshift", "shift", "splice", "sort", "reverse", "update", "set", "insertAt", "deleteAt"].forEach (fun) =>
    original = this::[fun]
    this::[fun] = ->
      old = @clone()
      val = original.apply(@, arguments)
      @change.trigger(old, @)
      val
