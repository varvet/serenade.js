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

  @view: (ast, model, parent) ->
    controller = Serenade.controllerFor(ast.arguments[0], model, parent)
    controller or= parent
    new Node(ast, Serenade.render(ast.arguments[0], model, controller), model, controller)

  @helper: (ast, model, controller) ->
    render = (element, model=model, controller=controller) ->
      for child in ast.children
        node = Nodes.compile(child, model, controller)
        node.append(element)
      element
    helperFunction = Serenade.Helpers[ast.command] or throw SyntaxError "no helper #{ast.command} defined"
    context = { render, model, controller }
    element = helperFunction.apply(context, ast.arguments)
    new Node(ast, element, model, controller)

  @text: (ast, model, controller) ->
    getValue = ->
      value = format(model, ast.value, ast.bound)
      value = "0" if value is 0
      value or ""
    textNode = Serenade.document.createTextNode(getValue())
    model.bind?("change:#{ast.value}", -> textNode.nodeValue = getValue()) if ast.bound
    new Node(ast, textNode, model, controller)

  constructor: (@ast, @element, @model, @controller) ->

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

  remove: ->
    @element.parentNode?.removeChild(@element)

  lastElement: ->
    @element

class Dynamic
  class Item
    constructor: (@children, @model, @controller) ->
      @nodes = (Nodes.compile(child, @model, @controller) for child in @children)
    insertAfter: (element) ->
      last = element
      for node in @nodes
        node.insertAfter(last)
        last = node.lastElement()
    lastElement: -> @nodes[@nodes.length-1].lastElement()
    remove: -> node.remove() for node in @nodes

  @collection: (ast, model, controller) ->
    collection = get(model, ast.arguments[0])
    new Dynamic(ast, collection, model, controller)

  @in: (ast, model, controller) ->
    collection = new Serenade.Collection([])
    update = ->
      subModel = get(model, ast.arguments[0])
      if subModel
        collection.update([subModel])
      else
        collection.update([])
    update()
    model.bind? "change:#{ast.arguments[0]}", update
    new Dynamic(ast, collection, model, controller)

  @if: (ast, model, controller) ->
    collection = new Serenade.Collection([])
    update = ->
      value = get(model, ast.arguments[0])
      if value
        collection.update([model])
      else
        collection.update([])
    update()
    model.bind? "change:#{ast.arguments[0]}", update
    new Dynamic(ast, collection, model, controller)

  constructor: (@ast, @collection, @model, @controller) ->
    @anchor = Serenade.document.createTextNode('')
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
    node = new Item(@ast.children, item, @controller)
    node.insertAfter(@lastElement())
    @items.push(node)

  insertItem: (index, item) ->
    node = new Item(@ast.children, item, @controller)
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
    Serenade.bindEvent @element, @ast.name, (e) =>
      preventDefault(e) if self.ast.preventDefault
      self.controller[self.ast.value](@model, @node.element, e)

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

Nodes =
  compile: (ast, model, controller) ->
    switch ast.type
      when 'element' then Node.element(ast, model, controller)
      when 'text' then new Node.text(ast, model, controller)
      when 'instruction'
        switch ast.command
          when "view" then new Node.view(ast, model, controller)
          when "collection" then new Dynamic.collection(ast, model, controller)
          when "if" then new Dynamic.if(ast, model, controller)
          when "in" then new Dynamic.in(ast, model, controller)
          else new Node.helper(ast, model, controller)
      else throw SyntaxError "unknown type '#{ast.type}'"

exports.Nodes = Nodes
