/* Jison generated parser */
var parser = (function(){
undefined
var parser = {trace: function trace() { },
yy: {},
symbols_: {"error":2,"Root":3,"Element":4,"TERMINATOR":5,"IDENTIFIER":6,"PropertyArgument":7,"WHITESPACE":8,"InlineChild":9,"INDENT":10,"ChildList":11,"OUTDENT":12,"STRING_LITERAL":13,"Child":14,"Instruction":15,"LPAREN":16,"RPAREN":17,"PropertyList":18,"Property":19,"ASSIGN":20,"SCOPE":21,"INSTRUCT":22,"InstructionArgumentsList":23,"InstructionArgument":24,"$accept":0,"$end":1},
terminals_: {2:"error",5:"TERMINATOR",6:"IDENTIFIER",8:"WHITESPACE",10:"INDENT",12:"OUTDENT",13:"STRING_LITERAL",16:"LPAREN",17:"RPAREN",20:"ASSIGN",21:"SCOPE",22:"INSTRUCT"},
productions_: [0,[3,0],[3,1],[3,2],[4,2],[4,3],[4,4],[9,1],[9,1],[11,0],[11,1],[11,3],[14,1],[14,1],[14,1],[7,0],[7,2],[7,3],[18,1],[18,3],[19,3],[19,3],[19,3],[15,5],[15,4],[23,1],[23,3],[24,1],[24,1]],
performAction: function anonymous(yytext,yyleng,yylineno,yy,yystate,$$,_$) {

var $0 = $$.length - 1;
switch (yystate) {
case 1:this.$ = null;
break;
case 2:return this.$
break;
case 3:return this.$
break;
case 4:this.$ = {
          name: $$[$0-1],
          properties: $$[$0],
          children: [],
          type: 'element'
        };
break;
case 5:this.$ = (function () {
        $$[$0-2].children = $$[$0-2].children.concat($$[$0]);
        return $$[$0-2];
      }());
break;
case 6:this.$ = (function () {
        $$[$0-3].children = $$[$0-3].children.concat($$[$0-1]);
        return $$[$0-3];
      }());
break;
case 7:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: true
        };
break;
case 8:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: false
        };
break;
case 9:this.$ = [];
break;
case 10:this.$ = [$$[$0]];
break;
case 11:this.$ = $$[$0-2].concat($$[$0]);
break;
case 12:this.$ = $$[$0];
break;
case 13:this.$ = $$[$0];
break;
case 14:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: false
        };
break;
case 15:this.$ = [];
break;
case 16:this.$ = [];
break;
case 17:this.$ = $$[$0-1];
break;
case 18:this.$ = [$$[$0]];
break;
case 19:this.$ = $$[$0-2].concat($$[$0]);
break;
case 20:this.$ = {
          name: $$[$0-2],
          value: $$[$0],
          bound: true,
          scope: 'attribute'
        };
break;
case 21:this.$ = {
          name: $$[$0-2],
          value: $$[$0],
          bound: false,
          scope: 'attribute'
        };
break;
case 22:this.$ = (function () {
        $$[$0].scope = $$[$0-2];
        return $$[$0];
      }());
break;
case 23:this.$ = {
          command: $$[$0-2],
          arguments: $$[$0],
          children: [],
          type: 'instruction'
        };
break;
case 24:this.$ = (function () {
        $$[$0-3].children = $$[$0-1];
        return $$[$0-3];
      }());
break;
case 25:this.$ = [$$[$0]];
break;
case 26:this.$ = $$[$0-2].concat($$[$0]);
break;
case 27:this.$ = $$[$0];
break;
case 28:this.$ = $$[$0];
break;
}
},
table: [{1:[2,1],3:1,4:2,6:[1,3]},{1:[3]},{1:[2,2],5:[1,4],8:[1,5],10:[1,6]},{1:[2,15],5:[2,15],7:7,8:[2,15],10:[2,15],12:[2,15],16:[1,8]},{1:[2,3]},{6:[1,10],9:9,13:[1,11]},{4:14,5:[2,9],6:[1,3],11:12,12:[2,9],13:[1,16],14:13,15:15,22:[1,17]},{1:[2,4],5:[2,4],8:[2,4],10:[2,4],12:[2,4]},{6:[1,21],17:[1,18],18:19,19:20},{1:[2,5],5:[2,5],8:[2,5],10:[2,5],12:[2,5]},{1:[2,7],5:[2,7],8:[2,7],10:[2,7],12:[2,7]},{1:[2,8],5:[2,8],8:[2,8],10:[2,8],12:[2,8]},{5:[1,23],12:[1,22]},{5:[2,10],12:[2,10]},{5:[2,12],8:[1,5],10:[1,6],12:[2,12]},{5:[2,13],10:[1,24],12:[2,13]},{5:[2,14],12:[2,14]},{8:[1,25]},{1:[2,16],5:[2,16],8:[2,16],10:[2,16],12:[2,16]},{8:[1,27],17:[1,26]},{8:[2,18],17:[2,18]},{20:[1,28],21:[1,29]},{1:[2,6],5:[2,6],8:[2,6],10:[2,6],12:[2,6]},{4:14,6:[1,3],13:[1,16],14:30,15:15,22:[1,17]},{4:14,5:[2,9],6:[1,3],11:31,12:[2,9],13:[1,16],14:13,15:15,22:[1,17]},{6:[1,32]},{1:[2,17],5:[2,17],8:[2,17],10:[2,17],12:[2,17]},{6:[1,21],19:33},{6:[1,34],13:[1,35]},{6:[1,21],19:36},{5:[2,11],12:[2,11]},{5:[1,23],12:[1,37]},{8:[1,38]},{8:[2,19],17:[2,19]},{8:[2,20],17:[2,20]},{8:[2,21],17:[2,21]},{8:[2,22],17:[2,22]},{5:[2,24],10:[2,24],12:[2,24]},{6:[1,41],13:[1,42],23:39,24:40},{5:[2,23],8:[1,43],10:[2,23],12:[2,23]},{5:[2,25],8:[2,25],10:[2,25],12:[2,25]},{5:[2,27],8:[2,27],10:[2,27],12:[2,27]},{5:[2,28],8:[2,28],10:[2,28],12:[2,28]},{6:[1,41],13:[1,42],24:44},{5:[2,26],8:[2,26],10:[2,26],12:[2,26]}],
defaultActions: {4:[2,3]},
parseError: function parseError(str, hash) {
    throw new Error(str);
},
parse: function parse(input) {
    var self = this, stack = [0], vstack = [null], lstack = [], table = this.table, yytext = "", yylineno = 0, yyleng = 0, recovering = 0, TERROR = 2, EOF = 1;
    this.lexer.setInput(input);
    this.lexer.yy = this.yy;
    this.yy.lexer = this.lexer;
    if (typeof this.lexer.yylloc == "undefined")
        this.lexer.yylloc = {};
    var yyloc = this.lexer.yylloc;
    lstack.push(yyloc);
    if (typeof this.yy.parseError === "function")
        this.parseError = this.yy.parseError;
    function popStack(n) {
        stack.length = stack.length - 2 * n;
        vstack.length = vstack.length - n;
        lstack.length = lstack.length - n;
    }
    function lex() {
        var token;
        token = self.lexer.lex() || 1;
        if (typeof token !== "number") {
            token = self.symbols_[token] || token;
        }
        return token;
    }
    var symbol, preErrorSymbol, state, action, a, r, yyval = {}, p, len, newState, expected;
    while (true) {
        state = stack[stack.length - 1];
        if (this.defaultActions[state]) {
            action = this.defaultActions[state];
        } else {
            if (symbol == null)
                symbol = lex();
            action = table[state] && table[state][symbol];
        }
        if (typeof action === "undefined" || !action.length || !action[0]) {
            if (!recovering) {
                expected = [];
                for (p in table[state])
                    if (this.terminals_[p] && p > 2) {
                        expected.push("'" + this.terminals_[p] + "'");
                    }
                var errStr = "";
                if (this.lexer.showPosition) {
                    errStr = "Parse error on line " + (yylineno + 1) + ":\n" + this.lexer.showPosition() + "\nExpecting " + expected.join(", ") + ", got '" + this.terminals_[symbol] + "'";
                } else {
                    errStr = "Parse error on line " + (yylineno + 1) + ": Unexpected " + (symbol == 1?"end of input":"'" + (this.terminals_[symbol] || symbol) + "'");
                }
                this.parseError(errStr, {text: this.lexer.match, token: this.terminals_[symbol] || symbol, line: this.lexer.yylineno, loc: yyloc, expected: expected});
            }
        }
        if (action[0] instanceof Array && action.length > 1) {
            throw new Error("Parse Error: multiple actions possible at state: " + state + ", token: " + symbol);
        }
        switch (action[0]) {
        case 1:
            stack.push(symbol);
            vstack.push(this.lexer.yytext);
            lstack.push(this.lexer.yylloc);
            stack.push(action[1]);
            symbol = null;
            if (!preErrorSymbol) {
                yyleng = this.lexer.yyleng;
                yytext = this.lexer.yytext;
                yylineno = this.lexer.yylineno;
                yyloc = this.lexer.yylloc;
                if (recovering > 0)
                    recovering--;
            } else {
                symbol = preErrorSymbol;
                preErrorSymbol = null;
            }
            break;
        case 2:
            len = this.productions_[action[1]][1];
            yyval.$ = vstack[vstack.length - len];
            yyval._$ = {first_line: lstack[lstack.length - (len || 1)].first_line, last_line: lstack[lstack.length - 1].last_line, first_column: lstack[lstack.length - (len || 1)].first_column, last_column: lstack[lstack.length - 1].last_column};
            r = this.performAction.call(yyval, yytext, yyleng, yylineno, this.yy, action[1], vstack, lstack);
            if (typeof r !== "undefined") {
                return r;
            }
            if (len) {
                stack = stack.slice(0, -1 * len * 2);
                vstack = vstack.slice(0, -1 * len);
                lstack = lstack.slice(0, -1 * len);
            }
            stack.push(this.productions_[action[1]][0]);
            vstack.push(yyval.$);
            lstack.push(yyval._$);
            newState = table[stack[stack.length - 2]][stack[stack.length - 1]];
            stack.push(newState);
            break;
        case 3:
            return true;
        }
    }
    return true;
}
};
return parser;
})();
if (typeof require !== 'undefined' && typeof exports !== 'undefined') {
exports.parser = parser;
exports.parse = function () { return parser.parse.apply(parser, arguments); }
exports.main = function commonjsMain(args) {
    if (!args[1])
        throw new Error('Usage: '+args[0]+' FILE');
    if (typeof process !== 'undefined') {
        var source = require('fs').readFileSync(require('path').join(process.cwd(), args[1]), "utf8");
    } else {
        var cwd = require("file").path(require("file").cwd());
        var source = cwd.join(args[1]).read({charset: "utf-8"});
    }
    return exports.parser.parse(source);
}
if (typeof module !== 'undefined' && require.main === module) {
  exports.main(typeof process !== 'undefined' ? process.argv.slice(1) : require("system").args);
}
}