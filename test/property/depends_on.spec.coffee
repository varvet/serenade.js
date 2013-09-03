require './../spec_helper'

{defineProperty} = Serenade

describe 'Serenade.defineProperty', ->
  beforeEach ->
    @object = {}

  describe 'dependsOn', ->
    it 'binds to dependencies', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: ['first', 'last']
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").to.triggerEvent(@object.fullName_property, with: ['undefined Pan', 'Peter Pan'])

    it 'does not bind to dependencies when none are given', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: []
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").not.to.triggerEvent(@object.fullName_property)

    it 'does not bind to dependencies when false given', ->
      defineProperty @object, 'first'
      defineProperty @object, 'last'
      defineProperty @object, 'fullName',
        get: -> @first + " " + @last
        dependsOn: false
      @object.last = 'Pan'
      expect(=> @object.first = "Peter").not.to.triggerEvent(@object.fullName_property)

    it 'binds to single dependency', ->
      defineProperty @object, 'name'
      defineProperty @object, 'reverseName',
        get: -> @name.split("").reverse().join("") if @name
        dependsOn: 'name'
      expect(=> @object.name = 'Jonas').to.triggerEvent(@object.reverseName_property, with: [undefined, 'sanoJ'])

    context "reaching into an object", ->
      beforeEach ->
        defineProperty @object, 'bigName', dependsOn: 'name', get: -> @name.toUpperCase() if @name
        defineProperty @object, 'name', dependsOn: 'author.name', get: -> @author.name
        defineProperty @object, 'author', value: Serenade(name: "Peter")

      it "observes changes to the property", ->
        @object.author = Serenade(name: "Jonas")
        expect(=> @object.author.name = 'test').to.triggerEvent(@object.name_property)

      it "can depend on properties which reach into other properties", ->
        @object.author = Serenade(name: "Jonas")
        expect(=> @object.author.name = 'test').to.triggerEvent(@object.bigName_property)

      it "triggers changes when object is assigned after event is bound", ->
        expect =>
          @object.author = Serenade(name: "Jonas")
          @object.author.name = "Kim"
        .to.triggerEvent(@object.name_property, count: 2)

      it "does not observe changes on objects which are no longer associated", ->
        expect =>
          @object.author = Serenade(name: "Jonas")
          oldAuthor = @object.author
          @object.author = Serenade(name: "Peter")
          oldAuthor.name = "Kim"
        .to.triggerEvent(@object.name_property, count: 2)

      it "observes changes to cached properties", ->
        defineProperty @object, 'cachedName', cache: true, dependsOn: "name", get: -> @name
        expect(@object.cachedName).to.eql("Peter")
        @object.author.name = "John"
        expect(@object.cachedName).to.eql("John")

      it "unbinds global listeners when property no longer has any listeners", ->
        foo = ->
        bar = ->
        @object.name_property.bind(foo)
        @object.name_property.bind(bar)
        expect(@object.author.name_property.listeners.length).to.eql(1)
        expect(@object.author_property.listeners.length).to.eql(1)
        @object.name_property.unbind(foo)
        expect(@object.author.name_property.listeners.length).to.eql(1)
        expect(@object.author_property.listeners.length).to.eql(1)
        @object.name_property.unbind(bar)
        expect(@object.author.name_property.listeners.length).to.eql(0)
        expect(@object.author_property.listeners.length).to.eql(0)
        @object.name_property.bind(bar)
        expect(@object.author.name_property.listeners.length).to.eql(1)
        expect(@object.author_property.listeners.length).to.eql(1)

      it "unbinds global listeners when dependent property no longer has any listeners", ->
        foo = ->
        bar = ->
        @object.name_property.bind(foo)
        @object.bigName_property.bind(bar)
        expect(@object.author.name_property.listeners.length).to.eql(1)
        expect(@object.author_property.listeners.length).to.eql(1)
        @object.name_property.unbind(foo)
        expect(@object.author.name_property.listeners.length).to.eql(1)
        expect(@object.author_property.listeners.length).to.eql(1)
        @object.bigName_property.unbind(bar)
        expect(@object.author.name_property.listeners.length).to.eql(0)
        expect(@object.author_property.listeners.length).to.eql(0)
        @object.bigName_property.bind(bar)
        expect(@object.author.name_property.listeners.length).to.eql(1)
        expect(@object.author_property.listeners.length).to.eql(1)

    context "reaching into a collection", ->
      beforeEach ->
        defineProperty @object, 'authors', value: new Serenade.Collection()
        defineProperty @object, 'authorNames', dependsOn: "authors:name", get: -> @authors.map (a) -> a.name
        defineProperty @object, 'attribution', dependsOn: "authorNames", get: -> @authorNames.join(", ")

      it "observes changes to the entire collection", ->
        newAuthor = Serenade(name: "Anders")
        expect(=> @object.authors.push(newAuthor)).to.triggerEvent(@object.authorNames_property)

      it "observes changes to each individual object", ->
        @object.authors.push(Serenade(name: "Bert"))
        author = @object.authors[0]
        expect(-> author.name = 'test').to.triggerEvent(@object.authorNames_property)

      it "is not affected by additional event listeners", ->
        @object.authorNames_property.bind -> @wasTriggered = true
        expect(=> @object.authors.push({ name: "Bert" })).to.triggerEvent(@object.authorNames_property)
        expect(@object.wasTriggered).to.be.ok

      it "observes changes to elements added after event is bound", ->
        expect =>
          @object.authors.push(Serenade(name: "Bert"))
          @object.authors[0].name = "Kim"
        .to.triggerEvent(@object.authorNames_property, count: 2)

      it "does not observe changes to elements no longer in the collcection", ->
        @object.authors.push(Serenade(name: "Bert"))
        expect =>
          oldAuthor = @object.authors[0]
          @object.authors.deleteAt(0)
          oldAuthor.name = 'test'
        .to.triggerEvent(@object.authorNames_property, count: 1)

      it "observes changes to newly assigned collections", ->
        expect =>
          @object.authors = new Serenade.Collection([Serenade(name: "Jonas")])
          @object.authors.push(Serenade(name: "Kim"))
        .to.triggerEvent(@object.authorNames_property, count: 2)

      it "no longer observes changes to old collections", ->
        oldAuthors = @object.authors
        expect =>
          @object.authors = new Serenade.Collection([Serenade(name: "Jonas")])
          oldAuthors.push(Serenade(name: "Kim"))
        .to.triggerEvent(@object.authorNames_property, count: 1)

      it "no longer observes changes to items in old collections", ->
        oldAuthors = @object.authors
        oldAuthors.push(Serenade(name: "Peter"))
        expect =>
          @object.authors = new Serenade.Collection([Serenade(name: "Jonas")])
          oldAuthors[0].name = "Kim"
        .to.triggerEvent(@object.authorNames_property, count: 1)

      it "unbinds global listeners when property no longer has any listeners", ->
        @object.authors = new Serenade.Collection([Serenade(name: "Jonas"), Serenade(name: "Kim")])
        foo = ->
        bar = ->
        @object.authorNames_property.bind(foo)
        @object.authorNames_property.bind(bar)
        expect(@object.authors[0].name_property.listeners.length).to.eql(1)
        expect(@object.authors[1].name_property.listeners.length).to.eql(1)
        expect(@object.authors.change.listeners.length).to.eql(2)
        expect(@object.authors_property.listeners.length).to.eql(1)
        @object.authorNames_property.unbind(foo)
        expect(@object.authors[0].name_property.listeners.length).to.eql(1)
        expect(@object.authors[1].name_property.listeners.length).to.eql(1)
        expect(@object.authors.change.listeners.length).to.eql(2)
        expect(@object.authors_property.listeners.length).to.eql(1)
        @object.authorNames_property.unbind(bar)
        expect(@object.authors[0].name_property.listeners.length).to.eql(0)
        expect(@object.authors[1].name_property.listeners.length).to.eql(0)
        expect(@object.authors.change.listeners.length).to.eql(0)
        expect(@object.authors_property.listeners.length).to.eql(0)
        @object.authorNames_property.bind(bar)
        expect(@object.authors[0].name_property.listeners.length).to.eql(1)
        expect(@object.authors[1].name_property.listeners.length).to.eql(1)
        expect(@object.authors.change.listeners.length).to.eql(2)
        expect(@object.authors_property.listeners.length).to.eql(1)

      it "unbinds global listeners when dependent property no longer has any listeners", ->
        @object.authors = new Serenade.Collection([Serenade(name: "Jonas"), Serenade(name: "Kim")])
        foo = ->
        bar = ->
        @object.authorNames_property.bind(foo)
        @object.attribution_property.bind(bar)
        expect(@object.authors[0].name_property.listeners.length).to.eql(1)
        expect(@object.authors[1].name_property.listeners.length).to.eql(1)
        expect(@object.authors.change.listeners.length).to.eql(2)
        expect(@object.authors_property.listeners.length).to.eql(1)
        @object.authorNames_property.unbind(foo)
        expect(@object.authors[0].name_property.listeners.length).to.eql(1)
        expect(@object.authors[1].name_property.listeners.length).to.eql(1)
        expect(@object.authors.change.listeners.length).to.eql(2)
        expect(@object.authors_property.listeners.length).to.eql(1)
        @object.attribution_property.unbind(bar)
        expect(@object.authors[0].name_property.listeners.length).to.eql(0)
        expect(@object.authors[1].name_property.listeners.length).to.eql(0)
        expect(@object.authors.change.listeners.length).to.eql(0)
        expect(@object.authors_property.listeners.length).to.eql(0)
        @object.attribution_property.bind(bar)
        expect(@object.authors[0].name_property.listeners.length).to.eql(1)
        expect(@object.authors[1].name_property.listeners.length).to.eql(1)
        expect(@object.authors.change.listeners.length).to.eql(2)
        expect(@object.authors_property.listeners.length).to.eql(1)
