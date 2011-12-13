(function() {
  var Jison, grammar, o, parser, unwrap;
  unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/;
  o = function(patternString, action, options) {
    var match;
    patternString = patternString.replace(/\s{2,}/g, ' ');
    if (!action) {
      return [patternString, '$$ = $1;', options];
    }
    action = (match = unwrap.exec(action)) ? match[1] : "(" + action + "())";
    action = action.replace(/\bnew /g, '$&yy.');
    action = action.replace(/\b(?:Block\.wrap|extend)\b/g, 'yy.$&');
    return [patternString, "$$ = " + action + ";", options];
  };
  grammar = {
    Root: [
      o('', function() {
        return null;
      }), ['Element', 'return $$']
    ],
    Element: [
      o('IDENTIFIER PropertyArgument', function() {
        return new Monkey.AST.Element($1, $2);
      }), o('IDENTIFIER PropertyArgument INDENT ChildList OUTDENT', function() {
        return new Monkey.AST.Element($1, $2, $4);
      }), o('IDENTIFIER PropertyArgument WHITESPACE InlineChildList', function() {
        return new Monkey.AST.Element($1, $2, $4);
      })
    ],
    InlineChildList: [
      o('InlineChild', function() {
        return [$1];
      }), o('InlineChildList WHITESPACE InlineChild', function() {
        return $1.concat($3);
      })
    ],
    InlineChild: [
      o('IDENTIFIER', function() {
        return new Monkey.AST.TextNode($1, true);
      }), o('STRING_LITERAL', function() {
        return new Monkey.AST.TextNode($1, false);
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
        return new Monkey.AST.TextNode($1, false);
      })
    ],
    PropertyArgument: [
      o('', function() {
        return [];
      }), o('LPAREN RPAREN', function() {
        return [];
      }), o('LPAREN PropertyList RPAREN', function() {
        return $2;
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
        return new Monkey.AST.Property($1, $3, true);
      }), o('IDENTIFIER ASSIGN STRING_LITERAL', function() {
        return new Monkey.AST.Property($1, $3, false);
      }), o('IDENTIFIER SCOPE IDENTIFIER ASSIGN IDENTIFIER', function() {
        return new Monkey.AST.Property($3, $5, true, $1);
      }), o('IDENTIFIER SCOPE IDENTIFIER ASSIGN STRING_LITERAL', function() {
        return new Monkey.AST.Property($3, $5, false, $1);
      })
    ],
    Instruction: [
      o('INSTRUCT WHITESPACE IDENTIFIER WHITESPACE InstructionArgumentsList', function() {
        return new Monkey.AST.Instruction($3, $5);
      }), o('Instruction INDENT ChildList OUTDENT', function() {
        $1.children = $3;
        return $1;
      })
    ],
    InstructionArgumentsList: [
      o('InstructionArgument', function() {
        return [$1];
      }), o('InstructionArgumentsList WHITESPACE InstructionArgument', function() {
        return $1.concat($3);
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
