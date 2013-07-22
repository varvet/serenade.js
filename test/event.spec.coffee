require "./spec_helper"
{defineEvent} = Serenade

describe "Serenade.defineEvent", ->
  beforeEach ->
    @object = { text: "Hello", num: 0 }
    @increment = -> @num += 1
    @append = (val) -> @text += val

  it "adds an event property which is not enumerable", ->
    defineEvent(@object, "event")
    expect(@object.event).not.to.be.undefined
    expect(Object.keys(@object)).not.to.include("event")

  describe "#bind", ->
    it "listens to the event", ->
      defineEvent(@object, "event")
      @object.event.bind(@append)
      @object.event.trigger(" world")
      expect(@object.text).to.eql("Hello world")

    it "can be triggered multiple times", ->
      defineEvent(@object, "event")
      @object.event.bind(@append)
      @object.event.trigger(" world")
      @object.event.trigger(", yay!")
      expect(@object.text).to.eql("Hello world, yay!")

    it "does not bind the same function twice", ->
      defineEvent(@object, "event")
      @object.event.bind(@increment)
      @object.event.bind(@increment)

      @object.event.trigger("world")
      expect(@object.num).to.eql(1)

    it "does not bleed listeners to prototype", ->
      result = null
      defineEvent(@object, "event")
      @child = Object.create(@object)
      @child.event.bind (val) -> result = @text + " " + val
      @object.event.trigger("world")
      expect(result).to.eql(null)

    it "preserves listeners from parent", ->
      result = 0
      defineEvent(@object, "event")
      @object.event.bind -> result += 1
      @child = Object.create(@object)
      @child.event.bind -> result += 1

      @child.event.trigger("world")
      expect(result).to.eql(2)

    it "does not bleed listeners between events", ->
      result = null
      defineEvent(@object, "event1")
      defineEvent(@object, "event2")
      @object.event1.bind (val) -> result = @text + " " + val
      @object.event2.trigger("world")
      expect(result).to.eql(null)

    it "doesn't listen to the event more than once", ->
      defineEvent(@object, "event")
      @object.event.bind(@append)
      @object.event.bind(@append)
      @object.event.trigger(" world")
      expect(@object.text).to.eql("Hello world")

  describe "#unbind", ->
    it "does nothing when the given function isn't bound", ->
      defineEvent(@object, "event")
      @object.event.unbind(->)
      @object.event.trigger("world")

    it "stops listening to the event", ->
      defineEvent(@object, "event")
      @object.event.bind(@append)
      @object.event.unbind(@append)
      @object.event.trigger("world")
      expect(@object.text).to.eql("Hello")

    it "does not remove listeners from prototype", ->
      result = null
      defineEvent(@object, "event")
      @child = Object.create(@object)
      fun = (val) -> result = @text + " " + val
      @object.event.bind(fun)
      @child.event.unbind(fun)
      @object.event.trigger("world")
      expect(result).to.eql("Hello world")

    it "stops listening when bound on prototype", ->
      result = null
      defineEvent(@object, "event")
      @child = Object.create(@object)
      fun = (val) -> result = @text + " " + val
      @object.event.bind(fun)
      @child.event.unbind(fun)
      @child.event.trigger("world")
      expect(result).to.eql(null)

    it "does not bleed listeners between events", ->
      result = null
      defineEvent(@object, "event1")
      defineEvent(@object, "event2")
      fun = (val) -> result = @text + " " + val
      @object.event1.bind(fun)
      @object.event2.bind(fun)
      @object.event1.unbind(fun)
      @object.event2.trigger("world")
      expect(result).to.eql("Hello world")

  describe "#one", ->
    it "listens to the event", ->
      defineEvent(@object, "event")
      @object.event.one(@append)
      @object.event.trigger(" world")
      expect(@object.text).to.eql("Hello world")

    it "can only be triggered once", ->
      defineEvent(@object, "event")
      @object.event.one(@append)
      @object.event.trigger(" world")
      @object.event.trigger(", yay!")
      expect(@object.text).to.eql("Hello world")

  describe "with `bind` option", ->
    it "calls bind option when new listener is bound", ->
      defineEvent(@object, "event", bind: (fun) -> @result = fun()[0])
      expect(@object.result).not.to.be.ok
      @object.event.bind(-> "test")
      expect(@object.result).to.eql("t")

  describe "with `unbind` option", ->
    it "calls bind option when listener is removed", ->
      defineEvent(@object, "event", unbind: (fun) -> @result = fun()[0])
      expect(@object.result).not.to.be.ok
      fun = -> "test"
      @object.event.bind(fun)
      expect(@object.result).not.to.be.ok
      @object.event.unbind(fun)
      expect(@object.result).to.eql("t")

  describe "with `async` option", ->
    it "eventually calls event", (done) ->
      defineEvent(@object, "event", async: true)
      @object.event.bind -> @result = true
      @object.event.trigger()
      expect(@object.result).not.to.be.ok
      expect(=> @object.result).to.become(true, done)

    it "dispatches multiple events in correct order", (done) ->
      defineEvent(@object, "event", async: true)
      @object.event.bind (val) -> @text += val
      @object.event.trigger(" world")
      @object.event.trigger(", yay!")
      expect(@object.text).to.eql("Hello")
      expect(=> @object.text).to.become("Hello world, yay!", done)

    it "allows queue to be introspected between triggering and resolving event", (done) ->
      defineEvent(@object, "event", async: true)
      @object.event.bind (val) -> @num += val
      @object.event.trigger("foo", "bar")
      expect(@object.event.queue[0][0]).to.eql("foo")
      expect(@object.event.queue[0][1]).to.eql("bar")
      expect(=> @object.event.queue.length).to.become(0, done)

    it "can be manually resolved", ->
      defineEvent(@object, "event", async: true)
      @object.event.bind -> @result = true
      @object.event.trigger()
      expect(@object.result).not.to.be.ok
      @object.event.resolve()
      expect(@object.result).to.be.ok

  describe "with `optimize` option", ->
    it "runs all events individually when synchronous", ->
      defineEvent(@object, "event", optimize: (queue) -> queue[0] )
      @object.event.bind (val) -> @text += val
      @object.event.trigger(" world")
      @object.event.trigger(", yay!")
      expect(@object.text).to.eql("Hello world, yay!")

    it "optimizes queue into a single call to bound functions", (done) ->
      defineEvent(@object, "event", async: true, optimize: (queue) -> queue[0] )
      @object.event.bind (val) -> @text += val
      @object.event.trigger(" world")
      @object.event.trigger(", yay!")
      expect(=> @object.text).to.become("Hello world", done)

    it "does nothing when queue is empty", ->
      defineEvent(@object, "event", async: true, optimize: (queue) -> queue[0] )
      @object.event.bind (val) -> @text += val
      @object.event.resolve()
      expect(@object.text).to.eql("Hello")

  describe "when Serenade.async = true", ->
    beforeEach ->
      Serenade.async = true

    it "calls event asynchronously by default", (done) ->
      defineEvent(@object, "event")
      @object.event.bind -> @result = true
      @object.event.trigger()
      expect(@object.result).not.to.be.ok
      expect(=> @object.result).to.become(true, done)

    it "stays async when async option is true", (done) ->
      defineEvent(@object, "event", async: true)
      @object.event.bind -> @result = true
      @object.event.trigger()
      expect(@object.result).not.to.be.ok
      expect(=> @object.result).to.become(true, done)

    it "can be made synchronous", ->
      defineEvent(@object, "event", async: false)
      @object.event.bind -> @result = true
      @object.event.trigger()
      expect(@object.result).to.be.ok

    describe "with `timeout` option", ->
      it "resolves after the given amount of ms", (done) ->
        now = new Date()
        defineEvent(@object, "event", timeout: 50, optimize: (q) -> q[0])
        @object.event.bind ->
          expect((new Date()) - now).to.be.within(45,55)
          done()

        @object.event.trigger()
        setTimeout((=> @object.event.trigger()), 25)

    describe "with `buffer` option", ->
      it "buffers changes until there are no more changes within the given timeout", (done) ->
        now = new Date()
        defineEvent(@object, "event", buffer: true, timeout: 50, optimize: (q) -> q[0])
        @object.event.bind ->
          expect((new Date()) - now).to.be.within(70,80)
          done()

        @object.event.trigger()
        setTimeout((=> @object.event.trigger()), 25)

    describe "with `animate` option", ->
      it "animates with requestAnimationFrame", (done) ->
        # requestAnimationFrame doesn't exist on node,
        # so we've faked this out with a setTimeout of
        # 17 ms (ca 60fps).

        now = new Date()
        defineEvent(@object, "event", animate: true, optimize: (q) -> q[0])
        @object.event.bind ->
          expect((new Date()) - now).to.be.within(12,22)
          done()

        @object.event.trigger()
        setTimeout((=> @object.event.trigger()), 10)
