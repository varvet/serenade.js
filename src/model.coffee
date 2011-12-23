{Monkey} = require './monkey'

class Monkey.Model
  Monkey.extend(@prototype, Monkey.Events)
  Monkey.extend(@prototype, Monkey.Properties)

  @property: -> @prototype.property(arguments...)
  @collection: -> @prototype.collection(arguments...)

  @_getFromCache: (id, object) ->
    @_identityMap ||= {}
    @_identityMap[id] if @_identityMap.hasOwnProperty(id)

  @_storeInCache: (id, object) ->
    @_identityMap ||= {}
    @_identityMap[id] = object

  constructor: (attributes) ->
    if attributes?.id
      fromCache = @constructor._getFromCache(attributes.id)
      if fromCache
        fromCache.set(attributes)
        return fromCache
      else
        @constructor._storeInCache(attributes.id, this)
    @set(attributes)
