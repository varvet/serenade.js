{serializeObject} = require '../src/helpers.coffee'

Cache =
  _storage: window?.localStorage
  _identityMap: {}
  get: (ctor, id) ->
    name = ctor.toString()
    if name and id
      @_identityMap[name]?[id] or @retrieve(ctor, id)
  set: (ctor, id, obj) ->
    name = ctor.toString()
    if name and id
      @_identityMap[name] or= {}
      @_identityMap[name][id] = obj
  store: (ctor, id, obj) ->
    name = ctor.toString()
    if name and id
      @_storage.setItem("#{name}_#{id}", JSON.stringify(serializeObject(obj)))
  retrieve: (ctor, id) ->
    name = ctor.toString()
    if name and id and ctor.localStorage
      data = @_storage.getItem("#{name}_#{id}")
      new ctor(JSON.parse(data)) if data


exports.Cache = Cache
