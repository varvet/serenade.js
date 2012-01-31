{parser} = require './parser'
{Lexer} = require './lexer'
{Nodes} = require './nodes'
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
  constructor: (@view) ->
  parse: ->
    if typeof(@view) is 'string'
      parser.parse(new Lexer().tokenize(@view))
    else
      @view
  render: (model={}, controller={}) ->
    node = Nodes.compile(@parse(), Serenade.document, model, controller)
    controller.model = model
    controller.view = node.element

exports.View = View
