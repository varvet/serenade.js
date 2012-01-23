{Cache} = require '../src/cache'
{Serenade} = require '../src/serenade'

describe 'Cache', ->
  beforeEach ->
    class CTOR
      constructor: (@attributes) ->
    @ctor = CTOR

  describe '.get', ->
    it 'returns undefined when nothing has been cached', ->
      @ctor.localStorage = true
      expect(Cache.get(@ctor, 4)).toBeUndefined()
    it 'retrieves an object from the identity map', ->
      obj = {}
      Cache.set(@ctor, 4, obj)
      expect(Cache.get(@ctor, 4)).toEqual(obj)
    it 'retrieves an object from the identity map even if it is stored', ->
      @ctor.localStorage = true
      obj = {}
      Cache.store(@ctor, 4, 'testing')
      Cache.set(@ctor, 4, obj)
      expect(Cache.get(@ctor, 4)).toEqual(obj)
    it 'returns undefined if the object is stored but local storage is not set', ->
      Cache.store(@ctor, 4, 'testing')
      expect(Cache.get(@ctor, 4)).toBeUndefined()
    it 'returns the object from cache and inits it with the constructor', ->
      @ctor.localStorage = true
      Cache.store(@ctor, 4, { test: 'foo' })
      expect(Cache.get(@ctor, 4).attributes.test).toEqual('foo')
      expect(Cache.get(@ctor, 4).constructor).toEqual(@ctor)

  describe '.store', ->
    it 'stores an object in the local storage engine', ->
      Cache.store(@ctor, 5, 12345)
      expect(Cache._storage.getItem('CTOR_5')).toEqual('12345')

    it 'uses a serialize function', ->
      Cache.store(@ctor, 5, { serialize: -> 456 })
      expect(Cache._storage.getItem('CTOR_5')).toEqual('456')

    it 'represents the result as JSON', ->
      Cache.store(@ctor, 5, { serialize: -> { test: 'foo' }})
      expect(JSON.parse(Cache._storage.getItem('CTOR_5')).test).toEqual('foo')

  describe '.retrieve', ->
    it 'retrieves an object from the local storage engine and inits it with constructor', ->
      @ctor.localStorage = true
      Cache._storage.setItem('CTOR_5', '12345')
      expect(Cache.retrieve(@ctor, 5).attributes).toEqual(12345)
    it 'returns undefined if local storage is disabled', ->
      @ctor.localStorage = false
      Cache._storage.setItem('CTOR_5', '12345')
      expect(Cache.retrieve(@ctor, 5)).toBeUndefined()
