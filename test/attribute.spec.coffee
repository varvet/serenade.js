require './spec_helper'

Serenade = require('../lib/serenade')
{defineAttribute, defineProperty} = Serenade

describe 'Serenade.defineAttribute', ->
  beforeEach ->
    @object = {}

  it 'does not bleed over between objects with same prototype', ->
    @inst1 = Object.create(@object)
    @inst2 = Object.create(@object)
    defineAttribute @object, 'name'
    defineAttribute @inst1, 'age'
    defineAttribute @inst2, 'height'
    expect(Object.keys(@inst1)).to.include('age')
    expect(Object.keys(@inst2)).not.to.include('age')

  it 'can be redefined', ->
    defineAttribute @object, 'name', value: "foo"
    defineAttribute @object, 'name', value: "bar"
    expect(@object.name).to.eql("bar")

  it 'is listed as an own property', ->
    defineAttribute @object, 'name'
    expect(Object.keys(@object)).to.eql(["name"])
    expect(prop for prop of @object).to.eql(["name"])
    @child = Object.create(@object)
    expect(Object.keys(@child)).to.eql([])

  it 'adopts own property status when redefined', ->
    defineAttribute @object, 'name'
    @child = Object.create(@object)
    @child.name = "bar"
    expect(Object.keys(@child)).to.eql(["name"])

  describe '{ as() { ... } }', ->
    beforeEach ->
      defineAttribute @object, "foo"

    it 'maps through the given function', ->
      defineAttribute @object, 'foo', as: (value) -> value + 12
      @object.foo = 42
      expect(@object.foo).to.eql(54)

  describe '{ enumerable: true|false }', ->
    it 'defaults to true', ->
      defineAttribute @object, 'foo'
      expect(Object.keys(@object)).to.include('foo')

    it 'can be set to false', ->
      defineAttribute @object, 'foo', enumerable: false
      expect(Object.keys(@object)).not.to.include('foo')

    it 'can be set to true', ->
      defineAttribute @object, 'foo', enumerable: true
      expect(Object.keys(@object)).to.include('foo')

    it 'adds no other enumerable properties', ->
      defineAttribute @object, 'foo', enumerable: true
      expect(Object.keys(@object)).to.eql(['foo'])

  describe "{ value: ... }", ->
    it 'can be given a value', ->
      defineAttribute @object, 'name', value: "Jonas"
      expect(@object.name).to.eql("Jonas")

    it 'can set up default value', ->
      defineAttribute @object, 'name', value: "foobar"
      expect(@object.name).to.eql("foobar")
      @object.name = "baz"
      expect(@object.name).to.eql("baz")
      @object.name = undefined
      expect(@object.name).to.eql(undefined)

    it 'can set up falsy default values', ->
      defineAttribute @object, 'name', value: null
      expect(@object.name).to.equal(null)

  describe "{ async: true|false }", ->
    it "dispatches a change event for this property asynchronously", (done) ->
      defineAttribute @object, "foo", async: true
      @object["@foo"].subscribe -> @result = true
      @object.foo = 23
      expect(@object.result).not.to.be.ok
      expect(=> @object.result).to.become(true, done)

    it "optimizes multiple change events for a property into one", (done) ->
      @object.num = 0
      defineAttribute @object, "foo", value: 12, async: true
      @object["@foo"].resolve()
      @object["@foo"].subscribe (before, after) -> @result = "#{before}:#{after}"
      @object.foo = 23
      @object.foo = 15
      @object.foo = 45
      expect(=> @object.result).to.become("12:45", done)

  describe "when Serenade.async is true", ->
    it "dispatches change event asynchronously", (done) ->
      defineAttribute @object, "foo"
      Serenade.async = true
      @object["@foo"].subscribe -> @result = true
      @object.foo = 23
      expect(@object.result).not.to.be.ok
      expect(=> @object.result).to.become(true, done)

    it "stays asynchronous when async option is true", (done) ->
      defineAttribute @object, "foo", async: true
      Serenade.async = true
      @object["@foo"].subscribe -> @result = true
      @object.foo = 23
      expect(@object.result).not.to.be.ok
      expect(=> @object.result).to.become(true, done)

    it "can be made synchronous", ->
      defineAttribute @object, "foo", async: false
      Serenade.async = true
      @object["@foo"].subscribe -> @result = true
      @object.foo = 23
      expect(@object.result).to.be.ok
