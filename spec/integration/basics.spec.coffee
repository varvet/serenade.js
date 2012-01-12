{Serenade} = require '../../src/serenade'

describe 'Basics', ->
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
