var COMMENT, IDENTIFIER, KEYWORDS, LITERALS, Lexer, MULTI_DENT, STRING, WHITESPACE,
	__indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

IDENTIFIER = /^[a-zA-Z][a-zA-Z0-9\-_]*/;

LITERALS = {
	"[": "LBRACKET",
	"]": "RBRACKET",
	"=": "EQUALS",
	":": "COLON",
	"-": "DASH",
	"!": "BANG",
	"#": "HASH",
	".": "DOT",
	"@": "AT"
}

STRING = /^"((?:\\.|[^"])*)"/;

MULTI_DENT = /^(?:\r?\n[^\r\n\S]*)+/;

WHITESPACE = /^[^\r\n\S]+/;

COMMENT = /^\s*\/\/[^\n]*/;

KEYWORDS = ["IF", "ELSE", "COLLECTION", "IN", "VIEW", "UNLESS"];

Lexer = (function() {
	function Lexer() {}

	Lexer.prototype.tokenize = function(code, opts) {
		var tag;
		if (opts == null) {
			opts = {};
		}
		this.code = code.replace(/^\s*/, '').replace(/\s*$/, '');
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
			if (tag === 'OUTDENT') {
				this.token('OUTDENT');
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
	};

	Lexer.prototype.commentToken = function() {
		var match;
		if (match = COMMENT.exec(this.chunk)) {
			return match[0].length;
		} else {
			return 0;
		}
	};

	Lexer.prototype.whitespaceToken = function() {
		var match;
		if (match = WHITESPACE.exec(this.chunk)) {
			this.token('WHITESPACE', match[0].length);
			return match[0].length;
		} else {
			return 0;
		}
	};

	Lexer.prototype.token = function(tag, value) {
		return this.tokens.push([tag, value, this.line]);
	};

	Lexer.prototype.identifierToken = function() {
		var match, name;
		if (match = IDENTIFIER.exec(this.chunk)) {
			name = match[0].toUpperCase();
			if (name === "ELSE" && this.last(this.tokens, 2)[0] === "TERMINATOR") {
				this.tokens.splice(this.tokens.length - 3, 1);
			}
			if (__indexOf.call(KEYWORDS, name) >= 0) {
				this.token(name, match[0]);
			} else {
				this.token('IDENTIFIER', match[0]);
			}
			return match[0].length;
		} else {
			return 0;
		}
	};

	Lexer.prototype.stringToken = function() {
		var match;
		if (match = STRING.exec(this.chunk)) {
			this.token('STRING_LITERAL', match[1].replace(/\\(.)/g, "$1"));
			return match[0].length;
		} else {
			return 0;
		}
	};

	Lexer.prototype.lineToken = function() {
		var diff, indent, match, prev, size;
		if (!(match = MULTI_DENT.exec(this.chunk))) {
			return 0;
		}
		indent = match[0];
		this.line += this.count(indent, '\n');
		prev = this.last(this.tokens, 1);
		size = indent.length - 1 - indent.lastIndexOf('\n');
		diff = size - this.indent;
		if (size === this.indent) {
			this.newlineToken();
		} else if (size > this.indent) {
			this.token('INDENT');
			this.indents.push(diff);
			this.ends.push('OUTDENT');
		} else {
			while (diff < 0) {
				this.ends.pop();
				diff += this.indents.pop();
				this.token('OUTDENT');
			}
			this.token('TERMINATOR', '\n');
		}
		this.indent = size;
		return indent.length;
	};

	Lexer.prototype.literalToken = function() {
		var match;
		if (match = LITERALS[this.chunk[0]]) {
			this.token(match);
			return 1;
		} else {
			return this.error("Unexpected token '" + (this.chunk.charAt(0)) + "'");
		}
	};

	Lexer.prototype.newlineToken = function() {
		if (this.tag() !== 'TERMINATOR') {
			return this.token('TERMINATOR', '\n');
		}
	};

	Lexer.prototype.tag = function(index, tag) {
		var tok;
		return (tok = this.last(this.tokens, index)) && (tag ? tok[0] = tag : tok[0]);
	};

	Lexer.prototype.value = function(index, val) {
		var tok;
		return (tok = this.last(this.tokens, index)) && (val ? tok[1] = val : tok[1]);
	};

	Lexer.prototype.error = function(message) {
		var chunk;
		chunk = this.code.slice(Math.max(0, this.i - 10), Math.min(this.code.length, this.i + 10));
		throw SyntaxError("" + message + " on line " + (this.line + 1) + " near " + (JSON.stringify(chunk)));
	};

	Lexer.prototype.count = function(string, substr) {
		var num, pos;
		num = pos = 0;
		if (!substr.length) {
			return 1 / 0;
		}
		while (pos = 1 + string.indexOf(substr, pos)) {
			num++;
		}
		return num;
	};

	Lexer.prototype.last = function(array, back) {
		return array[array.length - (back || 0) - 1];
	};

	return Lexer;

})();

export default Lexer;
