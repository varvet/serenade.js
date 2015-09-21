"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

Object.defineProperty(exports, "__esModule", {
	value: true
});

var _parser = require("./grammar");

var _parser2 = _interopRequireDefault(_parser);

var _Lexer = require("./lexer");

var _Lexer2 = _interopRequireDefault(_Lexer);

var _TemplateView = require("./views/template_view");

var _TemplateView2 = _interopRequireDefault(_TemplateView);

_parser2["default"].lexer = {
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

var Template = (function () {
	function Template(name, ast) {
		_classCallCheck(this, Template);

		this.name = name;
		this.ast = ast;
		if (typeof this.ast === "string") {
			try {
				this.ast = _parser2["default"].parse(new _Lexer2["default"]().tokenize(this.ast));
			} catch (error) {
				if (this.name) {
					error.message = "In view '" + this.name + "': " + error.message;
				}
				throw error;
			}
		}
	}

	_createClass(Template, [{
		key: "render",
		value: function render(context) {
			return new _TemplateView2["default"](this.ast, context).fragment;
		}
	}]);

	return Template;
})();

exports["default"] = Template;
module.exports = exports["default"];
