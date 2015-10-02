"use strict";

Object.defineProperty(exports, "__esModule", {
	value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var _grammar = require("./grammar");

var _grammar2 = _interopRequireDefault(_grammar);

var _lexer = require("./lexer");

var _lexer2 = _interopRequireDefault(_lexer);

var _viewsTemplate_view = require("./views/template_view");

var _viewsTemplate_view2 = _interopRequireDefault(_viewsTemplate_view);

_grammar2["default"].lexer = {
	lex: function lex() {
		var tag, _ref;
		_ref = this.tokens[this.pos++] || [''], tag = _ref[0], this.yytext = _ref[1], this.yylineno = _ref[2];
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
	function Template(ast) {
		_classCallCheck(this, Template);

		this.ast = ast;
		if (typeof this.ast === 'string') {
			this.ast = _grammar2["default"].parse(new _lexer2["default"]().tokenize(this.ast));
		}
	}

	_createClass(Template, [{
		key: "compile",
		value: function compile(context) {
			return new _viewsTemplate_view2["default"](this.ast, context);
		}
	}, {
		key: "render",
		value: function render(context) {
			return this.compile(context).fragment;
		}
	}]);

	return Template;
})();

exports["default"] = Template;
module.exports = exports["default"];
