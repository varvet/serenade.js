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
    ['ChildList', 'return $$']
  ]

  ElementIdentifier: [
    o 'AnyIdentifier', -> { name: $1, classes: [] }
    o 'AnyIdentifier # AnyIdentifier', -> { name: $1, id: $3, classes: [] }
    o '# AnyIdentifier', -> { name: 'div', id: $2, classes: [] }
    o '. AnyIdentifier', -> { name: 'div', classes: [$2] }
    o 'ElementIdentifier . AnyIdentifier', -> $1.classes.push($3); $1
  ]

  Element: [
    o 'ElementIdentifier', -> { name: $1.name, id: $1.id, classes: $1.classes, properties: [], children: [], type: 'element' }
    o 'Element [ ]', -> $1
    o 'Element [ PropertyList ]', -> $1.properties = $3; $1
    o 'Element WHITESPACE Text', -> $1.children = $1.children.concat($3); $1
    o 'Element INDENT ChildList OUTDENT', -> $1.children = $1.children.concat($3); $1
  ]

  TextList: [
    o 'Text', -> [$1]
    o 'TextList WHITESPACE Text', -> $1.concat $3
  ]

  Text: [
    o 'Bound', -> { type: 'text', value: $1, bound: true }
    o 'STRING_LITERAL', -> { type: 'text', value: $1 }
  ]

  ChildList: [
    o 'Child', -> [].concat($1)
    o 'ChildList TERMINATOR Child', -> $1.concat $3
  ]

  Child: [
    o 'Element', -> $1
    o 'IfInstruction', -> $1
    o 'Instruction', -> $1
    o 'Helper', -> $1
    o 'TextList', -> $1
  ]

  PropertyList: [
    o 'Property', -> [$1]
    o 'PropertyList WHITESPACE Property', -> $1.concat $3
  ]

  Property: [
    o 'AnyIdentifier = AnyIdentifier', -> { name: $1, static: true, value: $3, scope: 'attribute' }
    o 'AnyIdentifier = Bound', -> { name: $1, value: $3, bound: true, scope: 'attribute' }
    o 'AnyIdentifier = AnyIdentifier !', -> { name: $1, static: true, value: $3, scope: 'attribute', preventDefault: true }
    o 'AnyIdentifier = Bound !', -> { name: $1, value: $3, bound: true, scope: 'attribute', preventDefault: true }
    o 'AnyIdentifier = STRING_LITERAL', -> { name: $1, value: $3, scope: 'attribute' }
    o 'AnyIdentifier : Property', -> $3.scope = $1; $3
  ]

  Instruction: [
    o '- WHITESPACE VIEW WHITESPACE STRING_LITERAL', -> { children: [], type: 'view', argument: $5 }
    o '- WHITESPACE VIEW WHITESPACE Bound', -> { children: [], type: 'view', argument: $5, bound: true }
    o '- WHITESPACE COLLECTION WHITESPACE Bound', -> { children: [], type: 'collection', argument: $5 }
    o '- WHITESPACE UNLESS WHITESPACE Bound', -> { children: [], type: 'unless', argument: $5 }
    o '- WHITESPACE IN WHITESPACE Bound', -> { children: [], type: 'in', argument: $5 }
    o 'Instruction INDENT ChildList OUTDENT', -> $1.children = $3; $1
  ]

  Helper: [
    o '- WHITESPACE IDENTIFIER', -> { command: $3, arguments: [], children: [], type: 'helper' }
    o 'Helper WHITESPACE Text', -> $1.arguments.push $3; $1
    o 'Helper INDENT ChildList OUTDENT', -> $1.children = $3; $1
  ]

  IfInstruction: [
    o '- WHITESPACE IF WHITESPACE Bound', -> { children: [], type: 'if', argument: $5 }
    o 'IfInstruction INDENT ChildList OUTDENT', -> $1.children = $3; $1
    o 'IfInstruction ElseInstruction', -> $1.else = $2; $1
  ]

  ElseInstruction: [
    o '- WHITESPACE ELSE INDENT ChildList OUTDENT', -> { arguments: [], children: $5, type: 'else' }
  ]

  AnyIdentifier: [
    o 'VIEW', -> $1
    o 'COLLECTION', -> $1
    o 'IF', -> $1
    o 'UNLESS', -> $1
    o 'IN', -> $1
    o 'IDENTIFIER', -> $1
  ]

  Bound: [
    o '@ AnyIdentifier', -> $2
    o '@', ->
  ]

Jison = require("jison").Parser
parser = new Jison(tokens: [], bnf: grammar, startSymbol: 'Root')
parser.lexer = {}
parser.moduleInclude = ";"

exports.Parser = parser
