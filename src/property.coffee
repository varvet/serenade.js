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
            dependency.object[dependency.dependency + "_property"]?.triggerChanges?(dependency.object)
        else if dependency.type is "collection"
          if object in dependency.object[dependency.name]
            dependency.object[dependency.dependency + "_property"]?.triggerChanges?(dependency.object)

class Property
  constructor: (@name, @options) ->
    @valueName = "_s_#{@name}_val"
    if typeof(@options.serialize) is 'string'
      @serializeAlias = @options.serialize

    @dependsOn = if @options.dependsOn then [].concat(@options.dependsOn) else []
    @serialize = @options.serialize
    @format = @options.format

  set: (object, value) ->
    if typeof(value) is "function"
      @options.get = value
    else
      if @options.set
        @options.set.call(object, value)
      else
        Object.defineProperty(object, @valueName, value: value, configurable: true)
      @triggerChanges(object)

  get: (object) ->
    if @dependsOn.length
      addGlobalDependencies(object, @name, @dependsOn)
    if @options.get
      @options.get.call(object)
    else if "default" of @options and @valueName not of object
      @options.default
    else
      object[@valueName]

  dependencies: (object) ->
    return object._s_dependencyCache[@name] if object._s_dependencyCache[@name]
    deps = []
    findDependencies = (name) ->
      deps.push(name)
      for property in object._s_properties
        if property.name not in deps and name in property.dependsOn
          findDependencies(property.name)
    findDependencies(@name)

    object._s_dependencyCache[@name] = deps

  triggerChanges: (object) ->
    changes = {}
    changes[name] = object[name] for name in @dependencies(object)
    object.trigger?("change", changes)
    triggerGlobal(object, @dependencies(object))
    for own name, value of changes
      object.trigger?("change:#{name}", value)

defineProperty = (object, name, options={}) ->
  hasOriginal = name of object
  originalValue = object[name]
  property = new Property(name, options)

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
  Object.defineProperty object, "_s_dependencyCache", value: {}, configurable: true

  Object.defineProperty object, name,
    get: -> property.get(this)
    set: (value) -> property.set(this, value)
    configurable: true
    enumerable: if "enumerable" of options then options.enumerable else true

  Object.defineProperty object, name + "_property",
    get: -> property
    configurable: true

  if property.serializeAlias
    defineProperty object, property.serializeAlias,
      get: -> @[name]
      set: (v) -> @[name] = v
      configurable: true

  object[name] = originalValue if hasOriginal

exports.defineProperty = defineProperty
exports.Property = Property
exports.globalDependencies = globalDependencies
