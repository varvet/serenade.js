{Monkey} = require '../src/monkey'

describe 'Monkey.Collection', ->
  beforeEach ->
    @collection = new Monkey.Collection(['a', 'b', 'c'])

  describe '#get', ->
    it 'gets an item from the collection', ->
      expect(@collection.get(0)).toEqual('a')
      expect(@collection.get(1)).toEqual('b')
      expect(@collection.get(2)).toEqual('c')

  describe '#set', ->
    it 'gets an item in the collection', ->
      expect(@collection.get(0)).toEqual('a')
      @collection.set(0, 'changed')
      expect(@collection.get(0)).toEqual('changed')
    it 'triggers a change event', ->
      changed = false
      @collection.bind('change', -> changed = true)
      @collection.set(0, 'changed')
      expect(changed).toBeTruthy()
    it 'triggers a specific change event', ->
      changed = false
      @collection.bind('change:1', -> changed = true)
      @collection.set(1, 'changed')
      expect(changed).toBeTruthy()
    it 'triggers a set event', ->
      changed = false
      @collection.bind('set', -> changed = true)
      @collection.set(1, 'changed')
      expect(changed).toBeTruthy()

  describe '#update', ->
    it 'updates length', ->
      @collection.update([1,2])
      expect(@collection.length).toEqual(2)

  describe '#push', ->
    it 'adds an item to the collection', ->
      @collection.push('g')
      expect(@collection.get(3)).toEqual('g')
    it 'triggers a change event', ->
      changed = false
      @collection.bind('change', -> changed = true)
      @collection.push('g')
      expect(changed).toBeTruthy()
    it 'triggers an add event', ->
      added = false
      @collection.bind('add', -> added = true)
      @collection.push('g')
      expect(added).toBeTruthy()
