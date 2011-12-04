{Monkey} = require '../src/monkey'
jsdom = require("jsdom")
fs = require('fs')
jquery = fs.readFileSync("spec/jquery.js").toString()

el = (name, attributes, children) -> new Monkey.Element(name, attributes, children)
attr = (name, value, bound=false) -> new Monkey.Attribute(name, value, bound)
text = (value, bound=false) -> new Monkey.TextNode(value, bound)

compile = (actual, model, controller, callback) ->
  runs ->
    jsdom.env
      html: '<body></body>'
      src: [jquery]
      done: (errors, window) ->
        result = actual.compile(window.document, model, controller)
        window.$('body').append(result)
        runs ->
          callback(window.$("body"))
  waits(20)

describe 'Monkey.Element', ->
  describe '#compile', ->
    it 'compiles a simple element', ->
      compile el('div'), {}, {}, (body) ->
        expect(body).toHaveElement('div')

    it 'compiles a simple element with an attribute', ->
      compile el('div', [attr('id', 'foo')]), {}, {}, (body) ->
        expect(body).toHaveElement('div#foo')

    it 'compiles a simple element with attributes', ->
      compile el('div', [attr('id', 'foo'), attr('class', 'bar')]), {}, {}, (body) ->
        expect(body).toHaveElement('div#foo.bar')

    it 'compiles a simple element with a child', ->
      compile el('div', [], [el('p')]), {}, {}, (body) ->
        expect(body).toHaveElement('div > p')

    it 'compiles a simple element with multiple children', ->
      compile el('div', [], [el('p'), el('a', [attr('href', 'foo')])]), {}, {}, (body) ->
        expect(body).toHaveElement('div > a[href=foo]')

    it 'compiles a simple element with a text node child', ->
      compile el('div', [], [text('Monkey')]), {}, {}, (body) ->
        expect(body).toHaveElement('div:contains(Monkey)')

    it 'does not add bound attribute if value is undefined in model', ->
      model = { name: 'jonas' }
      compile el('div', [attr('id', 'foo', true)]), model, {}, (body) ->
        expect(body.find('div').get(0).hasAttribute('id')).toBeFalsy()

    it 'get bound attributes from the model', ->
      model = { name: 'jonas' }
      compile el('div', [attr('id', 'name', true)]), model, {}, (body) ->
        expect(body).toHaveElement('div#jonas')

    it 'get bound text from the model', ->
      model = { name: 'Jonas Nicklas' }
      compile el('div', [], [text('name', true)]), model, {}, (body) ->
        expect(body.find('div')).toHaveText('Jonas Nicklas')
