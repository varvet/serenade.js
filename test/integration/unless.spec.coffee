require './../spec_helper'

describe 'Unless', ->
  beforeEach ->
    @setupDom()

  it 'shows the content unless the context value is truthy', ->
    context = { valid: false, visible: 0 }

    @render '''
      ul
        - unless @valid
          li[id="valid"]
        - unless @visible
          li[id="visible"]
    ''', context
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')

  it 'can have multiple children', ->
    context = { valid: false }

    @render '''
      ul
        - unless @valid
          li[id="valid"]
          li[id="visible"]
          li[id="monkey"]
    ''', context
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    expect(@body).to.have.element('ul > li#monkey')

  it 'does not show the content unless the context value is falsy', ->
    context = { valid: true, visible: "true" }

    @render '''
      ul
        - unless @valid
          li[id="valid"]
        - unless @visible
          li[id="visible"]
    ''', context
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')

  it 'updates the existence of content based on context value truthiness', ->
    context = Serenade(valid: false, visible: 0)

    @render '''
      ul
        - unless @valid
          li[id="valid"]
        - unless @visible
          li[id="visible"]
    ''', context
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    context.valid = "yes"
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    context.valid = ""
    context.visible = "Cool"
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')
    context.valid = "Blah"
    context.visible = {}
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')

  it 'peacefully coexists with collections', ->
    context = Serenade(items: [{ valid: true, name: 'foo' }, { name: 'bar' }])
    @render '''
      ul
        - collection @items
          - unless @valid
            li[id=@name]
    ''', context
    expect(@body).not.to.have.element('ul > li#foo')
    expect(@body).to.have.element('ul > li#bar')

