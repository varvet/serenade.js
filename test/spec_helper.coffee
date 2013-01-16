# load globally so we don't have to load it again and again
root.Build = require('../src/build')
root.Serenade = Build.Serenade

chai = require 'chai'
chai.should()
root.expect = chai.expect
sinon = require('sinon')

isArray = (arr) -> arr and (Array.isArray(arr) or arr.constructor is Serenade.Collection)

compareArrays = (one, two) ->
  if isArray(one) and isArray(two)
    fail = true for item, i in one when not compareArrays(two[i], item)
    one.length is two.length and not fail
  else
    one is two

jsdom = require("jsdom")
fs = require('fs')

beforeEach ->
  Serenade.async = false
  Serenade.unregisterAll()
  Serenade.clearCache()

  @setupDom = ->
    @document = require("jsdom").jsdom(null, null, features: { QuerySelector: true })
    @window = @document.createWindow()
    @body = @document.body
    Serenade.document = @document

  @fireEvent = (element, name) ->
    event = @document.createEvent('HTMLEvents')
    event.initEvent(name, true, true)
    element.dispatchEvent(event)

  @render = (template, model, controller) =>
    @body.appendChild(Serenade.view(template).render(model, controller))

  chai.Assertion::element = (selector, options) ->
    if options and options.count
      actual = @obj.find(selector).length
      @assert actual == options.count, "expected #{options.count} of @{selector}, but there were #{actual}"
    else
      @assert @obj.querySelectorAll(selector).length > 0, "expected #{selector} to occur"

  chai.Assertion::text = (text) ->
    actual = @obj.textContent.trim().replace(/\s/g, ' ')
    @assert actual is text, "expected #{actual} to be #{text}"
  chai.Assertion::attribute = (name) ->
    @assert @obj.hasAttribute(name)
  chai.Assertion::triggerEvent = (event, options={}) ->
    args = null
    count = 0
    fun = (a...) ->
      args = a
      count += 1

    event.bind fun
    @obj()
    event.unbind fun

    @assert count is 1, "event #{event.name} was triggered #{count} times, expected 1"
    if options.with
      @assert compareArrays(args, options.with), "event arguments #{args} do not match expected arguments #{options.with}"
  chai.Assertion::become = (value, done) ->
    count = 0
    test = =>
      result = @obj()
      if result is value
        done()
      else if count > 3
        done(new Error("expected #{result} to become equal to #{value}"))
      else
        count += 1
        setTimeout(test, 5)
    test()

  @sinon = sinon.sandbox.create()

afterEach ->
  @sinon.restore()

root.context = describe
