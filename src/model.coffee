{Cache} = require './cache'
{Associations, Properties} = require './properties'
{extend, capitalize, serializeObject} = require './helpers'

idCounter = 1

class Model
  extend(@prototype, Properties)
  extend(@prototype, Associations)

  @property: -> @prototype.property(arguments...)
  @collection: -> @prototype.collection(arguments...)
  @belongsTo: -> @prototype.belongsTo(arguments...)
  @hasMany: -> @prototype.hasMany(arguments...)

  @find: (id) -> Cache.get(this, id) or new this(id: id)

  @property 'id',
    serialize: true,
    set: (val) ->
      Cache.unset(@constructor, @id)
      Cache.set(@constructor, val, this)
      Object.defineProperty @, "_s_id_val", value: val, configurable: true
    get: -> @_s_id_val

  @extend: (ctor) ->
    class New extends this
      constructor: ->
        val = super
        return val if val
        ctor.apply(this, arguments) if ctor

  @delegate = (names..., options) ->
    to = options.to
    names.forEach (name) =>
      propName = name
      propName = to + capitalize(name) if options.prefix
      propName = propName + capitalize(to) if options.suffix
      @property propName, dependsOn: "#{to}.#{name}", get: -> @[to]?[name]

  @uniqueId: ->
    unless @_uniqueId and @_uniqueGen is this
      @_uniqueId = (idCounter += 1)
      @_uniqueGen = this
    @_uniqueId

  constructor: (attributes, bypassCache=false) ->
    unless bypassCache
      if attributes?.id
        fromCache = Cache.get(@constructor, attributes.id)
        if fromCache
          fromCache.set(attributes)
          return fromCache
        else
          Cache.set(@constructor, attributes.id, this)
    if @constructor.localStorage
      @bind('saved', => Cache.store(@constructor, @id, this))
      if @constructor.localStorage isnt 'save'
        @bind('change', => Cache.store(@constructor, @id, this))
    @set(attributes)

  set: (attributes) ->
    for own name, value of attributes
      @property(name) unless name of this
      @[name] = value

  save: ->
    @trigger('saved')

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

exports.Model = Model
