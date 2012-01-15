{Serenade} = require '../../src/serenade'
{Lexer} = require '../../src/lexer'

describe 'Shortcuts', ->
  beforeEach ->
    @setupDom()

  it 'compiles an element with an id', ->
    @render 'div#jonas'
    expect(@body).toHaveElement('div#jonas')

  it 'compiles an element with a class', ->
    @render 'div.jonas'
    expect(@body).toHaveElement('div.jonas')

  it 'compiles an element with multiple classes', ->
    @render 'div.jonas.peter.pan'
    expect(@body).toHaveElement('div.jonas.peter.pan')

  it 'compiles an element with id and classes', ->
    @render 'div#jonas.peter.pan'
    expect(@body).toHaveElement('div#jonas.peter.pan')

  it 'compiles an id without an explicit element name into a div', ->
    @render '#jonas'
    expect(@body).toHaveElement('div#jonas')

  it 'compiles a class without an explicit element name into a div', ->
    @render '.jonas'
    expect(@body).toHaveElement('div.jonas')

  it 'compiles multiple classes without an explicit element name into a div', ->
    @render '.jonas.peter.pan'
    expect(@body).toHaveElement('div.jonas.peter.pan')

