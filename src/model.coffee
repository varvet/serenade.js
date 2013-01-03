{Cache} = require './cache'
{Associations, Properties} = require './properties'
{extend, capitalize} = require './helpers'

idCounter = 1

class Model
  extend(@prototype, Properties)
  extend(@prototype, Associations)

  @property: -> @prototype.property(arguments...)
  @collection: -> @prototype.collection(arguments...)
  @belongsTo: -> @prototype.belongsTo(arguments...)
  @hasMany: -> @prototype.hasMany(arguments...)

  @find: (id) -> Cache.get(this, id) or new this(id: id)

  @property 'id', serialize: true, set: (val) ->
    Cache.unset(@constructor, @attributes.id)
    Cache.set(@constructor, val, this)
    @attributes.id = val

  @extend: (ctor) ->
    class New extends this
      constructor: ->
        val = super
        return val if val
        ctor.apply(this, arguments) if ctor

  @delegate = (names..., options) ->
    to = options.to
    for name in names
      do (name) =>
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
          extend(fromCache, attributes)
          return fromCache
        else
          Cache.set(@constructor, attributes.id, this)
    if @constructor.localStorage
      @bind('saved', => Cache.store(@constructor, @get('id'), this))
      if @constructor.localStorage isnt 'save'
        @bind('change', => Cache.store(@constructor, @get('id'), this))
    extend(this, attributes)

  save: ->
    @trigger('saved')

exports.Model = Model
