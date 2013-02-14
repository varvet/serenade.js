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
    optimize: (queue) -> [queue[0]?[0], queue[queue.length - 1]?[1]]

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
    return if @_isRegistered
    @_isRegistered = true
    for { name, type, subname } in @definition.globalDependencies
      switch type
        when "singular"
          if @object[name]
            @object[name][subname + "_property"]?.rebind(@trigger)
          @object[name + "_property"]?.bind (before, after) =>
            before?[subname + "_property"]?.unbind(@trigger)
            after?[subname + "_property"]?.rebind(@trigger)
        when "collection"
          if @object[name] and @object[name].length?
            updateItemBindings = (before, after) =>
              before?.forEach? (item) =>
                item[subname + "_property"]?.unbind(@trigger)
              after?.forEach? (item) =>
                item[subname + "_property"]?.rebind(@trigger)

            updateCollectionBindings = (before, after) =>
              updateItemBindings(before, after)
              before?.change?.unbind(@trigger)
              after?.change?.rebind(@trigger)
              before?.change?.unbind(updateItemBindings)
              after?.change?.rebind(updateItemBindings)

            @object[name + "_property"]?.rebind(updateCollectionBindings)
            updateCollectionBindings(undefined, @object[name])

    for dependency in @definition.localDependencies
      @object[dependency + "_property"].registerGlobal()

  trigger: =>
    @clearCache()
    if @hasChanged()
      value = @get()

      changes = {}
      changes[name] = @object[name] for name in @dependents when name isnt @name

      @event.trigger(@_oldValue, value)
      for own name, value of changes
        prop = @object[name + "_property"]
        prop.clearCache()
        if prop.hasChanged()
          prop.event.trigger(prop._oldValue, value)
          prop._oldValue = value

      changes[@name] = value
      @object.changed?.trigger?(changes)
      @_oldValue = value

  bind: (fun) ->
    @registerGlobal()
    @event.bind(fun)

  rebind: (fun) ->
    @registerGlobal()
    @event.rebind(fun)

  unbind: (fun) ->
    @event.unbind(fun)

  one: (fun) ->
    @event.one(fun)

  resolve: ->
    @event.resolve()

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

  hasChanged: ->
    if @definition.changed in [true, false]
      @definition.changed
    else
      if "_oldValue" of this
        if @definition.changed
          @definition.changed.call(@object, @_oldValue, @get())
        else
          @_oldValue isnt @get()
      else
        true

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
