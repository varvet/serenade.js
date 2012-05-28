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

  ElementIdentifier: [
    o 'IDENTIFIER', -> { name: $1, classes: [] }
    o 'IDENTIFIER # IDENTIFIER', -> { name: $1, id: $3, classes: [] }
    o '# IDENTIFIER', -> { name: 'div', id: $2, classes: [] }
    o '. IDENTIFIER', -> { name: 'div', classes: [$2] }
    o 'ElementIdentifier . IDENTIFIER', -> $1.classes.push($3); $1
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
    o 'STRING_LITERAL', -> { type: 'text', value: $1, bound: false }
  ]

  ChildList: [
    o 'Child', -> [].concat($1)
    o 'ChildList TERMINATOR Child', -> $1.concat $3
  ]

  Child: [
    o 'Element', -> $1
    o 'Instruction', -> $1
    o 'TextList', -> $1
  ]

  PropertyList: [
    o 'Property', -> [$1]
    o 'PropertyList WHITESPACE Property', -> $1.concat $3
  ]

  Property: [
    o 'IDENTIFIER = IDENTIFIER', -> { name: $1, value: $3, bound: true, scope: 'attribute' }
    o 'IDENTIFIER = Bound', -> { name: $1, value: $3, bound: true, scope: 'attribute' }
    o 'IDENTIFIER = IDENTIFIER !', -> { name: $1, value: $3, bound: true, scope: 'attribute', preventDefault: true }
    o 'IDENTIFIER = Bound !', -> { name: $1, value: $3, bound: true, scope: 'attribute', preventDefault: true }
    o 'IDENTIFIER = STRING_LITERAL', -> { name: $1, value: $3, bound: false, scope: 'attribute' }
    o 'IDENTIFIER : Property', -> $3.scope = $1; $3
  ]

  Instruction: [
    o '- WHITESPACE IDENTIFIER', -> { command: $3, arguments: [], children: [], type: 'instruction' }
    o 'Instruction WHITESPACE Text', -> $1.arguments.push $3.value; $1
    o 'Instruction INDENT ChildList OUTDENT', -> $1.children = $3; $1
  ]

  Bound: [
    o '@ IDENTIFIER', -> $2
  ]

Jison = require("jison").Parser
parser = new Jison(tokens: [], bnf: grammar, startSymbol: 'Root')

exports.Parser = parser
