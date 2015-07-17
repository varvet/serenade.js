require './../spec_helper'
Serenade = require("../../lib/serenade")

describe 'Custom views', ->
  beforeEach -> @setupDom()

  it 'uses a custom view', ->
    class CustomView extends Serenade.Element
      constructor: (@ast) ->
        @node = Serenade.document.createElement('form')

    Serenade.view "funky", CustomView

    @render '''
      div
        funky
    '''
    expect(@body).to.have.element('div > form')
