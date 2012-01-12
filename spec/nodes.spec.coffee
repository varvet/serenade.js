{Serenade} = require '../src/serenade'

describe 'Nodes.compile', ->
  beforeEach ->
    @setupDom()

  it 'compiles a simple element', ->
    @render 'div'
    expect(@body).toHaveElement('div')

  it 'compiles a simple element with an attribute', ->
    @render 'div[id="foo"]'
    expect(@body).toHaveElement('div#foo')

  it 'compiles a simple element with attributes', ->
    @render 'div[id="foo" class="bar"]'
    expect(@body).toHaveElement('div#foo.bar')

  it 'compiles a simple element with a child', ->
    @render '''
      div
        p
    '''
    expect(@body).toHaveElement('div > p')

  it 'compiles a simple element with multiple children', ->
    @render '''
      div
        p
        a[href="foo"]
    '''
    expect(@body).toHaveElement('div > a[href=foo]')

  it 'compiles a simple element with a text node child', ->
    @render '''
      div "Serenade"
    '''
    expect(@body).toHaveElement('div:contains(Serenade)')

  it 'does not add bound attribute if value is undefined in model', ->
    model = { name: 'jonas' }
    @render 'div[id=foo]', model
    expect(@body.find('div')).not.toHaveAttribute('id')

  it 'get bound attributes from the model', ->
    model = { name: 'jonas' }
    @render 'div[id=name]', model
    expect(@body).toHaveElement('div#jonas')

  it 'get bound style from the model', ->
    model = { name: 'red' }
    @render 'div[style:color=name]', model
    expect(@body.find('div').css('color')).toEqual('red')

  it 'get bound text from the model', ->
    model = { name: 'Jonas Nicklas' }
    @render 'div name', model
    expect(@body.find('div')).toHaveText('Jonas Nicklas')

  it 'attaches an event which calls the controller action when triggered', ->
    controller = { iWasClicked: -> @clicked = true }
    @render 'div[event:click=iWasClicked]', {}, controller
    @fireEvent @body.find('div').get(0), 'click'
    expect(controller.clicked).toBeTruthy()

  it 'changes bound attributes as they are changed', ->
    model = new Serenade.Model
    model.set('name', 'jonas')
    @render 'div[id=name]', model
    expect(@body).toHaveElement('div#jonas')
    model.set('name', 'peter')
    expect(@body).toHaveElement('div#peter')

  it 'changes bound style as they are changed', ->
    model = new Serenade.Model
    model.set('name', 'red')
    @render 'div[style:color=name]', model
    expect(@body.find('div').css('color')).toEqual('red')
    model.set('name', 'blue')
    expect(@body.find('div').css('color')).toEqual('blue')

  it 'removes attributes and reattaches them as they are set to undefined', ->
    model = new Serenade.Model
    model.set('name', 'jonas')
    @render 'div[id=name]', model
    expect(@body).toHaveElement('div#jonas')
    model.set('name', undefined)
    expect(@body.find('div')).not.toHaveAttribute('id')
    model.set('name', 'peter')
    expect(@body).toHaveElement('div#peter')

  it 'handles value specially', ->
    model = new Serenade.Model
    model.set('name', 'jonas')
    @render 'input[value=name]', model
    @body.find('input').val('changed')
    model.set('name', 'peter')
    expect(@body.find('input').val()).toEqual('peter')

  it 'changes bound text nodes as they are changed', ->
    model = new Serenade.Model
    model.set('name', 'Jonas Nicklas')
    @render 'div name', model
    expect(@body.find('div')).toHaveText('Jonas Nicklas')
    model.set('name', 'Peter Pan')
    expect(@body.find('div')).toHaveText('Peter Pan')

  it 'compiles a collection instruction', ->
    model = { people: [{ name: 'jonas' }, { name: 'peter' }] }

    @render '''
      ul
        - collection "people"
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')

  it 'compiles a Serenade.collection in a collection instruction', ->
    model = { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

    @render '''
      ul
        - collection "people"
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')

  it 'updates a collection dynamically', ->
    model = { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

    @render '''
      ul
        - collection "people"
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')
    model.people.update([{ name: 'anders' }, { name: 'jimmy' }])
    expect(@body).not.toHaveElement('ul > li#jonas')
    expect(@body).not.toHaveElement('ul > li#peter')
    expect(@body).toHaveElement('ul > li#anders')
    expect(@body).toHaveElement('ul > li#jimmy')

  it 'removes item from collection when requested', ->
    model = { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

    @render '''
      ul
        - collection "people"
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')
    model.people.deleteAt(0)
    expect(@body).not.toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')

  it 'compiles a view instruction by fetching and compiling the given view', ->
    Serenade.registerView('test', 'li[id="foo"]')
    @render '''
      ul
        - view "test"
    '''
    expect(@body).toHaveElement('ul > li#foo')

  it 'changes controller in view', ->
    funked = false
    class TestCon
      funk: -> funked = true

    Serenade.registerView('test', 'li[id="foo" event:click=funk]')
    Serenade.registerController('test', TestCon)

    @render '''
      ul
        - view "test"
    '''
    @fireEvent @body.find('li#foo').get(0), 'click'

    expect(funked).toBeTruthy()

  it 'falls back to same controller if none is set up', ->
    funked = false
    class TestCon
      funk: -> funked = true

    Serenade.registerView('test', 'li[id="foo" event:click=funk]')

    @render '''
      ul
        - view "test"
    ''', {}, new TestCon()
    @fireEvent @body.find('li#foo').get(0), 'click'

    expect(funked).toBeTruthy()
