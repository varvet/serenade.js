Cache =
  _identityMap: {}
  get: (ctor, id) ->
    name = ctor.toString()
    @_identityMap[name]?[id] if name
  set: (ctor, id, obj) ->
    name = ctor.toString()
    if name
      @_identityMap[name] or= {}
      @_identityMap[name][id] = obj

exports.Cache = Cache
