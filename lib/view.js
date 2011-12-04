(function() {
  var Monkey;
  Monkey = require('./monkey').Monkey;
  Monkey.Parser.lexer = {
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
  Monkey.Parser.yy = {
    Monkey: Monkey
  };
  Monkey.View = (function() {
    function View(string) {
      this.string = string;
    }
    View.prototype.parse = function() {
      return Monkey.Parser.parse(new Monkey.Lexer().tokenize(this.string));
    };
    return View;
  })();
}).call(this);
