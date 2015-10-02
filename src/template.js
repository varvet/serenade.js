import parser from "./grammar"
import Lexer from "./lexer"
import TemplateView from "./views/template_view"

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

class Template {
	constructor(ast) {
		this.ast = ast;
		if (typeof this.ast === 'string') {
      this.ast = parser.parse(new Lexer().tokenize(this.ast));
		}
	}

	compile(context) {
		return new TemplateView(this.ast, context);
	}

	render(context) {
		return this.compile(context).fragment;
	}
}

export default Template;
