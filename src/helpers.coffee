Helpers =
  prefix: "_prop_"
  extend: (target, source) ->
    for own key, value of source
      target[key] = value

  format: (model, key) ->
    value = model[key]
    formatter = model[Helpers.prefix + key]?.format
    if typeof(formatter) is 'function'
      formatter.call(this, value)
    else
      value

  isArray: (object) ->
    Object::toString.call(object) is "[object Array]"

  pairToObject: (one, two) ->
    temp = {}
    temp[one] = two
    temp

  serializeObject: (object) ->
    if object and typeof(object.toJSON) is 'function'
      object.toJSON()
    else if Helpers.isArray(object)
      Helpers.serializeObject(item) for item in object
    else
      object

  capitalize: (word) ->
    word.slice(0,1).toUpperCase() + word.slice(1)

Helpers.extend(exports, Helpers)
