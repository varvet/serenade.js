require './spec_helper'

{defineProperty} = Serenade

describe 'Serenade.defineProperty', ->
  beforeEach ->
    @object = {}

  it 'does not bleed over between objects with same prototype', ->
    @inst1 = Object.create(@object)
    @inst2 = Object.create(@object)
    defineProperty @object, 'name', serialize: true
    defineProperty @inst1, 'age', serialize: true
    defineProperty @inst2, 'height', serialize: true
    expect(Object.keys(@inst1)).to.include('age')
    expect(Object.keys(@inst2)).not.to.include('age')

  it 'can be redefined', ->
    defineProperty @object, 'name', get: -> "foo"
    defineProperty @object, 'name', get: -> "bar"
    expect(@object.name).to.eql("bar")

  it 'is listed as an own property', ->
    defineProperty @object, 'name'
    expect(Object.keys(@object)).to.eql(["name"])
    expect(prop for prop of @object).to.eql(["name"])
    @child = Object.create(@object)
    expect(Object.keys(@child)).to.eql([])

  it 'adopts own property status when redefined', ->
    defineProperty @object, 'name'
    @child = Object.create(@object)
    @child.name = "bar"
    expect(Object.keys(@child)).to.eql(["name"])

  describe '#set', ->
    beforeEach ->
      defineProperty @object, ("foo")

    it 'sets that property', ->
      @object.foo = 23
      expect(@object.foo).to.eql(23)

    it 'triggers a change event if it is defined', ->
      Serenade.defineEvent(@object, "changed")
      expect(=> @object.foo = 23).to.triggerEvent(@object.changed)

    it 'triggers a change event for this property', ->
      expect(=> @object.foo = 23).to.triggerEvent(@object.foo_property, with: [undefined, 23])
      expect(=> @object.foo = 32).to.triggerEvent(@object.foo_property, with: [23, 32])

    it 'uses a custom setter', ->
      setValue = null
      defineProperty @object, 'foo', set: (value) -> setValue = value
      @object.foo = 42
      expect(setValue).to.eql(42)

    it 'consumes assigned functions and makes them getters', ->
      defineProperty @object, 'foo'
      @object.foo = -> 42
      expect(@object.foo).to.eql(42)

  describe '#get', ->
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

  describe 'enumerable', ->
    it 'defaults to true', ->
      defineProperty @object, 'foo'
      expect(Object.keys(@object)).to.include('foo')

    it 'can be set to false', ->
      defineProperty @object, 'foo', enumerable: false
      expect(Object.keys(@object)).not.to.include('foo')

    it 'can be set to true', ->
      defineProperty @object, 'foo', enumerable: true
      expect(Object.keys(@object)).to.include('foo')

    it 'adds no other enumerable properties', ->
      defineProperty @object, 'foo', enumerable: true
      expect(Object.keys(@object)).to.eql(['foo'])

  describe 'serialize', ->
    it 'will setup a setter method for that name', ->
      defineProperty @object, 'fooBar', serialize: 'foo_bar'
      @object.foo_bar = 56
      expect(@object.foo_bar).to.eql(56)
      expect(@object.fooBar).to.eql(56)

  describe "with `value` option", ->
    it 'can be given a value', ->
      defineProperty @object, 'name', value: "Jonas"
      expect(@object.name).to.eql("Jonas")

    it 'can set up default value', ->
      defineProperty @object, 'name', value: "foobar"
      expect(@object.name).to.eql("foobar")
      @object.name = "baz"
      expect(@object.name).to.eql("baz")
      @object.name = undefined
      expect(@object.name).to.eql(undefined)

    it 'can set up falsy default values', ->
      defineProperty @object, 'name', value: null
      expect(@object.name).to.equal(null)

    it 'ignores default when custom getter given', ->
      defineProperty @object, 'name', value: "bar", get: -> "foo"
      expect(@object.name).to.eql("foo")

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
      @object.name_property.trigger()
      expect(@object.name).to.eql("Jonas")
      expect(@object.name).to.eql("Jonas")
      expect(hitCount).to.eql(2)

    it "resets cache before attached events are fired", ->
      @object.__hitCount = 0
      defineProperty @object, "hitCount", cache: true, get: -> ++@__hitCount
      @object.hitCount_property.bind -> @result = @hitCount

      expect(@object.hitCount).to.eql(1)
      expect(@object.hitCount).to.eql(1)

      @object.hitCount_property.trigger()
      expect(@object.result).to.eql(2)

    it "resets cache before attached global events are fired", ->
      defineProperty @object, "foo", value: { __hitCount: 0 }
      defineProperty @object.foo, "hitCount", cache: true, get: -> ++@__hitCount
      defineProperty @object, "hitCount", dependsOn: "foo.hitCount", get: -> @foo.hitCount
      @object.hitCount_property.bind -> @result = @hitCount

      expect(@object.hitCount).to.eql(1)
      expect(@object.hitCount).to.eql(1)

      @object.foo.hitCount_property.trigger()
      expect(@object.result).to.eql(2)

  describe "with `changed` option", ->
    it "triggers a change event if value of property has changed if option not given", ->
      defineProperty @object, "name"

      expect(=> @object.name = "jonas").to.triggerEvent(@object.name_property)
      expect(=> @object.name = "jonas").not.to.triggerEvent(@object.name_property)
      expect(=> @object.name = "kim").to.triggerEvent(@object.name_property)

    it "triggers a change event if changed option evaluates to true", ->
      defineProperty @object, "name", value: "jonas", changed: (oldVal, newVal) -> oldVal is newVal

      expect(=> @object.name = "jonas").to.triggerEvent(@object.name_property)
      expect(=> @object.name = "jonas").to.triggerEvent(@object.name_property)
      expect(=> @object.name = "kim").not.to.triggerEvent(@object.name_property)

    it "always triggers a change event the first time a property is changed when a function is given since we don't know the initial value", ->
      defineProperty @object, "name", changed: -> false
      expect(=> @object.name = "jonas").to.triggerEvent(@object.name_property)
      expect(=> @object.name = "kim").not.to.triggerEvent(@object.name_property)

    it "does not trigger dependencies when not changed", ->
      defineProperty @object, "name", changed: (oldVal, newVal) -> oldVal isnt newVal
      defineProperty @object, "bigName", dependsOn: "name", get: -> @name?.toUpperCase()

      expect(=> @object.name = "jonas").to.triggerEvent(@object.bigName_property)
      expect(=> @object.name = "jonas").not.to.triggerEvent(@object.bigName_property)
      expect(=> @object.name = "kim").to.triggerEvent(@object.bigName_property)

    it "always triggers a change event when mutable object is assigned", ->
      obj = {}
      defineProperty @object, "name", value: obj
      expect(=> @object.name = {}).to.triggerEvent(@object.name_property)

    it "does not trigger when computed property has not changed", ->
      defineProperty @object, "name"
      defineProperty @object, "bigName",
        dependsOn: "name"
        get: -> @name?.toUpperCase()
        changed: (oldVal, newVal) -> oldVal isnt newVal

      expect(=> @object.name = "jonas").to.triggerEvent(@object.bigName_property)
      expect(=> @object.name = "jonas").not.to.triggerEvent(@object.bigName_property)
      expect(=> @object.name = "kim").to.triggerEvent(@object.bigName_property)

    it "never triggers a change event when option is false", ->
      defineProperty @object, "name", changed: false

      expect(=> @object.name = "jonas").not.to.triggerEvent(@object.name_property)
      expect(=> @object.name = "jonas").not.to.triggerEvent(@object.name_property)
      expect(=> @object.name = "kim").not.to.triggerEvent(@object.name_property)

    it "always triggers a change event when option is true", ->
      defineProperty @object, "name", changed: true

      expect(=> @object.name = "jonas").to.triggerEvent(@object.name_property)
      expect(=> @object.name = "jonas").to.triggerEvent(@object.name_property)
      expect(=> @object.name = "kim").to.triggerEvent(@object.name_property)

  describe "with `async` option", ->
    it "dispatches a change event for this property asynchronously", (done) ->
      defineProperty @object, "foo", async: true
      @object.foo_property.bind -> @result = true
      @object.foo = 23
      expect(@object.result).not.to.be.ok
      expect(=> @object.result).to.become(true, done)

    it "optimizes multiple change events for a property into one", (done) ->
      @object.num = 0
      defineProperty @object, "foo", value: 12, async: true
      @object.foo_property.resolve()
      @object.foo_property.bind (before, after) -> @result = "#{before}:#{after}"
      @object.foo = 23
      @object.foo = 15
      @object.foo = 45
      expect(=> @object.result).to.become("12:45", done)

  describe "when Serenade.async is true", ->
    it "dispatches change event asynchronously", (done) ->
      defineProperty @object, "foo"
      Serenade.async = true
      @object.foo_property.bind -> @result = true
      @object.foo = 23
      expect(@object.result).not.to.be.ok
      expect(=> @object.result).to.become(true, done)

    it "stays asynchronous when async option is true", (done) ->
      defineProperty @object, "foo", async: true
      Serenade.async = true
      @object.foo_property.bind -> @result = true
      @object.foo = 23
      expect(@object.result).not.to.be.ok
      expect(=> @object.result).to.become(true, done)

    it "can be made synchronous", ->
      defineProperty @object, "foo", async: false
      Serenade.async = true
      @object.foo_property.bind -> @result = true
      @object.foo = 23
      expect(@object.result).to.be.ok
