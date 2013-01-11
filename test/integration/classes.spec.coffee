require './../spec_helper'

describe 'Classes', ->
  beforeEach ->
    @setupDom()

  it 'adds bound class when model value is true', ->
    model = { isActive: true }
    @render 'div[class:active=@isActive]', model
    expect(@body).to.have.element("div.active")

  it 'adds multiple bindings', ->
    model = { isActive: true, isSelected: true }
    @render 'div[class:active=@isActive class:selected=@isSelected]', model
    expect(@body.children[0].className).to.eql("active selected")

  it 'does not add bound class when model value is false', ->
    model = { active: false }
    @render 'div[class:active=@active]', model
    expect(@body).not.to.have.element("div.active")

  it 'updates when attribute changes', ->
    model = Serenade({ active: false })
    @render 'div[class:active=@active]', model
    expect(@body).not.to.have.element("div.active")
    model.active = true
    expect(@body).to.have.element("div.active")
    model.active = false
    expect(@body).not.to.have.element("div.active")

  it 'plays nice with class attributes and CSS like template values', ->
    model = Serenade({ active: true, status: "done" })
    @render 'div.status[class=@status class:active=@active]', model
    expect(@body.children[0].className).to.eql("status done active")
    model.status = "pending"
    expect(@body.children[0].className).to.eql("status pending active")
    model.active = false
    expect(@body.children[0].className).to.eql("status pending")
