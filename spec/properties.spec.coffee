{Monkey} = require '../src/monkey'

describe 'Monkey.Properties', ->
  beforeEach ->
    @object = {}
    Monkey.extend(@object, Monkey.Properties)

  describe '.collection', ->
    it 'is initialized to a collection', ->
      @object.collection 'numbers'
      expect(@object.numbers.get(0)).toBeUndefined()
      @object.numbers.push(5)
      expect(@object.numbers.get(0)).toEqual(5)



