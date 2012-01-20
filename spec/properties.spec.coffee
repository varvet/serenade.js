{Serenade} = require '../src/serenade'
{Collection} = require '../src/collection'
{extend} = require '../src/helpers'

describe 'Serenade.Properties', ->
  extended = (obj={}) ->
    extend(obj, Serenade.Properties)
    obj

  beforeEach ->
    @object = extended()

  describe '.property', ->
    describe 'with serialize with a string given', ->
      it 'will setup a setter method for that name', ->
        @object.property 'fooBar', serialize: 'foo_bar'
        @object.set('foo_bar', 56)
        expect(@object.get('foo_bar')).toEqual(56)
        expect(@object.get('fooBar')).toEqual(56)
      it 'can handle circular dependencies', ->
        @object.property 'foo', dependsOn: 'bar'
        @object.property 'bar', dependsOn: 'foo'
        @object.set('foo', 23)
        expect(@object).toHaveReceivedEvent('change:foo')
        expect(@object).toHaveReceivedEvent('change:bar')
      it 'can handle secondary dependencies', ->
        @object.property 'foo', dependsOn: 'quox'
        @object.property 'bar', dependsOn: ['quox']
        @object.property 'quox', dependsOn: ['bar', 'foo']
        @object.set('foo', 23)
        expect(@object).toHaveReceivedEvent('change:foo')
        expect(@object).toHaveReceivedEvent('change:bar')
        expect(@object).toHaveReceivedEvent('change:quox')
      it 'can reach into properties and observe changes to them', ->
        @object.property 'name', dependsOn: 'author.name'
        @object.property 'author'
        @object.set(author: extended())
        @object.get('author').set(name: 'test')

        expect(@object).toHaveReceivedEvent('change:name')
      it 'does not observe changes on objects which are no longer associated', ->
        @object.property 'name', dependsOn: 'author.name'
        @object.property 'author'
        @object.set(author: extended())
        oldAuthor = @object.get('author')
        @object.set(author: extended())
        oldAuthor.set(name: 'test')
        expect(@object).not.toHaveReceivedEvent('change:name')

      it 'does not bleed over between objects with same prototype', ->
        @ctor = ->
        @inst1 = new @ctor()
        @inst2 = new @ctor()
        extend(@ctor.prototype, Serenade.Properties)
        @ctor.prototype.property 'name', serialize: true
        @inst1.property 'age', serialize: true
        @inst2.property 'height', serialize: true
        expect(Object.keys(@inst2.serialize())).not.toContain('age')

  describe '.collection', ->
    it 'is initialized to a collection', ->
      @object.collection 'numbers'
      expect(@object.numbers.get(0)).toBeUndefined()
      @object.numbers.push(5)
      expect(@object.numbers.get(0)).toEqual(5)
    it 'updates the collection on set', ->
      @object.collection 'numbers'
      @object.set('numbers', [1,2,3])
      expect(@object.get('numbers').get(0)).toEqual(1)
    it 'triggers a change event when collection is changed', ->
      @object.collection 'numbers'
      @object.get('numbers').push(4)
      expect(@object).toHaveReceivedEvent('change:numbers', with: [@object.get('numbers')])

  describe '.set', ->
    describe 'with a single property', ->
      it 'sets that property', ->
        @object.set('foo', 23)
        expect(@object.get('foo')).toEqual(23)
      it 'triggers a change event', ->
        @object.set('foo', 23)
        expect(@object).toHaveReceivedEvent('change')
      it 'triggers a change event for this property', ->
        @object.set('foo', 23)
        expect(@object).toHaveReceivedEvent('change:foo', with: [23])
      it 'uses a custom setter', ->
        setValue = null
        @object.property 'foo', set: (value) -> setValue = value
        @object.set('foo', 42)
        expect(setValue).toEqual(42)
    describe 'with multiple properties', ->
      it 'sets those property', ->
        @object.set(foo: 23, bar: 56)
        expect(@object.get('foo')).toEqual(23)
        expect(@object.get('bar')).toEqual(56)
      it 'triggers a change event', ->
        @object.set(foo: 23, bar: 56)
        expect(@object).toHaveReceivedEvent('change')
      it 'triggers a change event for each property', ->
        @object.set(foo: 23, bar: 56)
        expect(@object).toHaveReceivedEvent('change:foo', with: [23])
        expect(@object).toHaveReceivedEvent('change:bar', with: [56])
      it 'uses a custom setter', ->
        setValue = null
        @object.property 'foo', set: (value) -> setValue = value
        @object.set(foo: 42, bar: 12)
        expect(setValue).toEqual(42)
        expect(@object.get('bar')).toEqual(12)

  describe '.get', ->
    it 'reads an existing property', ->
      @object.set('foo', 23)
      expect(@object.get('foo')).toEqual(23)
    it 'uses a custom getter', ->
      @object.property 'foo', get: -> 42
      expect(@object.get('foo')).toEqual(42)
    it 'runs custom getter in context of object', ->
      @object.set('first', 'Jonas')
      @object.set('last', 'Nicklas')
      @object.property 'fullName', get: -> [@get('first'), @get('last')].join(' ')
      expect(@object.get('fullName')).toEqual('Jonas Nicklas')
    it 'binds to dependencies', ->
      @object.property 'fullName',
        get: -> 'derp'
        dependsOn: ['first', 'last']
      @object.set('first', 'Peter')
      expect(@object).toHaveReceivedEvent('change:fullName', with: ['derp'])
    it 'binds to single dependency', ->
      @object.property 'reverseName',
        get: -> 'reverse!'
        dependsOn: 'name'
      @object.set('name', 'Jonas')
      expect(@object).toHaveReceivedEvent('change:reverseName', with: ['reverse!'])

  describe '.format', ->
    it 'reads an existing property normally if it is not declared', ->
      @object.set('foo', 23)
      expect(@object.format('foo')).toEqual(23)
    it 'reads an existing property normally if it is declared without format', ->
      @object.property('foo')
      @object.set('foo', 23)
      expect(@object.format('foo')).toEqual(23)
    it 'converts a property through a given format function', ->
      @object.property('foo', format: (x) -> x + 2)
      @object.set('foo', 23)
      expect(@object.format('foo')).toEqual(25)
    it 'uses a globally defined format function', ->
      Serenade.registerFormat('plusTwo', (x) -> x + 2)
      @object.property('foo', format: 'plusTwo')
      @object.set('foo', 23)
      expect(@object.format('foo')).toEqual(25)

  describe '.serialize', ->
    it 'serializes any properties marked as serializable', ->
      @object.property('foo', serialize: true)
      @object.property('barBaz', serialize: true)
      @object.property('quox')
      @object.set(foo: 23, barBaz: 'quack', quox: 'schmoo', other: 55)
      serialized = @object.serialize()
      expect(serialized.foo).toEqual(23)
      expect(serialized.barBaz).toEqual('quack')
      expect(serialized.quox).toBeUndefined()
      expect(serialized.other).toBeUndefined()
    it 'serializes properties with the given string as key', ->
      @object.property('foo', serialize: true)
      @object.property('barBaz', serialize: 'bar_baz')
      @object.property('quox')
      @object.set(foo: 23, barBaz: 'quack', quox: 'schmoo', other: 55)
      serialized = @object.serialize()
      expect(serialized.foo).toEqual(23)
      expect(serialized.bar_baz).toEqual('quack')
      expect(serialized.barBaz).toBeUndefined()
      expect(serialized.quox).toBeUndefined()
      expect(serialized.other).toBeUndefined()
    it 'serializes a property with the given function', ->
      @object.property('foo', serialize: true)
      @object.property('barBaz', serialize: -> ['bork', @get('foo').toUpperCase()])
      @object.property('quox')
      @object.set(foo: 'fooy', barBaz: 'quack', quox: 'schmoo', other: 55)
      serialized = @object.serialize()
      expect(serialized.foo).toEqual('fooy')
      expect(serialized.bork).toEqual('FOOY')
      expect(serialized.barBaz).toBeUndefined()
      expect(serialized.quox).toBeUndefined()
      expect(serialized.other).toBeUndefined()
    it 'serializes an object which has a serialize function', ->
      @object.property('foo', serialize: true)
      @object.set(foo: { serialize: -> 'from serialize' })
      serialized = @object.serialize()
      expect(serialized.foo).toEqual('from serialize')
    it 'serializes an array of objects which have a serialize function', ->
      @object.property('foo', serialize: true)
      @object.set(foo: [{ serialize: -> 'from serialize' }, {serialize: -> 'another'}, "normal"])
      serialized = @object.serialize()
      expect(serialized.foo[0]).toEqual('from serialize')
      expect(serialized.foo[1]).toEqual('another')
      expect(serialized.foo[2]).toEqual('normal')
    it 'serializes a Serenade.Collection by virtue of it having a serialize method', ->
      @object.property('foo', serialize: true)
      collection = new Collection([{ serialize: -> 'from serialize' }, {serialize: -> 'another'}, "normal"])
      @object.set(foo: collection)
      serialized = @object.serialize()
      expect(serialized.foo[0]).toEqual('from serialize')
      expect(serialized.foo[1]).toEqual('another')
      expect(serialized.foo[2]).toEqual('normal')
