{Monkey} = require './monkey'

Monkey.Properties =
  property: (name, options) ->
    @properties or= {}
    @properties[name] = options
    Object.defineProperty @, name,
      get: -> Monkey.Properties.get.call(this, name)
      set: (value) -> Monkey.Properties.set.call(this, name, value)

  collection: (name, options) ->
    @property name,
      get: ->
        @attributes[name] or= new Monkey.Collection([])
      set: (value) ->
        @get(name).update(value)

  set: (name, value) ->
    @attributes or= {}
    if @properties?[name]?.set
      @properties[name].set.call(this, value)
    else
      @attributes[name] = value

    @trigger?("change:#{name}", value)
    # Trigger events for dependencies
    if @properties
      for propertyName, property of @properties when name in property.dependsOn
        @trigger?("change:#{propertyName}", @get(propertyName))
    # Trigger global change event
    @trigger?("change", name, value)

  get: (name) ->
    @attributes or= {}
    if @properties?[name]?.get
      @properties[name].get.call(this)
    else
      @attributes[name]
