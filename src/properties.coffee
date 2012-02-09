{Serenade} = require './serenade'
{Collection} = require './collection'
{Events} = require './events'
{pairToObject, serializeObject, extend, map} = require './helpers'

prefix = "_prop_"
exp = /^_prop_/
define = Object.defineProperties # we check for the plural because it is unsupported in buggy IE8

Serenade.Properties =
  property: (name, options={}) ->
    @[prefix + name] = options
    @[prefix + name].name = name
    if define
      Object.defineProperty @, name,
        get: -> Serenade.Properties.get.call(this, name)
        set: (value) -> Serenade.Properties.set.call(this, name, value)
    if typeof(options.serialize) is 'string'
      @property options.serialize,
        get: -> @get(name)
        set: (v) -> @set(name, v)

  collection: (name, options) ->
    @property name,
      get: ->
        unless @attributes[name]
          @attributes[name] = new Collection([])
          @attributes[name].bind 'change', =>
            @_triggerChangesTo([name])
          @attributes[name]._deferTo = pairToObject(name, this)
        @attributes[name]
      set: (value) ->
        @get(name).update(value)

  set: (attributes, value) ->
    attributes = pairToObject(attributes, value) if typeof(attributes) is 'string'

    names = []
    for name, value of attributes
      @_undefer(name)
      names.push(name)
      @attributes or= {}
      if @[prefix + name]?.set
        @[prefix + name].set.call(this, value)
      else
        @attributes[name] = value
      @_defer(name)
    @_triggerChangesTo(names)

  get: (name) ->
    @attributes or= {}
    if @[prefix + name]?.get
      @[prefix + name].get.call(this)
    else
      @attributes[name]

  format: (name) ->
    format = @[prefix + name]?.format
    if typeof(format) is 'string'
      Serenade._formats[format].call(this, @get(name))
    else if typeof(format) is 'function'
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

  _defer: (name) ->
    deferred = @get(name)
    if deferred?._triggerChangesTo
      deferred._deferTo or= {}
      deferred._deferTo?[name] = this

  _undefer: (name) ->
    deferred = @get(name)
    delete deferred._deferTo[name] if deferred?._deferTo

  _triggerChangesTo: (changedProperties) ->
    normalizeDeps = (deps) -> [].concat(deps)
    checkDependenciesFor = (toCheck) =>
      for name, property of this when name.match(exp) and property.dependsOn
        if toCheck in normalizeDeps(property.dependsOn) and property.name not in changedProperties
          changedProperties.push(property.name)
          checkDependenciesFor(property.name)
    checkDependenciesFor(prop) for prop in changedProperties

    changes = {}
    for name in changedProperties
      value = @get(name)
      @trigger("change:#{name}", value)
      changes[name] = value
      unless define
        @[name] = @get(name)

    @trigger("change", changes)

    allDefers = (@_deferTo or [])
    if @_inCollections
      for collection in @_inCollections
        extend(allDefers, collection._deferTo)

    for deferName, deferObject of allDefers when allDefers.hasOwnProperty(deferName)
      keys = map(changedProperties, (prop) -> "#{deferName}.#{prop}")
      deferObject._triggerChangesTo(keys)

extend(Serenade.Properties, Events)
