class PropertyDefinition
  constructor: (@name, options) ->
    extend(this, options)

    @dependencies = []
    @localDependencies = []
    @globalDependencies = []

    if @dependsOn
      for name in [].concat(@dependsOn)
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

  def @prototype, "eventOptions", get: ->
    name = @name
    options =
      timeout: @timeout
      buffer: @buffer
      animate: @animate
      bind: ->
        @[name + "_property"].registerGlobal()
      optimize: (queue) -> [queue[0]?[0], queue[queue.length - 1]?[1]]
    options.async = @async if @async?
    options

class PropertyAccessor
  constructor: (@definition, @object) ->
    @name = @definition.name
    @valueName = "_" + @name
    @event = new Event(@object, @name + "_change", @definition.eventOptions)
    @_gcQueue = []

  set: (value) ->
    if typeof(value) is "function"
      @definition.get = value
    else
      if @definition.set
        @definition.set.call(@object, value)
      else
        def @object, @valueName, value: value, configurable: true
      @trigger()

  get: ->
    if @definition.get and not (@definition.cache and @valueName of @object)
      value = @definition.get.call(@object)
      if @definition.cache
        @object[@valueName] = value
        # make sure global listeners are attached and stay attached
        unless @_isCached
          @_isCached = true
          @bind(->)
    else
      value = @object[@valueName]

    @object._s.property_access.trigger(@name)
    value

  format: ->
    if typeof(@definition.format) is "function"
      @definition.format.call(@object, @get())
    else
      @get()

  registerGlobal: ->
    return if @_isRegistered
    @_isRegistered = true
    @definition.globalDependencies.forEach (dep) =>
      { name, type, subname } = dep
      switch type
        when "singular"
          updateItemBinding = (before, after) =>
            before?[subname + "_property"]?.unbind(@trigger)
            after?[subname + "_property"]?.bind(@trigger)
          @object[name + "_property"]?.bind(updateItemBinding)
          updateItemBinding(undefined, @object[name])
          @_gcQueue.push =>
            updateItemBinding(@object[name], undefined)
            @object[name + "_property"]?.unbind(updateItemBinding)
        when "collection"
          updateItemBindings = (before, after) =>
            before?.forEach? (item) =>
              item[subname + "_property"]?.unbind(@trigger)
            after?.forEach? (item) =>
              item[subname + "_property"]?.bind(@trigger)

          updateCollectionBindings = (before, after) =>
            updateItemBindings(before, after)
            before?.change?.unbind(@trigger)
            after?.change?.bind(@trigger)
            before?.change?.unbind(updateItemBindings)
            after?.change?.bind(updateItemBindings)

          @object[name + "_property"]?.bind(updateCollectionBindings)
          updateCollectionBindings(undefined, @object[name])
          @_gcQueue.push =>
            updateCollectionBindings(@object[name], undefined)
            @object[name + "_property"]?.unbind(updateCollectionBindings)

    for dependency in @definition.localDependencies
      @object[dependency + "_property"]?.registerGlobal()

  gc: ->
    if @listeners.length is 0 and not @dependentProperties.find((prop) => prop.listeners.length isnt 0)
      fn() for fn in @_gcQueue
      @_isRegistered = false

    for dependency in @definition.localDependencies
      @object[dependency + "_property"]?.gc()

  trigger: =>
    @clearCache()
    if @hasChanged()
      newValue = @get()

      @event.trigger(@_oldValue, newValue)

      changes = {}
      changes[@name] = newValue
      @object.changed?.trigger?(changes)

      @object[name + "_property"].trigger() for name in @dependents

      @_oldValue = newValue

  ["bind", "one", "resolve"].forEach (fn) =>
    this::[fn] = -> @event[fn](arguments...)

  unbind: (fn) ->
    @event.unbind(fn)
    @gc()

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
      delete @object[@valueName]

  hasChanged: ->
    if @definition.changed in [true, false]
      @definition.changed
    else
      if "_oldValue" of this
        if @definition.changed
          @definition.changed.call(@object, @_oldValue, @get())
        else
          if typeof(@_oldValue) in primitiveTypes
            @_oldValue isnt @get()
          else
            true
      else
        true

  def @prototype, "dependentProperties", get: ->
    new Serenade.Collection(@object[name + "_property"] for name in @dependents)

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

  accessorName = name + "_property"
  def object, accessorName,
    get: ->
      unless @_s.hasOwnProperty(accessorName)
        @_s[accessorName] = new PropertyAccessor(definition, this)
      @_s[accessorName]
    configurable: true

  if typeof(options.serialize) is 'string'
    defineProperty object, options.serialize,
      get: -> @[name]
      set: (v) -> @[name] = v
      configurable: true

  object[name] = options.value if "value" of options
