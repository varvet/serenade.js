Model.hasMany = (name, options={}) ->
  propOptions = merge options,
    changed: true
    get: ->
      valueName = "_" + name
      unless @[valueName]
        @[valueName] = new AssociationCollection(this, options, [])
        @[valueName].change.bind(@[name + "_property"].trigger)
      @[valueName]
    set: (value) ->
      @[name].update(value)
  @property name, propOptions
  @property name + 'Ids',
    get: -> new Collection(@[name]).map((item) -> item?.id)
    set: (ids) ->
      objects = (options.as().find(id) for id in ids)
      @[name].update(objects)
    dependsOn: name
    serialize: options.serializeIds
  @property name + 'Count',
    get: -> @[name].length
    dependsOn: name
