require './../spec_helper'
Serenade = require('../../lib/serenade')

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

  it 'it does not lose listeners on re-render', ->
    class Thing extends Serenade.Model
      @property "shown", value: true

    person  = Serenade(name: "Jonas")
    personView = Serenade.template('@name').render(person)
    context = new Thing(person: personView)

    @render '''
      - if @shown
        p#name
          @person
    ''', context

    expect(@body.querySelector("#name").textContent).to.eql("Jonas")

    context.shown = true
    person.name = "Kim"

    expect(@body.querySelector("#name").textContent).to.eql("Kim")

  it 'it reads views when attching listenres', ->
    person  = Serenade(name: "Jonas")
    template = Serenade.template('p#name @name')
    personView = template.render(person)

    person.name = "Kim"

    personView.append(@body)

    expect(@body.querySelector("#name").textContent).to.eql("Kim")

  it 'it does not lose listeners on re-render 2', ->
    class Person extends Serenade.Model
      @property "name"

    person  = new Person(name: "Jonas")
    personView = Serenade.template('p#name @name').render(person)

    personView.append(@body)

    expect(@body.querySelector("#name").textContent).to.eql("Jonas")

    personView.remove()
    personView.append(@body)

    expect(@body.querySelector("#name").textContent).to.eql("Jonas")
    person.name = "Kim"
    expect(@body.querySelector("#name").textContent).to.eql("Kim")
