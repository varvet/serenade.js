{Cache} = require './cache'
{Associations, Properties} = require './properties'
{extend} = require './helpers'

class Model
  extend(@prototype, Properties)
  extend(@prototype, Associations)

  @property: -> @prototype.property(arguments...)
  @collection: -> @prototype.collection(arguments...)
  @belongsTo: -> @prototype.belongsTo(arguments...)
  @hasMany: -> @prototype.hasMany(arguments...)

  @find: (id) -> Cache.get(this, id) or new this(id: id)

  @property 'id', serialize: true

  @extend: (name, ctor) ->
    class New extends this
      @modelName: name
      constructor: ->
        super
        ctor.apply(this, arguments) if ctor

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
      @bind('saved', => Cache.store(@constructor, @get('id'), this))
      if @constructor.localStorage isnt 'save'
        @bind('change', => Cache.store(@constructor, @get('id'), this))
    @set(attributes)

  save: ->
    @trigger('saved')

exports.Model = Model
