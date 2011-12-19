/* Jison generated parser */
var parser = (function(){
undefined
var parser = {trace: function trace() { },
yy: {},
symbols_: {"error":2,"Root":3,"Element":4,"TERMINATOR":5,"IDENTIFIER":6,"LPAREN":7,"RPAREN":8,"PropertyList":9,"WHITESPACE":10,"InlineChild":11,"INDENT":12,"ChildList":13,"OUTDENT":14,"STRING_LITERAL":15,"Child":16,"Instruction":17,"Property":18,"ASSIGN":19,"BANG":20,"SCOPE":21,"INSTRUCT":22,"InstructionArgumentsList":23,"InstructionArgument":24,"$accept":0,"$end":1},
terminals_: {2:"error",5:"TERMINATOR",6:"IDENTIFIER",7:"LPAREN",8:"RPAREN",10:"WHITESPACE",12:"INDENT",14:"OUTDENT",15:"STRING_LITERAL",19:"ASSIGN",20:"BANG",21:"SCOPE",22:"INSTRUCT"},
productions_: [0,[3,0],[3,1],[3,2],[4,1],[4,3],[4,4],[4,3],[4,4],[11,1],[11,1],[13,0],[13,1],[13,3],[16,1],[16,1],[16,1],[9,1],[9,3],[18,3],[18,4],[18,3],[18,3],[17,5],[17,4],[23,1],[23,3],[24,1],[24,1]],
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
          name: $$[$0],
          properties: [],
          children: [],
          type: 'element'
        };
break;
case 5:this.$ = $$[$0-2];
break;
case 6:this.$ = (function () {
        $$[$0-3].properties = $$[$0-1];
        return $$[$0-3];
      }());
break;
case 7:this.$ = (function () {
        $$[$0-2].children = $$[$0-2].children.concat($$[$0]);
        return $$[$0-2];
      }());
break;
case 8:this.$ = (function () {
        $$[$0-3].children = $$[$0-3].children.concat($$[$0-1]);
        return $$[$0-3];
      }());
break;
case 9:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: true
        };
break;
case 10:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: false
        };
break;
case 11:this.$ = [];
break;
case 12:this.$ = [$$[$0]];
break;
case 13:this.$ = $$[$0-2].concat($$[$0]);
break;
case 14:this.$ = $$[$0];
break;
case 15:this.$ = $$[$0];
break;
case 16:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: false
        };
break;
case 17:this.$ = [$$[$0]];
break;
case 18:this.$ = $$[$0-2].concat($$[$0]);
break;
case 19:this.$ = {
          name: $$[$0-2],
          value: $$[$0],
          bound: true,
          scope: 'attribute'
        };
break;
case 20:this.$ = {
          name: $$[$0-3],
          value: $$[$0-1],
          bound: true,
          scope: 'attribute',
          preventDefault: true
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
table: [{1:[2,1],3:1,4:2,6:[1,3]},{1:[3]},{1:[2,2],5:[1,4],7:[1,5],10:[1,6],12:[1,7]},{1:[2,4],5:[2,4],7:[2,4],10:[2,4],12:[2,4],14:[2,4]},{1:[2,3]},{6:[1,11],8:[1,8],9:9,18:10},{6:[1,13],11:12,15:[1,14]},{4:17,5:[2,11],6:[1,3],13:15,14:[2,11],15:[1,19],16:16,17:18,22:[1,20]},{1:[2,5],5:[2,5],7:[2,5],10:[2,5],12:[2,5],14:[2,5]},{8:[1,21],10:[1,22]},{8:[2,17],10:[2,17]},{19:[1,23],21:[1,24]},{1:[2,7],5:[2,7],7:[2,7],10:[2,7],12:[2,7],14:[2,7]},{1:[2,9],5:[2,9],7:[2,9],10:[2,9],12:[2,9],14:[2,9]},{1:[2,10],5:[2,10],7:[2,10],10:[2,10],12:[2,10],14:[2,10]},{5:[1,26],14:[1,25]},{5:[2,12],14:[2,12]},{5:[2,14],7:[1,5],10:[1,6],12:[1,7],14:[2,14]},{5:[2,15],12:[1,27],14:[2,15]},{5:[2,16],14:[2,16]},{10:[1,28]},{1:[2,6],5:[2,6],7:[2,6],10:[2,6],12:[2,6],14:[2,6]},{6:[1,11],18:29},{6:[1,30],15:[1,31]},{6:[1,11],18:32},{1:[2,8],5:[2,8],7:[2,8],10:[2,8],12:[2,8],14:[2,8]},{4:17,6:[1,3],15:[1,19],16:33,17:18,22:[1,20]},{4:17,5:[2,11],6:[1,3],13:34,14:[2,11],15:[1,19],16:16,17:18,22:[1,20]},{6:[1,35]},{8:[2,18],10:[2,18]},{8:[2,19],10:[2,19],20:[1,36]},{8:[2,21],10:[2,21]},{8:[2,22],10:[2,22]},{5:[2,13],14:[2,13]},{5:[1,26],14:[1,37]},{10:[1,38]},{8:[2,20],10:[2,20]},{5:[2,24],12:[2,24],14:[2,24]},{6:[1,41],15:[1,42],23:39,24:40},{5:[2,23],10:[1,43],12:[2,23],14:[2,23]},{5:[2,25],10:[2,25],12:[2,25],14:[2,25]},{5:[2,27],10:[2,27],12:[2,27],14:[2,27]},{5:[2,28],10:[2,28],12:[2,28],14:[2,28]},{6:[1,41],15:[1,42],24:44},{5:[2,26],10:[2,26],12:[2,26],14:[2,26]}],
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