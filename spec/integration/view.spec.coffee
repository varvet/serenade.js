{Serenade} = require '../../src/serenade'

describe 'View', ->
  beforeEach ->
    @setupDom()

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
