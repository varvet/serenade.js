Compile =
  element: (ast, model, controller) ->
    Serenade.renderView(ast, model, controller)

  view: (ast, model, parent) ->
    controller = Serenade.controllers[ast.argument]
    # If we cannot find a controller, we inherit the base view's controller,
    controller = parent unless controller

    if ast.bound
      new BoundViewView(ast, model, controller)
    else
      Serenade.templates[ast.argument].render(model, controller).view

  text: (ast, model, controller) ->
    new TextView(ast, model, controller)

  collection: (ast, model, controller) ->
    new CollectionView(ast, model, controller)

  in: (ast, model, controller) ->
    new InView(ast, model, controller)

  if: (ast, model, controller) ->
    new IfView(ast, model, controller)

  unless: (ast, model, controller) ->
    new UnlessView(ast, model, controller)
