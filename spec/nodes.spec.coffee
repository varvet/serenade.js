{Monkey} = require '../src/monkey'
jsdom = require("jsdom")
fs = require('fs')
jquery = fs.readFileSync("spec/jquery.js").toString()

el = (name, attributes, children) -> new Monkey.Element(name, attributes, children)
attr = (name, value, bound=false) -> new Monkey.Attribute(name, value, bound)
text = (value, bound=false) -> new Monkey.TextNode(value, bound)

expectToCompileTo = (actual, selector) ->
  runs ->
    jsdom.env
      html: '<body></body>'
      src: [jquery]
      done: (errors, window) ->
        result = actual.compile(window.document, {}, {})
        window.$('body').append(result)
        runs ->
          expect(window.$("body > #{selector}").length).toEqual(1)
  waits(20)

describe 'Monkey.Element', ->
  describe '#compile', ->
    it 'compiles a simple element', ->
      expectToCompileTo(el('div'), 'div')

    it 'compiles a simple element with an attribute', ->
      expectToCompileTo(el('div', [attr('id', 'foo')]), 'div#foo')

    it 'compiles a simple element with attributes', ->
      expectToCompileTo(el('div', [attr('id', 'foo'), attr('class', 'bar')]), 'div#foo.bar')

    it 'compiles a simple element with a child', ->
      expectToCompileTo(el('div', [], [el('p')]), 'div > p')

    it 'compiles a simple element with multiple children', ->
      expectToCompileTo(el('div', [], [el('p'), el('a', [attr('href', 'foo')])]), 'div > a[href=foo]')

    it 'compiles a simple element with a text node child', ->
      expectToCompileTo(el('div', [], [text('Monkey')]), 'div:contains(Monkey)')
