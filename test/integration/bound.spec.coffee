require './../spec_helper'

describe 'Bound attributes and text nodes', ->
  beforeEach ->
    @setupDom()

  it 'does not add bound attribute if value is undefined in context', ->
    context = { name: 'jonas' }
    @render 'div[id=foo]', context
    expect(@body.querySelector('div')).not.to.have.attribute('id')

  it 'get bound attributes from the context', ->
    context = { name: 'jonas' }
    @render 'div[id=name]', context
    expect(@body).to.have.element('div#jonas')

  it 'get bound text from the context', ->
    context = { name: 'Jonas Nicklas' }
    @render 'div @name', context
    expect(@body.querySelector('div')).to.have.text('Jonas Nicklas')

  it 'sets multiple classes with an array given as the class attribute', ->
    context = { names: ['jonas', 'peter'] }
    @render 'div[class=names]', context
    expect(@body).to.have.element('div.jonas.peter')

  it 'changes bound attributes as they are changed', ->
    context = Serenade(name: "jonas")
    @render 'div[id=@name]', context
    expect(@body).to.have.element('div#jonas')
    context.name = 'peter'
    expect(@body).to.have.element('div#peter')

  it 'does not change static attributes as they are changed', ->
    context = Serenade(name: "jonas")
    @render 'div[id=name]', context
    expect(@body).to.have.element('div#jonas')
    context.name = 'peter'
    expect(@body).to.have.element('div#jonas')

  it 'removes attributes and reattaches them as they are set to undefined', ->
    context = Serenade(name: "jonas")
    @render 'div[id=@name]', context
    expect(@body).to.have.element('div#jonas')
    context.name = undefined
    expect(@body.querySelector('div')).not.to.have.attribute('id')
    context.name = 'peter'
    expect(@body).to.have.element('div#peter')

  it 'handles value specially', ->
    context = Serenade(name: "jonas")
    @render 'input[value=@name]', context
    @body.querySelector('input').value = "changed"
    context.name = 'peter'
    expect(@body.querySelector('input').value).to.eql('peter')

  it 'handles checked specially', ->
    context = Serenade(checked: true)
    @render 'input[checked=@checked]', context

    expect(@body.querySelector('input').checked).to.be.ok
    context.checked = false
    expect(@body.querySelector('input').checked).not.to.be.ok
    context.checked = 'schmock'
    expect(@body.querySelector('input').checked).to.be.ok

  it 'changes bound text nodes as they are changed', ->
    context = Serenade(name: "Jonas Nicklas")
    @render 'div @name', context
    expect(@body.querySelector('div')).to.have.text('Jonas Nicklas')
    context.name = 'Peter Pan'
    expect(@body.querySelector('div')).to.have.text('Peter Pan')

  it 'updates multiple classes as the class attribute changes', ->
    context = Serenade( names: ['jonas', 'peter'] )
    @render 'div[class=@names]', context
    expect(@body).to.have.element('div.jonas.peter')
    context.names = undefined
    expect(@body.querySelector('div')).not.to.have.attribute('class')
    context.names = 'jonas'
    expect(@body).to.have.element('div.jonas')
    context.names = ['harry', 'jonas']
    expect(@body).to.have.element('div.harry.jonas')

  it 'handles the number zero correctly', ->
    context = { number: 0 }
    @render 'div[data-foo=@number] @number', context
    expect(@body.querySelector('div').getAttribute('data-foo')).to.eql("0")
    expect(@body.querySelector('div').textContent).to.eql("0")

  it 'can handle bound text as root nodes', ->
    context = Serenade(first: "Jonas", last: "Nicklas")
    @render """
      @first
      " "
      @last
    """, context
    expect(@body).to.have.text("Jonas Nicklas")
    context.first = "Petter"
    expect(@body).to.have.text("Petter Nicklas")

  it 'does not access getter more than once when updating dom nodes', ->
    context = {}
    counter = 0
    Serenade.defineProperty(context, "counter", get: -> counter += 1)
    context.counter_property.trigger()
    @render "h1 @counter", context
    expect(counter).to.eql(2)
    context.counter = "foo"
    expect(counter).to.eql(3)
    context.counter = "blah"
    expect(counter).to.eql(4)
