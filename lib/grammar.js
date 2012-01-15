(function() {
  var Jison, grammar, o, parser, unwrap;

  unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/;

  o = function(patternString, action, options) {
    var match;
    patternString = patternString.replace(/\s{2,}/g, ' ');
    if (!action) return [patternString, '$$ = $1;', options];
    action = (match = unwrap.exec(action)) ? match[1] : "(" + action + "())";
    action = action.replace(/\bnew /g, '$&yy.');
    action = action.replace(/\b(?:Block\.wrap|extend)\b/g, 'yy.$&');
    return [patternString, "$$ = " + action + ";", options];
  };

  grammar = {
    Root: [
      o('', function() {
        return null;
      }), ['Element', 'return $$'], ['Element TERMINATOR', 'return $$']
    ],
    Element: [
      o('IDENTIFIER', function() {
        return {
          name: $1,
          properties: [],
          children: [],
          type: 'element'
        };
      }), o('Element LPAREN RPAREN', function() {
        return $1;
      }), o('Element LPAREN PropertyList RPAREN', function() {
        $1.properties = $3;
        return $1;
      }), o('Element WHITESPACE InlineChild', function() {
        $1.children = $1.children.concat($3);
        return $1;
      }), o('Element INDENT ChildList OUTDENT', function() {
        $1.children = $1.children.concat($3);
        return $1;
      })
    ],
    InlineChild: [
      o('IDENTIFIER', function() {
        return {
          type: 'text',
          value: $1,
          bound: true
        };
      }), o('STRING_LITERAL', function() {
        return {
          type: 'text',
          value: $1,
          bound: false
        };
      })
    ],
    ChildList: [
      o('', function() {
        return [];
      }), o('Child', function() {
        return [$1];
      }), o('ChildList TERMINATOR Child', function() {
        return $1.concat($3);
      })
    ],
    Child: [
      o('Element', function() {
        return $1;
      }), o('Instruction', function() {
        return $1;
      }), o('STRING_LITERAL', function() {
        return {
          type: 'text',
          value: $1,
          bound: false
        };
      })
    ],
    PropertyList: [
      o('Property', function() {
        return [$1];
      }), o('PropertyList WHITESPACE Property', function() {
        return $1.concat($3);
      })
    ],
    Property: [
      o('IDENTIFIER ASSIGN IDENTIFIER', function() {
        return {
          name: $1,
          value: $3,
          bound: true,
          scope: 'attribute'
        };
      }), o('IDENTIFIER ASSIGN IDENTIFIER BANG', function() {
        return {
          name: $1,
          value: $3,
          bound: true,
          scope: 'attribute',
          preventDefault: true
        };
      }), o('IDENTIFIER ASSIGN STRING_LITERAL', function() {
        return {
          name: $1,
          value: $3,
          bound: false,
          scope: 'attribute'
        };
      }), o('IDENTIFIER SCOPE Property', function() {
        $3.scope = $1;
        return $3;
      })
    ],
    Instruction: [
      o('INSTRUCT WHITESPACE IDENTIFIER', function() {
        return {
          command: $3,
          arguments: [],
          children: [],
          type: 'instruction'
        };
      }), o('Instruction WHITESPACE InstructionArgument', function() {
        $1.arguments.push($3);
        return $1;
      }), o('Instruction INDENT ChildList OUTDENT', function() {
        $1.children = $3;
        return $1;
      })
    ],
    InstructionArgument: [
      o('IDENTIFIER', function() {
        return $1;
      }), o('STRING_LITERAL', function() {
        return $1;
      })
    ]
  };

  Jison = require("jison").Parser;

  parser = new Jison({
    tokens: [],
    bnf: grammar,
    startSymbol: 'Root'
  });

  exports.Parser = parser;

}).call(this);
