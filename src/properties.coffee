{Monkey} = require './monkey'

Monkey.Properties =
  property: (name, options) ->
    @propertyOptions or= {}
    @propertyOptions[name] = options
    Object.defineProperty @, name,
      get: -> Monkey.Properties.get.call(this, name)
      set: (value) -> Monkey.Properties.set.call(this, name, value)

  collection: (name, options) ->
    @property(name, default: -> new Monkey.Collection([]))

  set: (property, value) ->
    @properties or= {}
    @properties[property] = value
    @trigger("change:#{property}", value)
    @trigger("change", property, value)

  get: (property) ->
    @properties or= {}
    unless @properties.hasOwnProperty(property)
      @properties[property] = @propertyOptions?[property]?['default']?()
    @properties[property]
