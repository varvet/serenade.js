require './../spec_helper'

describe 'Bound attributes and text nodes', ->
  beforeEach ->
    @setupDom()

  it 'does not add bound attribute if value is undefined in model', ->
    model = { name: 'jonas' }
    @render 'div[id=foo]', model
    expect(@body.querySelector('div')).not.to.have.attribute('id')

  it 'get bound attributes from the model', ->
    model = { name: 'jonas' }
    @render 'div[id=name]', model
    expect(@body).to.have.element('div#jonas')

  it 'get bound text from the model', ->
    model = { name: 'Jonas Nicklas' }
    @render 'div @name', model
    expect(@body.querySelector('div')).to.have.text('Jonas Nicklas')

  it 'sets multiple classes with an array given as the class attribute', ->
    model = { names: ['jonas', 'peter'] }
    @render 'div[class=names]', model
    expect(@body).to.have.element('div.jonas.peter')

  it 'changes bound attributes as they are changed', ->
    model = Serenade(name: "jonas")
    @render 'div[id=name]', model
    expect(@body).to.have.element('div#jonas')
    model.name = 'peter'
    expect(@body).to.have.element('div#peter')

  it 'removes attributes and reattaches them as they are set to undefined', ->
    model = Serenade(name: "jonas")
    @render 'div[id=name]', model
    expect(@body).to.have.element('div#jonas')
    model.name = undefined
    expect(@body.querySelector('div')).not.to.have.attribute('id')
    model.name = 'peter'
    expect(@body).to.have.element('div#peter')

  it 'handles value specially', ->
    model = Serenade(name: "jonas")
    @render 'input[value=name]', model
    @body.querySelector('input').value = "changed"
    model.name = 'peter'
    expect(@body.querySelector('input').value).to.eql('peter')

  it 'handles checked specially', ->
    model = Serenade(checked: true)
    @render 'input[checked=checked]', model

    expect(@body.querySelector('input').checked).to.be.ok
    model.checked = false
    expect(@body.querySelector('input').checked).not.to.be.ok
    model.checked = 'schmock'
    expect(@body.querySelector('input').checked).to.be.ok

  it 'handles novalidate specially', ->
    model = Serenade(novalidate: true)
    @render 'input[novalidate=novalidate]', model

    expect(@body.querySelector('input').noValidate).to.be.ok
    model.novalidate = false
    expect(@body.querySelector('input').noValidate).not.to.be.ok
    model.novalidate = 'schmock'
    expect(@body.querySelector('input').noValidate).to.be.ok

  it 'changes bound text nodes as they are changed', ->
    model = Serenade(name: "Jonas Nicklas")
    @render 'div @name', model
    expect(@body.querySelector('div')).to.have.text('Jonas Nicklas')
    model.name = 'Peter Pan'
    expect(@body.querySelector('div')).to.have.text('Peter Pan')

  it 'updates multiple classes as the class attribute changes', ->
    model = Serenade( names: ['jonas', 'peter'] )
    @render 'div[class=names]', model
    expect(@body).to.have.element('div.jonas.peter')
    model.names = undefined
    expect(@body.querySelector('div')).not.to.have.attribute('class')
    model.names = 'jonas'
    expect(@body).to.have.element('div.jonas')
    model.names = ['harry', 'jonas']
    expect(@body).to.have.element('div.harry.jonas')

  it 'handles the number zero correctly', ->
    model = { number: 0 }
    @render 'div[data-foo=number] @number', model
    expect(@body.querySelector('div').getAttribute('data-foo')).to.eql("0")
    expect(@body.querySelector('div').textContent).to.eql("0")

  it 'uses model formatter', ->
    model = {}
    Serenade.defineProperty(model, "name", value: "Jonas", format: (val) -> val.toUpperCase())
    @render 'div[data-name=@name style:color=@name] @name', model
    expect(@body.querySelector('div').getAttribute('data-name')).to.eql("JONAS")
    expect(@body.querySelector('div').style.color).to.eql("JONAS")
    expect(@body.querySelector('div').textContent).to.eql("JONAS")
    model.name = "peter"
    expect(@body.querySelector('div').getAttribute('data-name')).to.eql("PETER")
    expect(@body.querySelector('div').style.color).to.eql("PETER")
    expect(@body.querySelector('div').textContent).to.eql("PETER")

  it 'can handle bound text as root nodes', ->
    model = Serenade(first: "Jonas", last: "Nicklas")
    @render """
      @first
      " "
      @last
    """, model
    expect(@body).to.have.text("Jonas Nicklas")
    model.first = "Petter"
    expect(@body).to.have.text("Petter Nicklas")

  it 'does not access getter more than once when updating dom nodes', ->
    model = {}
    counter = 0
    Serenade.defineProperty(model, "counter", get: -> counter += 1)
    model.counter_property.trigger()
    @render "h1 @counter", model
    expect(counter).to.eql(2)
    model.counter = "foo"
    expect(counter).to.eql(3)
    model.counter = "blah"
    expect(counter).to.eql(4)

  it 'can set several class bindings', ->
    model = Serenade(names: ['jonas', 'peter'], job: 'handyman')
    @render 'div[class=@names class=@job]', model
    expect(@body).to.have.element('div.jonas.peter.handyman')
    model.names = ["john"]
    expect(@body).not.to.have.element('div.jonas.peter.handyman')
    expect(@body).to.have.element('div.john.handyman')
    model.job = "carpenter"
    expect(@body).not.to.have.element('div.john.handyman')
    expect(@body).to.have.element('div.john.carpenter')
