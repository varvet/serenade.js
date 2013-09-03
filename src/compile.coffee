formatValue = (ast, model, value) ->
  if formatter = model[ast.value + "_property"]
    formatter.format(value)
  else
    value

formatTextValue = (value) ->
  value = "0" if value is 0
  value or ""

Property =
  style: (ast, node, model, controller) ->
    if ast.bound and ast.value
      set = (value) ->
        assignUnlessEqual(node.element.style, ast.name, formatValue(ast, model, value))
      node.bindEvent(model["#{ast.value}_property"], (_, value) -> set(value))
      set(model[ast.value])
    else
      node.element.style[ast.name] = ast.value ? model

  event: (ast, node, model, controller) ->
    node.element.addEventListener ast.name, (e) ->
      e.preventDefault() if ast.preventDefault
      controller[ast.value](node.element, model, e)

  class: (ast, node, model, controller) ->
    update = ->
      if model[ast.value]
        node.boundClasses.push(ast.name) unless node.boundClasses.includes(ast.name)
      else
        node.boundClasses.delete(ast.name)
      node.updateClass()
    update()
    node.bindEvent(model["#{ast.value}_property"], update)

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
        assignUnlessEqual(element, "value", val)

    modelUpdated()
    node.bindEvent(model["#{ast.value}_property"], modelUpdated)
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
        node.attributeClasses = value
        node.updateClass()
      else if value is undefined
        node.element.removeAttribute(ast.name) if node.element.hasAttribute(ast.name)
      else
        value = "0" if value is 0
        unless node.element.getAttribute(ast.name) is value
          node.element.setAttribute(ast.name, value)

    if ast.bound and ast.value
      node.bindEvent(model["#{ast.value}_property"], (_, value) -> set(formatValue(ast, model, value)))
      set(formatValue(ast, model, model[ast.value]))
    else
      set(ast.value ? model)

  on: (ast, node, model, controller) ->
    if ast.name in ["load", "unload"]
      node[ast.name].bind ->
        controller[ast.value](node.element, model)
    else
      throw new SyntaxError("unkown lifecycle event '#{ast.name}'")

Compile =
  element: (ast, model, controller) ->
    element = Serenade.document.createElement(ast.name)
    node = new Node(ast, element)

    element.setAttribute('id', ast.id) if ast.id
    element.setAttribute('class', ast.classes.join(' ')) if ast.classes?.length

    node.children = compile(ast.children, model, controller)
    child.append(element) for child in node.children

    for property in ast.properties
      action = Property[property.scope]
      if action
        action(property, node, model, controller)
      else
        throw SyntaxError "#{property.scope} is not a valid scope"

    node.load.trigger()
    node

  view: (ast, model, parent) ->
    controller = Serenade.controllers[ast.argument]
    # If we cannot find a controller, we inherit the base view's controller,
    # in that case we don't want the `loaded` callback to be called
    unless controller
      skipCallback = true
      controller = parent

    compileView = (dynamic, before, after) ->
      view = Serenade.views[after].render(model, controller, parent, skipCallback)
      dynamic.replace([view.nodes])
      dynamic

    if ast.bound
      @bound(ast, model, controller, compileView)
    else
      compileView(new DynamicNode(ast), undefined, ast.argument)

  helper: (ast, model, controller) ->
    dynamic = new DynamicNode(ast)
    renderBlock = (model=model, controller=controller) ->
      new View(null, ast.children).render(model, controller)
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
      textNode = Serenade.document.createTextNode(formatTextValue(formatValue(ast, model, model[ast.value])))
      node = new Node(ast, textNode)
      node.bindEvent model["#{ast.value}_property"], (_, value) ->
        assignUnlessEqual textNode, "nodeValue", formatTextValue(formatValue(ast, model, value))
      node
    else
      new Node(ast, Serenade.document.createTextNode(ast.value ? model))

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
    dynamic = new DynamicNode(ast)
    update = (before, after) ->
      callback(dynamic, before, after) unless before is after
    update({}, model[ast.argument])
    dynamic.bindEvent(model["#{ast.argument}_property"], update)
    dynamic

# turn a single element, document fragment, compiled view or string, or an
# array of any of these into Nodes.
normalize = (ast, val) ->
  return [] unless val
  reduction = (aggregate, element) ->
    if typeof(element) is "string"
      div = Serenade.document.createElement("div")
      div.innerHTML = element
      aggregate.push(new Node(ast, child)) for child in div.childNodes
    else if element.nodeName is "#document-fragment"
      if element.nodes # rendered Serenade view, clean up listeners!
        aggregate = aggregate.concat(element.nodes)
      else
        aggregate.push(new Node(ast, child)) for child in element.childNodes
    else
      aggregate.push(new Node(ast, element))
    aggregate
  [].concat(val).reduce(reduction, [])

compile = (asts, model, controller) -> Compile[ast.type](ast, model, controller) for ast in asts
