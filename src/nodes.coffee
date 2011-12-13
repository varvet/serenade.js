{Monkey} = require './monkey'

EVENTS = ['click', 'blur', 'focus', 'change', 'mouseover', 'mouseout', 'submit']

Monkey.AST = {}
Monkey.Nodes = {}

class Monkey.AST.Element
  type: 'element'
  constructor: (@name, @properties, @children) ->
    @properties or= []
    @children or= []
  compile: (document, model, controller) ->
    new Monkey.Nodes.Element(this, document, model, controller)

class Monkey.Nodes.Element
  constructor: (@ast, @document, @model, @controller) ->
    @element = @document.createElement(@ast.name)

    for attribute in @ast.properties
      attribute.compile(@document, @model, @controller).apply(@element)

    for child in @ast.children
      child.compile(@document, @model, @controller).append(@element)

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

  remove: ->
    @element.parentNode.removeChild(@element)

  lastElement: ->
    @element

class Monkey.AST.Attribute
  constructor: (@name, @value, @bound) ->
  compile: (document, model, controller) ->
    new Monkey.Nodes.Attribute(this, document, model, controller)

class Monkey.Nodes.Attribute
  constructor: (@ast, @document, @model, @controller) ->

  updateAttribute: (element, value) ->
    if @ast.name is 'value'
      element.value = value or ''
    else if value is undefined
      element.removeAttribute(@ast.name)
    else
      element.setAttribute(@ast.name, value)

  updateStyle: (element, name, value) ->
    element.style[name] = value

  attribute: (element) ->
    @updateAttribute(element, @get())
    if @ast.bound
      @model.bind? "change:#{@ast.value}", (value) => @updateAttribute(element, value)


  event: (element, name) ->
    callback = (e) =>
      @controller[@ast.value](e)
    element.addEventListener(name, callback, false)

  style: (element, name) ->
    @updateStyle(element, name, @get())
    if @ast.bound
      @model.bind? "change:#{@ast.value}", (value) => @updateStyle(element, name, value)

  apply: (element) ->
    if @ast.name in EVENTS
      @event(element, @ast.name)
    else if @ast.name.match(/^event-/)
      @event(element, @ast.name.replace(/^event-/, ''))
    else if @ast.name.match(/^style-/)
      @style(element, @ast.name.replace(/^style-/, ''))
    else
      @attribute(element)

  get: -> Monkey.get(@model, @ast.value, @ast.bound)

class Monkey.AST.TextNode
  constructor: (@value, @bound) ->
  name: 'text'
  compile: (document, model, controller) ->
    new Monkey.Nodes.TextNode(this, document, model, controller)

class Monkey.Nodes.TextNode
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

class Monkey.AST.Instruction
  type: 'instruction'
  constructor: (@command, @arguments, @children) ->
  compile: (document, model, controller) ->
    switch @command
      when "view" then new Monkey.Nodes.View(this, document, model, controller)
      when "collection" then new Monkey.Nodes.Collection(this, document, model, controller)

class Monkey.Nodes.View
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

class Monkey.Nodes.Collection
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
    node = new Monkey.Nodes.CollectionItem(@ast.children, @document, item, @controller)
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

class Monkey.Nodes.CollectionItem
  constructor: (@children, @document, @model, @controller) ->
    @nodes = (child.compile(@document, @model, @controller) for child in @children)

  insertAfter: (element) ->
    last = element
    for node in @nodes
      node.insertAfter(last)
      last = node.lastElement()

  lastElement: ->
    @nodes[@nodes.length-1].lastElement()

  remove: ->
    node.remove() for node in @nodes
