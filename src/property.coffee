{extend} = require './helpers'

class Property
  constructor: (@object, @name, @options) ->
    @valueName = "_s_#{@name}_val"

  set: (value) ->
    attributes = pairToObject(attributes, value) if typeof(attributes) is 'string'

    names = []
    for name, value of attributes
      names.push(name)
      if @options.set
        @options.set.call(@object, value)
      else
        Object.defineProperty(@object, @valueName, value: value, configurable: true)
    #triggerChangesTo(this, names)

  get: ->
    if @options.get
      @options.get.call(@object)
    else if "default" of @options and not @name of @object
      @options.default
    else
      @object[@valueName]

exports.defineProperty = (object, name, options={}) ->
  property = new Property(object, name, options)
  property
  Object.defineProperty object, name,
    get: -> property.get()
    set: (value) -> property.set(value)
    configurable: true

exports.Property = Property
