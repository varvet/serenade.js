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

    it 'assumes value when inheriting', ->
      defineAttribute @object, 'name', value: "Jonas"
      child = Object.create(@object)
      expect(child.name).to.eql("Jonas")

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

  describe "when Serenade.async is false", ->
    it "dispatches a change event for this property synchronously", ->
      result = null

      defineAttribute @object, "name", value: "Kim"

      @object["@name"].subscribe (val) -> result = val

      @object.name = "Jonas"

      expect(result).to.equal("Jonas")

  describe "when Serenade.async is true", ->
    beforeEach ->
      Serenade.async = true

    it "dispatches change event asynchronously", (done) ->
      result = null

      defineAttribute @object, "name", value: "Kim"

      @object["@name"].subscribe (val) -> result = val

      @object.name = "Jonas"

      expect(result).not.to.be.ok
      expect(-> result).to.become("Jonas", done)

    it "optimizes multiple change events for a property into one", (done) ->
      values = []

      defineAttribute @object, "foo", value: 12

      @object["@foo"].subscribe (val) -> values.push(val)
      @object.foo = 23
      @object.foo = 15
      @object.foo = 45
      expect(=> values.toString()).to.become("45", done)
