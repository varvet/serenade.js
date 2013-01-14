Cache =
  _identityMap: {}
  get: (ctor, id) ->
    name = ctor.uniqueId()
    if name and id
      @_identityMap[name]?[id]
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
