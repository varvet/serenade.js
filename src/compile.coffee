formatTextValue = (value) ->
  value = "0" if value is 0
  value or ""

bindToProperty = (view, model, name, cb) ->
  value = model[name]
  model["#{name}_property"]?.registerGlobal?(value)
  view.bindEvent(model["#{name}_property"], cb)
  cb({}, value)

Compile =
  element: (ast, model, controller) ->
    Serenade.renderView(ast, model, controller)

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
      compileView(new TemplateView(ast, model, controller), undefined, ast.argument)

  text: (ast, model, controller) ->
    if ast.bound and ast.value
      textNode = Serenade.document.createTextNode("")
      view = new Node(ast, textNode)
      bindToProperty view, model, ast.value, (_, value) ->
        assignUnlessEqual textNode, "nodeValue", formatTextValue(value)
      view
    else
      new Node(ast, Serenade.document.createTextNode(ast.value ? model))

  collection: (ast, model, controller) ->
    new CollectionView(ast, model, controller)

  in: (ast, model, controller) ->
    @bound ast, model, controller, (dynamic, _, value) ->
      if value
        dynamic.replace([new TemplateView(ast.children, value, controller)])
      else
        dynamic.clear()

  if: (ast, model, controller) ->
    @bound ast, model, controller, (dynamic, _, value) ->
      if value
        dynamic.replace([new TemplateView(ast.children, model, controller)])
      else if ast.else
        dynamic.replace([new TemplateView(ast.else.children, model, controller)])
      else
        dynamic.clear()

  unless: (ast, model, controller) ->
    @bound ast, model, controller, (dynamic, _, value) ->
      if value
        dynamic.clear()
      else
        nodes = new TemplateView(ast.children, model, controller)
        dynamic.replace([nodes])

  bound: (ast, model, controller, callback) ->
    dynamic = new DynamicView(ast, model, controller)
    bindToProperty dynamic, model, ast.argument, (before, after) ->
      callback(dynamic, before, after) unless before is after
    dynamic

