formatValue = (ast, model, value) ->
  if formatter = model[ast.value + "_property"]
    formatter.format(value)
  else
    value

formatTextValue = (value) ->
  value = "0" if value is 0
  value or ""

bindToProperty = (node, model, name, cb) ->
  value = model[name]
  model["#{name}_property"]?.registerGlobal?(value)
  node.bindEvent(model["#{name}_property"], cb)
  cb({}, value)

Property =
  style: (ast, node, model, controller) ->
    if ast.bound and ast.value
      bindToProperty node, model, ast.value, (_, value) ->
        assignUnlessEqual(node.element.style, ast.name, formatValue(ast, model, value))
    else
      node.element.style[ast.name] = ast.value ? model

  event: (ast, node, model, controller) ->
    node.element.addEventListener ast.name, (e) ->
      e.preventDefault() if ast.preventDefault
      controller[ast.value](node.element, model, e)

  class: (ast, node, model, controller) ->
    bindToProperty node, model, ast.value, (_, value) ->
      if value
        node.addBoundClass(ast.name)
      else
        node.removeBoundClass(ast.name)

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

    bindToProperty node, model, ast.value, (_, value) ->
      if element.type is "checkbox"
        element.checked = !!value
      else if element.type is "radio"
        element.checked = true if value is element.getAttribute("value")
      else
        value = "" if value == undefined
        assignUnlessEqual(element, "value", value)

    if ast.name is "binding"
      # we can't bind to the form directly since it doesn't exist yet
      handler = (e) -> domUpdated() if element.form is (e.target or e.srcElement)
      Serenade.document.addEventListener("submit", handler, true)
      node.unload.bind -> Serenade.document.removeEventListener("submit", handler, true)
    else
      element.addEventListener(ast.name, domUpdated)

  attribute: (ast, node, model, controller) ->
    return Property.binding(ast, node, model, controller) if ast.name is "binding"

    set = (value) ->
      if ast.name is 'value'
        assignUnlessEqual(node.element, "value", value or '')
      else if node.ast.name is 'input' and ast.name is 'checked'
        assignUnlessEqual(node.element, "checked", !!value)
      else if ast.name is 'class'
        node.setAttributeClass(value)
      else if value is undefined
        node.element.removeAttribute(ast.name) if node.element.hasAttribute(ast.name)
      else
        value = "0" if value is 0
        unless node.element.getAttribute(ast.name) is value
          node.element.setAttribute(ast.name, value)

    if ast.bound and ast.value
      bindToProperty node, model, ast.value, (_, value) ->
        set(formatValue(ast, model, value))
    else
      set(ast.value ? model)

  on: (ast, node, model, controller) ->
    if ast.name in ["load", "unload"]
      node[ast.name].bind ->
        controller[ast.value](node.element, model)
    else
      throw new SyntaxError("unkown lifecycle event '#{ast.name}'")

  property: (ast, node, model, controller) ->
    set = (value) ->
      assignUnlessEqual(node.element, ast.name, value)
    if ast.bound and ast.value
      bindToProperty node, model, ast.value, (_, value) ->
        set(value)
    else
      set(ast.value ? model)

