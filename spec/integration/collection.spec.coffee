{Serenade} = require '../../src/serenade'

describe 'Collection', ->
  beforeEach ->
    @setupDom()

  it 'compiles a collection instruction', ->
    model = { people: [{ name: 'jonas' }, { name: 'peter' }] }

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')

  it 'compiles a Serenade.collection in a collection instruction', ->
    model = { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')

  it 'updates a collection dynamically', ->
    model = { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')
    model.people.update([{ name: 'anders' }, { name: 'jimmy' }])
    expect(@body).not.toHaveElement('ul > li#jonas')
    expect(@body).not.toHaveElement('ul > li#peter')
    expect(@body).toHaveElement('ul > li#anders')
    expect(@body).toHaveElement('ul > li#jimmy')

  it 'removes item from collection when requested', ->
    model = { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', model
    expect(@body).toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')
    model.people.deleteAt(0)
    expect(@body).not.toHaveElement('ul > li#jonas')
    expect(@body).toHaveElement('ul > li#peter')
