globalDependencies = {}

triggerGlobal = (target, names) ->
  for name in names
    if globalDependencies.hasOwnProperty(name)
      for { name, type, object, subname, dependency } in globalDependencies[name]
        if type is "singular"
          if target is object[name]
            object[dependency + "_property"]?.trigger?(object)
        else if type is "collection"
          if target in object[name]
            object[dependency + "_property"]?.trigger?(object)

class PropertyDefinition
  constructor: (@name, options) ->
    extend(this, options)

    @dependencies = []
    @localDependencies = []
    @globalDependencies = []

    if @dependsOn
      @addDependency(name) for name in [].concat(@dependsOn)

  def @prototype, "eventOptions", get: ->
    name = @name
    async: if @async? then @async else settings.async
    bind: -> @[name] # make sure dependencies have been discovered and registered
    optimize: (queue) -> queue[queue.length - 1]

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

class PropertyAccessor
  constructor: (@definition, @object) ->
    @name = @definition.name
    @valueName = "val_#{@name}"
    @event = new Event(@object, @name + "_change", @definition.eventOptions)

  set: (value) ->
    if typeof(value) is "function"
      @definition.get = value
    else
      if @definition.set
        @definition.set.call(@object, value)
      else
        def @object._s, @valueName, value: value, configurable: true
      @trigger()

  get: ->
    @registerGlobal()
    if @definition.get and not (@definition.cache and @valueName of @object._s)
      # add a listener which adds any dependencies that haven't been specified
      listener = (name) => @definition.addDependency(name)
      @object._s.property_access.bind(listener) unless "dependsOn" of @definition
      value = @definition.get.call(@object)
      @object._s[@valueName] = value if @definition.cache
      @object._s.property_access.unbind(listener) unless "dependsOn" of @definition
    else
      value = @object._s[@valueName]

    @object._s.property_access.trigger(@name)
    value

  format: ->
    if typeof(@definition.format) is "function"
      @definition.format.call(@object, @get())
    else
      @get()

  registerGlobal: ->
    unless @object._s["glb_" + @name]
      @object._s["glb_" + @name] = true
      for { name, type, subname } in @definition.globalDependencies
        globalDependencies[subname] or= []
        globalDependencies[subname].push({ @object, subname, name, type, dependency: @name })

  trigger: ->
    names = [@name].concat(@dependents)
    changes = {}
    changes[name] = @object[name] for name in names
    @object.changed?.trigger?(changes)
    for own name, value of changes
      @object[name + "_property"].clearCache()
      @object[name + "_property"].event.trigger(value)
    triggerGlobal(@object, names)

  bind: (fun) ->
    @event.bind(fun)

  unbind: (fun) ->
    @event.unbind(fun)

  one: (fun) ->
    @event.one(fun)

  # Find all properties which are dependent upon this one
  def @prototype, "dependents", get: ->
    deps = []
    findDependencies = (name) =>
      for property in @object._s.properties
        if property.name not in deps and name in property.localDependencies
          deps.push(property.name)
          findDependencies(property.name)
    findDependencies(@name)
    deps

  def @prototype, "listeners", get: ->
    @event.listeners

  clearCache: ->
    if @definition.cache and @definition.get
      delete @object._s[@valueName]

defineProperty = (object, name, options={}) ->
  definition = new PropertyDefinition(name, options)

  defineOptions(object, "_s") unless "_s" of object

  safePush object._s, "properties", definition
  defineEvent object._s, "property_access"

  def object, name,
    get: -> @[name + "_property"].get()
    set: (value) -> @[name + "_property"].set(value)
    configurable: true
    enumerable: if "enumerable" of options then options.enumerable else true

  def object, name + "_property",
    get: -> new PropertyAccessor(definition, this)
    configurable: true

  if typeof(options.serialize) is 'string'
    defineProperty object, options.serialize,
      get: -> @[name]
      set: (v) -> @[name] = v
      configurable: true

  object[name] = options.value if "value" of options
