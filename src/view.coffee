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

  render: (model, controller, parent, skipCallback) ->
    controller or= Serenade.controllers[@name] or {}
    if typeof(controller) is "function"
      controller = new controller(model, parent)

    nodes = compile(@parse(), model, controller)
    controller.loaded?(nodes.map((node) -> node.element)..., model) unless skipCallback

    fragment = Serenade.document.createDocumentFragment()
    for node in nodes
      node.append(fragment)
    fragment.nodes = nodes
    fragment.remove = ->
      node.remove() for node in @nodes
    fragment
