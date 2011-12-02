# mygenerator.js
Parser = require("jison").Parser

tokens = ['IDENTIFIER']

unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

o = (patternString, action, options) ->
  patternString = patternString.replace /\s{2,}/g, ' '
  return [patternString, '$$ = $1;', options] unless action
  action = if match = unwrap.exec action then match[1] else "(#{action}())"
  action = action.replace /\bnew /g, '$&yy.'
  action = action.replace /\b(?:Block\.wrap|extend)\b/g, 'yy.$&'
  [patternString, "$$ = #{action};", options]

# a grammar in JSON
grammar =
  Root: [
    o '', -> []
    #o 'Body'
    #o 'Block TERMINATOR'
    #o 'Element', -> console.log 'I was here'; $1
    ['Element', 'return $$']
  ]
  #Body: [
    #o 'Line',                                   -> Block.wrap [$1]
    #o 'Body TERMINATOR Line',                   -> $1.push $3
    #o 'Body TERMINATOR'
  #]
  Element: [
    #o 'IDENTIFIER', -> "<#{$1}>"
    ['IDENTIFIER', '$$ = "foobar"']
  ]

  #'IDENTIFIER = IDENTIFIER|STRING_LITERAL'
  #'IDENTIFIER LPAREN argument* RPARENS'
  #
parser = new Parser(tokens: tokens, bnf: grammar, startSymbol: 'Root')

parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

exports.Parser = parser
