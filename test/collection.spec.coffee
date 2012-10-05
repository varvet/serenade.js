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

  it "can be serialized to JSON", ->
    expect(JSON.parse(JSON.stringify(@collection))).to.eql(["a", "b", "c"])

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
      expect(=> @collection.set(0, 'foo')).to.triggerEvent(@collection, 'change')
    it 'triggers a specific change event', ->
      expect(=> @collection.set(1, 'foo')).to.triggerEvent(@collection, 'change:1', with: ['foo'])
    it 'triggers a set event', ->
      expect(=> @collection.set(1, 'foo')).to.triggerEvent(@collection, 'set', with: [1, 'foo'])
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
    it 'triggers a change event', ->
      expect(=> @collection.update(["q", "x"])).to.triggerEvent(@collection, 'change', with: [@collection])
    it 'triggers an update event', ->
      expect(=> @collection.update(["q", "x"])).to.triggerEvent(@collection, 'update', with: [["a", "b", "c"], ["q", "x"]])
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
      @collection.push('a')
      expect(=> @collection.sort()).to.triggerEvent(@collection, 'update', with: [["a", "b", "c", "a"], ["a", "a", "b", "c"]])
    it 'triggers a change event', ->
      expect(=> @collection.sort()).to.triggerEvent(@collection, 'change', with: [@collection])

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
      expect(=> @collection.push("g")).to.triggerEvent(@collection, 'change')
    it 'triggers an add event', ->
      expect(=> @collection.push("g")).to.triggerEvent(@collection, 'add', with: ['g'])
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
      expect(@collection.get(0)).to.eql("a")
      expect(@collection.get(1)).to.eql("b")
      expect(@collection.get(2)).to.eql(undefined)
    it 'returns the item', ->
      expect(@collection.pop()).to.eql('c')
    it 'triggers a change event', ->
      expect(=> @collection.pop()).to.triggerEvent(@collection, 'change')
    it 'triggers a delete event', ->
      expect(=> @collection.pop()).to.triggerEvent(@collection, 'delete', with: [2, 'c'])
    it 'updates the length', ->
      @collection.pop()
      expect(@collection.length).to.eql(2)

  describe '#unshift', ->
    it 'adds an item to the collection', ->
      @collection.unshift('g')
      expect(@collection.get(0)).to.eql('g')
      expect(@collection.get(1)).to.eql('a')
      expect(@collection.get(2)).to.eql('b')
      expect(@collection.get(3)).to.eql('c')
    it 'triggers a change event', ->
      expect(=> @collection.unshift("g")).to.triggerEvent(@collection, 'change')
    it 'triggers an add event', ->
      @collection.unshift('g')
      expect(=> @collection.unshift("g")).to.triggerEvent(@collection, 'insert', with: [0, 'g'])
    it 'returns the item', ->
      expect(@collection.unshift('g')).to.eql('g')
    it 'updates the length', ->
      @collection.unshift('g')
      expect(@collection.length).to.eql(4)

  describe '#shift', ->
    it 'removes an item from the collection', ->
      @collection.shift()
      expect(@collection.get(0)).to.eql("b")
      expect(@collection.get(1)).to.eql("c")
      expect(@collection.get(2)).to.eql(undefined)
    it 'returns the item', ->
      expect(@collection.shift()).to.eql('a')
    it 'triggers a change event', ->
      expect(=> @collection.shift()).to.triggerEvent(@collection, 'change')
    it 'triggers a delete event', ->
      expect(=> @collection.shift()).to.triggerEvent(@collection, 'delete', with: [0, 'a'])
    it 'updates the length', ->
      @collection.shift()
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

  describe "#lastIndexOf", ->
    it "returns the last index of the given element", ->
      @collection = new Serenade.Collection(["c", "a", "b", "a"])
      expect(@collection.lastIndexOf("a")).to.eql(3)
      expect(@collection.lastIndexOf("b")).to.eql(2)
      expect(@collection.lastIndexOf("c")).to.eql(0)
      expect(@collection.lastIndexOf("d")).to.eql(-1)
    it "works without native implementation", ->
      original = Array.prototype.lastIndexOf
      Array.prototype.lastIndexOf = undefined

      @collection = new Serenade.Collection(["c", "a", "b", "a"])
      expect(@collection.lastIndexOf("a")).to.eql(3)
      expect(@collection.lastIndexOf("b")).to.eql(2)
      expect(@collection.lastIndexOf("c")).to.eql(0)
      expect(@collection.lastIndexOf("d")).to.eql(-1)

      Array.prototype.lastIndexOf = original

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

  describe '#insertAt', ->
    it 'inserts the item into the collection', ->
      @collection.insertAt(1, "d")
      expect(@collection.get(0)).to.eql("a")
      expect(@collection.get(1)).to.eql("d")
      expect(@collection.get(2)).to.eql("b")
      expect(@collection.get(3)).to.eql("c")
    it 'triggers a change event', ->
      expect(=> @collection.insertAt(1, "d")).to.triggerEvent(@collection, 'change')
    it 'triggers an insert event', ->
      expect(=> @collection.insertAt(1, "d")).to.triggerEvent(@collection, 'insert', with: [1, 'd'])
    it 'returns the item', ->
      expect(@collection.insertAt(1, "d")).to.eql('d')

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
      expect(=> @collection.deleteAt(1)).to.triggerEvent(@collection, 'change')
    it 'triggers a delete event', ->
      expect(=> @collection.deleteAt(1)).to.triggerEvent(@collection, 'delete', with: [1, 'b'])
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
    it "does nothing and returns undefined if the item doesn't exist", ->
      expect(@collection.delete('z')).to.be.undefined
      expect(@collection[0]).to.eql("a")
      expect(@collection[1]).to.eql("b")
      expect(@collection[2]).to.eql("c")

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

  describe "#join", ->
    it "joins the array with commas", ->
      expect(@collection.join()).to.eql("a,b,c")
    it "joins the array with the given separator", ->
      expect(@collection.join(":")).to.eql("a:b:c")

  describe "#reverse", ->
    it "reverses the collection", ->
      @collection.reverse()
      expect(@collection[0]).to.eql("c")
      expect(@collection[1]).to.eql("b")
      expect(@collection[2]).to.eql("a")
    it "returns self", ->
      expect(@collection.reverse()).to.eql(@collection)
    it "triggers an update event", ->
      expect(=> @collection.reverse()).to.triggerEvent(@collection, 'update', with: [["a", "b", "c"], ["c", "b", "a"]])
    it "triggers a change event", ->
      expect(=> @collection.reverse()).to.triggerEvent(@collection, 'change', with: [@collection])

  describe "#toString", ->
    it "joins the array with commas", ->
      expect(@collection.toString()).to.eql("a,b,c")

  describe "#toLocaleString", ->
    it "joins the array with commas", ->
      expect(@collection.toLocaleString()).to.eql("a,b,c")

  describe "#concat", ->
    it "returns a new collection with the given items appended", ->
      array = @collection.concat(["d", "e"], ["f"])
      expect(array.length).to.eql(6)
      expect(array[3]).to.eql("d")
      expect(array[4]).to.eql("e")
      expect(array[5]).to.eql("f")
    it "returns a new collection with the given collections appended", ->
      array = @collection.concat(new Serenade.Collection(["d", "e"]), ["f"])
      expect(array.length).to.eql(6)
      expect(array[3]).to.eql("d")
      expect(array[4]).to.eql("e")
      expect(array[5]).to.eql("f")

  describe "#slice", ->
    it "slices the collection", ->
      array = @collection.slice(1)
      expect(array[0]).to.eql("b")
      expect(array[1]).to.eql("c")
      expect(array[2]).to.eql(undefined)
      expect(array).to.be.an.instanceof(Serenade.Collection)

  describe '#splice', ->
    it 'splices the given values into the collection', ->
      @collection.splice(1, 1, "q", "x")
      expect(@collection[0]).to.eql("a")
      expect(@collection[1]).to.eql("q")
      expect(@collection[2]).to.eql("x")
      expect(@collection[3]).to.eql("c")
    it 'splices the removed elements as a collection', ->
      deleted = @collection.splice(1, 1, "q", "x")
      expect(deleted.length).to.eql(1)
      expect(deleted.get(0)).to.eql("b")
    it 'triggers an update event', ->
      expect(=> @collection.splice(1, 1, "q", "x")).to.triggerEvent(@collection, 'update', with: [["a", "b", "c"], ["a", "q", "x", "c"]])
    it 'triggers a change event', ->
      expect(=> @collection.splice(1, 1, "q", "x")).to.triggerEvent(@collection, 'change', with: [@collection])

  describe "#every", ->
    it "returns whether every item matches the given function", ->
      expect(@collection.every((item) -> item.match(/[abc]/))).to.be.true
      expect(@collection.every((item) -> item.match(/[ab]/))).to.be.false
    it "works without native implementation", ->
      original = Array.prototype.every

      Array.prototype.every = undefined
      expect(@collection.every((item) -> item.match(/[abc]/))).to.be.true
      expect(@collection.every((item) -> item.match(/[ab]/))).to.be.false
      Array.prototype.every = original

  describe "#some", ->
    it "returns whether some item matches the given function", ->
      expect(@collection.some((item) -> item.match(/[abc]/))).to.be.true
      expect(@collection.some((item) -> item.match(/[ab]/))).to.be.true
      expect(@collection.some((item) -> item.match(/[d]/))).to.be.false
    it "works without native implementation", ->
      original = Array.prototype.some

      Array.prototype.some = undefined
      expect(@collection.some((item) -> item.match(/[abc]/))).to.be.true
      expect(@collection.some((item) -> item.match(/[ab]/))).to.be.true
      expect(@collection.some((item) -> item.match(/[d]/))).to.be.false
      Array.prototype.some = original

  describe "#reduce", ->
    it "reduces the collection to a value", ->
      expect(@collection.reduce((agg, item) -> agg + ":" + item)).to.eql("a:b:c")
      expect(@collection.reduce(((agg, item) -> agg + ":" + item), "foo")).to.eql("foo:a:b:c")
      expect(@collection.reduce((agg, item, index, obj) -> agg + ":" + index + obj.join())).to.eql("a:1a,b,c:2a,b,c")

    it "works without native implementation", ->
      original = Array.prototype.reduce

      Array.prototype.reduce = undefined
      expect(@collection.reduce((agg, item) -> agg + ":" + item)).to.eql("a:b:c")
      expect(@collection.reduce(((agg, item) -> agg + ":" + item), "foo")).to.eql("foo:a:b:c")
      expect(@collection.reduce((agg, item, index, obj) -> agg + ":" + index + obj.join())).to.eql("a:1a,b,c:2a,b,c")
      Array.prototype.reduce = original

  describe "#reduceRight", ->
    it "reduces the collection to a value", ->
      expect(@collection.reduceRight((agg, item) -> agg + ":" + item)).to.eql("c:b:a")
      expect(@collection.reduceRight(((agg, item) -> agg + ":" + item), "foo")).to.eql("foo:c:b:a")
      expect(@collection.reduceRight((agg, item, index, obj) -> agg + ":" + index + obj.join())).to.eql("c:1a,b,c:0a,b,c")

    it "works without native implementation", ->
      original = Array.prototype.reduceRight

      Array.prototype.reduceRight = undefined
      expect(@collection.reduceRight((agg, item) -> agg + ":" + item)).to.eql("c:b:a")
      expect(@collection.reduceRight(((agg, item) -> agg + ":" + item), "foo")).to.eql("foo:c:b:a")
      expect(@collection.reduceRight((agg, item, index, obj) -> agg + ":" + index + obj.join())).to.eql("c:1a,b,c:0a,b,c")
      Array.prototype.reduceRight = original

  describe "#clone", ->
    it "returns a collection which is identical, but not the same object", ->
      clone = @collection.clone()
      expect(clone).not.to.equal(@collection)
      expect(clone[0]).to.eql("a")
      expect(clone[1]).to.eql("b")
      expect(clone[2]).to.eql("c")
      expect(clone.length).to.eql(3)

  describe "#first", ->
    it "returns the first element", ->
      expect(@collection.first()).to.eql("a")

  describe "#last", ->
    it "returns the last element", ->
      expect(@collection.last()).to.eql("c")
