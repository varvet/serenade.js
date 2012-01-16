Helpers =
  extend: (target, source) ->
    for key, value of source
      if Object.prototype.hasOwnProperty.call(source, key)
        target[key] = value
  get: (model, value, bound=true) ->
    if bound and model.get
      model.get(value)
    else if bound
      model[value]
    else
      value
  format: (model, value, bound=true) ->
    if bound and model.format
      model.format(value)
    else
      Helpers.get(model, value, bound)
  # Iteration with fallback
  forEach: (collection, fun) ->
    if typeof(collection.forEach) is 'function'
      collection.forEach(fun)
    else
      fun(element) for element in collection

  map: (collection, fun) ->
    if typeof(collection.map) is 'function'
      collection.map(fun)
    else
      fun(element) for element in collection

  isArray: (object) ->
    toString.call(object) is "[object Array]"

  pairToObject: (one, two) ->
    temp = {}
    temp[one] = two
    temp

  serializeObject: (object) ->
    if typeof(object.serialize) is 'function'
      object.serialize()
    else if Helpers.isArray(object)
      Helpers.map(object, (item) -> Helpers.serializeObject(item))
    else
      object

Helpers.extend(exports, Helpers)
