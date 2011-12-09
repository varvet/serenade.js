{Monkey} = require '../src/monkey'
require('../src/events')

originalTrigger = Monkey.Events.trigger
Monkey.Events.trigger = (name) ->
  @_triggeredEvents or= []
  @_triggeredEvents.push(name)
  originalTrigger.apply(this, arguments)

require('../src/nodes')
require('../src/lexer')
require('../src/properties')
require('../src/model')
require('../src/view')
require('../src/collection')

beforeEach ->
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
    toHaveReceivedEvent: (name) -> name in @actual._triggeredEvents

root.context = describe
