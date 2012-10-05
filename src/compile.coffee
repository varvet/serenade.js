{Serenade} = require './serenade'
{Collection} = require './collection'
{Node} = require './node'
{DynamicNode} = require './dynamic_node'
{format} = require './helpers'

getValue = (ast, model) ->
  if ast.bound and ast.value
    format(model, ast.value)
  else if ast.value?
    ast.value
  else
    model

Property =
  style: (ast, node, model, controller) ->
    update = ->
      node.element.style[ast.name] = getValue(ast, model)
    update()
    node.bindEvent(model, "change:#{ast.value}", update) if ast.bound

  event: (ast, node, model, controller) ->
    node.element.addEventListener ast.name, (e) ->
      e.preventDefault() if ast.preventDefault
      controller[ast.value](model, node.element, e)

  binding: (ast, node, model, controller) ->
    element = node.element
    node.ast.name in ["input", "textarea", "select"] or throw SyntaxError "invalid node type #{node.ast.name} for two way binding"
    ast.value or throw SyntaxError "cannot bind to whole model, please specify an attribute to bind to"

    domUpdated = ->
      model[ast.value] = if element.type is "checkbox"
        element.checked
      else if element.type is "radio"
        element.getAttribute("value") if element.checked
      else
        element.value

    modelUpdated = ->
      val = model[ast.value]
      if element.type is "checkbox"
        element.checked = !!val
      else if element.type is "radio"
        element.checked = true if val is element.getAttribute("value")
      else
        val = "" if val == undefined
        element.value = val unless element.value is val

    modelUpdated()
    node.bindEvent(model, "change:#{ast.value}", modelUpdated)
    if ast.name is "binding"
      # we can't bind to the form directly since it doesn't exist yet
      handler = (e) -> domUpdated() if element.form is (e.target or e.srcElement)
      Serenade.document.addEventListener("submit", handler, true)
      node.bind "unload", -> Serenade.document.removeEventListener("submit", handler, true)
    else
      element.addEventListener(ast.name, domUpdated)

  attribute: (ast, node, model, controller) ->
    return Property.binding(ast, node, model, controller) if ast.name is "binding"
    element = node.element
    update = ->
      value = getValue(ast, model)
      if ast.name is 'value'
        element.value = value or ''
      else if node.ast.name is 'input' and ast.name is 'checked'
        element.checked = !!value
      else if ast.name is 'class'
        classes = node.ast.classes
        classes = classes.concat(value) unless value is undefined
        if classes.length
          element.className = classes.join(' ')
        else
          element.className = '' # IE7-compat
          element.removeAttribute(ast.name)
      else if value is undefined
        element.removeAttribute(ast.name)
      else
        value = "0" if value is 0
        element.setAttribute(ast.name, value)

    node.bindEvent(model, "change:#{ast.value}", update) if ast.bound
    update()

  on: (ast, node, model, controller) ->
    if ast.name in ["load", "unload"]
      node.bind ast.name, ->
        controller[ast.value](model, node.element)
    else
      throw new SyntaxError("unkown lifecycle event '#{ast.name}'")

Compile =
  element: (ast, model, controller) ->
    element = Serenade.document.createElement(ast.name)
    node = new Node(ast, element)

    element.setAttribute('id', ast.id) if ast.id
    element.setAttribute('class', ast.classes.join(' ')) if ast.classes?.length

    for child in ast.children
      childNode = compile(child, model, controller)
      childNode.append(element)
      node.children.push childNode

    for property in ast.properties
      action = Property[property.scope]
      if action
        action(property, node, model, controller)
      else
        throw SyntaxError "#{property.scope} is not a valid scope"

    node.trigger("load")
    node

  view: (ast, model, parent) ->
    controller = Serenade.controllerFor(ast.arguments[0])
    # If we cannot find a controller, we inherit the base view's controller,
    # in that case we don't want the `loaded` callback to be called
    unless controller
      skipCallback = true
      controller = parent
    Serenade._views[ast.arguments[0]].node(model, controller, parent, skipCallback)

  helper: (ast, model, controller) ->
    render = (model=model, controller=controller) ->
      fragment = Serenade.document.createDocumentFragment()
      for child in ast.children
        node = compile(child, model, controller)
        node.append(fragment)
      fragment
    helperFunction = Serenade.Helpers[ast.command] or throw SyntaxError "no helper #{ast.command} defined"
    context = { render, model, controller }
    element = helperFunction.apply(context, ast.arguments)
    new Node(ast, element)

  text: (ast, model, controller) ->
    getText = ->
      value = getValue(ast, model)
      value = "0" if value is 0
      value or ""
    textNode = Serenade.document.createTextNode(getText())
    node = new Node(ast, textNode)
    node.bindEvent(model, "change:#{ast.value}", -> textNode.nodeValue = getText()) if ast.bound
    node

  collection: (ast, model, controller) ->
    compileItem = (item) -> compileAll(ast.children, item, controller)

    dynamic = new DynamicNode(ast)
    collection = model[ast.arguments[0]]
    if typeof(collection.bind) is "function"
      dynamic.bindEvent(collection, 'set', => dynamic.replace(compileItem(item) for item in collection))
      dynamic.bindEvent(collection, 'update', => dynamic.replace(compileItem(item) for item in collection))
      dynamic.bindEvent(collection, 'add', (item) => dynamic.appendNodeSet(compileItem(item)))
      dynamic.bindEvent(collection, 'insert', (index, item) => dynamic.insertNodeSet(index, compileItem(item)))
      dynamic.bindEvent(collection, 'delete', (index) => dynamic.deleteNodeSet(index))
    dynamic.replace(compileItem(item) for item in collection)
    dynamic

  in: (ast, model, controller) ->
    Compile.bound ast, model, controller, (dynamic, value) ->
      if value
        dynamic.replace([compileAll(ast.children, value, controller)])
      else
        dynamic.clear()

  if: (ast, model, controller) ->
    Compile.bound ast, model, controller, (dynamic, value) ->
      if value
        dynamic.replace([compileAll(ast.children, model, controller)])
      else if ast.else
        dynamic.replace([compileAll(ast.else.children, model, controller)])
      else
        dynamic.clear()

  unless: (ast, model, controller) ->
    Compile.bound ast, model, controller, (dynamic, value) ->
      if value
        dynamic.clear()
      else
        nodes = (compile(child, model, controller) for child in ast.children)
        dynamic.replace([nodes])

  bound: (ast, model, controller, callback) ->
    dynamic = new DynamicNode(ast)
    update = ->
      value = model[ast.arguments[0]]
      callback(dynamic, value)
    update()
    dynamic.bindEvent model, "change:#{ast.arguments[0]}", update
    dynamic

compile = (ast, model, controller) -> Compile[ast.type](ast, model, controller)
compileAll = (asts, model, controller) -> Compile[ast.type](ast, model, controller) for ast in asts

exports.compile = compile
