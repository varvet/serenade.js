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
    model = Serenade({ active: true, status: "done", type: "blob" })
    @render 'div.status[class=@status class=@type class:active=@active]', model
    expect(@body.children[0].className).to.eql("active blob done status")
    model.status = "pending"
    expect(@body.children[0].className).to.eql("active blob pending status")
    model.active = false
    expect(@body.children[0].className).to.eql("blob pending status")
    model.type = "qloog"
    expect(@body.children[0].className).to.eql("pending qloog status")

  it 'does not add same class more than once', ->
    model = Serenade({ active: false })
    @render 'div[class:active=@active]', model
    model.active = true
    model.active = true
    expect(@body.children[0].className).to.eql("active")
