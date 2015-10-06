require './../spec_helper'
Serenade = require('../../lib/serenade')

describe 'Basics', ->
  beforeEach ->
    @setupDom()

  it 'compiles a simple element', ->
    @render 'div'
    expect(@body).to.have.element('div')

  it 'compiles multiple root nodes', ->
    @render """
      #foo
      #bar
      #baz
    """
    expect(@body).to.have.element('#foo')
    expect(@body).to.have.element('#bar')
    expect(@body).to.have.element('#baz')

  it 'compiles a simple element with an attribute', ->
    @render 'div[id="foo"]'
    expect(@body).to.have.element('div#foo')

  it 'compiles a simple element with attributes', ->
    @render 'div[id="foo" class="bar"]'
    expect(@body).to.have.element('div#foo.bar')

  it 'compiles a simple element with a child', ->
    @render '''
      div
        p
    '''
    expect(@body).to.have.element('div > p')

  it 'compiles a simple element with multiple children', ->
    @render '''
      div
        p
        a[href="foo"]
    '''
    expect(@body).to.have.element('div > a[href=foo]')

  it 'compiles a simple element with a text node child', ->
    @render '''
      div "Serenade"
    '''
    expect(@body.children[0]).to.have.text("Serenade")

  it 'compiles a simple element with a text node with escaped quotes', ->
    @render '''
      div "hello \\"Serenade\\""
    '''
    expect(@body.children[0]).to.have.text('hello "Serenade"')

  it 'ignores comments', ->
    @render '''
      // Hello
      // From
      div // this
        // view
      // which
        ul // has
          // lots
          li "only text"
          // foo
          p
      // of
      // comments
    '''
    expect(@body.textContent).to.eql('only text')
    expect(@body.children[0].nodeName).to.eql('DIV')
    expect(@body.children[0].children[0].nodeName).to.eql('UL')
    expect(@body.children[0].children[0].children[0].nodeName).to.eql('LI')
    expect(@body.children[0].children[0].children[1].nodeName).to.eql('P')
