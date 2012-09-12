{Serenade} = require './serenade'
{Collection} = require './collection'
{Node} = require './node'
{DynamicNode} = require './dynamic_node'
{get, set, preventDefault} = require './helpers'

getValue = (ast, model) ->
  if ast.bound and ast.value
    get(model, ast.value, true)
  else if ast.value?
    ast.value
  else
    model

Property =
  style: (ast, node, model, controller) ->
    update = ->
      node.element.style[ast.name] = getValue(ast, model)
    update()
    model.bind?("change:#{ast.value}", update) if ast.bound

  event: (ast, node, model, controller) ->
    Serenade.bindEvent node.element, ast.name, (e) =>
      preventDefault(e) if ast.preventDefault
      controller[ast.value](model, node.element, e)

  binding: (ast, node, model, controller) ->
    element = node.element
    node.ast.name in ["input", "textarea", "select"] or throw SyntaxError "invalid node type #{node.ast.name} for two way binding"
    ast.value or throw SyntaxError "cannot bind to whole model, please specify an attribute to bind to"

    domUpdated = ->
      if element.type is "checkbox"
        set(model, ast.value, element.checked)
      else if element.type is "radio"
        set(model, ast.value, element.getAttribute("value")) if element.checked
      else
        set(model, ast.value, element.value)

    modelUpdated = ->
      if element.type is "checkbox"
        val = get(model, ast.value)
        element.checked = !!val
      else if element.type is "radio"
        val = get(model, ast.value)
        element.checked = true if val == element.getAttribute("value")
      else
        val = get(model, ast.value)
        val = "" if val == undefined
        element.value = val unless element.value is val

    modelUpdated()
    model.bind?("change:#{ast.value}", modelUpdated)
    if ast.name is "binding"
      # we can't bind to the form directly since it doesn't exist yet
      handler = (e) => domUpdated() if element.form is (e.target or e.srcElement)
      Serenade.bindEvent Serenade.document, "submit", handler, true
    else
      Serenade.bindEvent element, ast.name, domUpdated

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

    model.bind?("change:#{ast.value}", update) if ast.bound
    update()

  on: (ast, node, model, controller) ->
    if ast.name isnt "load"
      throw new SyntaxError("unkown lifecycle event '#{ast.name}'")
    else
      node.bind ast.name, ->
        controller[ast.value](model, node.element)

Compile =
  element: (ast, model, controller) ->
    element = Serenade.document.createElement(ast.name)
    node = new Node(ast, element)

    element.setAttribute('id', ast.id) if ast.id
    element.setAttribute('class', ast.classes.join(' ')) if ast.classes?.length

    for child in ast.children
      compile(child, model, controller).append(element)

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
    element = Serenade.render(ast.arguments[0], model, controller, parent, skipCallback)
    new Node(ast, element)

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
    model.bind?("change:#{ast.value}", -> textNode.nodeValue = getText()) if ast.bound
    new Node(ast, textNode)

  collection: (ast, model, controller) ->
    compileItem = (item) -> compile(child, item, controller) for child in ast.children

    dynamic = new DynamicNode(ast)
    collection = get(model, ast.arguments[0])
    if typeof(collection.bind) is "function"
      collection.bind('set', => dynamic.replace(compileItem(item) for item in collection))
      collection.bind('update', => dynamic.replace(compileItem(item) for item in collection))
      collection.bind('add', (item) => dynamic.appendNodeSet(compileItem(item)))
      collection.bind('insert', (index, item) => dynamic.insertNodeSet(index, compileItem(item)))
      collection.bind('delete', (index) => dynamic.deleteNodeSet(index))
    dynamic.replace(compileItem(item) for item in collection)
    dynamic

  in: (ast, model, controller) ->
    Compile.bound ast, model, controller, (dynamic, value) ->
      if value
        nodes = (compile(child, value, controller) for child in ast.children)
        dynamic.replace([nodes])
      else
        dynamic.clear()

  if: (ast, model, controller) ->
    Compile.bound ast, model, controller, (dynamic, value) ->
      if value
        nodes = (compile(child, model, controller) for child in ast.children)
        dynamic.replace([nodes])
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
      value = get(model, ast.arguments[0])
      callback(dynamic, value)
    update()
    model.bind? "change:#{ast.arguments[0]}", update
    dynamic

compile = (ast, model, controller) -> Compile[ast.type](ast, model, controller)

exports.compile = compile
