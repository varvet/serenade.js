require './../spec_helper'

describe 'Events', ->
  beforeEach ->
    @setupDom()

  it 'attaches an event which calls the context action when triggered', ->
    context = { iWasClicked: -> @clicked = true }
    @render 'div[event:click=iWasClicked]', context
    @fireEvent @body.querySelector('div'), 'click'
    expect(context.clicked).to.be.ok

  it 'sends in context, element and event when action is triggered', ->
    nodeName = null
    name = null
    eventType = null
    context =
      name: "Jonas"
      iWasClicked: (view, context, event) ->
        nodeName = view.nodeName
        name = context.name
        eventType = event.type
    @render 'div\n\ta[event:click=iWasClicked]', context
    @fireEvent @body.querySelector('a'), 'click'
    expect(nodeName).to.eql("A")
    expect(name).to.eql("Jonas")
    expect(eventType).to.eql("click")

  it 'sends in the element that the event was bound to, not where it was triggered', ->
    nodeName = null
    context =
      iWasClicked: (view) ->
        nodeName = view.nodeName
    @render 'div[event:click=iWasClicked]\n\ta', context
    @fireEvent @body.querySelector('a'), 'click'
    expect(nodeName).to.eql("DIV")
