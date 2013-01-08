require './../spec_helper'

describe 'In', ->
  beforeEach ->
    @setupDom()

  it 'changes the context to a subobject', ->
    model = { author: { name: 'jonas' } }

    @render '''
      article
        - in @author
          p[id=name]
    ''', model
    expect(@body).to.have.element('article > p#jonas')

  it 'can have multiple children', ->
    model = { author: { name: 'jonas' } }

    @render '''
      article
        - in @author
          p[id=name]
          div
    ''', model
    expect(@body).to.have.element('article > p#jonas')
    expect(@body).to.have.element('article > div')

  it 'updates when the subobject is changed', ->
    model = new Serenade.Model( author: { name: 'jonas' } )

    @render '''
      article
        - in @author
          p[id=name]
    ''', model
    expect(@body).to.have.element('article > p#jonas')
    model.author = { name: "peter" }
    expect(@body).to.have.element('article > p#peter')
    expect(@body).not.to.have.element('article > p#jonas')

  it 'updates when a property on the subobject is changed', ->
    model = { author: new Serenade.Model( name: 'jonas' ) }

    @render '''
      article
        - in @author
          p[id=name]
    ''', model
    expect(@body).to.have.element('article > p#jonas')
    model.author.name = 'peter'
    expect(@body).to.have.element('article > p#peter')
    expect(@body).not.to.have.element('article > p#jonas')
