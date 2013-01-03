{Cache} = require './cache'
{Collection} = require './collection'
{Events} = require './events'
{AssociationCollection} = require './association_collection'
{extend, capitalize, serializeObject} = require './helpers'
{defineProperty} = require './property'

idCounter = 1

class Model
  extend(@prototype, Events)

  @belongsTo: -> @prototype.belongsTo(arguments...)
  @hasMany: -> @prototype.hasMany(arguments...)

  @find: (id) -> Cache.get(this, id) or new this(id: id)

  @extend: (ctor) ->
    class New extends this
      constructor: ->
        val = super
        return val if val
        ctor.apply(this, arguments) if ctor

  @property: (name, options) ->
    defineProperty(@prototype, name, options)

  @delegate: (names..., options) ->
    to = options.to
    names.forEach (name) =>
      propName = name
      propName = to + capitalize(name) if options.prefix
      propName = propName + capitalize(to) if options.suffix
      @property propName, dependsOn: "#{to}.#{name}", get: -> @[to]?[name]

  @collection: (name, options={}) ->
    extend options,
      get: ->
        valueName = "_s_#{name}_val"
        unless @[valueName]
          @[valueName] = new Collection([])
          @[valueName].bind 'change', =>
            @[name + "_property"].triggerChanges(this)
        @[valueName]
      set: (value) ->
        @[name].update(value)
    @property name, options

  @belongsTo: (name, attributes={}) ->
    extend attributes,
      set: (model) ->
        valueName = "_s_#{name}_val"
        if model and model.constructor is Object and attributes.as
          model = new (attributes.as())(model)
        previous = @[valueName]
        @[valueName] = model
        if attributes.inverseOf and not model[attributes.inverseOf].includes(this)
          previous[attributes.inverseOf].delete(this) if previous
          model[attributes.inverseOf].push(this)
    @property name, attributes
    @property name + 'Id',
      get: -> @[name]?.id
      set: (id) -> @[name] = attributes.as().find(id) if id?
      dependsOn: name
      serialize: attributes.serializeId

  @hasMany: (name, attributes={}) ->
    extend attributes,
      get: ->
        valueName = "_s_#{name}_val"
        unless @[valueName]
          @[valueName] = new AssociationCollection(this, attributes, [])
          @[valueName].bind 'change', =>
            @[name + "_property"].triggerChanges(this)
        @[valueName]
      set: (value) ->
        @[name].update(value)
    @property name, attributes
    @property name + 'Ids',
      get: -> new Collection(@[name]).map((item) -> item?.id)
      set: (ids) ->
        objects = (attributes.as().find(id) for id in ids)
        @[name].update(objects)
      dependsOn: name
      serialize: attributes.serializeIds

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
      Object.defineProperty @, "_s_id_val", value: val, configurable: true
    get: -> @_s_id_val

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
      defineProperty(this, name) unless name of this
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
