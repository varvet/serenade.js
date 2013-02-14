require './spec_helper'

{extend} = Build
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
      expect(=> @object.foo = 23).to.triggerEvent(@object.foo_property, with: [23])

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

  describe 'dependsOn', ->
    it 'binds to dependencies', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: ['first', 'last']
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").to.triggerEvent(@object.fullName_property, with: ['Peter Pan'])

    it 'does not bind to dependencies when none are given', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: []
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").not.to.triggerEvent(@object.fullName_property)

    it 'does not bind to dependencies when false given', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: false
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").not.to.triggerEvent(@object.fullName_property)

    it 'automatically discovers dependencies within the same object', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'initial', get: -> @first?[0]
      defineProperty @object, 'fullName', get: -> @initial + " " + @last
      @object.last = 'Pan'

      expect(=> @object.first = "Peter").to.triggerEvent(@object.fullName_property)
      expect(=> @object.last = "Smith").to.triggerEvent(@object.fullName_property)
      expect(=> @object.first = "John").to.triggerEvent(@object.initial_property)
      expect(=> @object.last = "Doe").not.to.triggerEvent(@object.initial_property)

    it 'binds to single dependency', ->
      defineProperty @object, 'name'
      defineProperty @object, 'reverseName',
        get: -> @name.split("").reverse().join("") if @name
        dependsOn: 'name'
      expect(=> @object.name = 'Jonas').to.triggerEvent(@object.reverseName_property, with: ['sanoJ'])

    it 'can handle circular dependencies', ->
      defineProperty @object, 'foo', dependsOn: 'bar'
      defineProperty @object, 'bar', dependsOn: 'foo', get: -> @foo
      expect(=> @object.foo = 21).to.triggerEvent(@object.foo_property)
      expect(=> @object.foo = 22).to.triggerEvent(@object.bar_property)

    it 'can handle secondary dependencies', ->
      defineProperty @object, 'foo', dependsOn: 'quox'
      defineProperty @object, 'bar', dependsOn: ['quox'], get: -> @quox
      defineProperty @object, 'quox', dependsOn: ['bar', 'foo'], get: -> @foo
      expect(=> @object.foo = 21).to.triggerEvent(@object.foo_property, with: [21])
      expect(=> @object.foo = 22).to.triggerEvent(@object.bar_property, with: [22])
      expect(=> @object.foo = 23).to.triggerEvent(@object.quox_property, with: [23])

    context "reaching into an object", ->
      it "observes changes to the property", ->
        defineProperty @object, 'name', dependsOn: 'author.name', get: -> @author.name
        defineProperty @object, 'author'
        @object.author = Serenade(name: "Jonas")
        expect(=> @object.author.name = 'test').to.triggerEvent(@object.name_property)

      it "can depend on properties which reach into other properties", ->
        defineProperty @object, 'uppityName', dependsOn: 'name', get: -> @name.toUpperCase() if @name
        defineProperty @object, 'name', dependsOn: 'author.name', get: -> @author.name
        defineProperty @object, 'author'
        @object.author = Serenade(name: "Jonas")
        expect(=> @object.author.name = 'test').to.triggerEvent(@object.uppityName_property)

      it "triggers changes when object is assigned after event is bound", ->
        defineProperty @object, 'name', dependsOn: 'author.name', get: -> @author?.name
        defineProperty @object, 'author'
        expect =>
          @object.author = Serenade(name: "Jonas")
          @object.author.name = "Kim"
        .to.triggerEvent(@object.name_property, count: 2)

      it "does not observe changes on objects which are no longer associated", ->
        defineProperty @object, 'name', dependsOn: 'author.name', get: -> @author?.name
        defineProperty @object, 'author'
        expect =>
          @object.author = Serenade(name: "Jonas")
          oldAuthor = @object.author
          oldAuthor.name = "Kim"
          @object.author = Serenade(name: "Peter")
        .to.triggerEvent(@object.name_property, count: 2)

    context "reaching into a collection", ->
      beforeEach ->
        defineProperty @object, 'authors', value: new Serenade.Collection()
        defineProperty @object, 'authorNames', dependsOn: "authors:name", get: -> @authors.map (a) -> a.name

      it "observes changes to the entire collection", ->
        newAuthor = Serenade(name: "Anders")
        expect(=> @object.authors.push(newAuthor)).to.triggerEvent(@object.authorNames_property)

      it "observes changes to each individual object", ->
        @object.authors.push(Serenade(name: "Bert"))
        author = @object.authors[0]
        expect(-> author.name = 'test').to.triggerEvent(@object.authorNames_property)

      it "is not affected by additional event listeners", ->
        @object.authorNames_property.bind -> @wasTriggered = true
        expect(=> @object.authors.push({ name: "Bert" })).to.triggerEvent(@object.authorNames_property)
        expect(@object.wasTriggered).to.be.ok

      it "does not observe changes to elements no longer in the collcection", ->
        @object.authors.push(Serenade(name: "Bert"))
        oldAuthor = @object.authors[0]
        @object.authors.deleteAt(0)
        expect(-> oldAuthor.name = 'test').not.to.triggerEvent(@object.authorNames_property)

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
      @object._hitCount = 0
      defineProperty @object, "hitCount", cache: true, get: -> ++@_hitCount
      @object.hitCount_property.bind -> @result = @hitCount

      expect(@object.hitCount).to.eql(1)
      expect(@object.hitCount).to.eql(1)

      @object.hitCount_property.trigger()
      expect(@object.result).to.eql(2)

    it "resets cache before attached global events are fired", ->
      defineProperty @object, "foo", value: { _hitCount: 0 }
      defineProperty @object.foo, "hitCount", cache: true, get: -> ++@_hitCount
      defineProperty @object, "hitCount", dependsOn: "foo.hitCount", get: -> @foo.hitCount
      @object.hitCount_property.bind -> @result = @hitCount

      expect(@object.hitCount).to.eql(1)
      expect(@object.hitCount).to.eql(1)

      @object.foo.hitCount_property.trigger()
      expect(@object.result).to.eql(2)

  describe "with `changed` option", ->
    it "triggers a change event if changed option evaluates to true", ->
      defineProperty @object, "name", changed: (oldVal, newVal) -> oldVal isnt newVal

      expect(=> @object.name = "jonas").to.triggerEvent(@object.name_property)
      expect(=> @object.name = "jonas").not.to.triggerEvent(@object.name_property)
      expect(=> @object.name = "kim").to.triggerEvent(@object.name_property)

    it "does not trigger dependencies when not changed", ->
      defineProperty @object, "name", changed: (oldVal, newVal) -> oldVal isnt newVal
      defineProperty @object, "bigName", dependsOn: "name", get: -> @name?.toUpperCase()

      expect(=> @object.name = "jonas").to.triggerEvent(@object.bigName_property)
      expect(=> @object.name = "jonas").not.to.triggerEvent(@object.bigName_property)
      expect(=> @object.name = "kim").to.triggerEvent(@object.bigName_property)

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

  describe "with `async` option", ->
    it "dispatches a change event for this property asynchronously", (done) ->
      defineProperty @object, "foo", async: true
      @object.foo_property.bind -> @result = true
      @object.foo = 23
      expect(@object.result).not.to.be.ok
      expect(=> @object.result).to.become(true, done)

    it "optimizes multiple change events for a property into one", (done) ->
      @object.num = 0
      defineProperty @object, "foo", async: true
      @object.foo_property.bind (val) -> @num += val
      @object.foo = 23
      @object.foo = 12
      expect(=> @object.num).to.become(12, done)

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
