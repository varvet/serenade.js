class Monkey.Model
  Monkey.extend(@.prototype, Events)

  @property: (name) ->
    Object.defineProperty @.prototype, name,
      get: -> Monkey.Model.get.call(this, name)
      set: (value) -> Monkey.Model.set.call(this, name, value)

  @set: (property, value) ->
    @_properties or= {}
    @_properties[name] = value
    @trigger("change:#{property}", value)

  @get: (property) ->
    @_properties or= {}
    @_properties[name]

  get: @get
  set: @set
