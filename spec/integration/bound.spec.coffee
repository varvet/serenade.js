{Serenade} = require '../../src/serenade'

describe 'Bound attributes and text nodes', ->
  beforeEach ->
    @setupDom()

  it 'does not add bound attribute if value is undefined in model', ->
    model = { name: 'jonas' }
    @render 'div[id=foo]', model
    expect(@body.find('div')).not.toHaveAttribute('id')

  it 'get bound attributes from the model', ->
    model = { name: 'jonas' }
    @render 'div[id=name]', model
    expect(@body).toHaveElement('div#jonas')

  it 'get bound text from the model', ->
    model = { name: 'Jonas Nicklas' }
    @render 'div name', model
    expect(@body.find('div')).toHaveText('Jonas Nicklas')

  it 'sets multiple classes with an array given as the class attribute', ->
    model = { names: ['jonas', 'peter'] }
    @render 'div[class=names]', model
    expect(@body).toHaveElement('div.jonas.peter')

  it 'changes bound attributes as they are changed', ->
    model = new Serenade.Model
    model.set('name', 'jonas')
    @render 'div[id=name]', model
    expect(@body).toHaveElement('div#jonas')
    model.set('name', 'peter')
    expect(@body).toHaveElement('div#peter')

  it 'removes attributes and reattaches them as they are set to undefined', ->
    model = new Serenade.Model
    model.set('name', 'jonas')
    @render 'div[id=name]', model
    expect(@body).toHaveElement('div#jonas')
    model.set('name', undefined)
    expect(@body.find('div')).not.toHaveAttribute('id')
    model.set('name', 'peter')
    expect(@body).toHaveElement('div#peter')

  it 'handles value specially', ->
    model = new Serenade.Model
    model.set('name', 'jonas')
    @render 'input[value=name]', model
    @body.find('input').val('changed')
    model.set('name', 'peter')
    expect(@body.find('input').val()).toEqual('peter')

  it 'handles checked specially', ->
    model = new Serenade.Model
    model.set('checked', true)
    @render 'input[checked=checked]', model

    expect(@body.find('input').is(':checked')).toBeTruthy()
    model.set('checked', false)
    expect(@body.find('input').is(':checked')).toBeFalsy()
    model.set('checked', 'schmock')
    expect(@body.find('input').is(':checked')).toBeTruthy()

  it 'changes bound text nodes as they are changed', ->
    model = new Serenade.Model
    model.set('name', 'Jonas Nicklas')
    @render 'div name', model
    expect(@body.find('div')).toHaveText('Jonas Nicklas')
    model.set('name', 'Peter Pan')
    expect(@body.find('div')).toHaveText('Peter Pan')

  it 'updates multiple classes as the class attribute changes', ->
    model = new Serenade.Model( names: ['jonas', 'peter'] )
    @render 'div[class=names]', model
    expect(@body).toHaveElement('div.jonas.peter')
    model.set('names', undefined)
    expect(@body.find('div')).not.toHaveAttribute('class')
    model.set('names', 'jonas')
    expect(@body).toHaveElement('div.jonas')
    model.set('names', ['harry', 'jonas'])
    expect(@body).toHaveElement('div.harry.jonas')

