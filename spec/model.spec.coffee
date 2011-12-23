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
    it 'returns an object from the cache if it has previously been cached', ->
      john1 = new Monkey.Model(id: 'j123', name: 'John')
      john1.test = true
      john2 = Monkey.Model.find('j123')

      expect(john2.test).toBeTruthy()
      expect(john2.get('name')).toEqual('John')
