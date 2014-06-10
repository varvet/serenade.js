formatTextValue = (value) ->
  value = "0" if value is 0
  value or ""

bindToProperty = (view, model, name, cb) ->
  value = model[name]
  model["#{name}_property"]?.registerGlobal?(value)
  view.bindEvent(model["#{name}_property"], cb)
  cb({}, value)

Property =
  style:
    update: (ast, view, model, controller, value) ->
      assignUnlessEqual(view.element.style, ast.name, value)

  event:
    setup: (ast, view, model, controller) ->
      view.element.addEventListener ast.name, (e) ->
        e.preventDefault() if ast.preventDefault
        controller[ast.value](view.element, model, e)

  class:
    update: (ast, view, model, controller, value) ->
      if value
        view.addBoundClass(ast.name)
      else
        view.removeBoundClass(ast.name)

  binding:
    setup: (ast, view, model, controller) ->
      element = view.element
      view.ast.name in ["input", "textarea", "select"] or throw SyntaxError "invalid view type #{view.ast.name} for two way binding"
      ast.value or throw SyntaxError "cannot bind to whole model, please specify an attribute to bind to"

      domUpdated = ->
        model[ast.value] = if element.type is "checkbox"
          element.checked
        else if element.type is "radio"
          element.getAttribute("value") if element.checked
        else
          element.value

      if ast.name is "binding"
        # we can't bind to the form directly since it doesn't exist yet
        handler = (e) -> domUpdated() if element.form is (e.target or e.srcElement)
        Serenade.document.addEventListener("submit", handler, true)
        view.unload.bind -> Serenade.document.removeEventListener("submit", handler, true)
      else
        element.addEventListener(ast.name, domUpdated)

    update: (ast, view, model, controller, value) ->
      element = view.element
      if element.type is "checkbox"
        element.checked = !!value
      else if element.type is "radio"
        element.checked = true if value is element.getAttribute("value")
      else
        value = "" if value == undefined
        assignUnlessEqual(element, "value", value)

  attribute:
    update: (ast, view, model, controller, value) ->
      view.setAttribute(ast.name, value)

  on:
    setup: (ast, view, model, controller) ->
      if ast.name in ["load", "unload"]
        view[ast.name].bind ->
          controller[ast.value](view.element, model)
      else
        throw new SyntaxError("unkown lifecycle event '#{ast.name}'")

  property:
    update: (ast, view, model, controller, value) ->
      assignUnlessEqual(view.element, ast.name, value)

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

    ast.properties.forEach (property) ->
      action = Property[property.scope]
      if property.scope is "attribute" and property.name is "binding"
        action = Property.binding

      if action
        action.setup(property, view, model, controller) if action.setup

        if action.update
          if property.static
            action.update(property, view, model, controller, model[property.value])
          else if property.bound
            if property.value
              bindToProperty view, model, property.value, (_, value) ->
                action.update(property, view, model, controller, value)
            else
              action.update(property, view, model, controller, model)
          else
            action.update(property, view, model, controller, property.value)
        else if property.bound
          throw SyntaxError "properties in scope #{property.scope} cannot be bound, use: `#{property.scope}:#{property.name}=#{property.value}`"

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
      view = new Element(ast, textNode)
      bindToProperty view, model, ast.value, (_, value) ->
        assignUnlessEqual textNode, "nodeValue", formatTextValue(value)
      view
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
