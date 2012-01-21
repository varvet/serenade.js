{Serenade} = require './serenade'
{Cache} = require './cache'
{Associations} = require './associations'
{extend} = require './helpers'

class Serenade.Model
  extend(@prototype, Serenade.Properties)
  extend(@prototype, Associations)

  @property: -> @prototype.property(arguments...)
  @collection: -> @prototype.collection(arguments...)
  @belongsTo: -> @prototype.belongsTo(arguments...)
  @hasMany: -> @prototype.hasMany(arguments...)

  @find: (id) -> Cache.get(this, id) or new this(id: id)

  constructor: (attributes) ->
    if attributes?.id
      fromCache = Cache.get(@constructor, attributes.id)
      if fromCache
        fromCache.set(attributes)
        return fromCache
      else
        Cache.set(@constructor, attributes.id, this)
    if @constructor.localStorage is 'save'
      @bind('saved', -> Cache.store(@constructor, attributes.id, this))
    else if @constructor.localStorage
      @bind('change', -> Cache.store(@constructor, attributes.id, this))
    @set(attributes)

  save: ->
    @trigger('saved')
