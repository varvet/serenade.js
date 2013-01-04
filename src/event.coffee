{safePush, safeDelete} = require './helpers'

class Event
  constructor: (@object, @name, @options) ->
    @prop = "_s_#{@name}_listeners"

  trigger: (args...) ->
    if @object[@prop]
      @object[@prop].forEach (fun) =>
        fun.apply(@object, args)

  bind: (fun) ->
    @options.bind.call(@object, fun) if @options.bind
    safePush(@object, @prop, fun)

  one: (fun) ->
    unbind = (fun) => @unbind(fun)
    @bind ->
      unbind(arguments.callee)
      fun.apply(@, arguments)

  unbind: (fun) ->
    safeDelete(@object, @prop, fun)
    @options.unbind.call(@object, fun) if @options.unbind

  Object.defineProperty @prototype, "listeners", get: ->
    @object[@prop]

defineEvent = (object, name, options={}) ->
  Object.defineProperty object, name,
    configurable: true
    get: ->
      new Event(this, name, options)

exports.defineEvent = defineEvent
