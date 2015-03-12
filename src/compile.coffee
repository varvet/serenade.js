Compile =
  element: (ast, context) ->
    Serenade.renderView(ast, context)

  view: (ast, context) ->
    if ast.bound
      new BoundViewView(ast, context)
    else
      Serenade.templates[ast.argument].render(context).view

  text: (ast, context) ->
    new TextView(ast, context)

  collection: (ast, context) ->
    new CollectionView(ast, context)

  in: (ast, context) ->
    new InView(ast, context)

  if: (ast, context) ->
    new IfView(ast, context)

  unless: (ast, context) ->
    new UnlessView(ast, context)
