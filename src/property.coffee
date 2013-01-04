{safePush} = require './helpers'
{defineEvent} = require './event'

globalDependencies = {}

triggerGlobal = (target, names) ->
  for name in names
    if globalDependencies[name]
      for { name, type, object, subname, dependency } in globalDependencies[name]
        if type is "singular"
          if target is object[name]
            object[dependency + "_property"]?.triggerChanges?(object)
        else if type is "collection"
          if target in object[name]
            object[dependency + "_property"]?.triggerChanges?(object)

class Property
  constructor: (@name, @options) ->
    @valueName = "_s_#{@name}_val"

    @dependencies = []
    @localDependencies = []
    @globalDependencies = []

    if @options.dependsOn
      @addDependency(name) for name in [].concat(@options.dependsOn)

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
    @registerGlobal(object)
    if @options.get
      # add a listener which adds any dependencies that haven't been specified
      listener = (name) =>
        if @addDependency(name)
          # bust the cache
          Object.defineProperty object, "_s_dependencyCache", value: {}, configurable: true

      object._s_property_access.bind(listener) unless "dependsOn" of @options
      value = @options.get.call(object)
      object._s_property_access.unbind(listener) unless "dependsOn" of @options
    else if "default" of @options and @valueName not of object
      value = @options.default
    else
      value = object[@valueName]

    object._s_property_access.trigger(@name)
    value

  addDependency: (name) ->
    if @dependencies.indexOf(name) is -1
      @dependencies.push(name)

      if name.match(/\./)
        type = "singular"
        [name, subname] = name.split(".")
      else if name.match(/:/)
        type = "collection"
        [name, subname] = name.split(":")

      @localDependencies.push(name)
      @localDependencies.push(name) if @localDependencies.indexOf(name) is -1
      @globalDependencies.push({ subname, name, type }) if type
      true
    else
      false

  # Find all properties which are dependent upon this one
  dependents: (object) ->
    return object._s_dependencyCache[@name] if object._s_dependencyCache[@name]
    deps = []
    findDependencies = (name) ->
      for property in object._s_properties
        if property.name not in deps and name in property.localDependencies
          deps.push(property.name)
          findDependencies(property.name)
    findDependencies(@name)

    object._s_dependencyCache[@name] = deps

  triggerChanges: (object) ->
    changes = {}
    changes[name] = object[name] for name in [@name].concat(@dependents(object))
    object.change.trigger(changes)
    triggerGlobal(object, [@name].concat(@dependents(object)))
    for own name, value of changes
      object["change_" + name].trigger(value)

  registerGlobal: (object) ->
    unless object["_glb_" + @name]
      object["_glb_" + @name] = true
      for { name, type, subname } in @globalDependencies
        globalDependencies[subname] or= []
        globalDependencies[subname].push({ object, subname, name, type, dependency: @name })

defineProperty = (object, name, options={}) ->
  hasOriginal = name of object
  originalValue = object[name]
  property = new Property(name, options)

  safePush(object, "_s_properties", property)

  defineEvent object, "change"
  defineEvent object, "_s_property_access"
  defineEvent object, "change_" + name,
    bind: -> @[name] # make sure dependencies have been discovered and registered

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

  if typeof(options.serialize) is 'string'
    defineProperty object, options.serialize,
      get: -> @[name]
      set: (v) -> @[name] = v
      configurable: true

  object[name] = originalValue if hasOriginal

exports.defineProperty = defineProperty
exports.Property = Property
exports.globalDependencies = globalDependencies
