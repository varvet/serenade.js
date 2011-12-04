{Monkey} = require './monkey'
require './nodes'
{Parser} = require './grammar'
{Lexer} = require './lexer'

Parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

Parser.yy = { Monkey }

class View
  constructor: (@string) ->
  parse: ->
    Parser.parse(new Lexer().tokenize(@string))

exports.View = View
