require './../spec_helper'

describe 'Unless', ->
  beforeEach ->
    @setupDom()

  it 'shows the content unless the model value is truthy', ->
    model = { valid: false, visible: 0 }

    @render '''
      ul
        - unless @valid
          li[id="valid"]
        - unless @visible
          li[id="visible"]
    ''', model
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')

  it 'can have multiple children', ->
    model = { valid: false }

    @render '''
      ul
        - unless @valid
          li[id="valid"]
          li[id="visible"]
          li[id="monkey"]
    ''', model
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    expect(@body).to.have.element('ul > li#monkey')

  it 'does not show the content unless the model value is falsy', ->
    model = { valid: true, visible: "true" }

    @render '''
      ul
        - unless @valid
          li[id="valid"]
        - unless @visible
          li[id="visible"]
    ''', model
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')

  it 'updates the existence of content based on model value truthiness', ->
    model = Serenade(valid: false, visible: 0)

    @render '''
      ul
        - unless @valid
          li[id="valid"]
        - unless @visible
          li[id="visible"]
    ''', model
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    model.valid = "yes"
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    model.valid = ""
    model.visible = "Cool"
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')
    model.valid = "Blah"
    model.visible = {}
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')

  it 'peacefully coexists with collections', ->
    model = Serenade(items: [{ valid: true, name: 'foo' }, { name: 'bar' }])
    @render '''
      ul
        - collection @items
          - unless @valid
            li[id=@name]
    ''', model
    expect(@body).not.to.have.element('ul > li#foo')
    expect(@body).to.have.element('ul > li#bar')

