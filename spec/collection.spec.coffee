{Monkey} = require '../src/monkey'

describe 'Monkey.Collection', ->
  describe '#get', ->
    it 'gets an item from the collection', ->
      collection = new Monkey.Collection(['a', 'b', 'c'])
      expect(collection.get(0)).toEqual('a')
      expect(collection.get(1)).toEqual('b')
      expect(collection.get(2)).toEqual('c')

  describe '#set', ->
    it 'gets an item in the collection', ->
      collection = new Monkey.Collection(['a', 'b', 'c'])
      expect(collection.get(0)).toEqual('a')
      collection.set(0, 'changed')
      expect(collection.get(0)).toEqual('changed')
    it 'triggers a change event', ->
      changed = false
      collection = new Monkey.Collection(['a', 'b', 'c'])
      collection.bind('change', -> changed = true)
      collection.set(0, 'changed')
      expect(changed).toBeTruthy()
    it 'triggers a specific change event', ->
      changed = false
      collection = new Monkey.Collection(['a', 'b', 'c'])
      collection.bind('change:1', -> changed = true)
      collection.set(1, 'changed')
      expect(changed).toBeTruthy()

  describe '#push', ->
    it 'adds an item to the collection'
