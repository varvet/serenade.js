require './../spec_helper'
{expect} = require('chai')
{Serenade} = require '../../src/serenade'

describe 'Events', ->
  beforeEach ->
    @setupDom()

  it 'attaches an event which calls the controller action when triggered', ->
    controller = { iWasClicked: -> @clicked = true }
    @render 'div[event:click=iWasClicked]', {}, controller
    @fireEvent @body.find('div').get(0), 'click'
    expect(controller.clicked).to.be.ok

  it 'initializes controllers sent in as constructors', ->
    clicked = false
    class Controller
      iWasClicked: -> clicked = true
    @render 'div[event:click=iWasClicked]', {}, Controller
    @fireEvent @body.find('div').get(0), 'click'
    expect(clicked).to.be.ok

  it 'calls the loaded event after the view is done rendering, sending in model and view', ->
    nodeName = null
    name = null
    controller =
      loaded: (model, view) ->
        nodeName = view.nodeName
        name = model.name
    @render 'div', { name: "Jonas" }, controller
    expect(nodeName).to.eql("DIV")
    expect(name).to.eql("Jonas")

  it 'sends in model, element and event when action is triggered', ->
    nodeName = null
    name = null
    eventType = null
    controller =
      iWasClicked: (model, view, event) ->
        nodeName = view.nodeName
        name = model.name
        eventType = event.type
    @render 'div\n\ta[event:click=iWasClicked]', { name: "Jonas" }, controller
    @fireEvent @body.find('a').get(0), 'click'
    expect(nodeName).to.eql("A")
    expect(name).to.eql("Jonas")
    expect(eventType).to.eql("click")

  it 'sends in the element that the event was bound to, not where it was triggered', ->
    nodeName = null
    controller =
      iWasClicked: (_, view) ->
        nodeName = view.nodeName
    @render 'div[event:click=iWasClicked]\n\ta', {}, controller
    @fireEvent @body.find('a').get(0), 'click'
    expect(nodeName).to.eql("DIV")
