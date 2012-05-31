{Serenade} = require '../src/serenade'
{View} = require '../src/view'
{Cache} = require '../src/cache'
chai = require 'chai'
chai.should()
require('../src/properties')
require('../src/model')
sinon = require('sinon')

compareArrays = (one, two) ->
  fail = true for item, i in one when two[i] isnt item
  one.length is two.length and not fail

jsdom = require("jsdom")
fs = require('fs')
jquery = fs.readFileSync("test/jquery.js").toString()

Cache._storage =
  _items: {}
  getItem: (id) -> @_items[id]
  setItem: (id, item) -> @_items[id] = item.toString()
  clear: -> @_items = {}

beforeEach ->
  Serenade.unregisterAll()
  Serenade.clearCache()

  @setupDom = ->
    html = """
      <html>
        <head>
          <script>
            #{jquery}
          </script>
        </head>
        <body></body>
      </html>

    """
    @document = require("jsdom").jsdom(html, null, src: jquery)
    @window = @document.createWindow()
    @body = @window.$(@document.body)
    Serenade.document = @document

  @fireEvent = (element, name) ->
    event = @document.createEvent('HTMLEvents')
    event.initEvent(name, true, true)
    element.dispatchEvent(event)

  @render = (template, model, controller) =>
    @body.append(Serenade.view(template).render(model, controller))

  chai.Assertion::element = (selector, options) ->
    if options and options.count
      @assert @obj.find(selector).length == options.count
    else
      @assert @obj.find(selector).length > 0

  chai.Assertion::text = (text) ->
    @assert @obj.text().trim().replace(/\s/g, ' ') is text
  chai.Assertion::attribute = (name) ->
    @assert @obj.get(0).hasAttribute(name)
  chai.Assertion::triggerEvent = (object, eventName, options={}) ->
    args = null
    triggered = null
    fun = (a...) ->
      args = a
      triggered = true

    object.bind eventName, fun
    @obj()
    object.unbind eventName, fun

    @assert triggered, "event #{eventName} was not triggered"
    if options.with
      @assert compareArrays(args, options.with), "event arguments #{args} do not match expected arguments #{options.with}"

  @sinon = sinon.sandbox.create()

afterEach ->
  @sinon.restore()

root.context = describe
