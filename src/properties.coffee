Monkey.Properties =
  property: (name) ->
    Object.defineProperty @, name,
      get: -> Monkey.Properties.get.call(this, name)
      set: (value) -> Monkey.Properties.set.call(this, name, value)

  set: (property, value) ->
    @properties or= {}
    @properties[name] = value
    @trigger("change:#{property}", value)
    @trigger("change", property, value)

  get: (property) ->
    @properties or= {}
    @properties[name]
