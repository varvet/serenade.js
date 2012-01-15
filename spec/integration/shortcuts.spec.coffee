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

  it 'is overridden by explicitly given id', ->
    @render '#jonas[id="peter"]'
    expect(@body).not.toHaveElement('div#jonas')
    expect(@body).toHaveElement('div#peter')

  it 'is joined with explicitly given classes', ->
    @render '.jonas[class="peter"]'
    expect(@body).toHaveElement('div.peter.jonas')

  it 'updates multiple classes with short form as the class attribute changes', ->
    model = new Serenade.Model( names: ['jonas', 'peter'] )
    @render 'div.quack[class=names]', model
    expect(@body).toHaveElement('div.quack.jonas.peter')
    model.set('names', undefined)
    expect(@body).toHaveElement('div.quack')
    expect(@body).not.toHaveElement('div.jonas')
    expect(@body).not.toHaveElement('div.peter')
    model.set('names', 'jonas')
    expect(@body).toHaveElement('div.jonas')
    model.set('names', ['harry', 'jonas'])
    expect(@body).toHaveElement('div.harry.jonas')
