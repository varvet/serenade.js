class Event
  constructor: (@object, @name, @options) ->

  def @prototype, "async", get: ->
    if "async" of @options then @options.async else settings.async

  trigger: (args...) ->
    if @listeners.length
      @queue.push(args)
      if @async
        if @options.animate
          @queue.frame or= requestAnimationFrame((=> @resolve()), @options.timeout or 0)
        else
          return if @queue.timeout and not @options.buffer
          if @options.timeout
            clearTimeout(@queue.timeout)
            @queue.timeout = setTimeout((=> @resolve()), @options.timeout or 0)
          else if not @queue.tick
            @queue.tick = true
            nextTick => @resolve()
      else
        @resolve()

  bind: (fun) ->
    @options.bind.call(@object, fun) if @options.bind
    safePush(@object._s, "listeners_#{@name}", fun)

  one: (fun) ->
    unbind = (fun) => @unbind(fun)
    @bind ->
      unbind(arguments.callee)
      fun.apply(@, arguments)

  unbind: (fun) ->
    safeDelete(@object._s, "listeners_#{@name}", fun)
    @options.unbind.call(@object, fun) if @options.unbind

  resolve: ->
    cancelAnimationFrame(@queue.frame) if @queue.frame
    clearTimeout(@queue.timeout) if @queue.timeout
    if @queue.length
      perform = (args) =>
        if @listeners
          ([].concat(@listeners)).forEach (listener) =>
            listener.apply(@object, args)
      if @options.optimize
        perform(@options.optimize(@queue))
      else
        perform(args) for args in @queue
    @queue = []

  def @prototype, "listeners", get: ->
    @object._s["listeners_#{@name}"] or []

  def @prototype, "queue",
    get: ->
      @queue = [] unless @object._s.hasOwnProperty("queue_#{@name}")
      @object._s["queue_#{@name}"]
    set: (val) ->
      @object._s["queue_#{@name}"] = val

defineEvent = (object, name, options={}) ->
  defineOptions(object, "_s") unless "_s" of object
  def object, name,
    configurable: true
    get: ->
      new Event(this, name, options)
