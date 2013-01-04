require "./spec_helper"
{defineEvent} = require '../src/event'
{expect} = require('chai')

describe "Serenade.defineEvent", ->
  beforeEach ->
    @object = { text: "Hello" }

  it "adds an event property which is not enumerable", ->
    defineEvent(@object, "test")
    expect(@object.test).not.to.be.undefined
    expect(Object.keys(@object)).not.to.include("test")

  describe "bind", ->
    it "listens to the event", ->
      result = null
      defineEvent(@object, "test")
      @object.test.bind (val) -> result = @text + " " + val
      @object.test.trigger("world")
      expect(result).to.eql("Hello world")

    it "does not bind the same function twice", ->
      result = 0
      defineEvent(@object, "test")
      fun = -> result += 1
      @object.test.bind(fun)
      @object.test.bind(fun)

      @object.test.trigger("world")
      expect(result).to.eql(1)

    it "does not bleed listeners to prototype", ->
      result = null
      defineEvent(@object, "test")
      @child = Object.create(@object)
      @child.test.bind (val) -> result = @text + " " + val
      @object.test.trigger("world")
      expect(result).to.eql(null)

    it "preserves listeners from parent", ->
      result = 0
      defineEvent(@object, "test")
      @object.test.bind -> result += 1
      @child = Object.create(@object)
      @child.test.bind -> result += 1

      @child.test.trigger("world")
      expect(result).to.eql(2)

    it "does not bleed listeners between events", ->
      result = null
      defineEvent(@object, "test1")
      defineEvent(@object, "test2")
      @object.test1.bind (val) -> result = @text + " " + val
      @object.test2.trigger("world")
      expect(result).to.eql(null)

  describe "unbind", ->
    it "does nothing when the given function isn't bound", ->
      defineEvent(@object, "test")
      @object.test.unbind(->)
      @object.test.trigger("world")

    it "stops listening to the event", ->
      result = null
      defineEvent(@object, "test")
      fun = (val) -> result = @text + " " + val
      @object.test.bind(fun)
      @object.test.unbind(fun)
      @object.test.trigger("world")
      expect(result).to.eql(null)

    it "does not remove listeners from prototype", ->
      result = null
      defineEvent(@object, "test")
      @child = Object.create(@object)
      fun = (val) -> result = @text + " " + val
      @object.test.bind(fun)
      @child.test.unbind(fun)
      @object.test.trigger("world")
      expect(result).to.eql("Hello world")

    it "stops listening when bound on prototype", ->
      result = null
      defineEvent(@object, "test")
      @child = Object.create(@object)
      fun = (val) -> result = @text + " " + val
      @object.test.bind(fun)
      @child.test.unbind(fun)
      @child.test.trigger("world")
      expect(result).to.eql(null)

    it "does not bleed listeners between events", ->
      result = null
      defineEvent(@object, "test1")
      defineEvent(@object, "test2")
      fun = (val) -> result = @text + " " + val
      @object.test1.bind(fun)
      @object.test2.bind(fun)
      @object.test1.unbind(fun)
      @object.test2.trigger("world")
      expect(result).to.eql("Hello world")
