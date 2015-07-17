require './../spec_helper'
Serenade = require('../../lib/serenade')

describe 'Styles', ->
  beforeEach ->
    @setupDom()

  it 'get bound style from the context', ->
    context = { name: 'red' }
    @render 'div[style:color=@name]', context
    expect(@body.querySelector('div').style.color).to.eql('red')

  it 'changes bound style as they are changed', ->
    context = Serenade(name: "red")
    @render 'div[style:color=@name]', context
    expect(@body.querySelector('div').style.color).to.eql('red')
    context.name = 'blue'
    expect(@body.querySelector('div').style.color).to.eql('blue')
