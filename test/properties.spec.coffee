require './spec_helper'
{Serenade} = require '../src/serenade'
{Collection} = require '../src/collection'
{extend} = require '../src/helpers'
{expect} = require('chai')

describe 'Serenade.Properties', ->
  extended = (obj={}) ->
    extend(obj, Serenade.Properties)
    obj

  beforeEach ->
    @object = extended()

  describe '.property', ->
    it 'will setup a setter method for that name', ->
      @object.property 'fooBar', serialize: 'foo_bar'
      @object.set('foo_bar', 56)
      expect(@object.get('foo_bar')).to.eql(56)
      expect(@object.get('fooBar')).to.eql(56)
    it 'can handle circular dependencies', ->
      @object.property 'foo', dependsOn: 'bar'
      @object.property 'bar', dependsOn: 'foo'
      fun = => @object.set('foo', 23)
      expect(fun).to.triggerEvent(@object, 'change:foo')
      expect(fun).to.triggerEvent(@object, 'change:bar')
    it 'can handle secondary dependencies', ->
      @object.property 'foo', dependsOn: 'quox'
      @object.property 'bar', dependsOn: ['quox']
      @object.property 'quox', dependsOn: ['bar', 'foo']
      fun = => @object.set('foo', 23)
      expect(fun).to.triggerEvent(@object, 'change:foo', with: [23])
      expect(fun).to.triggerEvent(@object, 'change:bar', with: [undefined])
      expect(fun).to.triggerEvent(@object, 'change:quox', with: [undefined])
    it 'can reach into properties and observe changes to them', ->
      @object.property 'name', dependsOn: 'author.name'
      @object.property 'author'
      @object.set(author: extended())
      @object.name
      expect(=> @object.author.set('name', 'test')).to.triggerEvent(@object, 'change:name')
    it 'does not observe changes on objects which are no longer associated', ->
      @object.property 'name', dependsOn: 'author.name'
      @object.property 'author'
      @object.set(author: extended())
      oldAuthor = @object.get('author')
      @object.set(author: extended())
      expect(-> oldAuthor.set(name: 'test')).not.to.triggerEvent(@object, 'change:name')
    it 'does not bleed over between objects with same prototype', ->
      @ctor = ->
      @inst1 = new @ctor()
      @inst2 = new @ctor()
      extend(@ctor.prototype, Serenade.Properties)
      @ctor.prototype.property 'name', serialize: true
      @inst1.property 'age', serialize: true
      @inst2.property 'height', serialize: true
      expect(Object.keys(@inst2.serialize())).not.to.include('age')

  describe '.collection', ->
    it 'is initialized to a collection', ->
      @object.collection 'numbers'
      expect(@object.numbers.get(0)).to.not.exist
      @object.numbers.push(5)
      expect(@object.numbers.get(0)).to.eql(5)
    it 'updates the collection on set', ->
      @object.collection 'numbers'
      @object.set('numbers', [1,2,3])
      expect(@object.get('numbers').get(0)).to.eql(1)
    it 'triggers a change event when collection is changed', ->
      @object.collection 'numbers'
      collection = @object.numbers
      expect(-> collection.push(4)).to.triggerEvent(@object, 'change:numbers', with: [@object.numbers])
    it 'passes on the serialize option', ->
      @object.collection 'numbers', serialize: true
      @object.set('numbers', [1,2,3])
      expect(@object.serialize()).to.eql(numbers: [1,2,3])
    it 'can reach into collections and observe changes to the entire collection', ->
      @object.property 'authorNames', dependsOn: ['authors', 'authors:name']
      @object.collection 'authors'
      newAuthor = extended(name: "Anders")
      expect(=> @object.authors.push(newAuthor)).to.triggerEvent(@object, 'change:authorNames')
    it 'can reach into collections and observe changes to each individual object', ->
      @object.collection 'authors'
      @object.authors.push(extended())
      @object.property 'authorNames', dependsOn: ['authors', 'authors:name']
      @object.authorNames
      author = @object.authors.get(0)
      expect(-> author.set(name: 'test')).to.triggerEvent(@object, 'change:authorNames')
    it 'can reach into collections and observe changes to each individual object when defined on prototype', ->
      @object.collection 'authors'
      @object.property 'authorNames', dependsOn: ['authors', 'authors:name']

      @child = Object.create(@object)
      @child.authors.push(extended())
      @child.authorNames
      author = @child.authors.get(0)
      expect(-> author.set(name: 'test')).to.triggerEvent(@child, 'change:authorNames')
      expect(-> author.set(name: 'test')).not.to.triggerEvent(@object, 'change:authorNames')
    it 'does not trigger events multiple times when reaching and property is accessed multiple times', ->
      @object.collection 'authors'
      @object.property 'authorNames', dependsOn: ['authors', 'authors:name']
      @object.authors.push(extended())
      @object.authorNames
      @object.authorNames

      author = @object.authors.get(0)
      expect(-> author.set(name: 'test')).to.triggerEvent(@object, 'change:authorNames')
    it 'does not observe changes to elements no longer in the collcection', ->
      @object.property 'authorNames', dependsOn: 'authors:name'
      @object.authorNames
      @object.collection 'authors'
      @object.authors.push(extended())
      oldAuthor = @object.authors.get(0)
      oldAuthor.schmoo = true
      @object.authors.deleteAt(0)
      expect(-> oldAuthor.set(name: 'test')).not.to.triggerEvent(@object, 'change:authorNames')

  describe '.set', ->
    describe 'with a single property', ->
      it 'sets that property', ->
        @object.set('foo', 23)
        expect(@object.get('foo')).to.eql(23)
      it 'triggers a change event', ->
        expect(=> @object.set('foo', 23)).to.triggerEvent(@object, 'change')
      it 'triggers a change event for this property', ->
        expect(=> @object.set('foo', 23)).to.triggerEvent(@object, 'change:foo', with: [23])
      it 'uses a custom setter', ->
        setValue = null
        @object.property 'foo', set: (value) -> setValue = value
        @object.set('foo', 42)
        expect(setValue).to.eql(42)
    describe 'with multiple properties', ->
      it 'sets those property', ->
        @object.set(foo: 23, bar: 56)
        expect(@object.get('foo')).to.eql(23)
        expect(@object.get('bar')).to.eql(56)
      it 'triggers a change event', ->
        expect(=> @object.set(foo: 23, bar: 56)).to.triggerEvent(@object, 'change')
      it 'triggers a change event for each property', ->
        fun = => @object.set(foo: 23, bar: 56)
        expect(fun).to.triggerEvent(@object, 'change:foo', with: [23])
        expect(fun).to.triggerEvent(@object, 'change:bar', with: [56])
      it 'uses a custom setter', ->
        setValue = null
        @object.property 'foo', set: (value) -> setValue = value
        @object.set(foo: 42, bar: 12)
        expect(setValue).to.eql(42)
        expect(@object.get('bar')).to.eql(12)

  describe '.get', ->
    it 'reads an existing property', ->
      @object.set('foo', 23)
      expect(@object.get('foo')).to.eql(23)
    it 'uses a custom getter', ->
      @object.property 'foo', get: -> 42
      expect(@object.get('foo')).to.eql(42)
    it 'runs custom getter in context of object', ->
      @object.set('first', 'Jonas')
      @object.set('last', 'Nicklas')
      @object.property 'fullName', get: -> [@get('first'), @get('last')].join(' ')
      expect(@object.get('fullName')).to.eql('Jonas Nicklas')
    it 'binds to dependencies', ->
      @object.property 'first'
      @object.property 'last'
      @object.property 'fullName',
        get: -> @first + " " + @last
        dependsOn: ['first', 'last']
      fun = => @object.set(first: 'Peter', last: 'Pan')
      expect(fun).to.triggerEvent(@object, 'change:fullName', with: ['Peter Pan'])
    it 'binds to single dependency', ->
      @object.property 'name'
      @object.property 'reverseName',
        get: -> @name.split("").reverse().join("")
        dependsOn: 'name'
      expect(=> @object.set('name', 'Jonas')).to.triggerEvent(@object, 'change:reverseName', with: ['sanoJ'])

  describe '.format', ->
    it 'reads an existing property normally if it is not declared', ->
      @object.set('foo', 23)
      expect(@object.format('foo')).to.eql(23)
    it 'reads an existing property normally if it is declared without format', ->
      @object.property('foo')
      @object.set('foo', 23)
      expect(@object.format('foo')).to.eql(23)
    it 'converts a property through a given format function', ->
      @object.property('foo', format: (x) -> x + 2)
      @object.set('foo', 23)
      expect(@object.format('foo')).to.eql(25)

  describe '.serialize', ->
    it 'serializes any properties marked as serializable', ->
      @object.property('foo', serialize: true)
      @object.property('barBaz', serialize: true)
      @object.property('quox')
      @object.set(foo: 23, barBaz: 'quack', quox: 'schmoo', other: 55)
      serialized = @object.serialize()
      expect(serialized.foo).to.eql(23)
      expect(serialized.barBaz).to.eql('quack')
      expect(serialized.quox).to.not.exist
      expect(serialized.other).to.not.exist
    it 'serializes properties with the given string as key', ->
      @object.property('foo', serialize: true)
      @object.property('barBaz', serialize: 'bar_baz')
      @object.property('quox')
      @object.set(foo: 23, barBaz: 'quack', quox: 'schmoo', other: 55)
      serialized = @object.serialize()
      expect(serialized.foo).to.eql(23)
      expect(serialized.bar_baz).to.eql('quack')
      expect(serialized.barBaz).to.not.exist
      expect(serialized.quox).to.not.exist
      expect(serialized.other).to.not.exist
    it 'serializes a property with the given function', ->
      @object.property('foo', serialize: true)
      @object.property('barBaz', serialize: -> ['bork', @get('foo').toUpperCase()])
      @object.property('quox')
      @object.set(foo: 'fooy', barBaz: 'quack', quox: 'schmoo', other: 55)
      serialized = @object.serialize()
      expect(serialized.foo).to.eql('fooy')
      expect(serialized.bork).to.eql('FOOY')
      expect(serialized.barBaz).to.not.exist
      expect(serialized.quox).to.not.exist
      expect(serialized.other).to.not.exist
    it 'serializes an object which has a serialize function', ->
      @object.property('foo', serialize: true)
      @object.set(foo: { serialize: -> 'from serialize' })
      serialized = @object.serialize()
      expect(serialized.foo).to.eql('from serialize')
    it 'serializes an array of objects which have a serialize function', ->
      @object.property('foo', serialize: true)
      @object.set(foo: [{ serialize: -> 'from serialize' }, {serialize: -> 'another'}, "normal"])
      serialized = @object.serialize()
      expect(serialized.foo[0]).to.eql('from serialize')
      expect(serialized.foo[1]).to.eql('another')
      expect(serialized.foo[2]).to.eql('normal')
    it 'serializes a Serenade.Collection by virtue of it having a serialize method', ->
      @object.property('foo', serialize: true)
      collection = new Collection([{ serialize: -> 'from serialize' }, {serialize: -> 'another'}, "normal"])
      @object.set(foo: collection)
      serialized = @object.serialize()
      expect(serialized.foo[0]).to.eql('from serialize')
      expect(serialized.foo[1]).to.eql('another')
      expect(serialized.foo[2]).to.eql('normal')