Compile =
  element: (ast, model, controller) ->
    view = if Serenade.views[ast.name]
      Serenade.renderView(ast.name, model, controller)
    else
      new Element(ast, Serenade.document.createElement(ast.name))

    view.setAttribute('id', ast.id) if ast.id
    view.setAttribute('class', ast.classes.join(' ')) if ast.classes?.length

    view.addChildren(compile(ast.children, model, controller))
    child.append(view.element) for child in view.children

    for property in ast.properties
      action = Property[property.scope]
      if action
        action(property, view, model, controller)
      else
        throw SyntaxError "#{property.scope} is not a valid scope"

    view.load.trigger()
    view

  view: (ast, model, parent) ->
    controller = Serenade.controllers[ast.argument]
    # If we cannot find a controller, we inherit the base view's controller,
    controller = parent unless controller

    compileView = (dynamic, before, after) ->
      view = Serenade.templates[after].render(model, controller, parent)
      dynamic.replace([view.nodes])
      dynamic

    if ast.bound
      @bound(ast, model, controller, compileView)
    else
      compileView(new CollectionView(ast), undefined, ast.argument)

  helper: (ast, model, controller) ->
    dynamic = new CollectionView(ast)
    renderBlock = (model=model, blockController=controller) ->
      new Template(null, ast.children).render(model, blockController, controller)
    helperFunction = Serenade.Helpers[ast.command] or throw SyntaxError "no helper #{ast.command} defined"
    context = { model, controller, render: renderBlock }
    update = ->
      args = ast.arguments.map((a) -> if a.bound then model[a.value] else a.value)
      dynamic.replace([normalize(ast, helperFunction.apply(context, args))])
    for argument in ast.arguments when argument.bound is true
      dynamic.bindEvent(model["#{argument.value}_property"], update)
    update()
    dynamic

  text: (ast, model, controller) ->
    if ast.bound and ast.value
      textNode = Serenade.document.createTextNode("")
      node = new Element(ast, textNode)
      bindToProperty node, model, ast.value, (_, value) ->
        assignUnlessEqual textNode, "nodeValue", formatTextValue(formatValue(ast, model, value))
      node
    else
      new Element(ast, Serenade.document.createTextNode(ast.value ? model))

  collection: (ast, model, controller) ->
    dynamic = null
    compileItem = (item) -> compile(ast.children, item, controller)
    renderedCollection = []
    updateCollection = (_, after) ->
      for operation in Transform(renderedCollection, after)
        switch operation.type
          when "insert"
            dynamic.insertNodeSet(operation.index, compileItem(operation.value))
          when "remove"
            dynamic.deleteNodeSet(operation.index)
          when "swap"
            dynamic.swapNodeSet(operation.index, operation.with)
      renderedCollection = after?.map((a) -> a) or []
    update = (dyn, before, after) ->
      dynamic = dyn
      dynamic.unbindEvent(before?.change, updateCollection)
      dynamic.bindEvent(after?.change, updateCollection)
      updateCollection(before, after)
    @bound(ast, model, controller, update)

  in: (ast, model, controller) ->
    @bound ast, model, controller, (dynamic, _, value) ->
      if value
        dynamic.replace([compile(ast.children, value, controller)])
      else
        dynamic.clear()

  if: (ast, model, controller) ->
    @bound ast, model, controller, (dynamic, _, value) ->
      if value
        dynamic.replace([compile(ast.children, model, controller)])
      else if ast.else
        dynamic.replace([compile(ast.else.children, model, controller)])
      else
        dynamic.clear()

  unless: (ast, model, controller) ->
    @bound ast, model, controller, (dynamic, _, value) ->
      if value
        dynamic.clear()
      else
        nodes = compile(ast.children, model, controller)
        dynamic.replace([nodes])

  bound: (ast, model, controller, callback) ->
    dynamic = new CollectionView(ast)
    bindToProperty dynamic, model, ast.argument, (before, after) ->
      callback(dynamic, before, after) unless before is after
    dynamic

# turn a single element, document fragment, compiled view or string, or an
# array of any of these into Nodes.
normalize = (ast, val) ->
  return [] unless val
  reduction = (aggregate, element) ->
    if typeof(element) is "string"
      div = Serenade.document.createElement("div")
      div.innerHTML = element
      aggregate.push(new Element(ast, child)) for child in div.childNodes
    else if element.nodeName is "#document-fragment"
      if element.nodes # rendered Serenade.template, clean up listeners!
        aggregate = aggregate.concat(element.nodes)
      else
        aggregate.push(new Element(ast, child)) for child in element.childNodes
    else
      aggregate.push(new Element(ast, element))
    aggregate
  [].concat(val).reduce(reduction, [])

compile = (asts, model, controller) -> Compile[ast.type](ast, model, controller) for ast in asts
