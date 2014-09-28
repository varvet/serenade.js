Model.collection = (name, options={}) ->
  propOptions = merge options,
    changed: true
    get: ->
      valueName = "_" + name
      unless @[valueName]
        @[valueName] = new Collection([])
        @[valueName].change.bind(@[name + "_property"].trigger)
      @[valueName]
    set: (value) ->
      @[name].update(value)
  @property name, propOptions
  @property name + 'Count',
    get: -> @[name].length
    dependsOn: name
