require './spec_helper'
Helpers = require '../src/helpers'
{expect} = require('chai')

describe 'Helpers', ->
  describe '.getFunctionName', ->
    it 'prefers model name when given', ->
      obj = { modelName: 'Thingy', name: 'Comment' }
      expect(Helpers.getFunctionName(obj)).to.eql('Thingy')

    it 'returns a name when set', ->
      obj = { name: 'Comment' }
      expect(Helpers.getFunctionName(obj)).to.eql('Comment')

    it 'returns it from an object like to string', ->
      obj = { toString: -> "[object Comment]" }
      expect(Helpers.getFunctionName(obj)).to.eql('Comment')

    it 'returns it from a function like to string', ->
      obj = { toString: -> "function Comment() {}" }
      expect(Helpers.getFunctionName(obj)).to.eql('Comment')
