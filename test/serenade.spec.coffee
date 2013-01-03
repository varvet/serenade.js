require './spec_helper'
{Serenade} = require "../src/serenade"
{expect} = require('chai')

describe "Serenade", ->
  beforeEach -> @setupDom()

  it "can decorate an object with properties", ->
    object = Serenade(name: "Jonas")
    expect(object.name).to.eql("Jonas")
    expect(-> object.name = "John").to.triggerEvent(object, "change:name")

  describe ".view", ->
    it "registers a view object", ->
      Serenade.view("test", "h1#test")
      @body.appendChild Serenade.render("test", {}, {})
      expect(@body).to.have.element("h1#test")

    it "doesn't require model or controller to be given", ->
      Serenade.view("test", "h1#test")
      @body.appendChild Serenade.render("test")
      expect(@body).to.have.element("h1#test")

    it "can be rendered directly", ->
      @body.appendChild Serenade.view("test", "h1#test").render()
      expect(@body).to.have.element("h1#test")

    it "works fine without a name", ->
      @body.appendChild Serenade.view("h1#test").render()
      expect(@body).to.have.element("h1#test")

    it "can be take models as parameters", ->
      model = { id: 'test' }
      @body.appendChild Serenade.view("test", "h1[id=@id]").render(model)
      expect(@body).to.have.element("h1#test")

    it "can be take controllers as parameters", ->
      tested = false
      controller = { test: -> tested = true }
      model = {}
      @body.appendChild Serenade.view("test", "a[event:click=test]").render(model, controller)
      @fireEvent @body.querySelector('a'), 'click'
      expect(tested).to.be.ok

  describe ".format", ->
    it 'reads an existing property normally on a normal object', ->
      @object = { foo: 23 }
      expect(Serenade.format(@object, 'foo')).to.eql(23)
    it 'reads an existing property normally if it is not declared', ->
      @object = Serenade(foo: 23)
      expect(Serenade.format(@object, 'foo')).to.eql(23)
    it 'reads an existing property normally if it is declared without format', ->
      @object = Serenade({})
      @object.property('foo')
      @object.foo = 23
      expect(Serenade.format(@object, 'foo')).to.eql(23)
    it 'converts a property through a given format function', ->
      @object = Serenade({})
      @object.property('foo', format: (x) -> x + 2)
      @object.foo = 23
      expect(Serenade.format(@object, 'foo')).to.eql(25)
    it 'properly assigns the formatters scope', ->
      @object = Serenade({})
      @object.property('bar', get: -> 2)
      @object.property('foo', format: (x) -> x + @bar)
      @object.foo = 23
      expect(Serenade.format(@object, 'foo')).to.eql(25)
