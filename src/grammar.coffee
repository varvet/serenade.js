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
    ['Element TERMINATOR', 'return $$']
  ]

  Element: [
    o 'IDENTIFIER', -> { name: $1, properties: [], children: [], type: 'element' }
    o 'Element LPAREN RPAREN', -> $1
    o 'Element LPAREN PropertyList RPAREN', -> $1.properties = $3; $1
    o 'Element WHITESPACE InlineChild', -> $1.children = $1.children.concat($3); $1
    o 'Element INDENT ChildList OUTDENT', -> $1.children = $1.children.concat($3); $1
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
