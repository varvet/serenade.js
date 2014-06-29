require './../spec_helper'

describe 'Custom helpers', ->
  beforeEach -> @setupDom()

  it 'uses a custom helper', ->
    Serenade.helper "funky", -> Serenade.document.createElement('form')
    @render '''
      div
        - funky
    '''
    expect(@body).to.have.element('div > form')

  it 'can return multiple elements', ->
    Serenade.helper "funky", ->
      [Serenade.document.createElement('form'), Serenade.document.createElement('article')]
    @render '''
      div
        - funky
    '''
    expect(@body).to.have.element('div > form')
    expect(@body).to.have.element('div > article')

  it 'can return a document fragment', ->
    Serenade.helper "funky", ->
      frag = Serenade.document.createDocumentFragment()
      frag.appendChild Serenade.document.createElement('form')
      frag.appendChild Serenade.document.createElement('article')
      frag

    @render '''
      div
        - funky
    '''

    expect(@body).to.have.element('div > form')
    expect(@body).to.have.element('div > article')

  it 'can return a renderered Serenade.template', ->
    Serenade.helper "funky", ->
      Serenade.template("""
        #foo
          #bar
        #baz
      """).render()

    @render '''
      div
        - funky
    '''

    expect(@body).to.have.element('div > #foo > #bar')
    expect(@body).to.have.element('div > #baz')

  it 'cleans up listeners from rendered serenade view', ->
    model = Serenade(name: "Jonas", active: true)
    Serenade.helper "funky", (active) ->
      if active
        Serenade.template("""
          #bar @name
        """).render(@model)
      else
        undefined

    @render '''
      div
        - funky @active
    ''', model

    expect(@body).to.have.element('#bar')
    expect(model.name_property.listeners.length).to.eql(1)
    model.active = false
    expect(@body).not.to.have.element('#bar')
    expect(model.name_property.listeners.length).to.eql(0)

  it 'can return undefined', ->
    Serenade.helper "funky", -> undefined
    @render '''
      div
        - funky
    '''
    expect(@body).to.have.element('div')

  it 'can return a string of text', ->
    Serenade.helper "funky", ->
      "Hello"
    @render '''
      div
        - funky
    '''
    expect(@body).to.have.element('div')
    expect(@body).to.have.text("Hello")

  it 'can return a string of html', ->
    Serenade.helper "funky", ->
      "<article>Hello</article>"
    @render '''
      div
        - funky
    '''
    expect(@body).to.have.element('div > article')
    expect(@body).to.have.text("Hello")

  it 'can return a string with multiple children', ->
    Serenade.helper "funky", ->
      "<article>Hello</article><section></section>"
    @render '''
      div
        - funky
    '''
    expect(@body).to.have.element('div > article')
    expect(@body).to.have.element('div > section')
    expect(@body).to.have.text("Hello")

  it 'provides access to model in helper', ->
    Serenade.helper "funky", ->
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
    Serenade.helper "funky", ->
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
    Serenade.helper "makeElement", (name) ->
      Serenade.document.createElement(name)
    @render '''
      div
        - makeElement "form"
        - makeElement "article"
    '''
    expect(@body).to.have.element('div > form')
    expect(@body).to.have.element('div > article')

  it 'uses a custom helper and sends in mupltiple arguments', ->
    Serenade.helper "makeElement", (name, id) ->
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

  it "doesn't fail when called from a collection", ->
    Serenade.helper "test", ->
      Serenade.document.createElement("span")
    model =
      col: [1, 2]
    @render '''
      div
        - collection @col
          - test
    ''', model
    expect(@body).to.have.element('div > span')

  describe 'with block argument', ->
    it 'renders the block contents into an element', ->
      Serenade.helper "form", ->
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
      Serenade.helper "form", ->
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
      Serenade.helper "form", ->
        Serenade.document.createElement('form')
      @render '''
        div
          - form
            div[id="jonas"]
      '''
      expect(@body).not.to.have.element('div > form > div#jonas')

    it 'allows model to be changed by passing it as an argument to render', ->
      Serenade.helper "form", ->
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
      Serenade.helper "form", ->
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
      Serenade.helper "form", ->
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

    it 'allows rendered block contents to be manually cleaned up', ->
      model = Serenade(name: "jonas")
      Serenade.helper "form", ->
        element = Serenade.document.createElement('form')
        view = @render(model)
        element.appendChild(view)
        element.addEventListener("submit", -> view.remove())
        element
      @render '''
        div
          - form
            div[id=name]
      '''
      expect(@body).to.have.element('div > form > div#jonas')
      @fireEvent(@body.querySelector("form"), "submit")

      expect(@body).not.to.have.element('div > form > div#jonas')
      expect(model.name_property.listeners.length).to.eql(0)

  describe 'with bound argument', ->
    it "binds to a model attribute", ->
      model = Serenade(name: "Jonas")
      Serenade.helper "upcase", (value) ->
        Serenade.document.createTextNode(value.toUpperCase())
      @render """
        div
          - upcase @name
      """, model
      expect(@body).to.have.text("JONAS")
      model.name = "Peter"
      expect(@body).to.have.text("PETER")

    it "binds to multiple arguments", ->
      model = Serenade(firstName: "Jonas", lastName: "Nicklas")
      Serenade.helper "upcase", (args...) ->
        Serenade.document.createTextNode(args.join("").toUpperCase())
      @render """
        div
          - upcase @lastName ", " @firstName
      """, model
      expect(@body).to.have.text("NICKLAS, JONAS")
      model.firstName = "Annika"
      expect(@body).to.have.text("NICKLAS, ANNIKA")
      model.lastName = "Lüchow"
      expect(@body).to.have.text("LÜCHOW, ANNIKA")

    it "update a rendered Serenade.template", ->
      model = Serenade(id: "test")
      Serenade.helper "funky", (id) ->
        Serenade.template("""
          #foo
          div[id=@id]
        """).render(id: id)

      @render '''
        div
          - funky @id
      ''', model

      expect(@body).to.have.element('div > #foo')
      expect(@body).to.have.element('div > #test')

      model.id = "quox"

      expect(@body).to.have.element('div > #foo')
      expect(@body).to.have.element('div > #quox')
      expect(@body).not.to.have.element('div > #test')
