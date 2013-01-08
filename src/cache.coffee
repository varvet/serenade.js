Cache =
  _storage: window?.localStorage
  _identityMap: {}
  get: (ctor, id) ->
    name = ctor.uniqueId()
    if name and id
      @_identityMap[name]?[id] or @retrieve(ctor, id)
  set: (ctor, id, obj) ->
    name = ctor.uniqueId()
    if name and id
      @_identityMap[name] or= {}
      @_identityMap[name][id] = obj
  unset: (ctor, id) ->
    name = ctor.uniqueId()
    if name and id
      @_identityMap[name] or= {}
      delete @_identityMap[name][id]

  store: (ctor, id, obj) ->
    name = ctor.uniqueId()
    if name and id and JSON?
      @_storage.setItem("#{name}_#{id}", JSON.stringify(serializeObject(obj)))
  retrieve: (ctor, id) ->
    name = ctor.uniqueId()
    if name and id and ctor.localStorage and JSON?
      data = @_storage.getItem("#{name}_#{id}")
      new ctor(JSON.parse(data), true) if data
