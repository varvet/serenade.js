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

  set: (property, value) ->
    @attributes or= {}
    if @properties?[property]?.set
      @properties[property].set.call(this, value)
    else
      @attributes[property] = value

    @trigger?("change:#{property}", value)
    @trigger?("change", property, value)

  get: (property) ->
    @attributes or= {}
    if @properties?[property]?.get
      @properties[property].get.call(this)
    else
      @attributes[property]
