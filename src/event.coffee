{safePush, safeDelete} = require './helpers'

class Event
  constructor: (@object, @name, @options) ->
    @prop = "_s_#{@name}_listeners"
    queue_name = "_s_#{name}_queue"
    @queue = if @object.hasOwnProperty(queue_name)
      @object[queue_name]
    else
      @object[queue_name] = []

  trigger: (args...) ->
    @queue.push(args)
    if @options.async
      setTimeout((=> @resolve()), 0)
    else
      @resolve()

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

  resolve: ->
    while args = @queue.shift()
      if @object[@prop]
        @object[@prop].forEach (fun) =>
          fun.apply(@object, args)

  Object.defineProperty @prototype, "listeners", get: ->
    @object[@prop]

defineEvent = (object, name, options={}) ->
  Object.defineProperty object, name,
    configurable: true
    get: ->
      new Event(this, name, options)

exports.defineEvent = defineEvent
