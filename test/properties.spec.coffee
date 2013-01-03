require './spec_helper'
{Serenade} = require '../src/serenade'
{Collection} = require '../src/collection'
{Properties} = require '../src/properties'
{extend} = require '../src/helpers'
{expect} = require('chai')

describe 'Properties', ->
  beforeEach ->
    @object = {}
    extend(@object, Properties)

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
      expect(Object.keys(@inst2.toJSON())).not.to.include('age')
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

  describe '.collection', ->
    it 'is initialized to a collection', ->
      @object.collection 'numbers'
      expect(@object.numbers[0]).to.not.exist
      @object.numbers.push(5)
      expect(@object.numbers[0]).to.eql(5)
    it 'updates the collection on set', ->
      @object.collection 'numbers'
      @object.numbers = [1,2,3]
      expect(@object.numbers[0]).to.eql(1)
    it 'triggers a change event when collection is changed', ->
      @object.collection 'numbers'
      collection = @object.numbers
      expect(-> collection.push(4)).to.triggerEvent(@object, 'change:numbers', with: [@object.numbers])
    it 'passes on the serialize option', ->
      @object.collection 'numbers', serialize: true
      @object.numbers = [1,2,3]
      expect(@object.toJSON()).to.eql(numbers: [1,2,3])
    it 'can reach into collections and observe changes to the entire collection', ->
      @object.property 'authorNames', dependsOn: ['authors', 'authors:name']
      @object.collection 'authors'
      newAuthor = Serenade(name: "Anders")
      expect(=> @object.authors.push(newAuthor)).to.triggerEvent(@object, 'change:authorNames')
    it 'can reach into collections and observe changes to each individual object', ->
      @object.collection 'authors'
      @object.authors.push(Serenade(name: "Bert"))
      @object.property 'authorNames', dependsOn: ['authors', 'authors:name']
      @object.authorNames
      author = @object.authors[0]
      expect(-> author.name = 'test').to.triggerEvent(@object, 'change:authorNames')
    it 'can reach into collections and observe changes to each individual object when defined on prototype', ->
      @object.collection 'authors'
      @object.property 'authorNames', dependsOn: ['authors', 'authors:name']

      @child = Object.create(@object)
      @child.authors.push(Serenade(name: "Bert"))
      @child.authorNames
      author = @child.authors[0]
      expect(-> author.name = 'test').to.triggerEvent(@child, 'change:authorNames')
      expect(-> author.name = 'test').not.to.triggerEvent(@object, 'change:authorNames')
    it 'does not trigger events multiple times when reaching and property is accessed multiple times', ->
      @object.collection 'authors'
      @object.property 'authorNames', dependsOn: ['authors', 'authors:name']
      @object.authors.push(Serenade(name: "Bert"))
      @object.authorNames
      @object.authorNames

      author = @object.authors[0]
      expect(-> author.name = 'test').to.triggerEvent(@object, 'change:authorNames')
    it 'does not observe changes to elements no longer in the collcection', ->
      @object.property 'authorNames', dependsOn: 'authors:name'
      @object.authorNames
      @object.collection 'authors'
      @object.authors.push(Serenade(name: "Bert"))
      oldAuthor = @object.authors[0]
      oldAuthor.schmoo = true
      @object.authors.deleteAt(0)
      expect(-> oldAuthor.name = 'test').not.to.triggerEvent(@object, 'change:authorNames')

  describe '.set', ->
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
    it 'automatically sets up a property for an unkown key', ->
      @object.foo = 42
      expect(@object.foo).to.eql(42)

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
      fun = =>
        @object.first = 'Peter'
        @object.last = 'Pan'
      expect(fun).to.triggerEvent(@object, 'change:fullName', with: ['Peter Pan'])
    it 'binds to single dependency', ->
      @object.property 'name'
      @object.property 'reverseName',
        get: -> @name.split("").reverse().join("")
        dependsOn: 'name'
      expect(=> @object.name = 'Jonas').to.triggerEvent(@object, 'change:reverseName', with: ['sanoJ'])
