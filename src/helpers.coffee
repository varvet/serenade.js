Helpers =
  extend: (target, source) ->
    for own key, value of source
      target[key] = value
  get: (model, value, bound=true) ->
    if bound and model?.get
      model.get(value)
    else if bound
      model?[value]
    else
      value
  format: (model, value, bound=true) ->
    if bound and model.format
      model.format(value)
    else
      Helpers.get(model, value, bound)
  map: (collection, fun) ->
    if typeof(collection.map) is 'function'
      collection.map(fun)
    else
      fun(element) for element in collection

  isArray: (object) ->
    Object::toString.call(object) is "[object Array]"

  pairToObject: (one, two) ->
    temp = {}
    temp[one] = two
    temp

  serializeObject: (object) ->
    if object and typeof(object.serialize) is 'function'
      object.serialize()
    else if Helpers.isArray(object)
      Helpers.map(object, (item) -> Helpers.serializeObject(item))
    else
      object

  indexOf: (arr, search) ->
    if arr.indexOf
      arr.indexOf(search)
    else
      return index for item, index in arr when item is search
      return -1

  deleteItem: (arr, item) ->
    arr.splice(Helpers.indexOf(item), 1)

  getFunctionName: (fun) ->
    name = fun.modelName
    name or= fun.name
    name or= fun.toString().match(/\[object (.+?)\]/)?[1]
    name or= fun.toString().match(/function (.+?)\(\)/)?[1]
    name

  preventDefault: (event) ->
    if event.preventDefault
      event.preventDefault()
    else
      event.returnValue = false

Helpers.extend(exports, Helpers)
