require "./spec_helper"
Serenade = require("../lib/serenade")

describe "Serenade", ->
  beforeEach -> @setupDom()

  it "can decorate an object with properties", ->
    object = Serenade(name: "Jonas")
    expect(object.name).to.eql("Jonas")
    expect(-> object.name = "John").to.emit(object["@name"])

  it "can decorate an object which has an enumerable constructor property", ->
    object = Serenade(constructor: "Jonas")
    expect(object.constructor).to.eql("Jonas")
    expect(-> object.constructor = "John").to.emit(object["@constructor"])

  describe ".template", ->
    it "returns a template", ->
      context = { id: "test" }
      fragment = Serenade.template("h1[id=id]").render(context)
      @body.appendChild(fragment)
      expect(@body).to.have.element("h1#test")
