require './../spec_helper'
Serenade = require('../../lib/serenade')

{defineProperty, defineAttribute} = Serenade

describe 'Serenade.defineProperty', ->
  beforeEach ->
    @object = {}

  describe 'dependsOn', ->
    it 'binds to dependencies', ->
      defineAttribute @object, 'first'
      defineAttribute @object, 'last'
      defineProperty @object, 'fullName',
        get: (first, last) -> first + " " + last
        dependsOn: ['first', 'last']
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").to.emit(@object["~fullName"], with: 'Peter Pan')

    it 'does not bind to dependencies when none are given', ->
      defineAttribute @object, 'first'
      defineAttribute @object, 'last'
      defineProperty @object, 'fullName',
        get: (first, last) -> first + " " + last
        dependsOn: []
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").not.to.emit(@object["~fullName"])

    it 'does not bind to dependencies when false given', ->
      defineAttribute @object, 'first'
      defineAttribute @object, 'last'
      defineProperty @object, 'fullName',
        get: (first, last) -> first + " " + last
        dependsOn: false
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").not.to.emit(@object["~fullName"])

    it 'binds to single dependency', ->
      defineAttribute @object, 'name'
      defineProperty @object, 'reverseName',
        get: (name) -> name.split("").reverse().join("") if @name
        dependsOn: 'name'
      expect(=> @object.name = 'Jonas').to.emit(@object["~reverseName"], with: 'sanoJ')

    context "reaching into an object", ->
      beforeEach ->
        defineProperty @object, 'bigName', dependsOn: 'name', get: -> @name.toUpperCase() if @name
        defineProperty @object, 'name', dependsOn: 'author.name', get: -> @author.name
        defineAttribute @object, 'author', value: Serenade(name: "Peter")

      it "observes changes to the property", ->
        @object.author = Serenade(name: "Jonas")
        expect(=> @object.author.name = 'test').to.emit(@object["~name"])

      it "can depend on properties which reach into other properties", ->
        @object.author = Serenade(name: "Jonas")
        expect(=> @object.author.name = 'test').to.emit(@object["~bigName"])

      it "triggers changes when object is assigned after event is bound", ->
        expect =>
          @object.author = Serenade(name: "Jonas")
          @object.author.name = "Kim"
        .to.emit(@object["~name"], count: 2)

      it "does not observe changes on objects which are no longer associated", ->
        expect =>
          @object.author = Serenade(name: "Jonas")
          oldAuthor = @object.author
          @object.author = Serenade(name: "Peter")
          oldAuthor.name = "Kim"
        .to.emit(@object["~name"], count: 2)

      it "observes changes to cached properties", ->
        defineProperty @object, 'cachedName', cache: true, dependsOn: "name", get: -> @name
        expect(@object.cachedName).to.eql("Peter")
        @object.author.name = "John"
        expect(@object.cachedName).to.eql("John")

      it "unbinds global subscribers when property no longer has any subscribers", ->
        foo = ->
        bar = ->
        @object["~name"].subscribe(foo)
        @object["~name"].subscribe(bar)
        expect(@object.author["~name"].subscribers.length).to.eql(1)
        expect(@object["~author"].subscribers.length).to.eql(1)
        @object["~name"].unsubscribe(foo)
        expect(@object.author["~name"].subscribers.length).to.eql(1)
        expect(@object["~author"].subscribers.length).to.eql(1)
        @object["~name"].unsubscribe(bar)
        expect(@object.author["~name"].subscribers.length).to.eql(0)
        expect(@object["~author"].subscribers.length).to.eql(0)
        @object["~name"].subscribe(bar)
        expect(@object.author["~name"].subscribers.length).to.eql(1)
        expect(@object["~author"].subscribers.length).to.eql(1)

      it "unbinds global subscribers when dependent property no longer has any subscribers", ->
        foo = ->
        bar = ->
        @object["~name"].subscribe(foo)
        @object["~bigName"].subscribe(bar)
        expect(@object.author["~name"].subscribers.length).to.eql(1)
        expect(@object["~author"].subscribers.length).to.eql(1)
        @object["~name"].unsubscribe(foo)
        expect(@object.author["~name"].subscribers.length).to.eql(1)
        expect(@object["~author"].subscribers.length).to.eql(1)
        @object["~bigName"].unsubscribe(bar)
        expect(@object.author["~name"].subscribers.length).to.eql(0)
        expect(@object["~author"].subscribers.length).to.eql(0)
        @object["~bigName"].subscribe(bar)
        expect(@object.author["~name"].subscribers.length).to.eql(1)
        expect(@object["~author"].subscribers.length).to.eql(1)

      it "triggers change event if value in other object has changed while no subscribers were attached", ->
        class Item extends Serenade.Model
          @attribute "parent"
          @property "active",
            dependsOn: "parent.active"
            get: -> @parent?.active

        model = Serenade(active: true, item: undefined)
        item = new Item(parent: model)

        model.active = false
        expect(-> model.active = true).to.emit item["~active"]

    context "reaching into a collection", ->
      beforeEach ->
        defineAttribute @object, 'authors', value: new Serenade.Collection()
        defineProperty @object, 'authorNames', dependsOn: "authors:name", get: -> @authors.map (a) -> a.name
        defineProperty @object, 'attribution', dependsOn: "authorNames", get: -> @authorNames.join(", ")

      it "observes changes to the entire collection", ->
        newAuthor = Serenade(name: "Anders")
        expect(=> @object.authors.push(newAuthor)).to.emit(@object["~authorNames"])

      it "observes changes to each individual object", ->
        @object.authors.push(Serenade(name: "Bert"))
        author = @object.authors[0]

        expect(-> author.name = 'test').to.emit(@object["~authorNames"])

      it "is not affected by additional event subscribers", ->
        @object["~authorNames"].subscribe -> @wasTriggered = true
        expect(=> @object.authors.push({ name: "Bert" })).to.emit(@object["~authorNames"])
        expect(@object.wasTriggered).to.be.ok

      it "observes changes to elements added after event is bound", ->
        expect =>
          @object.authors.push(Serenade(name: "Bert"))
          @object.authors[0].name = "Kim"
        .to.emit(@object["~authorNames"], count: 2)

      it "does not observe changes to elements no longer in the collcection", ->
        @object.authors.push(Serenade(name: "Bert"))
        expect =>
          oldAuthor = @object.authors[0]
          @object.authors.deleteAt(0)
          oldAuthor.name = 'test'
        .to.emit(@object["~authorNames"], count: 1)

      it "observes changes to newly assigned collections", ->
        expect =>
          @object.authors = new Serenade.Collection([Serenade(name: "Jonas")])
          @object.authors.push(Serenade(name: "Kim"))
        .to.emit(@object["~authorNames"], count: 2)

      it "no longer observes changes to old collections", ->
        oldAuthors = @object.authors
        expect =>
          @object.authors = new Serenade.Collection([Serenade(name: "Jonas")])
          oldAuthors.push(Serenade(name: "Kim"))
        .to.emit(@object["~authorNames"], count: 1)

      it "no longer observes changes to items in old collections", ->
        oldAuthors = @object.authors
        oldAuthors.push(Serenade(name: "Peter"))
        expect =>
          @object.authors = new Serenade.Collection([Serenade(name: "Jonas")])
          oldAuthors[0].name = "Kim"
        .to.emit(@object["~authorNames"], count: 1)

      it "unbinds global subscribers when property no longer has any subscribers", ->
        @object.authors = new Serenade.Collection([Serenade(name: "Jonas"), Serenade(name: "Kim")])
        foo = ->
        bar = ->
        @object["~authorNames"].subscribe(foo)
        @object["~authorNames"].subscribe(bar)
        expect(@object.authors[0]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors[1]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors.change.subscribers.length).to.eql(2)
        expect(@object["~authors"].subscribers.length).to.eql(1)
        @object["~authorNames"].unsubscribe(foo)
        expect(@object.authors[0]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors[1]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors.change.subscribers.length).to.eql(2)
        expect(@object["~authors"].subscribers.length).to.eql(1)
        @object["~authorNames"].unsubscribe(bar)
        expect(@object.authors[0]["~name"].subscribers.length).to.eql(0)
        expect(@object.authors[1]["~name"].subscribers.length).to.eql(0)
        expect(@object.authors.change.subscribers.length).to.eql(0)
        expect(@object["~authors"].subscribers.length).to.eql(0)
        @object["~authorNames"].subscribe(bar)
        expect(@object.authors[0]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors[1]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors.change.subscribers.length).to.eql(2)
        expect(@object["~authors"].subscribers.length).to.eql(1)

      it "unbinds global subscribers when dependent property no longer has any subscribers", ->
        @object.authors = new Serenade.Collection([Serenade(name: "Jonas"), Serenade(name: "Kim")])
        foo = ->
        bar = ->
        @object["~authorNames"].subscribe(foo)
        @object["~attribution"].subscribe(bar)
        expect(@object.authors[0]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors[1]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors.change.subscribers.length).to.eql(2)
        expect(@object["~authors"].subscribers.length).to.eql(1)
        @object["~authorNames"].unsubscribe(foo)
        expect(@object.authors[0]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors[1]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors.change.subscribers.length).to.eql(2)
        expect(@object["~authors"].subscribers.length).to.eql(1)
        @object["~attribution"].unsubscribe(bar)
        expect(@object.authors[0]["~name"].subscribers.length).to.eql(0)
        expect(@object.authors[1]["~name"].subscribers.length).to.eql(0)
        expect(@object.authors.change.subscribers.length).to.eql(0)
        expect(@object["~authors"].subscribers.length).to.eql(0)
        @object["~attribution"].subscribe(bar)
        expect(@object.authors[0]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors[1]["~name"].subscribers.length).to.eql(1)
        expect(@object.authors.change.subscribers.length).to.eql(2)
        expect(@object["~authors"].subscribers.length).to.eql(1)
