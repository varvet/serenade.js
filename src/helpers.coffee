settings =
  async: false

def = Object.defineProperty

extend = (target, source, enumerable=true) ->
  for own key, value of source
    if enumerable
      target[key] = value
    else
      def target, key, value: value, configurable: true
  target

assignUnlessEqual = (object, prop, value) ->
  object[prop] = value unless object[prop] is value

merge = (target, source, enumerable=true) ->
  extend(extend({}, target, enumerable), source, enumerable)

format = (model, key) ->
  if model[key + "_property"]
    model[key + "_property"].format()
  else
    model[key]

isArray = (object) ->
  Object::toString.call(object) is "[object Array]"

pairToObject = (one, two) ->
  temp = {}
  temp[one] = two
  temp

serializeObject = (object) ->
  if object and typeof(object.toJSON) is 'function'
    object.toJSON()
  else if isArray(object)
    serializeObject(item) for item in object
  else
    object

capitalize = (word) ->
  word.slice(0,1).toUpperCase() + word.slice(1)

# Pushes item to a collection on object, interacts in a sane way with prototypes.
safePush = (object, collection, item) ->
  if not object[collection] or object[collection].indexOf(item) is -1
    # defined on self
    if object.hasOwnProperty(collection)
      object[collection].push(item)
    # defined on prototype, clone collection from prototype
    else if object[collection]
      def object, collection, value: [item].concat(object[collection])
    # not defined yet, define a new property
    else
      def object, collection, value: [item]

# Deletes an item from a collection on object, interacts in a sane way with prototypes.
safeDelete = (object, collection, item) ->
  if object[collection] and (index = object[collection].indexOf(item)) isnt -1
    # defined on prototype, clone collection from prototype
    unless object.hasOwnProperty(collection)
      def object, collection, value: [].concat(object[collection])
    object[collection].splice(index, 1)
