{Serenade} = require '../../src/serenade'
{Lexer} = require '../../src/lexer'

describe 'Shortcuts', ->
  beforeEach ->
    @setupDom()

  it 'compiles an element with an id', ->
    @render 'div#jonas'
    expect(@body).toHaveElement('div#jonas')

  it 'compiles an id without an explicit element name into a div', ->
    @render '#jonas'
    expect(@body).toHaveElement('div#jonas')
