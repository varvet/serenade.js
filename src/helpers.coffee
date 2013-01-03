Helpers =
  extend: (target, source, enumerable=true) ->
    for own key, value of source
      if enumerable
        target[key] = value
      else
        Object.defineProperty(target, key, value: value, configurable: true)

  format: (model, key) ->
    value = model[key]
    formatter = model[key + "_property"]?.format
    if typeof(formatter) is 'function'
      formatter.call(model, value)
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

  # Pushes item to a collection on object, interacts in a sane way with prototypes.
  safePush: (object, collection, item) ->
    if not object[collection] or object[collection].indexOf(item) is -1
      # defined on self
      if object.hasOwnProperty(collection)
        object[collection].push(item)
      # defined on prototype, clone collection from prototype
      else if object[collection]
        Object.defineProperty object, collection, value: [item].concat(object[collection])
      # not defined yet, define a new property
      else
        Object.defineProperty object, collection, value: [item]

  # Deletes an item from a collection on object, interacts in a sane way with prototypes.
  safeDelete: (object, collection, item) ->
    if object[collection] and (index = object[collection].indexOf(item)) isnt -1
      # defined on prototype, clone collection from prototype
      unless object.hasOwnProperty(collection)
        Object.defineProperty object, collection, value: [].concat(object[collection])
      object[collection].splice(index, 1)

Helpers.extend(exports, Helpers)
