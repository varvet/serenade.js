require './../spec_helper'

describe "Sereande.Model.collection", ->
  beforeEach ->
    class @Person extends Serenade.Model
      @collection "numbers"
      @collection "authors"

      @property 'authorNames', dependsOn: ['authors', 'authors:name']
    @object = new @Person()

  it 'is initialized to a collection', ->
    expect(@object.numbers[0]).to.not.exist
    @object.numbers.push(5)
    expect(@object.numbers[0]).to.eql(5)

  it 'updates the collection on set', ->
    @object.numbers = [1,2,3]
    expect(@object.numbers[0]).to.eql(1)

  it 'triggers a change event when collection is changed', ->
    collection = @object.numbers
    expect(-> collection.push(4)).to.triggerEvent(@object.numbers_property, with: [@object.numbers])

  it 'can reach into collections and observe changes to the entire collection', ->
    newAuthor = Serenade(name: "Anders")
    expect(=> @object.authors.push(newAuthor)).to.triggerEvent(@object.authorNames_property)

  it 'can reach into collections and observe changes to each individual object', ->
    @object.authors.push(Serenade(name: "Bert"))
    author = @object.authors[0]
    expect(-> author.name = 'test').to.triggerEvent(@object.authorNames_property)

  it 'can reach into collections and observe changes to each individual object when defined on prototype', ->
    @child = Object.create(@object)
    @child.authors.push(Serenade(name: "Bert"))
    author = @child.authors[0]
    expect(-> author.name = 'test').to.triggerEvent(@child.authorNames_property)
    expect(-> author.name = 'test').not.to.triggerEvent(@object.authorNames_property)

  it 'does not observe changes to elements no longer in the collcection', ->
    @object.authors.push(Serenade(name: "Bert"))
    oldAuthor = @object.authors[0]
    oldAuthor.schmoo = true
    @object.authors.deleteAt(0)
    expect(-> oldAuthor.name = 'test').not.to.triggerEvent(@object.authorNames_property)

  it 'adds a count property', ->
    @object.authors = ["John", "Peter"]
    expect(@object.authorsCount).to.eql(2)
    expect(=> @object.authors.push("Harry")).to.triggerEvent(@object.authorsCount_property)
