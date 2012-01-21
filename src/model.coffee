{Serenade} = require './serenade'
{Associations} = require './associations'
{extend} = require './helpers'

class Serenade.Model
  extend(@prototype, Serenade.Properties)
  extend(@prototype, Associations)

  @property: -> @prototype.property(arguments...)
  @collection: -> @prototype.collection(arguments...)
  @belongsTo: -> @prototype.belongsTo(arguments...)
  @hasMany: -> @prototype.hasMany(arguments...)

  @_getFromCache: (id) ->
    @_identityMap ||= {}
    @_identityMap[id] if @_identityMap.hasOwnProperty(id)

  @_storeInCache: (id, object) ->
    @_identityMap ||= {}
    @_identityMap[id] = object

  @find: (id) ->
    unless document = @_getFromCache(id)
      document = new this(id: id)
    document


  constructor: (attributes) ->
    if attributes?.id
      fromCache = @constructor._getFromCache(attributes.id)
      if fromCache
        fromCache.set(attributes)
        return fromCache
      else
        @constructor._storeInCache(attributes.id, this)
    @set(attributes)
