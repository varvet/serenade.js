import { Parser } from "./grammar"
import Lexer from "./lexer"

var Template;

var parser = new Parser()

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

Template = (function() {
	function Template(name, ast) {
		var e;
		this.name = name;
		this.ast = ast;
		if (typeof this.ast === 'string') {
			try {
				this.ast = parser.parse(new Lexer().tokenize(this.ast));
			} catch (_error) {
				e = _error;
				if (this.name) {
					e.message = "In view '" + this.name + "': " + e.message;
				}
				throw e;
			}
		}
	}

	Template.prototype.render = function(context) {
		return new TemplateView(this.ast, context).fragment;
	};

	return Template;

})();

export default Template;
