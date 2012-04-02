{Serenade} = require './serenade'
{format, getPath, forEach, preventDefault, bind} = require './helpers'

class Node
  constructor: (@ast, @document, @model, @controller) ->
    @element = @document.createElement(@ast.name)

    @element.setAttribute('id', @ast.id) if @ast.id
    @element.setAttribute('class', @ast.classes.join(' ')) if @ast.classes?.length

    for property in @ast.properties
      Nodes.property(property, this, @document, @model, @controller)

    for child in @ast.children
      Nodes.compile(child, @document, @model, @controller).append(@element)

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

  remove: ->
    @element.parentNode?.removeChild(@element)

  lastElement: ->
    @element

class Style
  constructor: (@ast, @node, @document, @model, @controller) ->
    @element = @node.element
    @update()
    if @ast.bound
      bind @model, @ast.value, (value) => @update()
  update: ->
    @element.style[@ast.name] = @get()
  get: -> format(@model, @ast.value, @ast.bound)

class Event
  constructor: (@ast, @node, @document, @model, @controller) ->
    @element = @node.element
    self = this # work around a bug in coffeescript
    callback = (e) ->
      preventDefault(e) if self.ast.preventDefault
      self.controller[self.ast.value](e)
    Serenade.bindEvent(@element, @ast.name, callback)

class Attribute
  constructor: (@ast, @node, @document, @model, @controller) ->
    @element = @node.element
    @update()
    if @ast.bound
      bind @model, @ast.value, (value) => @update()

  update: ->
    value = @get()
    if @ast.name is 'value'
      @element.value = value or ''
    else if @node.ast.name is 'input' and @ast.name is 'checked'
      @element.checked = !!value
    else if @ast.name is 'class'
      classes = @node.ast.classes
      classes = classes.concat(value) unless value is undefined
      if classes.length
        @element.setAttribute(@ast.name, classes.join(' '))
      else
        @element.removeAttribute(@ast.name)
    else if value is undefined
      @element.removeAttribute(@ast.name)
    else
      value = "0" if value is 0
      @element.setAttribute(@ast.name, value)

  get: -> format(@model, @ast.value, @ast.bound)

class TextNode
  constructor: (@ast, @document, @model, @controller) ->
    @textNode = document.createTextNode(@get())
    if @ast.bound
      bind @model, @ast.value, =>
        @textNode.nodeValue = @get()

  append: (inside) ->
    inside.appendChild(@textNode)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@textNode, after.nextSibling)

  remove: ->
    @textNode.parentNode.removeChild(@textNode)

  lastElement: ->
    @textNode

  get: ->
    value = format(@model, @ast.value, @ast.bound)
    value = "0" if value is 0
    value or ""

class View
  constructor: (@ast, @document, @model, @parentController) ->
    @controller = Serenade.controllerFor(@ast.arguments[0], @model)
    @controller.parent = @parentController if @controller
    @view = Serenade.render(@ast.arguments[0], @model, @controller or @parentController, @document)

  append: (inside) ->
    inside.appendChild(@view)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@view, after.nextSibling)

  remove: ->
    @view.parentNode.removeChild(@view)

  lastElement: ->
    @view

class If
  constructor: (@ast, @document, @model, @controller) ->
    @anchor = document.createTextNode('')
    bind @model, @ast.arguments[0], @build

  build: =>
    if getPath(@model, @ast.arguments[0])
      @nodes ||= (Nodes.compile(child, @document, @model, @controller) for child in @ast.children)
      node.insertAfter(@nodes[i-1]?.lastElement() or @anchor) for node, i in @nodes
    else
      @removeNodes()

  append: (inside) ->
    inside.appendChild(@anchor)
    @build()

  insertAfter: (after) ->
    after.parentNode.insertBefore(@anchor, after.nextSibling)
    @build()

  remove: ->
    @removeNodes()
    @anchor.parentNode.removeChild(@anchor)

  removeNodes: ->
    node.remove() for node in @nodes if @nodes
    @nodes = undefined

  lastElement: ->
    if @nodes?.length
      @nodes[@nodes.length - 1].lastElement()
    else
      @anchor

class In
  constructor: (@ast, @document, @model, @controller) ->
    @anchor = document.createTextNode('')
    bind @model, @ast.arguments, @build

  build: =>
    @removeNodes()
    subModel = getPath(@model, @ast.arguments[0])
    @nodes = (Nodes.compile(child, @document, subModel, @controller) for child in @ast.children)
    node.insertAfter(@nodes[i-1]?.lastElement() or @anchor) for node, i in @nodes

  append: (inside) ->
    inside.appendChild(@anchor)
    @build()

  insertAfter: (after) ->
    after.parentNode.insertBefore(@anchor, after.nextSibling)
    @build()

  remove: ->
    @removeNodes()
    @anchor.parentNode.removeChild(@anchor)

  removeNodes: ->
    node.remove() for node in @nodes if @nodes
    @nodes = undefined

  lastElement: ->
    @nodes[@nodes.length - 1].lastElement()

class Collection
  constructor: (@ast, @document, @model, @controller) ->
    @anchor = document.createTextNode('')
    bind @model, @ast.arguments[0], ( => @rebuild()), (collection) =>
      if collection.bind
        collection.bind('update', => @rebuild())
        collection.bind('set', => @rebuild())
        collection.bind('add', (item) => @appendItem(item))
        collection.bind('delete', (index) => @delete(index))

  rebuild: ->
    item.remove() for item in @items
    @build()

  build: ->
    @items = []
    forEach @get(), (item) => @appendItem(item)

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

  get: -> getPath(@model, @ast.arguments[0])

class Helper
  constructor: (@ast, @document, @model, @controller) ->
    @helperFunction = Serenade.Helpers[@ast.command] or throw SyntaxError "no helper #{@ast.command} defined"
    @context = { @document, @render, @model, @controller }
    @element = @helperFunction.apply(@context, @ast.arguments)

  render: (element, model=@model, controller=@controller) =>
    for child in @ast.children
      node = Nodes.compile(child, @document, model, controller)
      node.append(element)
    element

  lastElement: ->
    item = @lastItem()
    if item then item.lastElement() else @anchor

  remove: ->
    @element.parentNode.removeChild(@element)
    item.remove() for item in @items

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

class CollectionItem
  constructor: (@children, @document, @model, @controller) ->
    @nodes = (Nodes.compile(child, @document, @model, @controller) for child in @children)

  insertAfter: (element) ->
    last = element
    for node in @nodes
      node.insertAfter(last)
      last = node.lastElement()

  lastElement: ->
    @nodes[@nodes.length-1].lastElement()

  remove: ->
    node.remove() for node in @nodes

Nodes =
  compile: (ast, document, model, controller) ->
    switch ast.type
      when 'element' then new Node(ast, document, model, controller)
      when 'text' then new TextNode(ast, document, model, controller)
      when 'instruction'
        switch ast.command
          when "view" then new View(ast, document, model, controller)
          when "collection" then new Collection(ast, document, model, controller)
          when "if" then new If(ast, document, model, controller)
          when "in" then new In(ast, document, model, controller)
          else new Helper(ast, document, model, controller)
      else throw SyntaxError "unknown type '#{ast.type}'"

  property: (ast, node, document, model, controller) ->
    switch ast.scope
      when "attribute" then new Attribute(ast, node, document, model, controller)
      when "style" then new Style(ast, node, document, model, controller)
      when "event" then new Event(ast, node, document, model, controller)
      else throw SyntaxError "#{ast.scope} is not a valid scope"

exports.Nodes = Nodes
