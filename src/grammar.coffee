unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

o = (patternString, action, options) ->
  patternString = patternString.replace /\s{2,}/g, ' '
  return [patternString, '$$ = $1;', options] unless action
  action = if match = unwrap.exec action then match[1] else "(#{action}())"
  action = action.replace /\bnew /g, '$&yy.'
  action = action.replace /\b(?:Block\.wrap|extend)\b/g, 'yy.$&'
  [patternString, "$$ = #{action};", options]

grammar =
  Root: [
    o '', -> null
    ['Element', 'return $$']
  ]
  Element: [
    o 'IDENTIFIER PropertyArgument', -> new Monkey.AST.Element($1, $2)
    o 'IDENTIFIER PropertyArgument INDENT ChildList OUTDENT', -> new Monkey.AST.Element($1, $2, $4)
    o 'IDENTIFIER PropertyArgument WHITESPACE InlineChildList', -> new Monkey.AST.Element($1, $2, $4)
  ]

  InlineChildList: [
    o 'InlineChild', -> [$1]
    o 'InlineChildList WHITESPACE InlineChild', -> $1.concat $3
  ]

  InlineChild: [
    o 'IDENTIFIER', -> new Monkey.AST.TextNode($1, true)
    o 'STRING_LITERAL', -> new Monkey.AST.TextNode($1, false)
  ]

  ChildList: [
    o '', -> []
    o 'Child', -> [$1]
    o 'ChildList TERMINATOR Child', -> $1.concat $3
  ]

  Child: [
    o 'Element', -> $1
    o 'Instruction', -> $1
    o 'STRING_LITERAL', -> new Monkey.AST.TextNode($1, false)
  ]

  PropertyArgument: [
    o '', -> []
    o 'LPAREN RPAREN', -> []
    o 'LPAREN PropertyList RPAREN', -> $2
  ]

  PropertyList: [
    o 'Property', -> [$1]
    o 'PropertyList WHITESPACE Property', -> $1.concat $3
  ]

  Property: [
    o 'IDENTIFIER ASSIGN IDENTIFIER', -> new Monkey.AST.Attribute($1, $3, true)
    o 'IDENTIFIER ASSIGN STRING_LITERAL', -> new Monkey.AST.Attribute($1, $3, false)
  ]

  Instruction: [
    o 'INSTRUCT WHITESPACE IDENTIFIER WHITESPACE InstructionArgumentsList', -> new Monkey.AST.Instruction($3, $5)
    o 'Instruction INDENT ChildList OUTDENT', -> $1.children = $3; $1
  ]

  InstructionArgumentsList: [
    o 'InstructionArgument', -> [$1]
    o 'InstructionArgumentsList WHITESPACE InstructionArgument', -> $1.concat $3
  ]

  InstructionArgument: [
    o 'IDENTIFIER', -> $1
    o 'STRING_LITERAL', -> $1
  ]

Jison = require("jison").Parser
parser = new Jison(tokens: [], bnf: grammar, startSymbol: 'Root')

exports.Parser = parser
