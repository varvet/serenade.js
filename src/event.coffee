class Event
  constructor: (@object, @name, @options) ->
    @prop = "_s_#{@name}_listeners"
    @queueName = "_s_#{name}_queue"

  def @prototype, "async", get: ->
    if "async" of @options then @options.async else settings.async

  trigger: (args...) ->
    @queue.push(args)
    if @async
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
    @queue = []

  def @prototype, "listeners", get: ->
    @object[@prop]

  def @prototype, "queue",
    get: ->
      @queue = [] unless @object.hasOwnProperty(@queueName)
      @object[@queueName]
    set: (val) ->
      def @object, @queueName, value: val, configurable: true

defineEvent = (object, name, options={}) ->
  def object, name,
    configurable: true
    get: ->
      new Event(this, name, options)
