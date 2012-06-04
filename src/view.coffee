{parser} = require './parser'
{Lexer} = require './lexer'
{compile} = require './compile'
{Serenade} = require './serenade'

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
      parser.parse(new Lexer().tokenize(@view))
    else
      @view
  render: (model, controller, parent) ->
    controller or= Serenade.controllerFor(@name, model) if @name
    controller or= {}
    if typeof(controller) is "function"
      controller = new controller(model, parent)

    node = compile(@parse(), model, controller)
    controller.loaded?(model, node.element)
    node.element

exports.View = View
