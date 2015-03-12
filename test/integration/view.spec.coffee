require './../spec_helper'

describe 'View', ->
  beforeEach ->
    @setupDom()

  it 'compiles a view instruction by fetching and compiling the given view', ->
    Serenade.template('test', 'li[id="foo"]')
    @render '''
      ul
        - view "test"
    '''
    expect(@body).to.have.element('ul > li#foo')

  it 'uses same controller', ->
    funked = false
    class TestCon
      funk: -> funked = true

    Serenade.template('test', 'li[id="foo" event:click=funk]')

    @render '''
      ul
        - view "test"
    ''', {}, new TestCon()
    @fireEvent @body.querySelector('li#foo'), 'click'

    expect(funked).to.be.ok

  it 'compiles a dynamic view instruction and updates it', ->
    model = Serenade(name: "foo")
    Serenade.template('foo', 'li#foo')
    Serenade.template('bar', 'li#bar')
    @render '''
      ul
        - view @name
    ''', model
    expect(@body).to.have.element('ul > li#foo')
    model.name = "bar"
    expect(@body).to.have.element('ul > li#bar')

  it 'does not leak memory when view is changed', ->
    model = Serenade(name: "foo", body: "hello")
    Serenade.template('foo', 'li#foo @body')
    Serenade.template('bar', 'li#bar')
    @render '''
      ul
        - view @name
    ''', model
    model.name = "bar"
    expect(model.body_property.listeners.length).to.eql(0)
