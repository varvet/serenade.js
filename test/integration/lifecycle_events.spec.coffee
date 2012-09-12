require "./../spec_helper"
{expect} = require("chai")
{Serenade} = require "../../src/serenade"

describe "Lifecycle events", ->
  beforeEach ->
    @setupDom()

  it "throws an error when given invalid lifecycle event", ->
    expect(=> @render 'div[on:schmoo=run id="thing"]').to.throw(SyntaxError)

  describe "on:load", ->
    it "runs an event when an element is rendered", ->
      ran = false
      model = Serenade(foo: false)
      @render """
        div
          - if @foo
            div[on:load=run id="thing"]
      """, model, run: (model, element) -> ran = element.getAttribute("id")
      expect(ran).to.eql(false)
      model.foo = true
      expect(ran).to.eql("thing")
