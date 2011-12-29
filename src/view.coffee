{parser} = require './parser'
{Lexer} = require './lexer'
{Nodes} = require './nodes'

parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

class View
  constructor: (@string) ->
  parse: ->
    parser.parse(new Lexer().tokenize(@string))
  render: (document, model, controller) ->
    node = Nodes.compile(@parse(), document, model, controller)
    controller.model = model
    controller.view = node.element

exports.View = View
