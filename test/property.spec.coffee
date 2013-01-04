require './spec_helper'
{Serenade} = require '../src/serenade'
{Collection} = require '../src/collection'
{extend} = require '../src/helpers'
{defineProperty} = require '../src/property'
{expect} = require('chai')

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

  it 'automatically sets up previous value as default', ->
    @object.name = "Jonas"
    defineProperty @object, 'name'
    expect(@object.name).to.eql("Jonas")

  it 'can be redefined', ->
    defineProperty @object, 'name', get: -> "foo"
    defineProperty @object, 'name', get: -> "bar"
    expect(@object.name).to.eql("bar")

  describe 'set', ->
    beforeEach ->
      defineProperty @object, ("foo")

    it 'sets that property', ->
      @object.foo = 23
      expect(@object.foo).to.eql(23)

    it 'triggers a change event', ->
      expect(=> @object.foo = 23).to.triggerEvent(@object.change)

    it 'triggers a change event for this property', ->
      expect(=> @object.foo = 23).to.triggerEvent(@object.change_foo, with: [23])

    it 'uses a custom setter', ->
      setValue = null
      defineProperty @object, 'foo', set: (value) -> setValue = value
      @object.foo = 42
      expect(setValue).to.eql(42)

    it 'consumes assigned functions and makes them getters', ->
      defineProperty @object, 'foo'
      @object.foo = -> 42
      expect(@object.foo).to.eql(42)

  describe 'get', ->
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

  describe 'dependsOn', ->
    it 'binds to dependencies', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: ['first', 'last']
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").to.triggerEvent(@object.change_fullName, with: ['Peter Pan'])

    it 'does not bind to dependencies when none are given', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: []
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").not.to.triggerEvent(@object.change_fullName)

    it 'automatically discovers dependencies with the same object', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'initial', get: -> @first?[0]
      defineProperty @object, 'fullName', get: -> @initial + " " + @last
      @object.last = 'Pan'

      expect(=> @object.first = "Peter").to.triggerEvent(@object.change_fullName)
      expect(=> @object.last = "Smith").to.triggerEvent(@object.change_fullName)
      expect(=> @object.first = "Peter").to.triggerEvent(@object.change_initial)
      expect(=> @object.last = "Smith").not.to.triggerEvent(@object.change_initial)

    it 'binds to single dependency', ->
      defineProperty @object, 'name'
      defineProperty @object, 'reverseName',
        get: -> @name.split("").reverse().join("") if @name
        dependsOn: 'name'
      expect(=> @object.name = 'Jonas').to.triggerEvent(@object.change_reverseName, with: ['sanoJ'])

    it 'can handle circular dependencies', ->
      defineProperty @object, 'foo', dependsOn: 'bar'
      defineProperty @object, 'bar', dependsOn: 'foo'
      fun = => @object.foo = 23
      expect(fun).to.triggerEvent(@object.change_foo)
      expect(fun).to.triggerEvent(@object.change_bar)

    it 'can handle secondary dependencies', ->
      defineProperty @object, 'foo', dependsOn: 'quox'
      defineProperty @object, 'bar', dependsOn: ['quox']
      defineProperty @object, 'quox', dependsOn: ['bar', 'foo']
      fun = => @object.foo = 23
      expect(fun).to.triggerEvent(@object.change_foo, with: [23])
      expect(fun).to.triggerEvent(@object.change_bar, with: [undefined])
      expect(fun).to.triggerEvent(@object.change_quox, with: [undefined])

    it 'can reach into properties and observe changes to them', ->
      defineProperty @object, 'name', dependsOn: 'author.name'
      defineProperty @object, 'author'
      @object.author = Serenade(name: "Jonas")
      expect(=> @object.author.name = 'test').to.triggerEvent(@object.change_name)

    it 'can depend on properties which reach into other properties', ->
      defineProperty @object, 'reverseName', dependsOn: 'name', get: -> @name.reverse() if @name
      defineProperty @object, 'name', dependsOn: 'author.name'
      defineProperty @object, 'author'
      @object.author = Serenade(name: "Jonas")
      expect(=> @object.author.name = 'test').to.triggerEvent(@object.change_reverseName)

    it 'does not observe changes on objects which are no longer associated', ->
      defineProperty @object, 'name', dependsOn: 'author.name'
      defineProperty @object, 'author'
      @object.author = Serenade(name: "Jonas")
      oldAuthor = @object.author
      @object.author = Serenade(name: "Peter")
      expect(-> oldAuthor.name = 'test').not.to.triggerEvent(@object.change_name)

  describe "default", ->
    it 'can set up default value', ->
      defineProperty @object, 'name', default: "foobar"
      expect(@object.name).to.eql("foobar")
      @object.name = "baz"
      expect(@object.name).to.eql("baz")
      @object.name = undefined
      expect(@object.name).to.eql(undefined)

    it 'can set up falsy default values', ->
      defineProperty @object, 'name', default: null
      expect(@object.name).to.equal(null)

    it 'ignores default when custom getter given', ->
      defineProperty @object, 'name', default: "bar", get: -> "foo"
      expect(@object.name).to.eql("foo")
