require './../spec_helper'
{expect} = require('chai')
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
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')

  it 'can have multiple children', ->
    model = { valid: true, visible: "true" }

    @render '''
      ul
        - if @valid
          li[id="valid"]
          li[id="visible"]
          li[id="monkey"]
    ''', model
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    expect(@body).to.have.element('ul > li#monkey')

  it 'does not show the content if the model value is falsy', ->
    model = { valid: false, visible: 0 }

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - if @visible
          li[id="visible"]
    ''', model
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')

  it 'updates the existence of content based on model value truthiness', ->
    model = new Serenade.Model(valid: false, visible: 0)

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - if @visible
          li[id="visible"]
    ''', model
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')
    model.set(valid: "yes")
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')
    model.set(valid: "", visible: "Cool")
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    model.set(valid: "Blah", visible: {})
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')

  it 'can have else statement', ->
    model = new Serenade.Model(valid: false)

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - else
          li[id="invalid"]
    ''', model
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#invalid')
    model.valid = true
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#invalid')


  it 'peacefully coexists with collections', ->
    model = new Serenade.Model(items: [{ valid: true, name: 'foo' }, { name: 'bar' }])
    @render '''
      ul
        - collection @items
          - if @valid
            li[id=@name]
    ''', model
    expect(@body).to.have.element('ul > li#foo')
    expect(@body).not.to.have.element('ul > li#bar')

  it "can be nested", ->
    model = new Serenade.Model(show: true, details: "test")
    @render """
      div
        - if @show
          - if @details
            p#test
    """, model
    model.show = false
    model.show = true
    expect(@body).to.have.element('#test')

