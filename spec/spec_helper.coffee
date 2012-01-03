{Serenade} = require '../src/serenade'
require('../src/properties')
require('../src/model')
sinon = require('sinon')

compareArrays = (one, two) ->
  fail = true for item, i in one when two[i] isnt item
  one.length is two.length and not fail

beforeEach ->
  Serenade._views = {}
  Serenade._controllers = {}
  Serenade._formats = {}

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
