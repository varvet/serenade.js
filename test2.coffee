#= require monkey
#= require monkey/events
#= require monkey/properties
#= require monkey/model
#= require monkey/renderer

Monkey.registerView 'thing', (t) ->
  t 'div', id: 'monkey',
    t 'a', href: 'http://google.com', 'Google'
    t 'a', click: 'doThing', href: '#', 'Do thing'
    t 'p', mouseover: 'over', mouseout: 'out',
      t 'span', {}, 'Schmoo: ', { bind: 'schmoo' }
    t 'p', {},
      t 'span', {}, 'Barr: ', { bind: 'barr' }
    t 'p', {},
      t 'input', type: 'text', value: { bind: 'schmoo' }, change: 'didChange', name: 'schmoo'
    t 'p', {},
      t 'textarea', value: { bind: 'barr' }, change: 'didChange', name: 'barr'

Monkey.registerView 'test', (t) ->
  t 'div', id: 'hellow-world',
    t 'h1', {}, { bind: 'name' }
    t 'p', {},
      t 'a', click: 'showAlert', href: "#", 'Show the alert'

class Thing extends Monkey.Model
  @property 'schmoo'
  @property 'barr'

Controller =
  doThing: ->
    @model.schmoo = 'I did a thing'
  over: ->
    @originalSchmoo = @model.schmoo
    @model.schmoo = 'mousin over'
  out: ->
    @model.schmoo = @originalSchmoo
  didChange: (e) ->
    @model[e.target.getAttribute('name')] = e.target.value

window.aThing = new Thing()

window.addEventListener 'load', ->
  thing = {}
  sandbox = document.getElementById('sandbox')
  view1 = Monkey.render('thing', aThing, Controller)
  sandbox.appendChild view1

  controller = { showAlert: -> alert('Alert!!!') }
  model = { name: 'Jonas' }
  result = Monkey.render('test', model, controller)
  document.querySelector('body').appendChild(result)
