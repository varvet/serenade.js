{Serenade} = require './serenade'
{format, get, set, preventDefault} = require './helpers'

class Node
  @element: (ast, model, controller) ->
    element = Serenade.document.createElement(ast.name)
    node = new Node(ast, element, model, controller)

    element.setAttribute('id', ast.id) if ast.id
    element.setAttribute('class', ast.classes.join(' ')) if ast.classes?.length

    for property in ast.properties
      switch property.scope
        when "attribute"
          if property.name is "binding"
            new TwoWayBinding(property, node, model, controller)
          else
            new Attribute(property, node, model, controller)
        when "style" then new Style(property, node, model, controller)
        when "event" then new Event(property, node, model, controller)
        when "binding" then new TwoWayBinding(property, node, model, controller)
        else throw SyntaxError "#{property.scope} is not a valid scope"

    for child in ast.children
      Nodes.compile(child, model, controller).append(element)
    node

  @view: (ast, model, parentController) ->
    controller = Serenade.controllerFor(ast.arguments[0], model)
    controller.parent = parentController if controller
    controller or= parentController
    new Node(ast, Serenade.render(ast.arguments[0], model, controller), model, controller)

  constructor: (@ast, @element, @model, @controller) ->

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

  remove: ->
    @element.parentNode?.removeChild(@element)

  lastElement: ->
    @element

class Style
  constructor: (@ast, @node, @model, @controller) ->
    @element = @node.element
    @update()
    if @ast.bound
      @model.bind? "change:#{@ast.value}", (value) => @update()
  update: ->
    @element.style[@ast.name] = @get()
  get: -> format(@model, @ast.value, @ast.bound)

class Event
  constructor: (@ast, @node, @model, @controller) ->
    @element = @node.element
    self = this # work around a bug in coffeescript
    Serenade.bindEvent @element, @ast.name, (e) ->
      preventDefault(e) if self.ast.preventDefault
      self.controller[self.ast.value](e)

class TwoWayBinding
  constructor: (@ast, @node, @model, @controller) ->
    @node.ast.name in ["input", "textarea", "select"] or throw SyntaxError "invalid node type #{@node.ast.name} for two way binding"
    @element = @node.element
    @modelUpdated()
    @model.bind? "change:#{@ast.value}", (value) => @modelUpdated()
    if @ast.name is "binding"
      # we can't bind to the form directly since it doesn't exist yet
      Serenade.bindEvent Serenade.document, "submit", (e) =>
        @domUpdated() if @element.form is (e.target or e.srcElement)
    else
      Serenade.bindEvent @element, @ast.name, => @domUpdated()

  domUpdated: ->
    if @element.type is "checkbox"
      set(@model, @ast.value, @element.checked)
    else if @element.type is "radio"
      set(@model, @ast.value, @element.getAttribute("value")) if @element.checked
    else
      set(@model, @ast.value, @element.value)

  modelUpdated: ->
    if @element.type is "checkbox"
      val = get(@model, @ast.value)
      @element.checked = !!val
    else if @element.type is "radio"
      val = get(@model, @ast.value)
      @element.checked = true if val == @element.getAttribute("value")
    else
      val = get(@model, @ast.value)
      val = "" if val == undefined
      @element.value = val

class Attribute
  constructor: (@ast, @node, @model, @controller) ->
    @element = @node.element
    @update()
    if @ast.bound
      @model.bind? "change:#{@ast.value}", (value) => @update()

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
  constructor: (@ast, @model, @controller) ->
    @textNode = Serenade.document.createTextNode(@get())
    if @ast.bound
      model.bind? "change:#{@ast.value}", =>
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

class If
  constructor: (@ast, @model, @controller) ->
    @anchor = Serenade.document.createTextNode('')
    @model.bind? "change:#{@ast.arguments[0]}", @build

  build: =>
    if get(@model, @ast.arguments[0])
      @nodes ||= (Nodes.compile(child, @model, @controller) for child in @ast.children)
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
  constructor: (@ast, @model, @controller) ->
    @anchor = Serenade.document.createTextNode('')
    @model.bind? "change:#{@ast.arguments[0]}", @build

  build: =>
    @removeNodes()
    subModel = get(@model, @ast.arguments[0])
    @nodes = (Nodes.compile(child, subModel, @controller) for child in @ast.children)
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
  constructor: (@ast, @model, @controller) ->
    @anchor = Serenade.document.createTextNode('')
    @collection = @get()
    if @collection.bind
      @collection.bind('update', => @rebuild())
      @collection.bind('set', => @rebuild())
      @collection.bind('add', (item) => @appendItem(item))
      @collection.bind('insert', (index, item) => @insertItem(index, item))
      @collection.bind('delete', (index) => @delete(index))

  rebuild: ->
    item.remove() for item in @items
    @build()

  build: ->
    @items = []
    new Serenade.Collection(@collection).forEach (item) => @appendItem(item)

  appendItem: (item) ->
    node = new CollectionItem(@ast.children, item, @controller)
    node.insertAfter(@lastElement())
    @items.push(node)

  insertItem: (index, item) ->
    node = new CollectionItem(@ast.children, item, @controller)
    node.insertAfter(@items[index-1]?.lastElement() or @anchor)
    @items.splice(0, node)

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

  get: -> get(@model, @ast.arguments[0])

class Helper
  constructor: (@ast, @model, @controller) ->
    @helperFunction = Serenade.Helpers[@ast.command] or throw SyntaxError "no helper #{@ast.command} defined"
    @context = { @render, @model, @controller }
    @element = @helperFunction.apply(@context, @ast.arguments)

  render: (element, model=@model, controller=@controller) =>
    for child in @ast.children
      node = Nodes.compile(child, model, controller)
      node.append(element)
    element

  lastElement: ->
    @element

  remove: ->
    unless @element.parentNode is null
      @element.parentNode.removeChild(@element)

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

class CollectionItem
  constructor: (@children, @model, @controller) ->
    @nodes = (Nodes.compile(child, @model, @controller) for child in @children)

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
  compile: (ast, model, controller) ->
    switch ast.type
      when 'element' then Node.element(ast, model, controller)
      when 'text' then new TextNode(ast, model, controller)
      when 'instruction'
        switch ast.command
          when "view" then new Node.view(ast, model, controller)
          when "collection" then new Collection(ast, model, controller)
          when "if" then new If(ast, model, controller)
          when "in" then new In(ast, model, controller)
          else new Helper(ast, model, controller)
      else throw SyntaxError "unknown type '#{ast.type}'"

exports.Nodes = Nodes
