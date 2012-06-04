{Serenade} = require './serenade'
{Collection} = require './collection'
{format, get, set, preventDefault} = require './helpers'

class Node
  @element: (ast, model, controller) ->
    element = Serenade.document.createElement(ast.name)
    node = new Node(ast, element)

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
    controller = Serenade.controllerFor(ast.arguments[0]) or parent
    element = Serenade.render(ast.arguments[0], model, controller, parent)
    new Node(ast, element)

  @helper: (ast, model, controller) ->
    render = (model=model, controller=controller) ->
      fragment = Serenade.document.createDocumentFragment()
      for child in ast.children
        node = Nodes.compile(child, model, controller)
        node.append(fragment)
      fragment
    helperFunction = Serenade.Helpers[ast.command] or throw SyntaxError "no helper #{ast.command} defined"
    context = { render, model, controller }
    element = helperFunction.apply(context, ast.arguments)
    new Node(ast, element)

  @text: (ast, model, controller) ->
    getValue = ->
      value = format(model, ast.value, ast.bound)
      value = "0" if value is 0
      value or ""
    textNode = Serenade.document.createTextNode(getValue())
    model.bind?("change:#{ast.value}", -> textNode.nodeValue = getValue()) if ast.bound
    new Node(ast, textNode)

  constructor: (@ast, @element) ->

  append: (inside) ->
    inside.appendChild(@element)

  insertAfter: (after) ->
    after.parentNode.insertBefore(@element, after.nextSibling)

  remove: ->
    @element.parentNode?.removeChild(@element)

  lastElement: ->
    @element

class Dynamic
  @collection: (ast, model, controller) ->
    compileItem = (item) -> Nodes.compile(child, item, controller) for child in ast.children

    dynamic = new Dynamic(ast)
    collection = get(model, ast.arguments[0])
    if typeof(collection.bind) is "function"
      collection.bind('set', => dynamic.replace(compileItem(item) for item in collection))
      collection.bind('update', => dynamic.replace(compileItem(item) for item in collection))
      collection.bind('add', (item) => dynamic.appendNodeSet(compileItem(item)))
      collection.bind('insert', (index, item) => dynamic.insertNodeSet(index, compileItem(item)))
      collection.bind('delete', (index) => dynamic.deleteNodeSet(index))
    dynamic.replace(compileItem(item) for item in collection)
    dynamic

  @in: (ast, model, controller) ->
    dynamic = new Dynamic(ast)
    update = ->
      value = get(model, ast.arguments[0])
      if value
        nodes = (Nodes.compile(child, value, controller) for child in ast.children)
        dynamic.replace([nodes])
      else
        dynamic.clear()
    update()
    model.bind? "change:#{ast.arguments[0]}", update
    dynamic

  @if: (ast, model, controller) ->
    dynamic = new Dynamic(ast)
    update = ->
      value = get(model, ast.arguments[0])
      if value
        nodes = (Nodes.compile(child, model, controller) for child in ast.children)
        dynamic.replace([nodes])
      else
        dynamic.clear()
    update()
    model.bind? "change:#{ast.arguments[0]}", update
    dynamic

  constructor: (@ast) ->
    @anchor = Serenade.document.createTextNode('')
    @nodeSets = new Collection([])

  eachNode: (fun) ->
    for set in @nodeSets
      fun(node) for node in set

  rebuild: ->
    if @anchor.parentNode
      last = @anchor
      @eachNode (node) ->
        node.insertAfter(last)
        last = node.lastElement()

  replace: (sets) ->
    @clear()
    @nodeSets.update(new Collection(set) for set in sets)
    @rebuild()

  appendNodeSet: (nodes) ->
    @insertNodeSet(@nodeSets.length, nodes)

  deleteNodeSet: (index) ->
    node.remove() for node in @nodeSets[index]
    @nodeSets.deleteAt(index)

  insertNodeSet: (index, nodes) ->
    last = @nodeSets[index-1].last()
    for node in nodes
      node.insertAfter(last.lastElement())
      last = node
    @nodeSets.insertAt(index, new Collection(nodes))

  clear: -> @eachNode (node) -> node.remove()

  remove: ->
    @clear()
    @anchor.parentNode.removeChild(@anchor)

  append: (inside) ->
    inside.appendChild(@anchor)
    @rebuild()

  insertAfter: (after) ->
    after.parentNode.insertBefore(@anchor, after.nextSibling)
    @rebuild()

  lastElement: ->
    @nodeSets.last()?.last()?.lastElement() or @anchor

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
      when 'text' then Node.text(ast, model, controller)
      when 'instruction'
        switch ast.command
          when "view" then Node.view(ast, model, controller)
          when "collection" then Dynamic.collection(ast, model, controller)
          when "if" then Dynamic.if(ast, model, controller)
          when "in" then Dynamic.in(ast, model, controller)
          else Node.helper(ast, model, controller)
      else throw SyntaxError "unknown type '#{ast.type}'"

exports.Nodes = Nodes
