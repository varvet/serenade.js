{Serenade} = require '../../src/serenade'

describe 'Styles', ->
  beforeEach ->
    @setupDom()

  it 'get bound style from the model', ->
    model = { name: 'red' }
    @render 'div[style:color=name]', model
    expect(@body.find('div').css('color')).toEqual('red')

  it 'changes bound style as they are changed', ->
    model = new Serenade.Model
    model.set('name', 'red')
    @render 'div[style:color=name]', model
    expect(@body.find('div').css('color')).toEqual('red')
    model.set('name', 'blue')
    expect(@body.find('div').css('color')).toEqual('blue')
