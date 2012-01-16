{Serenade} = require './serenade'
{Events} = require './events'
{AssociationCollection} = require './association_collection'
{Collection} = require './collection'
{extend, map, get, pairToObject} = require './helpers'

class Serenade.Model
  extend(@prototype, Events)
  extend(@prototype, Serenade.Properties)

  @property: -> @prototype.property(arguments...)
  @collection: -> @prototype.collection(arguments...)

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

  @belongsTo: (name, ctor=-> Object) ->
    @property name,
      set: (properties) -> @attributes[name] = new (ctor())(properties)
    @property name + 'Id',
      get: -> get(@get(name), 'id')
      set: (id) -> @attributes[name] = ctor().find(id)
      dependsOn: name

  @hasMany: (name, ctor=-> Object) ->
    @property name,
      get: ->
        unless @attributes[name]
          @attributes[name] = new AssociationCollection(ctor, [])
          @attributes[name].bind 'change', =>
            @_triggerChangesTo(pairToObject(name, @get(name)))
        @attributes[name]
      set: (value) ->
        @get(name).update(value)

    @property name + 'Ids',
      get: -> new Collection(@get(name).map((item) -> get(item, 'id')))
      set: (ids) ->
        objects = map(ids, (id) -> ctor().find(id))
        @attributes[name] = new AssociationCollection(ctor, objects)
      dependsOn: name

  constructor: (attributes) ->
    if attributes?.id
      fromCache = @constructor._getFromCache(attributes.id)
      if fromCache
        fromCache.set(attributes)
        return fromCache
      else
        @constructor._storeInCache(attributes.id, this)
    @set(attributes)
