{Serenade} = require '../../src/serenade'

describe 'If', ->
  beforeEach ->
    @setupDom()

  it 'shows the content if the model value is truthy', ->
    model = { valid: true, visible: "true" }

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - if @visible
          li[id="visible"]
    ''', model
    expect(@body).toHaveElement('ul > li#valid')
    expect(@body).toHaveElement('ul > li#visible')

  it 'can have multiple children', ->
    model = { valid: true, visible: "true" }

    @render '''
      ul
        - if @valid
          li[id="valid"]
          li[id="visible"]
          li[id="monkey"]
    ''', model
    expect(@body).toHaveElement('ul > li#valid')
    expect(@body).toHaveElement('ul > li#visible')
    expect(@body).toHaveElement('ul > li#monkey')

  it 'does not show the content if the model value is falsy', ->
    model = { valid: false, visible: 0 }

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - if @visible
          li[id="visible"]
    ''', model
    expect(@body).not.toHaveElement('ul > li#valid')
    expect(@body).not.toHaveElement('ul > li#visible')

  it 'updates the existence of content based on model value truthiness', ->
    model = new Serenade.Model(valid: false, visible: 0)

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - if @visible
          li[id="visible"]
    ''', model
    expect(@body).not.toHaveElement('ul > li#valid')
    expect(@body).not.toHaveElement('ul > li#visible')
    model.set(valid: "yes")
    expect(@body).toHaveElement('ul > li#valid')
    expect(@body).not.toHaveElement('ul > li#visible')
    model.set(valid: "", visible: "Cool")
    expect(@body).not.toHaveElement('ul > li#valid')
    expect(@body).toHaveElement('ul > li#visible')
    model.set(valid: "Blah", visible: {})
    expect(@body).toHaveElement('ul > li#valid')
    expect(@body).toHaveElement('ul > li#visible')
