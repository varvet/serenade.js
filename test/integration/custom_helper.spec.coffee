require './../spec_helper'

describe 'Custom helpers', ->
  beforeEach -> @setupDom()

  it 'uses a custom helper', ->
    Serenade.Helpers.funky = -> Serenade.document.createElement('form')
    @render '''
      div
        - funky
    '''
    expect(@body).to.have.element('div > form')

  it 'provides access to model in helper', ->
    Serenade.Helpers.funky = ->
      element = Serenade.document.createElement('form')
      element.setAttribute('id', @model.name)
      element
    model = name: 'jonas'
    @render '''
      div
        - funky
    ''', model
    expect(@body).to.have.element('div > form#jonas')

  it 'provides access to controller in helper', ->
    Serenade.Helpers.funky = ->
      element = Serenade.document.createElement('form')
      element.setAttribute('id', @controller.name)
      element
    controller = name: 'jonas'
    @render '''
      div
        - funky
    ''', {}, controller
    expect(@body).to.have.element('div > form#jonas')

  it 'uses a custom helper and sends in an argument', ->
    Serenade.Helpers.makeElement = (name) -> Serenade.document.createElement(name)
    @render '''
      div
        - makeElement "form"
        - makeElement "article"
    '''
    expect(@body).to.have.element('div > form')
    expect(@body).to.have.element('div > article')

  it 'uses a custom helper and sends in an argument', ->
    Serenade.Helpers.makeElement = (name) -> Serenade.document.createElement(name)
    @render '''
      div
        - makeElement "form"
        - makeElement "article"
    '''
    expect(@body).to.have.element('div > form')
    expect(@body).to.have.element('div > article')

  it 'uses a custom helper and sends in mupltiple arguments', ->
    Serenade.Helpers.makeElement = (name, id) ->
      element = Serenade.document.createElement(name)
      element.setAttribute('id', id)
      element
    @render '''
      div
        - makeElement "form" "product"
        - makeElement "article" "banana"
    '''
    expect(@body).to.have.element('div > form#product')
    expect(@body).to.have.element('div > article#banana')

  describe 'with block argument', ->
    it 'renders the block contents into an element', ->
      Serenade.Helpers.form = ->
        element = Serenade.document.createElement('form')
        element.appendChild(@render())
        element
      @render '''
        div
          - form
            div[id="jonas"]
      '''
      expect(@body).to.have.element('div > form > div#jonas')

    it 'works with muliple elements at the same indentation level in a block', ->
      Serenade.Helpers.form = ->
        element = Serenade.document.createElement('form')
        element.appendChild(@render())
        element
      @render '''
        div
          - form
            div#jonas
            div#peter
      '''
      expect(@body).to.have.element('div > form > div#jonas')
      expect(@body).to.have.element('div > form > div#peter')

    it 'does not use block contents if render is not called', ->
      Serenade.Helpers.form = ->
        Serenade.document.createElement('form')
      @render '''
        div
          - form
            div[id="jonas"]
      '''
      expect(@body).not.to.have.element('div > form > div#jonas')

    it 'allows model to be changed by passing it as an argument to render', ->
      Serenade.Helpers.form = ->
        element = Serenade.document.createElement('form')
        element.appendChild(@render(name: 'peter'))
        element
      @render '''
        div
          - form
            div[id=name]
      '''
      expect(@body).to.have.element('div > form > div#peter')

    it 'allows controller to be changed by passing it as an argument to render', ->
      funked = false
      Serenade.Helpers.form = ->
        element = Serenade.document.createElement('form')
        element.appendChild(@render(null, funky: -> funked = true))
        element
      @render '''
        div
          - form
            div[id="jonas" event:click=funky]
      '''
      @fireEvent(@body.querySelector('div#jonas'), 'click')
      expect(funked).to.be.ok

    it 'allows block content to be reused', ->
      funked = false
      Serenade.Helpers.form = ->
        element = Serenade.document.createElement('form')
        element.appendChild(@render(name: 'jonas'))
        element.appendChild(@render(name: 'peter'))
        element
      @render '''
        div
          - form
            div[id=name]
      '''
      expect(@body).to.have.element('div > form > div#jonas')
      expect(@body).to.have.element('div > form > div#peter')

    it "doesn't fail when called from a collection", ->
      Serenade.Helpers.test = ->
        Serenade.document.createElement("span")
      model =
        col: [1, 2]
      @render '''
        div
          - collection @col
            - test
      ''', model
      expect(@body).to.have.element('div > span')

