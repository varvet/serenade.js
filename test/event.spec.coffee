require "./spec_helper"
{defineEvent} = require '../src/event'
{expect} = require('chai')

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
