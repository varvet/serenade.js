{extend} = require './helpers'

globalDependencies = {}

addGlobalDependencies = (object, dependency, names) ->
  unless object["_glb_" + dependency]
    object["_glb_" + dependency] = true
    for name in names
      if name.match(/\./)
        type = "singular"
        [name, subname] = name.split(".")
      else if name.match(/:/)
        type = "collection"
        [name, subname] = name.split(":")

      if subname
        globalDependencies[subname] or= []
        globalDependencies[subname].push({ object, dependency, subname, name, type })

triggerGlobal = (object, names) ->
  for name in names
    if globalDependencies[name]
      for dependency in globalDependencies[name]
        if dependency.type is "singular"
          if object is dependency.object[dependency.name]
            dependency.object[dependency.dependency + "_property"]?.triggerChanges?()
        else if dependency.type is "collection"
          if object in dependency.object[dependency.name]
            dependency.object[dependency.dependency + "_property"]?.triggerChanges?()

class Property
  constructor: (@object, @name, @options) ->
    @valueName = "_s_#{@name}_val"
    if typeof(@options.serialize) is 'string'
      @serializeAlias = @options.serialize

    @dependsOn = if @options.dependsOn then [].concat(@options.dependsOn) else []

  set: (value) ->
    if @options.set
      @options.set.call(@object, value)
    else
      Object.defineProperty(@object, @valueName, value: value, configurable: true)
    @triggerChanges()

  get: ->
    if @dependsOn.length
      addGlobalDependencies(@object, @name, @dependsOn)
    if @options.get
      @options.get.call(@object)
    else if "default" of @options and not @name of @object
      @options.default
    else
      @object[@valueName]

  Object.defineProperty @prototype, "dependencies", get: ->
    return @_dependenciesCache if @_dependenciesCache
    @_dependenciesCache = []

    findDependencies = (name) =>
      @_dependenciesCache.push(name)
      for property in @object._s_properties
        if name in property.dependsOn and property.name not in @_dependenciesCache
          findDependencies(property.name)
    findDependencies(@name)

    @_dependenciesCache

  resetDependencyCache: ->
    @_dependenciesCache = undefined

  triggerChanges: ->
    changes = {}
    changes[name] = @object[name] for name in @dependencies
    @object.trigger("change", changes)
    triggerGlobal(@object, @dependencies)
    for own name, value of changes
      @object.trigger("change:#{name}", value)

defineProperty = (object, name, options={}) ->
  property = new Property(object, name, options)

  # defined on self
  if object.hasOwnProperty("_s_properties")
    object._s_properties.push(property)
  # defined on prototype
  else if object._s_properties
    Object.defineProperty object, "_s_properties", value: [property].concat(object._s_properties)
  # not defined yet
  else
    Object.defineProperty object, "_s_properties", value: [property]

  # adding properties busts the cache
  property.resetDependencyCache() for property in object._s_properties

  Object.defineProperty object, name,
    get: -> property.get()
    set: (value) -> property.set(value)
    configurable: true
    enumerable: true

  Object.defineProperty object, name + "_property",
    get: -> property
    configurable: true

  if property.serializeAlias
    defineProperty object, property.serializeAlias,
      get: -> @[name]
      set: (v) -> @[name] = v
      configurable: true

exports.defineProperty = defineProperty
exports.Property = Property
exports.globalDependencies = globalDependencies
