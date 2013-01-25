parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

class View
  constructor: (@name, @view) ->

  parse: ->
    if typeof(@view) is 'string'
      try
        @view = parser.parse(new Lexer().tokenize(@view))
      catch e
        e.message = "In view '#{@name}': #{e.message}" if @name
        throw e
    else
      @view

  render: (args...) ->
    fragment = Serenade.document.createDocumentFragment()
    for node in @nodes(args...)
      node.append(fragment)
    fragment

  nodes: (model, controller, parent, skipCallback) ->
    controller or= Serenade.controllerFor(@name, model) if @name
    controller or= {}
    if typeof(controller) is "function"
      controller = new controller(model, parent)

    nodes = compile(@parse(), model, controller)
    controller.loaded?(nodes.map((node) -> node.element)..., model) unless skipCallback
    nodes
