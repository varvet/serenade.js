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
    o 'IDENTIFIER', -> { type: 'text', value: $1, bound: true }
    o 'STRING_LITERAL', -> { type: 'text', value: $1, bound: false }
  ]

  ChildList: [
    o '', -> []
    o 'Child', -> [$1]
    o 'ChildList TERMINATOR Child', -> $1.concat $3
  ]

  Child: [
    o 'Element', -> $1
    o 'Instruction', -> $1
    o 'STRING_LITERAL', -> { type: 'text', value: $1, bound: false }
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
    o 'IDENTIFIER ASSIGN IDENTIFIER', -> { name: $1, value: $3, bound: true, scope: 'attribute' }
    o 'IDENTIFIER ASSIGN STRING_LITERAL', -> { name: $1, value: $3, bound: false, scope: 'attribute' }
    o 'IDENTIFIER SCOPE Property', -> $3.scope = $1; $3
  ]

  Instruction: [
    o 'INSTRUCT WHITESPACE IDENTIFIER WHITESPACE InstructionArgumentsList', -> { command: $3, arguments: $5, children: [], type: 'instruction' }
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
