class Event
  constructor: (@object, @name, @options) ->
    @prop = "_s_#{@name}_listeners"
    @queue_name = "_s_#{name}_queue"
    @queue = if @object.hasOwnProperty(@queue_name)
      @object[@queue_name]
    else
      @object[@queue_name] = []

  trigger: (args...) ->
    @queue.push(args)
    if @options.async
      @queue.timeout or= setTimeout((=> @resolve()), 0)
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
    perform = (args) =>
      if @object[@prop]
        @object[@prop].forEach (fun) =>
          fun.apply(@object, args)
    if @options.optimize
      perform(@options.optimize(@queue))
    else
      perform(args) for args in @queue
    @queue = @object[@queue_name] = []

  Object.defineProperty @prototype, "listeners", get: ->
    @object[@prop]

defineEvent = (object, name, options={}) ->
  Object.defineProperty object, name,
    configurable: true
    get: ->
      new Event(this, name, options)
