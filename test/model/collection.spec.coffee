require './../spec_helper'
{Serenade} = require '../../src/serenade'
{Model} = require '../../src/model'
{expect} = require('chai')

describe "Sereande.Model.collection", ->
  beforeEach ->
    class @Person extends Model
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
    expect(-> collection.push(4)).to.triggerEvent(@object.change_numbers, with: [@object.numbers])

  it 'can reach into collections and observe changes to the entire collection', ->
    newAuthor = Serenade(name: "Anders")
    expect(=> @object.authors.push(newAuthor)).to.triggerEvent(@object.change_authorNames)

  it 'can reach into collections and observe changes to each individual object', ->
    @object.authors.push(Serenade(name: "Bert"))
    @object.authorNames
    author = @object.authors[0]
    expect(-> author.name = 'test').to.triggerEvent(@object.change_authorNames)

  it 'can reach into collections and observe changes to each individual object when defined on prototype', ->
    @child = Object.create(@object)
    @child.authors.push(Serenade(name: "Bert"))
    @child.authorNames
    author = @child.authors[0]
    expect(-> author.name = 'test').to.triggerEvent(@child.change_authorNames)
    expect(-> author.name = 'test').not.to.triggerEvent(@object.change_authorNames)

  it 'does not trigger events multiple times when reaching and property is accessed multiple times', ->
    @object.authors.push(Serenade(name: "Bert"))
    @object.authorNames
    @object.authorNames

    author = @object.authors[0]
    expect(-> author.name = 'test').to.triggerEvent(@object.change_authorNames)

  it 'does not observe changes to elements no longer in the collcection', ->
    @object.authorNames
    @object.authors.push(Serenade(name: "Bert"))
    oldAuthor = @object.authors[0]
    oldAuthor.schmoo = true
    @object.authors.deleteAt(0)
    expect(-> oldAuthor.name = 'test').not.to.triggerEvent(@object.change_authorNames)
