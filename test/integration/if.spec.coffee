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

  it 'shows the else-content if the model value is not truthy', ->
    model = { valid: false, }

    @render '''
      ul
        - if @valid
          li[id="valid"]
        - else
          li[id="visible"]
    ''', model
    expect(@body).not.to.have.element('ul > li#valid')
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

  it 'can have multiple children in its else clause', ->
    model = { valid: false }

    @render '''
      ul
        - if @valid
          li[id="foo"]
        - else
          li[id="valid"]
          li[id="visible"]
          li[id="monkey"]
    ''', model
    expect(@body).not.to.have.element('ul > li#foo')
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
        - else
          li[id="invalid"]
        - if @visible
          li[id="visible"]
    ''', model
    expect(@body).to.have.element('ul > li#invalid')
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')
    model.set(valid: "yes")
    expect(@body).not.to.have.element('ul > li#invalid')
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).not.to.have.element('ul > li#visible')
    model.set(valid: "", visible: "Cool")
    expect(@body).to.have.element('ul > li#invalid')
    expect(@body).not.to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')
    model.set(valid: "Blah", visible: {})
    expect(@body).to.have.element('ul > li#valid')
    expect(@body).to.have.element('ul > li#visible')

  it 'peacefully coexists with collections', ->
    model = new Serenade.Model(items: [{ valid: true, name: 'foo' }, { name: 'bar' }])
    @render '''
      ul
        - collection @items
          - if @valid
            li[id=@name]
          - else
            li[class=@name]
    ''', model
    expect(@body).to.have.element('ul > li#foo')
    expect(@body).not.to.have.element('ul > li.foo')
    expect(@body).not.to.have.element('ul > li#bar')
    expect(@body).to.have.element('ul > li.bar')
