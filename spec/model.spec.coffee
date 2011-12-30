{Monkey} = require '../src/monkey'

describe 'Monkey.Model', ->
  describe '#constructor', ->
    it 'sets the given properties', ->
      john = new Monkey.Model(name: 'John', age: 23)
      expect(john.get('age')).toEqual(23)
      expect(john.get('name')).toEqual('John')

    it 'returns the same object if given the same id', ->
      john1 = new Monkey.Model(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Monkey.Model(id: 'j123', age: 46)

      expect(john2.test).toBeTruthy()
      expect(john2.get('age')).toEqual(46)
      expect(john2.get('name')).toEqual('John')

    it 'returns a new object when given a different id', ->
      john1 = new Monkey.Model(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Monkey.Model(id: 'j456', age: 46)

      expect(john2.test).toBeFalsy()
      expect(john2.get('age')).toEqual(46)
      expect(john2.get('name')).toBeUndefined()
  describe '.find', ->
    it 'returns the same object if it has previously been initialized', ->
      john1 = new Monkey.Model(id: 'j123', name: 'John')
      john1.test = true
      john2 = Monkey.Model.find('j123')

      expect(john2.test).toBeTruthy()
      expect(john2.get('name')).toEqual('John')
    context 'with store', ->
      it 'returns a new object and immediately refreshes it from the server', ->
    context 'with cache', ->
      it 'returns the object from cache on cache hit', ->
      it 'returns the object from cache on stale hit', ->
      it 'returns a blank object on cache miss', ->
    context 'with both', ->
      it 'returns the object from cache on cache hit', ->
      it 'returns the object from cache and refreshes it on stale hit', ->
      it 'returns a blank object and refreshes it on cache miss', ->
  describe '.all', ->
    it 'returns the same collection if it has been used previously', ->
    context 'with store', ->
      it 'returns a new collection and immediately refreshes it from the server', ->
    context 'with cache', ->
      it 'returns the collection from cache on cache hit', ->
      it 'returns the collection from cache on stale hit', ->
      it 'returns a blank collection on cache miss', ->
    context 'with both', ->
      it 'returns the collection from cache on cache hit', ->
      it 'returns the collection from cache and refreshes it on stale hit', ->
      it 'returns a blank collection and refreshes it on cache miss', ->
  describe '.belongsTo', ->
    it 'uses the given constructor', ->
    it 'uses the constructor given as a string', ->
    it 'creates a plain object if there is no constructor given', ->
    it 'updates the id property as it changes', ->
    it 'is updated if the id property changes', ->
  describe '.hasMany', ->
    it 'uses the given constructor', ->
    it 'uses the constructor given as a string', ->
    it 'creates plain objects if there is no constructor given', ->
    it 'updates the ids property as it changes', ->
    it 'is updated if the ids property changes', ->
  describe '.property', ->
    context 'with serialize with a string given', ->
      it 'will setup a setter method for that name', ->
  describe '#serialize()', ->
    it 'serializes only the id by default', ->
    it 'serializes any properties marked as serializable', ->
    it 'serializes properties with the given string as key', ->
    it 'serializes a property with the given function', ->
    it 'serializes a belongs to association', ->
    it 'serializes a has many association', ->
    it 'serializes the id of a belongs to association', ->
    it 'serializes the ids of a has many association', ->
