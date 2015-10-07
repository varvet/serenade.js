const IDENTIFIER = /^[a-zA-Z][a-zA-Z0-9\-_]*/;

const LITERALS = {
	"[": "LBRACKET",
	"]": "RBRACKET",
	"=": "EQUALS",
	":": "COLON",
	"-": "DASH",
	"!": "BANG",
	"#": "HASH",
	".": "DOT",
	"@": "AT",
	"$": "DOLLAR",
}

const STRING = /^"((?:\\.|[^"])*)"/;

const MULTI_DENT = /^(?:\r?\n[^\r\n\S]*)+/;

const WHITESPACE = /^[^\r\n\S]+/;

const COMMENT = /^\s*\/\/[^\n]*/;

const KEYWORDS = ["IF", "ELSE"];

class Lexer {
	tokenize(code, opts) {
		var tag;
		if(opts == null) {
			opts = {};
		}
		this.code = code.replace(/^\s*/, '').replace(/\s*$/, '');
		this.line = opts.line || 0;
		this.indent = 0;
		this.indents = [];
		this.ends = [];
		this.tokens = [];
		this.i = 0;
		while(this.chunk = this.code.slice(this.i)) {
			this.i += this.identifierToken() || this.commentToken() || this.whitespaceToken() || this.lineToken() || this.stringToken() || this.literalToken();
		}
		while(tag = this.ends.pop()) {
			if(tag === 'OUTDENT') {
				this.token('OUTDENT');
			} else {
				this.error("missing " + tag);
			}
		}
		while(this.tokens[0][0] === "TERMINATOR") {
			this.tokens.shift();
		}
		while(this.tokens[this.tokens.length - 1][0] === "TERMINATOR") {
			this.tokens.pop();
		}
		return this.tokens;
	}

	commentToken() {
		let match = COMMENT.exec(this.chunk);
		if(match) {
			return match[0].length;
		} else {
			return 0;
		}
	}

	whitespaceToken() {
		let match = WHITESPACE.exec(this.chunk);
		if(match) {
			this.token('WHITESPACE', match[0].length);
			return match[0].length;
		} else {
			return 0;
		}
	}

	token(tag, value) {
		return this.tokens.push([tag, value, this.line]);
	}

	identifierToken() {
    let match = IDENTIFIER.exec(this.chunk);
		if(match) {
			let name = match[0].toUpperCase();
			if (name === "ELSE" && this.last(this.tokens, 2)[0] === "TERMINATOR") {
				this.tokens.splice(this.tokens.length - 3, 1);
			}
			if (KEYWORDS.indexOf(name) >= 0) {
				this.token(name, match[0]);
			} else {
				this.token('IDENTIFIER', match[0]);
			}
			return match[0].length;
		} else {
			return 0;
		}
	}

	stringToken() {
    let match = STRING.exec(this.chunk);
		if(match) {
			this.token('STRING_LITERAL', match[1].replace(/\\(.)/g, "$1"));
			return match[0].length;
		} else {
			return 0;
		}
	}

	lineToken() {
    let match = MULTI_DENT.exec(this.chunk);

		if(!match) { return 0; }

		let indent = match[0];

		this.line += this.count(indent, '\n');

		let prev = this.last(this.tokens, 1);
		let size = indent.length - 1 - indent.lastIndexOf('\n');
		let diff = size - this.indent;

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
	}

	literalToken() {
		let match = LITERALS[this.chunk[0]];
		if(match) {
			this.token(match);
			return 1;
		} else {
			return this.error("Unexpected token '" + (this.chunk.charAt(0)) + "'");
		}
	}

	newlineToken() {
		if(this.tag() !== 'TERMINATOR') {
			return this.token('TERMINATOR', '\n');
		}
	}

	tag(index, tag) {
		var tok;
		return (tok = this.last(this.tokens, index)) && (tag ? tok[0] = tag : tok[0]);
	}

	value(index, val) {
		var tok;
		return (tok = this.last(this.tokens, index)) && (val ? tok[1] = val : tok[1]);
	}

	error(message) {
		var chunk;
		chunk = this.code.slice(Math.max(0, this.i - 10), Math.min(this.code.length, this.i + 10));
		throw SyntaxError("" + message + " on line " + (this.line + 1) + " near " + (JSON.stringify(chunk)));
	}

	count(string, substr) {
    let num = 0;
    let pos = 0;
		if (!substr.length) {
			return 1 / 0;
		}
		while (pos = 1 + string.indexOf(substr, pos)) {
			num++;
		}
		return num;
	}

	last(array, back) {
		return array[array.length - (back || 0) - 1];
	}

}

export default Lexer;
