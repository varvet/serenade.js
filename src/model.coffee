idCounter = 1

class Model
  @identityMap: true

  @find: (id) -> Cache.get(this, id) or new this(id: id)

  @extend: (ctor) ->
    class New extends this
      constructor: ->
        val = super
        return val if val
        ctor.apply(this, arguments) if ctor

  @property: (names..., options) ->
    if typeof(options) is "string"
      names.push(options)
      options = {}
    defineProperty(@prototype, name, options) for name in names

  @event: (name, options) ->
    defineEvent(@prototype, name, options)

  @uniqueId: ->
    unless @_uniqueId and @_uniqueGen is this
      @_uniqueId = (idCounter += 1)
      @_uniqueGen = this
    @_uniqueId

  @property 'id',
    serialize: true,
    set: (val) ->
      Cache.unset(@constructor, @id)
      Cache.set(@constructor, val, this)
      @_s.val_id = val
    get: -> @_s.val_id

  @event "saved"
  @event "changed",
    optimize: (queue) ->
      result = {}
      extend(result, item[0]) for item in queue
      [result]

  constructor: (attributes) ->
    if @constructor.identityMap and attributes?.id
      fromCache = Cache.get(@constructor, attributes.id)
      if fromCache
        Model::set.call(fromCache, attributes)
        return fromCache
      else
        Cache.set(@constructor, attributes.id, this)
    for own name, value of attributes
      property = @[name + "_property"]
      if property
        property.initialize(value)
      else
        @[name] = value

  def @prototype, "set", configurable: true, writable: true, value: (attributes) ->
    @[name] = value for own name, value of attributes

  def @prototype, "save", configurable: true, writable: true, value: ->
    @saved.trigger()

  def @prototype, "toJSON", configurable: true, writable: true, value: ->
    serialized = {}
    for property in @_s.properties
      if typeof(property.serialize) is 'string'
        serialized[property.serialize] = serializeObject(@[property.name])
      else if typeof(property.serialize) is 'function'
        [key, value] = property.serialize.call(@)
        serialized[key] = serializeObject(value)
      else if property.serialize
        serialized[property.name] = serializeObject(@[property.name])
    serialized

  def @prototype, "toString", configurable: true, writable: true, value: ->
    JSON.stringify(@toJSON())
