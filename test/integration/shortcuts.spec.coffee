require './../spec_helper'

describe 'Shortcuts', ->
  beforeEach ->
    @setupDom()

  it 'compiles an element with an id', ->
    @render 'div#jonas'
    expect(@body).to.have.element('div#jonas')

  it 'compiles an element with a class', ->
    @render 'div.jonas'
    expect(@body).to.have.element('div.jonas')

  it 'compiles an element with multiple classes', ->
    @render 'div.jonas.peter.pan'
    expect(@body).to.have.element('div.jonas.peter.pan')

  it 'compiles an element with id and classes', ->
    @render 'div#jonas.peter.pan'
    expect(@body).to.have.element('div#jonas.peter.pan')

  it 'compiles an id without an explicit element name into a div', ->
    @render '#jonas'
    expect(@body).to.have.element('div#jonas')

  it 'compiles a class without an explicit element name into a div', ->
    @render '.jonas'
    expect(@body).to.have.element('div.jonas')

  it 'compiles multiple classes without an explicit element name into a div', ->
    @render '.jonas.peter.pan'
    expect(@body).to.have.element('div.jonas.peter.pan')

  it 'is overridden by explicitly given id', ->
    @render '#jonas[id="peter"]'
    expect(@body).not.to.have.element('div#jonas')
    expect(@body).to.have.element('div#peter')

  it 'is joined with explicitly given classes', ->
    @render '.jonas[class="peter"]'
    expect(@body).to.have.element('div.peter.jonas')

  it 'updates multiple classes with short form as the class attribute changes', ->
    model = new Serenade.Model( names: ['jonas', 'peter'] )
    @render 'div.quack[class=names]', model
    expect(@body).to.have.element('div.quack.jonas.peter')
    model.names = undefined
    expect(@body).to.have.element('div.quack')
    expect(@body).not.to.have.element('div.jonas')
    expect(@body).not.to.have.element('div.peter')
    model.names = 'jonas'
    expect(@body).to.have.element('div.jonas')
    model.names = ['harry', 'jonas']
    expect(@body).to.have.element('div.harry.jonas')
