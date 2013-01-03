{Collection} = require './collection'
{Property, defineProperty} = require("./property")
{AssociationCollection} = require './association_collection'
{Events} = require './events'
{prefix, pairToObject, serializeObject, extend} = require './helpers'

Properties =
  property: (name, options={}) ->
    defineProperty(this, name, options)

  collection: (name, options={}) ->
    extend options,
      get: ->
        unless @attributes[name]
          @attributes[name] = new Collection([])
          @attributes[name].bind 'change', =>
            triggerChangesTo(this, [name])
        @attributes[name]
      set: (value) ->
        @get(name).update(value)
    @property name, options

extend(Properties, Events)

Associations =
  belongsTo: (name, attributes={}) ->
    extend attributes,
      set: (model) ->
        if model and model.constructor is Object and attributes.as
          model = new (attributes.as())(model)
        previous = @attributes[name]
        @attributes[name] = model
        if attributes.inverseOf and not model[attributes.inverseOf].includes(this)
          previous[attributes.inverseOf].delete(this) if previous
          model[attributes.inverseOf].push(this)
    @property name, attributes
    @property name + 'Id',
      get: -> @get(name)?.id
      set: (id) -> @set(name, attributes.as().find(id)) if id?
      dependsOn: name
      serialize: attributes.serializeId

  hasMany: (name, attributes={}) ->
    extend attributes,
      get: ->
        unless @attributes[name]
          @attributes[name] = new AssociationCollection(this, attributes, [])
          @attributes[name].bind 'change', => triggerChangesTo(this, [name])
        @attributes[name]
      set: (value) ->
        @get(name).update(value)
    @property name, attributes
    @property name + 'Ids',
      get: -> new Collection(@get(name)).map((item) -> item?.id)
      set: (ids) ->
        objects = (attributes.as().find(id) for id in ids)
        @get(name).update(objects)
      dependsOn: name
      serialize: attributes.serializeIds

exports.Properties = Properties
exports.Associations = Associations
