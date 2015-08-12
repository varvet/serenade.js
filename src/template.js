import { Parser } from "./grammar"
import Lexer from "./lexer"
import TemplateView from "./views/template_view"

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

class Template {
	constructor(name, ast) {
		this.name = name;
		this.ast = ast;
		if (typeof this.ast === 'string') {
			try {
				this.ast = parser.parse(new Lexer().tokenize(this.ast));
			} catch (error) {
				if (this.name) {
					error.message = `In view '${this.name}': ${error.message}`;
				}
				throw error;
			}
		}
	}

	render(context) {
		return new TemplateView(this.ast, context).fragment;
	}
}

export default Template;
