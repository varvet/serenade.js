(function() {
  var Monkey, parser;

  Monkey = require('./monkey').Monkey;

  parser = require('./parser').parser;

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

  Monkey.View = (function() {

    function View(string) {
      this.string = string;
    }

    View.prototype.parse = function() {
      return parser.parse(new Monkey.Lexer().tokenize(this.string));
    };

    View.prototype.render = function(document, model, controller) {
      var node;
      node = Monkey.Nodes.compile(this.parse(), document, model, controller);
      controller.model = model;
      return controller.view = node.element;
    };

    return View;

  })();

}).call(this);
