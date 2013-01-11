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
    if key = @key(ctor, id)
      @_storage.setItem(key, JSON.stringify(serializeObject(obj)))
  retrieve: (ctor, id) ->
    if key = @key(ctor, id)
      data = @_storage.getItem(key)
      new ctor(JSON.parse(data), true) if data

  key: (ctor, id) ->
    name = ctor.uniqueId()
    if name and id and ctor.localStorageOptions?.on
      if ctor.localStorageOptions?.as
        ctor.localStorageOptions?.as(id)
      else
        "#{name}_#{id}"
