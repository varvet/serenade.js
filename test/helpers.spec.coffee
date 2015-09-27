require './spec_helper'
helpers = require("../lib/helpers")

describe 'Helpers', ->
  describe ".capitalize", ->
    it "capitalizes a word", ->
      expect(helpers.capitalize("word")).to.eql("Word")
    it "does nothing with already capitalized words", ->
      expect(helpers.capitalize("Word")).to.eql("Word")

  describe ".merge", ->
    it "merges multiple objects without affecting any of them", ->
      a = { foo: 123, bar: "bar" }
      b = { foo: 33, quox: "quox" }
      c = { quox: "xo", monkey: 22 }

      d = helpers.merge(a, b, c)

      expect(a).to.eql({ foo: 123, bar: "bar" })
      expect(b).to.eql({ foo: 33, quox: "quox" })
      expect(c).to.eql({ quox: "xo", monkey: 22 })
      expect(d).to.eql({ bar: "bar", foo: 33, quox: "xo", monkey: 22 })

    it "preserves attribute metadata", ->
      a = {}
      b = {}

      Object.defineProperty(a, "foo", enumerable: true, value: 123, writable: false)
      Object.defineProperty(b, "bar", enumerable: true, get: -> 22)

      c = helpers.merge(a, b)

      expect(Object.getOwnPropertyDescriptor(c, "foo").writable).to.equal(false)

      expect(c.foo).to.equal(123)
      expect(c.bar).to.equal(22)

    it "only copies enumerable properties", ->
      a = {}
      b = {}

      Object.defineProperty(a, "foo", enumerable: false, value: 123, writable: false)
      Object.defineProperty(b, "bar", enumerable: false, get: -> 22)

      c = helpers.merge(a, b)

      expect(c.foo).to.equal(undefined)
      expect(c.bar).to.equal(undefined)

