{Serenade} = require '../src/serenade'
{View} = require '../src/view'
require('../src/properties')
require('../src/model')
sinon = require('sinon')

compareArrays = (one, two) ->
  fail = true for item, i in one when two[i] isnt item
  one.length is two.length and not fail

jsdom = require("jsdom")
fs = require('fs')
jquery = fs.readFileSync("spec/jquery.js").toString()

beforeEach ->
  Serenade._views = {}
  Serenade._controllers = {}
  Serenade._formats = {}

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

  @fireEvent = (element, name) ->
    event = @document.createEvent('HTMLEvents')
    event.initEvent(name, true, true)
    element.dispatchEvent(event)

  @render = (template, model={}, controller={}) =>
    @body.append(new View(template).render(@document, model, controller))

  @addMatchers
    toHaveElement: (selector, options) ->
      if options and options.count
        @actual.find(selector).length == options.count
      else
        @actual.find(selector).length > 0
    toBe: (selector) -> @actual.is(selector)
    toHaveChild: (selector) -> @actual.children(selector).length > 0
    toHaveClass: (className) -> @actual.hasClass(className)
    toHaveText: (text) -> @actual.text().trim().replace(/\s/g, ' ') is text
    toHaveNoMarkup: (html) -> @actual.html().trim().replace(/\s/g, ' ') is ""
    toContainText: (text) -> @actual.text().trim().replace(/\s/g, ' ').match(text)
    toBeVisible: -> @actual.css('display') isnt "none"
    toBeHidden: -> @actual.css('display') is "none"
    toBeEmpty: -> @actual.val() is ""
    toHaveValue: (value) -> @actual.val() is value
    toHaveNumberOfChildren: (number) -> @actual.children().length is parseInt(number)
    toHaveAttribute: (name) -> @actual.get(0).hasAttribute(name)
    toHaveReceivedEvent: (name, options={}) ->
      if options.with
        compareArrays(@actual._triggeredEvents[name], options.with)
      else
        @actual._triggeredEvents.hasOwnProperty(name)

  @sinon = sinon.sandbox.create()

afterEach ->
  @sinon.restore()

root.context = describe
root.recordEvents = true
