(function() {
  var Monkey, Parser, grammar, o, parser, tokens, unwrap;

  Parser = require("jison").Parser;

  Monkey = {};

  Monkey.Element = (function() {

    function Element(name, attributes, children) {
      this.name = name;
      this.attributes = attributes;
      this.children = children;
      this.attributes || (this.attributes = []);
      this.children || (this.children = []);
    }

    return Element;

  })();

  Monkey.Attribute = (function() {

    function Attribute(name, value, bound) {
      this.name = name;
      this.value = value;
      this.bound = bound;
    }

    return Attribute;

  })();

  Monkey.TextNode = (function() {

    function TextNode(value, bound) {
      this.value = value;
      this.bound = bound;
    }

    TextNode.prototype.name = 'text';

    return TextNode;

  })();

  tokens = ['IDENTIFIER'];

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
        return [];
      }), ['Element', 'return $$']
    ],
    Element: [
      o('IDENTIFIER AttributeArgument', function() {
        return new Monkey.Element($1, $2);
      }), o('IDENTIFIER AttributeArgument INDENT ChildList OUTDENT', function() {
        return new Monkey.Element($1, $2, $4);
      }), o('IDENTIFIER AttributeArgument WHITESPACE InlineChildList', function() {
        return new Monkey.Element($1, $2, $4);
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
        return new Monkey.TextNode($1, true);
      }), o('STRING_LITERAL', function() {
        return new Monkey.TextNode($1, false);
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
      }), o('STRING_LITERAL', function() {
        return new Monkey.TextNode($1, false);
      })
    ],
    AttributeArgument: [
      o('', function() {
        return [];
      }), o('LPAREN RPAREN', function() {
        return [];
      }), o('LPAREN AttributeList RPAREN', function() {
        return $2;
      })
    ],
    AttributeList: [
      o('Attribute', function() {
        return [$1];
      }), o('AttributeList WHITESPACE Attribute', function() {
        return $1.concat($3);
      })
    ],
    Attribute: [
      o('IDENTIFIER ASSIGN IDENTIFIER', function() {
        return new Monkey.Attribute($1, $3, true);
      }), o('IDENTIFIER ASSIGN STRING_LITERAL', function() {
        return new Monkey.Attribute($1, $3, false);
      })
    ]
  };

  parser = new Parser({
    tokens: tokens,
    bnf: grammar,
    startSymbol: 'Root'
  });

  parser.lexer = {
    lex: function() {
      var tag, _ref;
      _ref = this.tokens[this.pos++] || [''], tag = _ref[0], this.yytext = _ref[1], this.yylineno = _ref[2];
      return tag;
    },
    setInput: function(tokens) {
      this.tokens = tokens;
      return this.pos = 0;
    },
    upcomingInput: function() {
      return "";
    }
  };

  parser.yy = {
    Monkey: Monkey
  };

  exports.Parser = parser;

}).call(this);
