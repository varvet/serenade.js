require './spec_helper'

Serenade = require('../lib/serenade')
{defineProperty, defineAttribute} = Serenade

describe 'Serenade.defineProperty', ->
  beforeEach ->
    @object = {}

  it 'does not bleed over between objects with same prototype', ->
    @inst1 = Object.create(@object)
    @inst2 = Object.create(@object)
    defineProperty @object, 'name', get: -> "Jonas"
    defineProperty @inst1, 'age', get: -> 29
    defineProperty @inst2, 'height', get: -> 179
    expect(Object.keys(@inst1)).to.include('age')
    expect(Object.keys(@inst2)).not.to.include('age')

  it 'can be redefined', ->
    defineProperty @object, 'name', get: -> "foo"
    defineProperty @object, 'name', get: -> "bar"
    expect(@object.name).to.eql("bar")

  it 'is not listed as an own property', ->
    defineProperty @object, 'name', get: -> "blah"
    expect(Object.keys(@object)).to.eql([])
    expect(prop for prop of @object).to.eql([])
    @child = Object.create(@object)
    expect(Object.keys(@child)).to.eql([])

  describe '{ set() { ... } }', ->
    it 'is not setable by default', ->
      defineProperty @object, 'foo'
      expect(=> @object.foo = 42).to.eql(123)

    it 'uses a custom setter', ->
      defineProperty @object, 'foo', set: (value) -> @bar = foo + 10
      @object.foo = 42
      expect(@object.bar).to.eql(52)

  describe '{ get() { ... } }', ->
    it 'reads an existing property', ->
      @object.foo = 23
      expect(@object.foo).to.eql(23)

    it 'uses a custom getter', ->
      defineProperty @object, 'foo', get: -> 42
      expect(@object.foo).to.eql(42)

    it 'runs custom getter in context of object', ->
      @object.first = 'Jonas'
      @object.last = 'Nicklas'
      defineProperty @object, 'fullName', get: -> [@first, @last].join(' ')
      expect(@object.fullName).to.eql('Jonas Nicklas')

  describe '#format', ->
    it 'defaults to value', ->
      defineProperty @object, 'foo', value: 42
      expect(@object.foo_property.format()).to.eql(42)

    it 'uses a custom formatter', ->
      defineProperty @object, 'foo', value: 12, format: (val) -> val + "px"
      expect(@object.foo_property.format()).to.eql("12px")

    it 'runs formatter in object context', ->
      @object.unit = "em"
      defineProperty @object, 'foo', value: 12, format: (val) -> val + @unit
      expect(@object.foo_property.format()).to.eql("12em")

  describe 'enumerable', ->
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

  describe "with `value` option", ->
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

  describe "with `cache` option", ->
    it "returns values from cache", ->
      hitCount = 0
      defineProperty @object, "name", cache: true, get: -> hitCount++; "Jonas"

      expect(@object.name).to.eql("Jonas")
      expect(@object.name).to.eql("Jonas")
      expect(hitCount).to.eql(1)

    it "does not make cache enumerable", ->
      defineProperty @object, "name", cache: true, get: -> "Jonas"
      expect(@object.name).to.eql("Jonas")
      expect(Object.keys(@object)).to.eql(["name"])

    it "resets cache when change event triggered", ->
      hitCount = 0
      defineProperty @object, "name", cache: true, get: -> hitCount++; "Jonas"

      expect(@object.name).to.eql("Jonas")
      expect(@object.name).to.eql("Jonas")
      expect(hitCount).to.eql(1)
      @object["@name"].trigger()
      expect(@object.name).to.eql("Jonas")
      expect(@object.name).to.eql("Jonas")
      expect(hitCount).to.eql(2)

    it "resets cache before attached events are fired", ->
      @object.__hitCount = 0
      defineProperty @object, "hitCount", cache: true, get: -> ++@__hitCount
      @object["@hitCount"].subscribe -> @result = @hitCount

      expect(@object.hitCount).to.eql(1)
      expect(@object.hitCount).to.eql(1)

      @object["@hitCount"].trigger()
      expect(@object.result).to.eql(2)

    it "resets cache before attached global events are fired", ->
      defineProperty @object, "foo", value: { __hitCount: 0 }
      defineProperty @object.foo, "hitCount", cache: true, get: -> ++@__hitCount
      defineProperty @object, "hitCount", dependsOn: "foo.hitCount", get: -> @foo.hitCount
      @object["@hitCount"].subscribe -> @result = @hitCount

      expect(@object.hitCount).to.eql(1)
      expect(@object.hitCount).to.eql(1)

      @object.foo["@hitCount"].trigger()
      expect(@object.result).to.eql(2)

  describe "with `changed` option", ->
    it "triggers a change event if value of property has changed if option not given", ->
      defineAttribute @object, "name"

      expect(=> @object.name = "jonas").to.emit(@object["@name"])
      expect(=> @object.name = "jonas").not.to.emit(@object["@name"])
      expect(=> @object.name = "kim").to.emit(@object["@name"])

    it "triggers a change event if changed option evaluates to true", ->
      defineAttribute @object, "name", value: "jonas", changed: (oldVal, newVal) -> oldVal is newVal

      expect(=> @object.name = "jonas").to.emit(@object["@name"])
      expect(=> @object.name = "jonas").to.emit(@object["@name"])
      expect(=> @object.name = "kim").not.to.emit(@object["@name"])

    it "does not trigger dependencies when not changed", ->
      defineAttribute @object, "name", changed: (oldVal, newVal) -> oldVal isnt newVal
      defineProperty @object, "bigName", dependsOn: "name", get: (name) -> name?.toUpperCase()

      expect(=> @object.name = "jonas").to.emit(@object["@bigName"])
      expect(=> @object.name = "jonas").not.to.emit(@object["@bigName"])
      expect(=> @object.name = "kim").to.emit(@object["@bigName"])

    it "always triggers a change event when mutable object is assigned", ->
      obj = {}
      defineAttribute @object, "name", value: obj
      expect(=> @object.name = {}).to.emit(@object["@name"])

    it "does not trigger when computed property has not changed", ->
      defineAttribute @object, "name"
      defineProperty @object, "bigName",
        dependsOn: "name"
        get: (name) -> name?.toUpperCase()
        changed: (oldVal, newVal) -> oldVal isnt newVal

      expect(=> @object.name = "jonas").to.emit(@object["@bigName"])
      expect(=> @object.name = "jonas").not.to.emit(@object["@bigName"])
      expect(=> @object.name = "kim").to.emit(@object["@bigName"])

    it "never triggers a change event when option is false", ->
      defineAttribute @object, "name", changed: false

      expect(=> @object.name = "jonas").not.to.emit(@object["@name"])
      expect(=> @object.name = "jonas").not.to.emit(@object["@name"])
      expect(=> @object.name = "kim").not.to.emit(@object["@name"])

    it "always triggers a change event when option is true", ->
      defineAttribute @object, "name", changed: true

      expect(=> @object.name = "jonas").to.emit(@object["@name"])
      expect(=> @object.name = "jonas").to.emit(@object["@name"])
      expect(=> @object.name = "kim").to.emit(@object["@name"])

  describe "with `async` option", ->
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
