require './../spec_helper'

describe 'Collection', ->
  beforeEach ->
    @setupDom()

  it 'compiles a collection instruction', ->
    context = { people: [{ name: 'jonas' }, { name: 'peter' }] }

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', context
    expect(@body).to.have.element('ul > li#jonas')
    expect(@body).to.have.element('ul > li#peter')

  it 'renders nothing if collection is not defined', ->
    context = {}

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', context
    expect(@body).to.have.element('ul')

  it 'can reference the items itself', ->
    context = { colors: ['red', 'blue'] }

    @render '''
      ul
        - collection @colors
          li[id=@ style:color=@] @
    ''', context
    expect(@body).to.have.element('ul > li#red')
    expect(@body).to.have.element('ul > li#blue')
    expect(@body.querySelector("#red")).to.have.text("red")
    expect(@body.querySelector("#blue")).to.have.text("blue")
    expect(@body.querySelector("li").style.color).to.eql("red")

  it 'compiles a Serenade.collection in a collection instruction', ->
    context = { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', context
    expect(@body).to.have.element('ul > li#jonas')
    expect(@body).to.have.element('ul > li#peter')

  it 'updates a collection dynamically', ->
    context = { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', context
    expect(@body).to.have.element('ul > li#jonas')
    expect(@body).to.have.element('ul > li#peter')
    context.people.update([{ name: 'anders' }, { name: 'jimmy' }])
    expect(@body).not.to.have.element('ul > li#jonas')
    expect(@body).not.to.have.element('ul > li#peter')
    expect(@body).to.have.element('ul > li#anders')
    expect(@body).to.have.element('ul > li#jimmy')

  it 'removes item from collection when requested', ->
    context = { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', context
    expect(@body).to.have.element('ul > li#jonas')
    expect(@body).to.have.element('ul > li#peter')
    context.people.deleteAt(0)
    expect(@body).not.to.have.element('ul > li#jonas')
    expect(@body).to.have.element('ul > li#peter')

  it 'inserts item into collection when requested', ->
    context = { people: new Serenade.Collection([{ name: 'jonas' }, { name: 'peter' }]) }

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', context
    expect(@body).to.have.element('ul > li#jonas')
    expect(@body).to.have.element('ul > li#peter')
    context.people.insertAt(1, {name: "carry"})
    expect(@body).to.have.element('ul > li#jonas')
    expect(@body).to.have.element('ul > li#carry')
    expect(@body).to.have.element('ul > li#peter')

  it 'can insert at index zero', ->
    context = { people: new Serenade.Collection([]) }

    @render '''
      ul
        - collection @people
          li[id=name]
    ''', context
    context.people.insertAt(0, {name: "carry"})
    expect(@body).to.have.element('ul > li#carry')

  it 'updates when the collection is replaced', ->
    context = Serenade(things: ["hello"])

    @render """
      ul
        - collection @things
          li[id=@]
    """, context
    context.things = ["world"]
    expect(@body).to.have.element('ul > li#world')
    expect(@body).not.to.have.element('ul > li#hello')

  it 'updates when the collection is replaced for serenade contexts', ->
    class Thing extends Serenade.Model
      @property "things"
    context = new Thing(things: ["hello"])

    @render """
      ul
        - collection @things
          li[id=@]
    """, context
    context.things = ["world"]
    expect(@body).to.have.element('ul > li#world')
    expect(@body).not.to.have.element('ul > li#hello')

  it 'can handle being a root node', ->
    context = Serenade(things: ["hello"])

    @render """
      - collection @things
        @
    """, context
    expect(@body).to.have.text("hello")
    context.things = []
    expect(@body).to.have.text("")
    context.things = ["foo", "bar"]
    expect(@body).not.to.have.text("hello")
    expect(@body).to.have.text("foobar")

  it 'does not rerender collection items which have not changed', ->
    context = { things: new Serenade.Collection([{ name: "foo" }, {name: "bar"}]) }
    @render """
      ul
        - collection @things
          li[id=@name]
    """, context
    @body.querySelector("#foo").setAttribute("thing", "true")
    context.things.push(name: "quox")
    expect(@body).to.have.element('ul > li#foo[thing]')
    expect(@body).to.have.element('ul > li#quox')

  it 'correctly transforms any diff in collections', ->
    iterations = 100
    rand = (from, to) -> from + Math.floor(Math.random() * (to - from))
    letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    random_array = (length) ->
      for i in [0...rand(1, length)]
        letters[rand(0, letters.length)]

    context = Serenade(things: [])
    @render """
      ul
        - collection @things
          li @
    """, context

    for i in [0...iterations]
      context.things = random_array(rand(1, 10))
      expect(li.textContent for li in @body.querySelectorAll("li")).to.eql(context.things)

  it 'does not apply transform multiple times if event is async', ->
    context = {}
    Serenade.defineProperty(context, "things", async: true)
    context.things_property.bind(->)
    context.things = ["a", "b", "c"]

    @render """
      ul#things
        - collection @things
          li[class=@]
    """, context
    context.things_property.resolve()

    expect(n.className for n in @body.querySelectorAll("#things li")).to.eql(["a", "b", "c"])

  it 'can render same collection multiple times', ->
    context = { people: new Serenade.Collection(["jonas"]) }

    @render '''
      ul#one
        - collection @people
          li.one[class=@]
      ul#two
        - collection @people
          li.two[class=@]
      ul#three
        - collection @people
          li.three[class=@]
    ''', context
    context.people.push("peter")
    context.people.push("kim")
    expect(@body).to.have.element('#one > .jonas')
    expect(@body).to.have.element('#one > .kim')
    expect(@body).to.have.element('#one > .peter')
    expect(@body).to.have.element('#two > .jonas')
    expect(@body).to.have.element('#two > .kim')
    expect(@body).to.have.element('#one > .peter')
    expect(@body).to.have.element('#three > .jonas')
    expect(@body).to.have.element('#three > .kim')
    context.people.delete("peter")
    expect(@body).to.have.element('#one > .jonas')
    expect(@body).to.have.element('#one > .kim')
    expect(@body).not.to.have.element('#one > .peter')
    expect(@body).to.have.element('#two > .jonas')
    expect(@body).to.have.element('#two > .kim')
    expect(@body).not.to.have.element('#one > .peter')
    expect(@body).to.have.element('#three > .jonas')
    expect(@body).to.have.element('#three > .kim')
    expect(@body.querySelector('#one').children.length).to.eql(2)
    expect(@body.querySelector('#two').children.length).to.eql(2)
    expect(@body.querySelector('#three').children.length).to.eql(2)
