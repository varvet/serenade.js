require './../spec_helper'
Serenade = require('../../lib/serenade')

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
    @render 'div $name', context
    expect(@body.querySelector('div')).to.have.text('Jonas Nicklas')

  it 'get bound view from the context', ->
    context = { name: Serenade.template('h1 "Jonas"').render() }
    @render 'div $name', context
    expect(@body.querySelector('div h1')).to.have.text('Jonas')

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
    @render 'div[data-foo=number] $number', context
    expect(@body.querySelector('div').getAttribute('data-foo')).to.eql("0")
    expect(@body.querySelector('div').textContent).to.eql("0")

  it 'uses model formatter', ->
    model = {}
    Serenade.defineProperty model, "name", value: "OrAnGE", format: (val) -> val.toLowerCase()
    @render 'div[data-name=@name style:color=@name] @name', model
    expect(@body.querySelector('div').getAttribute('data-name')).to.eql("orange")
    expect(@body.querySelector('div').style.color).to.eql("orange")
    expect(@body.querySelector('div').textContent).to.eql("orange")
    model.name = "ReD"
    expect(@body.querySelector('div').getAttribute('data-name')).to.eql("red")
    expect(@body.querySelector('div').style.color).to.eql("red")
    expect(@body.querySelector('div').textContent).to.eql("red")

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
    context = Serenade(score: 0)
    counter = 0
    Serenade.defineProperty(context, "trackedScore", dependsOn: "score", get: (score) -> counter += 1; score)

    context.score += 1
    expect(counter).to.eql(0)
    @render "h1 @trackedScore", context
    expect(counter).to.eql(1)
    expect(@body.querySelector('h1').textContent).to.eql("1")

    context.score += 1
    expect(counter).to.eql(2)
    expect(@body.querySelector('h1').textContent).to.eql("2")
