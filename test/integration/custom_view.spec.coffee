require './../spec_helper'

describe 'Custom views', ->
  beforeEach -> @setupDom()

  it 'uses a custom view', ->
    class CustomView extends Serenade.Element
      constructor: (@ast) ->
        @element = Serenade.document.createElement('form')

    Serenade.view "funky", CustomView

    @render '''
      div
        funky
    '''
    expect(@body).to.have.element('div > form')
