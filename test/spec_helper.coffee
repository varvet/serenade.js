{Serenade} = require '../src/serenade'
{View} = require '../src/view'
{Cache} = require '../src/cache'
chai = require 'chai'
chai.should()
require('../src/properties')
require('../src/model')
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

Cache._storage =
  _items: {}
  getItem: (id) -> @_items[id]
  setItem: (id, item) -> @_items[id] = item.toString()
  clear: -> @_items = {}

beforeEach ->
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
    @assert @obj.textContent.trim().replace(/\s/g, ' ') is text
  chai.Assertion::attribute = (name) ->
    @assert @obj.hasAttribute(name)
  chai.Assertion::triggerEvent = (object, eventName, options={}) ->
    args = null
    count = 0
    fun = (a...) ->
      args = a
      count += 1

    object.bind eventName, fun
    @obj()
    object.unbind eventName, fun

    @assert count is 1, "event #{eventName} was triggered #{count} times, expected 1"
    if options.with
      @assert compareArrays(args, options.with), "event arguments #{args} do not match expected arguments #{options.with}"

  @sinon = sinon.sandbox.create()

afterEach ->
  @sinon.restore()

root.context = describe
