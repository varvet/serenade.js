{Serenade} = require './serenade'
{Collection} = require './collection'
{AssociationCollection} = require './association_collection'
{Events} = require './events'
{pairToObject, serializeObject, extend, get} = require './helpers'

prefix = "_prop_"
exp = /^_prop_/
define = Object.defineProperties # we check for the plural because it is unsupported in buggy IE8

contains = (array, search) ->
  return false unless array
  if typeof(array.indexOf) is "function"
    array.indexOf(search) isnt -1
  else
    return true for element in array when element is search
    return false

addGlobalDependencies = (object, dependency, names) ->
  for name in names
    if name.match(/\./)
      [name, subname] = name.split(".")
      Serenade.bind "change", (changed, changes) ->
        if changes.hasOwnProperty(subname) and changed is object.get(name)
          triggerChangesTo(object, [dependency])
    else if name.match(/:/)
      [name, subname] = name.split(":")
      Serenade.bind "change", (changed, changes) ->
        if changes.hasOwnProperty(subname) and contains(object.get(name), changed)
          triggerChangesTo(object, [dependency])

addDependencies = (object, dependency, names) ->
  names = [].concat(names)
  for name in names
    [name, subname] = name.split(/[:\.]/) if name.match(/[:\.]/)
    object["_dep_" + name] ||= []
    object["_dep_" + name].push(dependency) if object["_dep_" + name].indexOf(dependency) is -1

triggerChangesTo = (object, names) ->
  findDependencies = (name) ->
    dependencies = object["_dep_" + name]
    if dependencies
      for dependency in dependencies
        if names.indexOf(dependency) is -1
          names.push(dependency)
          findDependencies(dependency)
  findDependencies(name) for name in names

  changes = {}
  changes[name] = object.get(name) for name in names
  object.trigger("change", changes)
  Serenade.trigger("change", object, changes)
  for own name, value of changes
    object.trigger("change:#{name}", value)

Serenade.Properties =
  property: (name, options={}) ->
    @[prefix + name] = options
    @[prefix + name].name = name
    addDependencies(this, name, options.dependsOn) if options.dependsOn
    if define
      Object.defineProperty @, name,
        get: ->
          addGlobalDependencies(this, name, [].concat(options.dependsOn)) if options.dependsOn
          Serenade.Properties.get.call(this, name)
        set: (value) -> Serenade.Properties.set.call(this, name, value)
    if typeof(options.serialize) is 'string'
      @property options.serialize,
        get: -> @get(name)
        set: (v) -> @set(name, v)

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

  set: (attributes, value) ->
    attributes = pairToObject(attributes, value) if typeof(attributes) is 'string'

    names = []
    for name, value of attributes
      names.push(name)
      @attributes or= {}
      if @[prefix + name]?.set
        @[prefix + name].set.call(this, value)
      else
        @attributes[name] = value
    triggerChangesTo(this, names)

  get: (name) ->
    @attributes or= {}
    if @[prefix + name]?.get
      @[prefix + name].get.call(this)
    else
      @attributes[name]

  format: (name) ->
    format = @[prefix + name]?.format
    if typeof(format) is 'function'
      format.call(this, @get(name))
    else
      @get(name)

  serialize: ->
    serialized = {}
    for name, options of this when name.match(exp)
      if typeof(options.serialize) is 'string'
        serialized[options.serialize] = serializeObject(@get(options.name))
      else if typeof(options.serialize) is 'function'
        [key, value] = options.serialize.call(@)
        serialized[key] = serializeObject(value)
      else if options.serialize
        serialized[options.name] = serializeObject(@get(options.name))
    serialized

extend(Serenade.Properties, Events)

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
          @attributes[name].bind 'change', => triggerChangesTo(this, [name])
        @attributes[name]
      set: (value) ->
        @get(name).update(value)
    @property name, attributes
    @property name + 'Ids',
      get: -> new Collection(@get(name)).map((item) -> get(item, 'id'))
      set: (ids) ->
        objects = (attributes.as().find(id) for id in ids)
        @get(name).update(objects)
      dependsOn: name
      serialize: attributes.serializeIds

exports.Associations = Associations
