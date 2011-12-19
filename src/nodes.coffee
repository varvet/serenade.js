{Monkey} = require './monkey'

class Element
  constructor: (@ast, @document, @model, @controller) ->
    @element = @document.createElement(@ast.name)

    for property in @ast.properties
      Monkey.Nodes.property(property, @element, @document, @model, @controller)

    for child in @ast.children
      Monkey.Nodes.compile(child, @document, @model, @controller).append(@element)

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

  remove: ->
    @element.parentNode.removeChild(@element)

  lastElement: ->
    @element

class Style
  constructor: (@ast, @element, @document, @model, @controller) ->
    @update()
    if @ast.bound
      @model.bind? "change:#{@ast.value}", (value) => @update()
  update: ->
    @element.style[@ast.name] = @get()
  get: -> Monkey.get(@model, @ast.value, @ast.bound)

class Event
  constructor: (@ast, @element, @document, @model, @controller) ->
    callback = (e) =>
      @controller[@ast.value](e)
    @element.addEventListener(@ast.name, callback, false)

class Attribute
  constructor: (@ast, @element, @document, @model, @controller) ->
    @update()
    if @ast.bound
      @model.bind? "change:#{@ast.value}", (value) => @update()

  update: ->
    value = @get()
    if @ast.name is 'value'
      @element.value = value or ''
    else if value is undefined
      @element.removeAttribute(@ast.name)
    else
      @element.setAttribute(@ast.name, value)

  get: -> Monkey.get(@model, @ast.value, @ast.bound)

class TextNode
  constructor: (@ast, @document, @model, @controller) ->
    @textNode = document.createTextNode(@get() or '')
    if @ast.bound
      model.bind? "change:#{@ast.value}", (value) =>
        @textNode.nodeValue = value or ''

  append: (inside) ->
    inside.appendChild(@textNode)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@textNode, after.nextSibling)

  remove: ->
    @textNode.parentNode.removeChild(@textNode)

  lastElement: ->
    @textNode

  get: (model) -> Monkey.get(@model, @ast.value, @ast.bound)

class View
  constructor: (@ast, @document, @model, @parentController) ->
    @controller = Monkey.controllerFor(@ast.arguments[0])
    @controller.parent = @parentController
    @view = Monkey._views[@ast.arguments[0]].render(@document, @model, @controller)

  append: (inside) ->
    inside.appendChild(@view)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@view, after.nextSibling)

  remove: ->
    @view.parentNode.removeChild(@view)

  lastElement: ->
    @view

class Collection
  constructor: (@ast, @document, @model, @controller) ->
    @anchor = document.createTextNode('')
    @collection = @get()
    if @collection.bind
      @collection.bind('update', => @rebuild())
      @collection.bind('set', => @rebuild())
      @collection.bind('add', (item) => @appendItem(item))
      @collection.bind('delete', (index) => @delete(index))

  get: -> Monkey.get(@model, @ast.arguments[0])

  rebuild: ->
    item.remove() for item in @items
    @build()

  build: ->
    @items = []
    Monkey.forEach @collection, (item) => @appendItem(item)

  appendItem: (item) ->
    node = new CollectionItem(@ast.children, @document, item, @controller)
    node.insertAfter(@lastElement())
    @items.push(node)

  delete: (index) ->
    @items[index].remove()
    @items.splice(index, 1)

  lastItem: ->
    @items[@items.length - 1]

  lastElement: ->
    item = @lastItem()
    if item then item.lastElement() else @anchor

  remove: ->
    @anchor.parentNode.removeChild(@anchor)
    item.remove() for item in @items

  append: (inside) ->
    inside.appendChild(@anchor)
    @build()

  insertAfter: (after) ->
    after.parentNode.insertBefore(@anchor, after.nextSibling)
    @build()

  get: -> Monkey.get(@model, @ast.arguments[0])

class CollectionItem
  constructor: (@children, @document, @model, @controller) ->
    @nodes = (Monkey.Nodes.compile(child, @document, @model, @controller) for child in @children)

  insertAfter: (element) ->
    last = element
    for node in @nodes
      node.insertAfter(last)
      last = node.lastElement()

  lastElement: ->
    @nodes[@nodes.length-1].lastElement()

  remove: ->
    node.remove() for node in @nodes

Monkey.Nodes =
  compile: (ast, document, model, controller) ->
    switch ast.type
      when 'element' then new Element(ast, document, model, controller)
      when 'text' then new TextNode(ast, document, model, controller)
      when 'instruction'
        switch ast.command
          when "view" then new View(ast, document, model, controller)
          when "collection" then new Collection(ast, document, model, controller)
      else throw SyntaxError "unknown type #{ast.type}"

  property: (ast, element, document, model, controller) ->
    switch ast.scope
      when "attribute" then new Attribute(ast, element, document, model, controller)
      when "style" then new Style(ast, element, document, model, controller)
      when "event" then new Event(ast, element, document, model, controller)
