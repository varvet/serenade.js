{AssociationCollection} = require './association_collection'
{Collection} = require './collection'
{extend, map, get, pairToObject} = require './helpers'

Associations =
  belongsTo: (name, attributes={}) ->
    extend attributes,
      set: (model) ->
        if model.constructor is Object and attributes.as
          model = new (attributes.as())(model)
        @attributes[name] = model
    @property name, attributes
    @property name + 'Id',
      get: -> get(@get(name), 'id')
      set: (id) -> @attributes[name] = attributes.as().find(id)
      dependsOn: name
      serialize: attributes.serializeId

  hasMany: (name, attributes={}) ->
    extend attributes,
      get: ->
        unless @attributes[name]
          @attributes[name] = new AssociationCollection(attributes.as, [])
          @attributes[name].bind 'change', =>
            @_triggerChangesTo([name])
          @_defer(name)
        @attributes[name]
      set: (value) ->
        @get(name).update(value)
    @property name, attributes
    @property name + 'Ids',
      get: -> new Collection(@get(name).map((item) -> get(item, 'id')))
      set: (ids) ->
        objects = map(ids, (id) -> attributes.as().find(id))
        @attributes[name] = new AssociationCollection(attributes.as, objects)
        @_defer(name)
      dependsOn: name
      serialize: attributes.serializeIds

exports.Associations = Associations
