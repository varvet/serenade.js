class TemplateView
  constructor: (ast, model, controller) ->
    @nodes = compile(ast, model, controller)

    @element = Serenade.document.createDocumentFragment()
    for node in @nodes
      node.append(@element)
    @element.view = this
    @element.nodes = @nodes
    @element.remove = =>
      node.remove() for node in @nodes
    @element
