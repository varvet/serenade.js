require './spec_helper'
Helpers = require '../src/helpers'
{expect} = require('chai')

describe 'Helpers', ->
  describe ".capitalize", ->
    it "capitalizes a word", ->
      expect(Helpers.capitalize("word")).to.eql("Word")
    it "does nothing with already capitalized words", ->
      expect(Helpers.capitalize("Word")).to.eql("Word")
