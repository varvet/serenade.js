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

  @delegate: (names..., options) ->
    to = options.to
    names.forEach (name) =>
      propName = name
      if options.prefix is true
        propName = to + capitalize(name)
      else if options.prefix
        propName = options.prefix + capitalize(name)
      if options.suffix is true
        propName = propName + capitalize(to)
      else if options.suffix
        propName = propName + options.suffix
      propOptions = merge options,
        dependsOn: options.dependsOn or "#{to}.#{name}"
        get: -> @[to]?[name]
        set: (value) -> @[to]?[name] = value
      @property propName, propOptions

  @collection: (name, options={}) ->
    propOptions = merge options,
      get: ->
        valueName = "_s_#{name}_val"
        unless @[valueName]
          @[valueName] = new Collection([])
          @[valueName].change.bind =>
            @[name + "_property"].trigger()
        @[valueName]
      set: (value) ->
        @[name].update(value)
    @property name, propOptions
    @property name + 'Count',
      get: -> @[name].length
      dependsOn: name

  @belongsTo: (name, options={}) ->
    propOptions = merge options,
      set: (model) ->
        valueName = "_s_#{name}_val"
        if model and model.constructor is Object and options.as
          model = new (options.as())(model)
        previous = @[valueName]
        @[valueName] = model
        if options.inverseOf and not model[options.inverseOf].includes(this)
          previous[options.inverseOf].delete(this) if previous
          model[options.inverseOf].push(this)
    @property name, propOptions
    @property name + 'Id',
      get: -> @[name]?.id
      set: (id) -> @[name] = options.as().find(id) if id?
      dependsOn: name
      serialize: options.serializeId

  @hasMany: (name, options={}) ->
    propOptions = merge options,
      get: ->
        valueName = "_s_#{name}_val"
        unless @[valueName]
          @[valueName] = new AssociationCollection(this, options, [])
          @[valueName].change.bind =>
            @[name + "_property"].trigger()
        @[valueName]
      set: (value) ->
        @[name].update(value)
    @property name, propOptions
    @property name + 'Ids',
      get: -> new Collection(@[name]).map((item) -> item?.id)
      set: (ids) ->
        objects = (options.as().find(id) for id in ids)
        @[name].update(objects)
      dependsOn: name
      serialize: options.serializeIds
    @property name + 'Count',
      get: -> @[name].length
      dependsOn: name

  @selection: (name, options={}) ->
    @property name,
      get: -> @[options.from].filter((item) -> item[options.filter])
      dependsOn: "#{options.from}:#{options.filter}"
    @property name + 'Count',
      get: -> @[name].length
      dependsOn: name

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
      def @, "_s_id_val", value: val, configurable: true
    get: -> @_s_id_val

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
        fromCache.set(attributes)
        return fromCache
      else
        Cache.set(@constructor, attributes.id, this)
    @set(attributes)

  set: (attributes) ->
    for own name, value of attributes
      defineProperty(this, name) unless name of this
      @[name] = value

  save: ->
    @saved.trigger()

  toJSON: ->
    serialized = {}
    for property in @_s_properties
      if typeof(property.serialize) is 'string'
        serialized[property.serialize] = serializeObject(@[property.name])
      else if typeof(property.serialize) is 'function'
        [key, value] = property.serialize.call(@)
        serialized[key] = serializeObject(value)
      else if property.serialize
        serialized[property.name] = serializeObject(@[property.name])
    serialized

  toString: ->
    JSON.stringify(@toJSON())
