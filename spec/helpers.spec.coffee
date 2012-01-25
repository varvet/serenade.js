Helpers = require '../src/helpers'

describe 'Helpers', ->
  describe '.getFunctionName', ->
    it 'returns a name when set', ->
      obj = { name: 'Comment' }
      expect(Helpers.getFunctionName(obj)).toEqual('Comment')

    it 'returns it from an object like to string', ->
      obj = { toString: -> "[object Comment]" }
      expect(Helpers.getFunctionName(obj)).toEqual('Comment')

    it 'returns it from a function like to string', ->
      obj = { toString: -> "function Comment() {}" }
      expect(Helpers.getFunctionName(obj)).toEqual('Comment')
