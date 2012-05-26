require './spec_helper'
{Serenade} = require '../src/serenade'
{expect} = require('chai')

describe 'Serenade.Collection', ->
  beforeEach ->
    @collection = new Serenade.Collection(['a', 'b', 'c'])

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

  describe '#update', ->
    it 'updates length', ->
      @collection.update([1,2])
      expect(@collection.length).to.eql(2)
    it 'returns the new list', ->
      expect(@collection.update([1,2])).to.eql([1,2])

  describe '#sort', ->
    it 'updates the order of the items in the collection', ->
      @collection.push('a')
      @collection.sort()
      expect(@collection.list).to.eql(['a', 'a', 'b', 'c'])
    it 'updates the order of the items in the collection', ->
      @collection.sort((a, b) -> if a > b then -1 else 1)
      expect(@collection.list).to.eql(['c', 'b', 'a'])
    it 'triggers an update event', ->
      @collection.sort()
      expect(@collection).to.have.receivedEvent('update')

  describe '#sortBy', ->
    it 'updates the order of the items in the collection', ->
      item1 = {name: 'CJ', age: 30}
      item2 = {name: 'Anders', age: 37}
      @collection.update([item1, item2])

      @collection.sortBy('age')
      expect(@collection.list).to.eql([item1, item2])

      @collection.sortBy('name')
      expect(@collection.list).to.eql([item2, item1])

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

  describe '#indexOf', ->
    it 'returns where in the collection the given item is', ->
      expect(@collection.indexOf('a')).to.eql(0)
      expect(@collection.indexOf('b')).to.eql(1)
    it 'works without native indexOf function', ->
      @collection.list.indexOf = undefined
      expect(@collection.indexOf('a')).to.eql(0)
      expect(@collection.indexOf('b')).to.eql(1)

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
