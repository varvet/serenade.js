{Monkey} = require './monkey'
{parser} = require './parser'

parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

parser.yy = { Monkey }

class Monkey.View
  constructor: (@string) ->
  parse: ->
    parser.parse(new Monkey.Lexer().tokenize(@string))
  compile: (document, model, controller) ->
    controller.model = model
    controller.view = @parse().compile(document, model, controller)
