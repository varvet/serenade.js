require './spec_helper'
{Serenade} = require '../src/serenade'
{Collection} = require '../src/collection'
{Events} = require '../src/events'
{Properties} = require '../src/properties'
{extend} = require '../src/helpers'
{expect} = require('chai')

describe 'Properties', ->
  beforeEach ->
    @object = {}
    extend(@object, Properties)
    extend(@object, Events)

  describe '.property', ->
    it 'will setup a setter method for that name', ->
      @object.property 'fooBar', serialize: 'foo_bar'
      @object.foo_bar = 56
      expect(@object.foo_bar).to.eql(56)
      expect(@object.fooBar).to.eql(56)
    it 'can handle circular dependencies', ->
      @object.property 'foo', dependsOn: 'bar'
      @object.property 'bar', dependsOn: 'foo'
      fun = => @object.foo = 23
      expect(fun).to.triggerEvent(@object, 'change:foo')
      expect(fun).to.triggerEvent(@object, 'change:bar')
    it 'can handle secondary dependencies', ->
      @object.property 'foo', dependsOn: 'quox'
      @object.property 'bar', dependsOn: ['quox']
      @object.property 'quox', dependsOn: ['bar', 'foo']
      fun = => @object.foo = 23
      expect(fun).to.triggerEvent(@object, 'change:foo', with: [23])
      expect(fun).to.triggerEvent(@object, 'change:bar', with: [undefined])
      expect(fun).to.triggerEvent(@object, 'change:quox', with: [undefined])
    it 'can reach into properties and observe changes to them', ->
      @object.property 'name', dependsOn: 'author.name'
      @object.property 'author'
      @object.author = Serenade(name: "Jonas")
      @object.name
      expect(=> @object.author.name = 'test').to.triggerEvent(@object, 'change:name')
    it 'does not observe changes on objects which are no longer associated', ->
      @object.property 'name', dependsOn: 'author.name'
      @object.property 'author'
      @object.author = Serenade(name: "Jonas")
      oldAuthor = @object.author
      @object.author = Serenade(name: "Peter")
      expect(-> oldAuthor.name = 'test').not.to.triggerEvent(@object, 'change:name')
    it 'does not bleed over between objects with same prototype', ->
      @ctor = ->
      @inst1 = new @ctor()
      @inst2 = new @ctor()
      extend(@ctor.prototype, Properties)
      @ctor.prototype.property 'name', serialize: true
      @inst1.property 'age', serialize: true
      @inst2.property 'height', serialize: true
      expect(Object.keys(@inst1)).to.include('age')
      expect(Object.keys(@inst2)).not.to.include('age')
    it 'can set up default value', ->
      @object.property 'name', default: "foobar"
      expect(@object.name).to.eql("foobar")
      @object.name = "baz"
      expect(@object.name).to.eql("baz")
      @object.name = undefined
      expect(@object.name).to.eql(undefined)
    it 'can set up falsy default values', ->
      @object.property 'name', default: null
      expect(@object.name).to.equal(null)
    it 'ignores default when custom getter given', ->
      @object.property 'name', default: "bar", get: -> "foo"
      expect(@object.name).to.eql("foo")
    it 'automatically sets up previous value as default', ->
      @object.name = "Jonas"
      @object.property 'name'
      expect(@object.name).to.eql("Jonas")
    it 'can be redefined', ->
      @object.property 'name', get: -> "foo"
      @object.property 'name', get: -> "bar"
      expect(@object.name).to.eql("bar")

  describe '.set', ->
    beforeEach ->
      @object.property("foo")
    it 'sets that property', ->
      @object.foo = 23
      expect(@object.foo).to.eql(23)
    it 'triggers a change event', ->
      expect(=> @object.foo = 23).to.triggerEvent(@object, 'change')
    it 'triggers a change event for this property', ->
      expect(=> @object.foo = 23).to.triggerEvent(@object, 'change:foo', with: [23])
    it 'uses a custom setter', ->
      setValue = null
      @object.property 'foo', set: (value) -> setValue = value
      @object.foo = 42
      expect(setValue).to.eql(42)

  describe '.get', ->
    it 'reads an existing property', ->
      @object.foo = 23
      expect(@object.foo).to.eql(23)
    it 'uses a custom getter', ->
      @object.property 'foo', get: -> 42
      expect(@object.foo).to.eql(42)
    it 'runs custom getter in context of object', ->
      @object.first = 'Jonas'
      @object.last = 'Nicklas'
      @object.property 'fullName', get: -> [@first, @last].join(' ')
      expect(@object.fullName).to.eql('Jonas Nicklas')
    it 'binds to dependencies', ->
      @object.property 'first'
      @object.property 'last'
      @object.property 'fullName',
        get: -> @first + " " + @last
        dependsOn: ['first', 'last']
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").to.triggerEvent(@object, 'change:fullName', with: ['Peter Pan'])
    it 'binds to single dependency', ->
      @object.property 'name'
      @object.property 'reverseName',
        get: -> @name.split("").reverse().join("")
        dependsOn: 'name'
      expect(=> @object.name = 'Jonas').to.triggerEvent(@object, 'change:reverseName', with: ['sanoJ'])
