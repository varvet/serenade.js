{Monkey} = require './monkey'

Monkey.Parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

Monkey.Parser.yy = { Monkey }

class Monkey.View
  constructor: (@string) ->
  parse: ->
    Monkey.Parser.parse(new Monkey.Lexer().tokenize(@string))
