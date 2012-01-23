{AssociationCollection} = require './association_collection'
{Collection} = require './collection'
{extend, map, get} = require './helpers'

class Associations
  @belongsTo: (name, attributes={}) ->
    ctor = attributes.as or (-> Object)
    extend(attributes, set: (properties) ->
      @attributes[name] = new (ctor())(properties))
    @property name, attributes
    @property name + 'Id',
      get: -> get(@get(name), 'id')
      set: (id) -> @attributes[name] = ctor().find(id)
      dependsOn: name

  @hasMany: (name, attributes={}) ->
    ctor = attributes.as or (-> Object)
    extend attributes,
      get: ->
        unless @attributes[name]
          @attributes[name] = new AssociationCollection(ctor, [])
          @attributes[name].bind 'change', =>
            @_triggerChangesTo([name])
        @attributes[name]
      set: (value) ->
        @get(name).update(value)
    @property name, attributes
    @property name + 'Ids',
      get: -> new Collection(@get(name).map((item) -> get(item, 'id')))
      set: (ids) ->
        objects = map(ids, (id) -> ctor().find(id))
        @attributes[name] = new AssociationCollection(ctor, objects)
      dependsOn: name

exports.Associations = Associations
