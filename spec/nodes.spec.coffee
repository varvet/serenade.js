{Monkey} = require '../src/monkey'
jsdom = require("jsdom")
fs = require('fs')
jquery = fs.readFileSync("spec/jquery.js").toString()

el = (name, attributes, children) -> new Monkey.AST.Element(name, attributes, children)
prop = (name, value, bound=false, scope="attribute") -> new Monkey.AST.Property(name, value, bound, scope)
text = (value, bound=false) -> new Monkey.AST.TextNode(value, bound)
ins = (command, args, children) -> new Monkey.AST.Instruction(command, args, children)

compile = (actual, model, controller, callback) ->
  runs ->
    jsdom.env
      html: '<body></body>'
      src: [jquery]
      done: (errors, window) ->
        result = actual.compile(window.document, model, controller)
        window.document.body.appendChild(result.element)
        runs ->
          callback(window.$("body"), window.document)
  waits(20)

describe 'Monkey.Element', ->
  describe '#compile', ->
    it 'compiles a simple element', ->
      compile el('div'), {}, {}, (body) ->
        expect(body).toHaveElement('div')

    it 'compiles a simple element with an attribute', ->
      compile el('div', [prop('id', 'foo')]), {}, {}, (body) ->
        expect(body).toHaveElement('div#foo')

    it 'compiles a simple element with attributes', ->
      compile el('div', [prop('id', 'foo'), prop('class', 'bar')]), {}, {}, (body) ->
        expect(body).toHaveElement('div#foo.bar')

    it 'compiles a simple element with a child', ->
      compile el('div', [], [el('p')]), {}, {}, (body) ->
        expect(body).toHaveElement('div > p')

    it 'compiles a simple element with multiple children', ->
      compile el('div', [], [el('p'), el('a', [prop('href', 'foo')])]), {}, {}, (body) ->
        expect(body).toHaveElement('div > a[href=foo]')

    it 'compiles a simple element with a text node child', ->
      compile el('div', [], [text('Monkey')]), {}, {}, (body) ->
        expect(body).toHaveElement('div:contains(Monkey)')

    it 'does not add bound attribute if value is undefined in model', ->
      model = { name: 'jonas' }
      compile el('div', [prop('id', 'foo', true)]), model, {}, (body) ->
        expect(body.find('div').get(0).hasAttribute('id')).toBeFalsy()

    it 'get bound attributes from the model', ->
      model = { name: 'jonas' }
      compile el('div', [prop('id', 'name', true)]), model, {}, (body) ->
        expect(body).toHaveElement('div#jonas')

    it 'get bound style from the model', ->
      model = { color: 'red' }
      compile el('div', [prop('style-color', 'color', true)]), model, {}, (body) ->
        expect(body.find('div').css('color')).toEqual('red')

    it 'get bound text from the model', ->
      model = { name: 'Jonas Nicklas' }
      compile el('div', [], [text('name', true)]), model, {}, (body) ->
        expect(body.find('div')).toHaveText('Jonas Nicklas')

    it 'attaches an event which calls the controller action when triggered', ->
      controller = { iWasClicked: -> @clicked = true }
      compile el('div', [prop('click', 'iWasClicked')]), {}, controller, (body, document) ->
        event = document.createEvent('HTMLEvents')
        event.initEvent('click', true, true)
        body.find('div').get(0).dispatchEvent(event)
        expect(controller.clicked).toBeTruthy()

    it 'attaches an explicit event which calls the controller action when triggered', ->
      controller = { iWasClicked: -> @clicked = true }
      compile el('div', [prop('event-click', 'iWasClicked')]), {}, controller, (body, document) ->
        event = document.createEvent('HTMLEvents')
        event.initEvent('click', true, true)
        body.find('div').get(0).dispatchEvent(event)
        expect(controller.clicked).toBeTruthy()

    it 'changes bound attributes as they are changed', ->
      model = new Monkey.Model
      model.set('name', 'jonas')
      compile el('div', [prop('id', 'name', true)]), model, {}, (body) ->
        expect(body).toHaveElement('div#jonas')
        model.set('name', 'peter')
        expect(body).toHaveElement('div#peter')

    it 'changes bound style as they are changed', ->
      model = new Monkey.Model
      model.set('color', 'red')
      compile el('div', [prop('style-color', 'color', true)]), model, {}, (body) ->
        expect(body.find('div').css('color')).toEqual('red')
        model.set('color', 'blue')
        expect(body.find('div').css('color')).toEqual('blue')

    it 'removes attributes and reattaches them as they are set to undefined', ->
      model = new Monkey.Model
      model.set('name', 'jonas')
      compile el('div', [prop('id', 'name', true)]), model, {}, (body) ->
        expect(body).toHaveElement('div#jonas')
        model.set('name', undefined)
        expect(body.find('div').get(0).hasAttribute('id')).toBeFalsy()
        model.set('name', 'peter')
        expect(body).toHaveElement('div#peter')

    it 'handles value specially', ->
      model = new Monkey.Model
      model.set('name', 'jonas')
      compile el('input', [prop('value', 'name', true)]), model, {}, (body) ->
        body.find('input').val('changed')
        model.set('name', 'peter')
        expect(body.find('input').val()).toEqual('peter')

    it 'changes bound text nodes as they are changed', ->
      model = new Monkey.Model
      model.set('name', 'Jonas Nicklas')
      compile el('div', [], [text('name', true)]), model, {}, (body) ->
        expect(body.find('div')).toHaveText('Jonas Nicklas')
        model.set('name', 'Peter Pan')
        expect(body.find('div')).toHaveText('Peter Pan')

    it 'compiles a collection instruction', ->
      model = { people: [{ name: 'jonas' }, { name: 'peter' }] }

      tree =  el('ul', [], [ins('collection', ['people'], [el('li', [prop('id', 'name', true)])])])
      compile tree, model, {}, (body) ->
        expect(body).toHaveElement('ul > li#jonas')
        expect(body).toHaveElement('ul > li#peter')

    it 'compiles a Monkey.collection in a collection instruction', ->
      model = { people: new Monkey.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

      tree =  el('ul', [], [ins('collection', ['people'], [el('li', [prop('id', 'name', true)])])])
      compile tree, model, {}, (body) ->
        expect(body).toHaveElement('ul > li#jonas')
        expect(body).toHaveElement('ul > li#peter')

    it 'updates a collection dynamically', ->
      model = { people: new Monkey.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

      tree =  el('ul', [], [ins('collection', ['people'], [el('li', [prop('id', 'name', true)])])])
      compile tree, model, {}, (body) ->
        expect(body).toHaveElement('ul > li#jonas')
        expect(body).toHaveElement('ul > li#peter')
        model.people.update([{ name: 'anders' }, { name: 'jimmy' }])
        expect(body).not.toHaveElement('ul > li#jonas')
        expect(body).not.toHaveElement('ul > li#peter')
        expect(body).toHaveElement('ul > li#anders')
        expect(body).toHaveElement('ul > li#jimmy')

    it 'removes item from collection when requested', ->
      model = { people: new Monkey.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

      tree =  el('ul', [], [ins('collection', ['people'], [el('li', [prop('id', 'name', true)])])])
      compile tree, model, {}, (body) ->
        expect(body).toHaveElement('ul > li#jonas')
        expect(body).toHaveElement('ul > li#peter')
        model.people.delete(0)
        expect(body).not.toHaveElement('ul > li#jonas')
        expect(body).toHaveElement('ul > li#peter')

    it 'compiles a view instruction by fetching and compiling the given view', ->
      # TODO: Figure out how to isolate this test from the parser
      Monkey.registerView('test', 'li[id="foo"]')

      tree =  el('ul', [], [ins('view', ['test'])])
      compile tree, {}, {}, (body) ->
        expect(body).toHaveElement('ul > li#foo')

    it 'changes controller in view', ->
      # TODO: Figure out how to isolate this test from the parser
      funked = false
      class TestCon
        funk: -> funked = true

      Monkey.registerView('test', 'li[id="foo" click=funk]')
      Monkey.registerController('test', TestCon)

      tree =  el('ul', [], [ins('view', ['test'])])
      compile tree, {}, {}, (body, document) ->
        event = document.createEvent('HTMLEvents')
        event.initEvent('click', true, true)
        body.find('li#foo').get(0).dispatchEvent(event)

        expect(funked).toBeTruthy()
