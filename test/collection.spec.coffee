require './spec_helper'
{Serenade} = require '../src/serenade'
{expect} = require('chai')

describe 'Serenade.Collection', ->
  beforeEach ->
    @collection = new Serenade.Collection(['a', 'b', 'c'])

  it "is compatible with CoffeeScript's array comprehensions", ->
    letters = (letter.toUpperCase() for letter in @collection)
    expect(letters.join("")).to.eql("ABC")

  it "sets the length", ->
    expect(@collection.length).to.eql(3)
  it "sets the length to zero when empty", ->
    @collection = new Serenade.Collection([])
    expect(@collection.length).to.eql(0)

  describe '#get', ->
    it 'gets an item from the collection', ->
      expect(@collection.get(0)).to.eql('a')
      expect(@collection.get(1)).to.eql('b')
      expect(@collection.get(2)).to.eql('c')

  describe '#set', ->
    it 'sets an item in the collection', ->
      expect(@collection.get(0)).to.eql('a')
      @collection.set(0, 'foo')
      expect(@collection.get(0)).to.eql('foo')
    it 'triggers a change event', ->
      @collection.set(0, 'foo')
      expect(@collection).to.have.receivedEvent('change')
    it 'triggers a specific change event', ->
      @collection.set(1, 'foo')
      expect(@collection).to.have.receivedEvent('change:1', with: ['foo'])
    it 'triggers a set event', ->
      @collection.set(1, 'foo')
      expect(@collection).to.have.receivedEvent('set', with: [1, 'foo'])
    it 'returns the item', ->
      expect(@collection.set(0, 'foo')).to.eql('foo')
    it 'allows direct property access', ->
      @collection.set(0, 'foo')
      expect(@collection[0]).to.eql('foo')

  describe '#update', ->
    it 'sets the given properties', ->
      @collection.update(["q", "x"])
      expect(@collection.get(0)).to.eql("q")
      expect(@collection.get(1)).to.eql("x")
      expect(@collection.get(2)).to.eql(undefined)
    it 'sets the given properties directly', ->
      @collection.update(["q", "x"])
      expect(@collection[0]).to.eql("q")
      expect(@collection[1]).to.eql("x")
      expect(@collection[2]).to.eql(undefined)
    it 'updates length', ->
      @collection.update(["q", "x"])
      expect(@collection.length).to.eql(2)
    it 'returns self', ->
      expect(@collection.update([1,2])).to.eql([1,2])

  describe '#sort', ->
    it 'updates the order of the items in the collection', ->
      @collection.push('a')
      @collection.sort()
      expect(@collection[0]).to.eql("a")
      expect(@collection[1]).to.eql("a")
      expect(@collection[2]).to.eql("b")
      expect(@collection[3]).to.eql("c")
    it 'updates the order of the items in the collection', ->
      @collection.sort((a, b) -> if a > b then -1 else 1)
      expect(@collection[0]).to.eql("c")
      expect(@collection[1]).to.eql("b")
      expect(@collection[2]).to.eql("a")

    it 'triggers an update event', ->
      @collection.sort()
      expect(@collection).to.have.receivedEvent('update')

  describe '#sortBy', ->
    it 'updates the order of the items in the collection', ->
      item1 = {name: 'CJ', age: 30}
      item2 = {name: 'Anders', age: 37}
      @collection.update([item1, item2])

      @collection.sortBy('age')
      expect(@collection[0]).to.eql(item1)
      expect(@collection[1]).to.eql(item2)

      @collection.sortBy('name')
      expect(@collection[0]).to.eql(item2)
      expect(@collection[1]).to.eql(item1)

    it 'works with Serenade Models', ->
      item1 = new Serenade.Model(name: 'CJ', age: 30)
      item2 = new Serenade.Model(name: 'Anders', age: 37)
      @collection.update([item1, item2])

      @collection.sortBy('name')
      expect(@collection[0]).to.eql(item2)
      expect(@collection[1]).to.eql(item1)

  describe '#push', ->
    it 'adds an item to the collection', ->
      @collection.push('g')
      expect(@collection.get(3)).to.eql('g')
    it 'triggers a change event', ->
      @collection.push('g')
      expect(@collection).to.have.receivedEvent('change')
    it 'triggers an add event', ->
      @collection.push('g')
      expect(@collection).to.have.receivedEvent('add', with: ['g'])
    it 'returns the item', ->
      expect(@collection.push('g')).to.eql('g')
    it 'makes is accessible as a property', ->
      @collection.push('g')
      expect(@collection[3]).to.eql("g")
    it 'updates the length', ->
      @collection.push('g')
      expect(@collection.length).to.eql(4)
  describe '#pop', ->
    it 'removes an item from the collection', ->
      @collection.pop()
      expect(@collection.get(2)).to.eql(undefined)
    it 'returns the item', ->
      expect(@collection.pop()).to.eql('c')
    it 'triggers a change event', ->
      @collection.pop()
      expect(@collection).to.have.receivedEvent('change')
    it 'triggers a delete event', ->
      @collection.pop()
      expect(@collection).to.have.receivedEvent('delete', with: [2, 'c'])
    it 'updates the length', ->
      @collection.pop()
      expect(@collection.length).to.eql(2)

  describe '#indexOf', ->
    it 'returns where in the collection the given item is', ->
      expect(@collection.indexOf('a')).to.eql(0)
      expect(@collection.indexOf('b')).to.eql(1)
      expect(@collection.indexOf('foo')).to.eql(-1)
    it 'works without native indexOf function', ->
      original = Array.prototype.indexOf
      Array.prototype.indexOf = undefined

      expect(@collection.indexOf('a')).to.eql(0)
      expect(@collection.indexOf('b')).to.eql(1)
      expect(@collection.indexOf('foo')).to.eql(-1)

      Array.prototype.indexOf = original

  describe '#includes', ->
    it 'returns true if the item exists in the collection', ->
      expect(@collection.includes('b')).to.be.true
    it "returns false if the item doesn't exist in the collection", ->
      expect(@collection.includes('z')).to.be.false

  describe '#find', ->
    it 'returns the first object that matches the predicate function', ->
      predicate = (item) -> item.toUpperCase() == 'B'
      expect(@collection.find(predicate)).to.eql('b')
    it 'returns undefined when no object matches the predicate function', ->
      predicate = (item) -> item.length > 1
      expect(@collection.find(predicate)).to.equal(undefined)

  describe '#deleteAt', ->
    it 'removes the item from the collection', ->
      @collection.deleteAt(1)
      expect(@collection.get(0)).to.eql('a')
      expect(@collection.get(1)).to.eql('c')
      expect(@collection.get(2)).to.eql(undefined)
    it 'removes the property and reorders the remaining ones', ->
      @collection.deleteAt(1)
      expect(@collection[0]).to.eql('a')
      expect(@collection[1]).to.eql('c')
      expect(@collection[2]).to.eql(undefined)
    it 'triggers a change event', ->
      @collection.deleteAt(1)
      expect(@collection).to.have.receivedEvent('change')
    it 'triggers a delete event', ->
      @collection.deleteAt(1)
      expect(@collection).to.have.receivedEvent('delete', with: [1, 'b'])
    it 'returns the item', ->
      expect(@collection.deleteAt(1)).to.eql('b')

  describe '#delete', ->
    it 'removes the item from the collection', ->
      @collection.delete('b')
      expect(@collection.get(0)).to.eql('a')
      expect(@collection.get(1)).to.eql('c')
      expect(@collection.get(2)).to.be.undefined
    it 'returns the item', ->
      expect(@collection.delete('b')).to.eql('b')
    it "returns undefined if the item doesn't exist", ->
      expect(@collection.delete('z')).to.be.undefined

  describe '#toArray', ->
    it "returns the same values", ->
      array = @collection.toArray()
      expect(array[0]).to.eql("a")
      expect(array[1]).to.eql("b")
      expect(array[2]).to.eql("c")
    it "returns an array", ->
      expect(Array.isArray(@collection.toArray())).to.be.true

  describe '#serialize', ->
    it "serializes the array", ->
      collection = new Serenade.Collection([{serialize: -> "foo"}, "bar"])
      expect(collection.serialize()).to.eql(["foo", "bar"])

  describe "#forEach", ->
    it "iterates over the collection", ->
      array = []
      @collection.forEach (val, index) -> array[index] = val
      expect(array).to.eql(["a", "b", "c"])
    it "returns undefined", ->
      expect(@collection.forEach(->)).to.be.undefined
    it "works without native forEach implementation", ->
      array = []
      original = Array.prototype.forEach

      Array.prototype.forEach = undefined
      @collection.forEach (val, index) -> array[index] = val
      Array.prototype.forEach = original

      expect(array).to.eql(["a", "b", "c"])
      expect(@collection.forEach(->)).to.be.undefined

  describe "#map", ->
    it "maps over the collection", ->
      array = @collection.map (val, index) -> [index, val]
      expect(array[0]).to.eql([0, "a"])
      expect(array[1]).to.eql([1, "b"])
      expect(array[2]).to.eql([2, "c"])
      expect(array).to.be.an.instanceof(Serenade.Collection)
    it "works without native map implementation", ->
      original = Array.prototype.map

      Array.prototype.map = undefined
      array = @collection.map (val, index) -> [index, val]
      Array.prototype.map = original

      expect(array[0]).to.eql([0, "a"])
      expect(array[1]).to.eql([1, "b"])
      expect(array[2]).to.eql([2, "c"])
      expect(array).to.be.an.instanceof(Serenade.Collection)

  describe "#filter", ->
    it "filters the collections", ->
      array = @collection.filter (item) -> item in ["a", "c"]
      expect(array[0]).to.eql("a")
      expect(array[1]).to.eql("c")
      expect(array).to.be.an.instanceof(Serenade.Collection)
    it "works without native map implementation", ->
      original = Array.prototype.filter

      Array.prototype.filter = undefined
      array = @collection.filter (item) -> item in ["a", "c"]
      Array.prototype.filter = original

      expect(array[0]).to.eql("a")
      expect(array[1]).to.eql("c")
      expect(array).to.be.an.instanceof(Serenade.Collection)
