{safePush, safeDelete} = require './helpers'

class Event
  constructor: (@object, @name, @options) ->
    @prop = "_s_#{@name}_listeners"

  trigger: (args...) ->
    if @object[@prop]
      @object[@prop].forEach (fun) =>
        fun.apply(@object, args)

  bind: (fun) ->
    safePush(@object, @prop, fun)

  unbind: (fun) ->
    safeDelete(@object, @prop, fun)

defineEvent = (object, name, options={}) ->
  Object.defineProperty object, name, get: ->
    new Event(this, name, options)

exports.defineEvent = defineEvent
