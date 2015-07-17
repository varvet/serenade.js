require "./../spec_helper"
Serenade = require('../../lib/serenade')

describe "Lifecycle events", ->
  beforeEach ->
    @setupDom()

  it "throws an error when given invalid lifecycle event", ->
    expect(=> @render 'div[on:schmoo=run id="thing"]').to.throw(SyntaxError)

  describe "on:load", ->
    it "runs an event when an element is rendered", ->
      ran = false
      context = Serenade(foo: false)
      context.run = (element, context) ->
        ran = element.getAttribute("id")
      @render """
        div
          - if @foo
            div[on:load=run id="thing"]
      """, context
      expect(ran).to.eql(false)
      context.foo = true
      expect(ran).to.eql("thing")

  describe "on:unload", ->
    it "runs an event when an element is removed from the DOM", ->
      ran = false
      context = Serenade(foo: true)
      context.run = (element, context) ->
        ran = element.getAttribute("id")
      @render """
        div
          - if @foo
            div
              div[on:unload=run id="thing"]
      """, context
      expect(ran).to.eql(false)
      context.foo = false
      expect(ran).to.eql("thing")
