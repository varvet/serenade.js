require './../spec_helper'

describe 'If', ->
  beforeEach ->
    @setupDom()

  it 'shows the content if the context value is truthy', ->
    context = { valid: true, visible: "true" }

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - if @visible
          li[id="visible"]
    ''', context
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')

  it 'can have multiple children', ->
    context = { valid: true, visible: "true" }

    @render '''
      ul
        - if @valid
          li[id="valid"]
          li[id="visible"]
          li[id="monkey"]
    ''', context
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    expect(@body).to.have.element('ul > li#monkey')

  it 'does not show the content if the context value is falsy', ->
    context = { valid: false, visible: 0 }

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - if @visible
          li[id="visible"]
    ''', context
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')

  it 'updates the existence of content based on context value truthiness', ->
    context = Serenade(valid: false, visible: 0)

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - if @visible
          li[id="visible"]
    ''', context
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')
    context.valid = "yes"
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')
    context.valid = ""
    context.visible = "Cool"
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    context.valid = "Blah"
    context.visible = {}
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')

  it 'can have else statement', ->
    context = Serenade(valid: false)

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - else
          li[id="invalid"]
    ''', context
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#invalid')
    context.valid = true
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#invalid')


  it 'peacefully coexists with collections', ->
    context = Serenade(items: [{ valid: true, name: 'foo' }, { name: 'bar' }])
    @render '''
      ul
        - collection @items
          - if @valid
            li[id=@name]
    ''', context
    expect(@body).to.have.element('ul > li#foo')
    expect(@body).not.to.have.element('ul > li#bar')

  it "can be nested", ->
    context = Serenade(show: true, details: "test")
    @render """
      div
        - if @show
          - if @details
            p#test
    """, context
    context.show = false
    context.show = true
    expect(@body).to.have.element('#test')

  it 'can be a root node', ->
    context = Serenade(valid: false)

    @render '''
      - if @valid
        p[id="valid"]
      - else
        p[id="invalid"]
    ''', context
    expect(@body).not.to.have.element('p#valid')
    expect(@body).to.have.element('p#invalid')
    context.valid = true
    expect(@body).to.have.element('p#valid')
    expect(@body).not.to.have.element('p#invalid')
