"use strict";

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

Object.defineProperty(exports, "__esModule", {
	value: true
});
var IDENTIFIER = /^[a-zA-Z][a-zA-Z0-9\-_]*/;

var LITERALS = {
	"[": "LBRACKET",
	"]": "RBRACKET",
	"=": "EQUALS",
	":": "COLON",
	"-": "DASH",
	"!": "BANG",
	"#": "HASH",
	".": "DOT",
	"@": "AT"
};

var STRING = /^"((?:\\.|[^"])*)"/;

var MULTI_DENT = /^(?:\r?\n[^\r\n\S]*)+/;

var WHITESPACE = /^[^\r\n\S]+/;

var COMMENT = /^\s*\/\/[^\n]*/;

var KEYWORDS = ["IF", "ELSE", "COLLECTION", "IN", "VIEW", "UNLESS"];

var Lexer = (function () {
	function Lexer() {
		_classCallCheck(this, Lexer);
	}

	_createClass(Lexer, [{
		key: "tokenize",
		value: function tokenize(code, opts) {
			var tag;
			if (opts == null) {
				opts = {};
			}
			this.code = code.replace(/^\s*/, "").replace(/\s*$/, "");
			this.line = opts.line || 0;
			this.indent = 0;
			this.indents = [];
			this.ends = [];
			this.tokens = [];
			this.i = 0;
			while (this.chunk = this.code.slice(this.i)) {
				this.i += this.identifierToken() || this.commentToken() || this.whitespaceToken() || this.lineToken() || this.stringToken() || this.literalToken();
			}
			while (tag = this.ends.pop()) {
				if (tag === "OUTDENT") {
					this.token("OUTDENT");
				} else {
					this.error("missing " + tag);
				}
			}
			while (this.tokens[0][0] === "TERMINATOR") {
				this.tokens.shift();
			}
			while (this.tokens[this.tokens.length - 1][0] === "TERMINATOR") {
				this.tokens.pop();
			}
			return this.tokens;
		}
	}, {
		key: "commentToken",
		value: function commentToken() {
			var match = COMMENT.exec(this.chunk);
			if (match) {
				return match[0].length;
			} else {
				return 0;
			}
		}
	}, {
		key: "whitespaceToken",
		value: function whitespaceToken() {
			var match = WHITESPACE.exec(this.chunk);
			if (match) {
				this.token("WHITESPACE", match[0].length);
				return match[0].length;
			} else {
				return 0;
			}
		}
	}, {
		key: "token",
		value: function token(tag, value) {
			return this.tokens.push([tag, value, this.line]);
		}
	}, {
		key: "identifierToken",
		value: function identifierToken() {
			var match = IDENTIFIER.exec(this.chunk);
			if (match) {
				var _name = match[0].toUpperCase();
				if (_name === "ELSE" && this.last(this.tokens, 2)[0] === "TERMINATOR") {
					this.tokens.splice(this.tokens.length - 3, 1);
				}
				if (KEYWORDS.indexOf(_name) >= 0) {
					this.token(_name, match[0]);
				} else {
					this.token("IDENTIFIER", match[0]);
				}
				return match[0].length;
			} else {
				return 0;
			}
		}
	}, {
		key: "stringToken",
		value: function stringToken() {
			var match = STRING.exec(this.chunk);
			if (match) {
				this.token("STRING_LITERAL", match[1].replace(/\\(.)/g, "$1"));
				return match[0].length;
			} else {
				return 0;
			}
		}
	}, {
		key: "lineToken",
		value: function lineToken() {
			var match = MULTI_DENT.exec(this.chunk);

			if (!match) {
				return 0;
			}

			var indent = match[0];

			this.line += this.count(indent, "\n");

			var prev = this.last(this.tokens, 1);
			var size = indent.length - 1 - indent.lastIndexOf("\n");
			var diff = size - this.indent;

			if (size === this.indent) {
				this.newlineToken();
			} else if (size > this.indent) {
				this.token("INDENT");
				this.indents.push(diff);
				this.ends.push("OUTDENT");
			} else {
				while (diff < 0) {
					this.ends.pop();
					diff += this.indents.pop();
					this.token("OUTDENT");
				}
				this.token("TERMINATOR", "\n");
			}
			this.indent = size;
			return indent.length;
		}
	}, {
		key: "literalToken",
		value: function literalToken() {
			var match = LITERALS[this.chunk[0]];
			if (match) {
				this.token(match);
				return 1;
			} else {
				return this.error("Unexpected token '" + this.chunk.charAt(0) + "'");
			}
		}
	}, {
		key: "newlineToken",
		value: function newlineToken() {
			if (this.tag() !== "TERMINATOR") {
				return this.token("TERMINATOR", "\n");
			}
		}
	}, {
		key: "tag",
		value: (function (_tag) {
			function tag(_x, _x2) {
				return _tag.apply(this, arguments);
			}

			tag.toString = function () {
				return _tag.toString();
			};

			return tag;
		})(function (index, tag) {
			var tok;
			return (tok = this.last(this.tokens, index)) && (tag ? tok[0] = tag : tok[0]);
		})
	}, {
		key: "value",
		value: function value(index, val) {
			var tok;
			return (tok = this.last(this.tokens, index)) && (val ? tok[1] = val : tok[1]);
		}
	}, {
		key: "error",
		value: function error(message) {
			var chunk;
			chunk = this.code.slice(Math.max(0, this.i - 10), Math.min(this.code.length, this.i + 10));
			throw SyntaxError("" + message + " on line " + (this.line + 1) + " near " + JSON.stringify(chunk));
		}
	}, {
		key: "count",
		value: function count(string, substr) {
			var num = 0;
			var pos = 0;
			if (!substr.length) {
				return 1 / 0;
			}
			while (pos = 1 + string.indexOf(substr, pos)) {
				num++;
			}
			return num;
		}
	}, {
		key: "last",
		value: function last(array, back) {
			return array[array.length - (back || 0) - 1];
		}
	}]);

	return Lexer;
})();

exports["default"] = Lexer;
module.exports = exports["default"];
