{Serenade} = require '../../src/serenade'

describe 'Custom helpers', ->
  beforeEach -> @setupDom()

  it 'uses a custom helper', ->
    Serenade.Helpers.funky = -> @document.createElement('form')
    @render '''
      div
        - funky
    '''
    expect(@body).toHaveElement('div > form')

  it 'provides access to model in helper', ->
    Serenade.Helpers.funky = ->
      element = @document.createElement('form')
      element.setAttribute('id', @model.name)
      element
    model = name: 'jonas'
    @render '''
      div
        - funky
    ''', model
    expect(@body).toHaveElement('div > form#jonas')

  it 'provides access to controller in helper', ->
    Serenade.Helpers.funky = ->
      element = @document.createElement('form')
      element.setAttribute('id', @controller.name)
      element
    controller = name: 'jonas'
    @render '''
      div
        - funky
    ''', {}, controller
    expect(@body).toHaveElement('div > form#jonas')

  it 'uses a custom helper and sends in an argument', ->
    Serenade.Helpers.makeElement = (name) -> @document.createElement(name)
    @render '''
      div
        - makeElement "form"
        - makeElement "article"
    '''
    expect(@body).toHaveElement('div > form')
    expect(@body).toHaveElement('div > article')

  it 'uses a custom helper and sends in an argument', ->
    Serenade.Helpers.makeElement = (name) -> @document.createElement(name)
    @render '''
      div
        - makeElement "form"
        - makeElement "article"
    '''
    expect(@body).toHaveElement('div > form')
    expect(@body).toHaveElement('div > article')

  it 'uses a custom helper and sends in mupltiple arguments', ->
    Serenade.Helpers.makeElement = (name, id) ->
      element = @document.createElement(name)
      element.setAttribute('id', id)
      element
    @render '''
      div
        - makeElement "form" "product"
        - makeElement "article" "banana"
    '''
    expect(@body).toHaveElement('div > form#product')
    expect(@body).toHaveElement('div > article#banana')

  context 'with block argument', ->
    it 'renders the block contents into an element', ->
      Serenade.Helpers.form = ->
        element = @document.createElement('form')
        @render(element)
        element
      @render '''
        div
          - form
            div[id="jonas"]
      '''
      expect(@body).toHaveElement('div > form > div#jonas')

    it 'does not use block contents if render is not called', ->
      Serenade.Helpers.form = ->
        @document.createElement('form')
      @render '''
        div
          - form
            div[id="jonas"]
      '''
      expect(@body).not.toHaveElement('div > form > div#jonas')

    it 'allows model to be changed by passing it as an argument to render', ->
      Serenade.Helpers.form = ->
        element = @document.createElement('form')
        @render(element, name: 'peter')
        element
      @render '''
        div
          - form
            div[id=name]
      '''
      expect(@body).toHaveElement('div > form > div#peter')

    it 'allows controller to be changed by passing it as an argument to render', ->
      funked = false
      Serenade.Helpers.form = ->
        element = @document.createElement('form')
        @render(element, null, funky: -> funked = true)
        element
      @render '''
        div
          - form
            div[id="jonas" event:click=funky]
      '''
      @fireEvent(@body.find('div#jonas').get(0), 'click')
      expect(funked).toBeTruthy()

    it 'allows block content to be reused', ->
      funked = false
      Serenade.Helpers.form = ->
        element = @document.createElement('form')
        @render(element, name: 'jonas')
        @render(element, name: 'peter')
        element
      @render '''
        div
          - form
            div[id=name]
      '''
      expect(@body).toHaveElement('div > form > div#jonas')
      expect(@body).toHaveElement('div > form > div#peter')
