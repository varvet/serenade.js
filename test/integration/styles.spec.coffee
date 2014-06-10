require './../spec_helper'

describe 'Styles', ->
  beforeEach ->
    @setupDom()

  it 'get bound style from the model', ->
    model = { name: 'red' }
    @render 'div[style:color=@name]', model
    expect(@body.querySelector('div').style.color).to.eql('red')

  it 'changes bound style as they are changed', ->
    model = Serenade(name: "red")
    @render 'div[style:color=@name]', model
    expect(@body.querySelector('div').style.color).to.eql('red')
    model.name = 'blue'
    expect(@body.querySelector('div').style.color).to.eql('blue')
