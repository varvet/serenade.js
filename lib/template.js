"use strict";

Object.defineProperty(exports, "__esModule", {
	value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _grammar = require("./grammar");

var _grammar2 = _interopRequireDefault(_grammar);

var _lexer = require("./lexer");

var _lexer2 = _interopRequireDefault(_lexer);

var _viewsTemplate_view = require("./views/template_view");

var _viewsTemplate_view2 = _interopRequireDefault(_viewsTemplate_view);

var Template;

_grammar2["default"].lexer = {
	lex: function lex() {
		var tag, _ref;
		_ref = this.tokens[this.pos++] || [""], tag = _ref[0], this.yytext = _ref[1], this.yylineno = _ref[2];
		return tag;
	},
	setInput: function setInput(tokens) {
		this.tokens = tokens;
		return this.pos = 0;
	},
	upcomingInput: function upcomingInput() {
		return "";
	}
};

Template = (function () {
	function Template(name, ast) {
		var e;
		this.name = name;
		this.ast = ast;
		if (typeof this.ast === "string") {
			try {
				this.ast = _grammar2["default"].parse(new _lexer2["default"]().tokenize(this.ast));
			} catch (_error) {
				e = _error;
				if (this.name) {
					e.message = "In view '" + this.name + "': " + e.message;
				}
				throw e;
			}
		}
	}

	Template.prototype.render = function (context) {
		return new _viewsTemplate_view2["default"](this.ast, context).fragment;
	};

	return Template;
})();

exports["default"] = Template;
module.exports = exports["default"];
