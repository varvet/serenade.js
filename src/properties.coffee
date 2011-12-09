{Monkey} = require './monkey'

pairToObject = (one, two) ->
  temp = {}
  temp[one] = two
  temp

Monkey.Properties =
  property: (name, options={}) ->
    @properties or= {}
    @properties[name] = options
    Object.defineProperty @, name,
      get: -> Monkey.Properties.get.call(this, name)
      set: (value) -> Monkey.Properties.set.call(this, name, value)

  collection: (name, options) ->
    @property name,
      get: ->
        unless @attributes[name]
          @attributes[name] = new Monkey.Collection([])
          @attributes[name].bind 'change', =>
            @_triggerChangesTo(pairToObject(name, @get(name)))
        @attributes[name]
      set: (value) ->
        @get(name).update(value)

  set: (attributes, value) ->
    attributes = pairToObject(attributes, value) if typeof(attributes) is 'string'

    for name, value of attributes
      @attributes or= {}
      if @properties?[name]?.set
        @properties[name].set.call(this, value)
      else
        @attributes[name] = value
    @_triggerChangesTo(attributes)

  get: (name) ->
    @attributes or= {}
    if @properties?[name]?.get
      @properties[name].get.call(this)
    else
      @attributes[name]

  _triggerChangesTo: (attributes) ->
    for name, value of attributes
      @trigger?("change:#{name}", value)
      if @properties
        for propertyName, property of @properties
          if property.dependsOn
            dependencies = if typeof(property.dependsOn) is 'string' then [property.dependsOn] else property.dependsOn
            if name in dependencies
              @trigger?("change:#{propertyName}", @get(propertyName))
    @trigger?("change", attributes)
