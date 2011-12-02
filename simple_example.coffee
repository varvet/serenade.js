Parser = require("jison").Parser

tokens = ['IDENTIFIER']

grammar =
  Root: [
    ['Element', 'return $$']
  ]
  Element: [
    ['IDENTIFIER', '$$ = "foobar"']
  ]

parser = new Parser(tokens: tokens, bnf: grammar, startSymbol: 'Root')
parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

lexed = [ [ 'IDENTIFIER', 'div', 0 ] ]

console.log parser.parse(lexed) # => true
