require "./spec_helper"
{defineEvent} = require '../src/event2'
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
      @child = Object.create(@object)
      @child.test1.bind (val) -> result = @text + " " + val
      @object.test2.trigger("world")
      expect(result).to.eql(null)
