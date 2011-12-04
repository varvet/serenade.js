Monkey.registerView 'thing', '''
  div[id="monkey"]
    p
      a[click=doThing] "Do thing"
    p[mousover=over mouseout=out]
      "Mouse over this area to change"
    p
      strong "Thing:"
      " "
      span schmoo
    p
      strong "Barr:"
      " "
      span barr
    p
      input[type="text" value=schmoo change=didChange name="schmoo"]
    p
      input[type="text" value=schmoo change=didChange name="barr"]
'''


class Thing extends Monkey.Model
  @property 'schmoo'
  @property 'barr'

class Controller
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

$ ->
  view = Monkey.render('thing', aThing, new Controller())
  sandbox = document.body.appendChild(view)
