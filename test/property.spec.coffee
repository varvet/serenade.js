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
    expect(@inst1.name).to.eql("Jonas")
    expect(@inst2.name).to.eql("Jonas")
    expect(@inst1.age).to.eql(29)
    expect(@inst2.age).to.eql(undefined)

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
      @object.foo = 42
      expect(@object.foo).to.eql(undefined)

    it 'uses a custom setter', ->
      defineProperty @object, 'foo', set: (value) -> @bar = value + 10
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

    it 'passes dependencies to getter', ->
      @object.first = 'Jonas'
      @object.last = 'Nicklas'
      defineProperty @object, 'fullName',
        dependsOn: ["first", "last"],
        get: (first, last) -> [first, last].join(' ')
      expect(@object.fullName).to.eql('Jonas Nicklas')

  describe '{ enumerable: true|false }', ->
    it 'defaults to false', ->
      defineProperty @object, 'foo'
      expect(Object.keys(@object)).not.to.include('foo')

    it 'can be set to false', ->
      defineProperty @object, 'foo', enumerable: false
      expect(Object.keys(@object)).not.to.include('foo')

    it 'can be set to true', ->
      defineProperty @object, 'foo', enumerable: true
      expect(Object.keys(@object)).to.include('foo')

    it 'adds no other enumerable properties', ->
      defineProperty @object, 'foo', enumerable: true
      expect(Object.keys(@object)).to.eql(['foo'])

  describe "{ cache: true|false }", ->
    it "returns values from cache", ->
      hitCount = 0
      defineProperty @object, "name", cache: true, get: ->
        hitCount++; "Jonas"

      expect(@object.name).to.eql("Jonas")
      expect(@object.name).to.eql("Jonas")
      expect(hitCount).to.eql(1)

    it "resets cache when change event triggered", ->
      hitCount = 0
      defineAttribute @object, "name", value: "Jonas"
      defineProperty @object, "bigName", cache: true, dependsOn: "name", get: (name) ->
        hitCount++
        name.toUpperCase()

      expect(@object.bigName).to.eql("JONAS")
      expect(@object.bigName).to.eql("JONAS")
      expect(hitCount).to.eql(1)
      @object.name = "Kim"
      expect(@object.bigName).to.eql("KIM")
      expect(@object.bigName).to.eql("KIM")
      expect(hitCount).to.eql(2)

    it "resets cache before attached events are fired", ->
      defineAttribute @object, "name", value: "Jonas"
      defineProperty @object, "bigName", cache: true, dependsOn: "name", get: (name) ->
        name.toUpperCase()

      expect(=> @object.name = "Kim").to.emit(@object["@bigName"], with: "KIM")

  describe "when Serenade.async is false", ->
    it "dispatches a change event for this property synchronously", ->
      result = null

      defineAttribute @object, "name", value: "Kim"
      defineProperty @object, "bigName",
        dependsOn: "name"
        get: (name) -> name.toUpperCase()

      @object["@bigName"].subscribe (val) -> result = val

      @object.name = "Jonas"

      expect(result).to.equal("JONAS")

  describe "when Serenade.async is true", ->
    beforeEach ->
      Serenade.async = true

    it "dispatches change event asynchronously", (done) ->
      result = null

      defineAttribute @object, "name", value: "Kim"
      defineProperty @object, "bigName",
        dependsOn: "name"
        get: (name) -> name.toUpperCase()

      @object["@bigName"].subscribe (val) -> result = val

      @object.name = "Jonas"

      expect(result).not.to.be.ok
      expect(-> result).to.become("JONAS", done)

    it "optimizes multiple change events for a property into one", (done) ->
      values = []

      defineAttribute @object, "foo", value: 12
      defineProperty @object, "bar", dependsOn: "foo", get: (val) -> val + 1

      @object["@bar"].subscribe (val) -> values.push(val)
      @object.foo = 23
      @object.foo = 15
      @object.foo = 45
      expect(=> values.toString()).to.become("46", done)

    it "evaluates dependent properties in same tick", ->
      result = null

      defineAttribute @object, "first", value: "Jonas"
      defineAttribute @object, "last", value: "Nicklas"
      defineProperty @object, "name",
        dependsOn: ["first", "last"],
        get: (first, last) -> [first, last].join(' ')
      defineProperty @object, "bigName",
        dependsOn: "name"
        get: (name) ->
          name.toUpperCase()

      @object["@bigName"].subscribe (val) -> result = val

      @object.first = "Georg"

      Serenade.eventManager.tick()

      expect(result).to.equal("GEORG NICKLAS")
