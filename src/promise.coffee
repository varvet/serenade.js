class Promise
  constructor: ->
    @handlers = []
    @state = "pending"

  then: (onFulfilled, onRejected) ->
    promise = new Promise()
    @handlers.push([promise, onFulfilled, onRejected])
    setTimeout(@_resolve, 0) unless @state is "pending"
    promise

  fulfill: (@value) =>
    @state = "fulfilled"
    @_resolve()

  reject: (@value) =>
    @state = "rejected"
    @_resolve()

  _resolve: =>
    @_resolveHandler(handler...) while handler = @handlers.shift()

  _resolveHandler: (promise, onFulfilled, onRejected) ->
    handler = if @state is "fulfilled" then onFulfilled else onRejected
    if typeof(handler) is "function"
      try
        result = handler(@value)
      catch e
        promise.reject(e)
      if typeof(result?.then) is "function"
        result.then(promise.fulfill, promise.reject)
      else
        promise.fulfill(result)
    else if @state is "fulfilled"
      promise.fulfill(@value)
    else
      promise.reject(@value)
