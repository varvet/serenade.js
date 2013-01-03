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
        valueName = "_s_#{name}_val"
        unless @[valueName]
          @[valueName] = new Collection([])
          @[valueName].bind 'change', =>
            @[name + "_property"].triggerChanges(this)
        @[valueName]
      set: (value) ->
        @[name].update(value)
    @property name, options

extend(Properties, Events)

Associations =
  belongsTo: (name, attributes={}) ->
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

  hasMany: (name, attributes={}) ->
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

exports.Properties = Properties
exports.Associations = Associations
