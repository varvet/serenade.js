Helpers =
  extend: (target, source) ->
    for own key, value of source
      target[key] = value

  get: (model, value, bound=true) ->
    if bound
      model?.get?(value) or model?[value]
    else
      value

  getPath: (model, [head, rest...]) ->
    #console.log "getPath", model, head, rest, rest.length > 0

    if rest.length > 0
      Helpers.getPath(Helpers.get(model, head), rest)
    else
      Helpers.get(model, head)

  format: (model, value, bound=true) ->
    if !bound
      return Helpers.get(model, value, bound)

    [head..., last] = value
    for name in head
      model = Helpers.get(model, name, bound)

    if not model?
      return undefined

    if model.format
      model.format(last)
    else
      Helpers.get(model, last, bound)

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

  bind: (model, [first, rest...], callback, lastElementBind = undefined) ->

    #console.log "bind", model, first, rest

    bindRest = ->
      if not first?
        lastElementBind?(model)
      else
        model.bind? "change:#{first}", ->
          callback()
          bindRest()
        Helpers.bind Helpers.get(model, first), rest, callback, lastElementBind

    bindRest()

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
