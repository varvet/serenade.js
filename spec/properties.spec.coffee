{Monkey} = require '../src/monkey'

describe 'Monkey.Properties', ->
  beforeEach ->
    @object = {}
    Monkey.extend(@object, Monkey.Properties)
    Monkey.extend(@object, Monkey.Events)

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

  describe '.set', ->
    context 'with a sing property', ->
      it 'sets that property', ->
        @object.set('foo', 23)
        expect(@object.get('foo')).toEqual(23)
      it 'triggers a change event', ->
        @object.set('foo', 23)
        expect(@object).toHaveReceivedEvent('change')
      it 'triggers a change event for this property', ->
        @object.set('foo', 23)
        expect(@object).toHaveReceivedEvent('change:foo')
      it 'uses a custom setter', ->
        setValue = null
        @object.property 'foo', set: (value) -> setValue = value
        @object.set('foo', 42)
        expect(setValue).toEqual(42)

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
      @object.set('first', 'Jonas')
      @object.set('last', 'Nicklas')
      @object.property 'fullName',
        get: -> [@get('first'), @get('last')].join(' ')
        dependsOn: ['first', 'last']
      @object.set('first', 'Peter')
      expect(@object).toHaveReceivedEvent('change:fullName')
