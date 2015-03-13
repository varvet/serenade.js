require './spec_helper'
{ capitalize } = require("../lib/helpers")

describe 'Helpers', ->
  describe ".capitalize", ->
    it "capitalizes a word", ->
      expect(capitalize("word")).to.eql("Word")
    it "does nothing with already capitalized words", ->
      expect(capitalize("Word")).to.eql("Word")
