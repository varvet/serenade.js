# mygenerator.js
Parser = require("jison").Parser

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
    ['Element', 'return $$']
  ]
  Element: [
    o 'IDENTIFIER AttributeArgument', -> new Monkey.Element($1, $2)
    o 'IDENTIFIER AttributeArgument INDENT ChildList OUTDENT', -> new Monkey.Element($1, $2, $4)
    o 'IDENTIFIER AttributeArgument WHITESPACE InlineChildList', -> new Monkey.Element($1, $2, $4)
  ]

  InlineChildList: [
    o 'InlineChild', -> [$1]
    o 'InlineChildList WHITESPACE InlineChild', -> $1.concat $3
  ]

  InlineChild: [
    o 'IDENTIFIER', -> new Monkey.TextNode($1, true)
    o 'STRING_LITERAL', -> new Monkey.TextNode($1, false)
  ]

  ChildList: [
    o '', -> []
    o 'Child', -> [$1]
    o 'ChildList TERMINATOR Child', -> $1.concat $3
  ]

  Child: [
    o 'Element', -> $1
    o 'STRING_LITERAL', -> new Monkey.TextNode($1, false)
  ]

  AttributeArgument: [
    o '', -> []
    o 'LPAREN RPAREN', -> []
    o 'LPAREN AttributeList RPAREN', -> $2
  ]

  AttributeList: [
    o 'Attribute', -> [$1]
    o 'AttributeList WHITESPACE Attribute', -> $1.concat $3
  ]

  Attribute: [
    o 'IDENTIFIER ASSIGN IDENTIFIER', -> new Monkey.Attribute($1, $3, true)
    o 'IDENTIFIER ASSIGN STRING_LITERAL', -> new Monkey.Attribute($1, $3, false)
  ]

  #'IDENTIFIER = IDENTIFIER|STRING_LITERAL'
  #'IDENTIFIER LPAREN argument* RPARENS'
  #
parser = new Parser(tokens: [], bnf: grammar, startSymbol: 'Root')

exports.Parser = parser
