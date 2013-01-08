require './spec_helper'

describe 'Helpers', ->
  describe ".capitalize", ->
    it "capitalizes a word", ->
      expect(Build.capitalize("word")).to.eql("Word")
    it "does nothing with already capitalized words", ->
      expect(Build.capitalize("Word")).to.eql("Word")
