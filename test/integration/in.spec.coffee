require './../spec_helper'
Serenade = require("../../lib/serenade")

describe 'In', ->
  beforeEach ->
    @setupDom()

  it 'changes the context to a subobject', ->
    context = { author: { name: 'jonas' } }

    @render '''
      article
        - in $author
          p[id=name]
    ''', context
    expect(@body).to.have.element('article > p#jonas')

  it 'can have multiple children', ->
    context = { author: { name: 'jonas' } }

    @render '''
      article
        - in $author
          p[id=name]
          div
    ''', context
    expect(@body).to.have.element('article > p#jonas')
    expect(@body).to.have.element('article > div')

  it 'updates when the subobject is changed', ->
    context = Serenade( author: { name: 'jonas' } )

    @render '''
      article
        - in @author
          p[id=name]
    ''', context
    expect(@body).to.have.element('article > p#jonas')
    context.author = { name: "peter" }
    expect(@body).to.have.element('article > p#peter')
    expect(@body).not.to.have.element('article > p#jonas')

  it 'updates when a property on the subobject is changed', ->
    context = { author: Serenade( name: 'jonas' ) }

    @render '''
      article
        - in $author
          p[id=@name]
    ''', context
    expect(@body).to.have.element('article > p#jonas')
    context.author.name = 'peter'
    expect(@body).to.have.element('article > p#peter')
    expect(@body).not.to.have.element('article > p#jonas')
