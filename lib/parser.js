/* Jison generated parser */
var parser = (function(){
undefined
var parser = {trace: function trace() { },
yy: {},
symbols_: {"error":2,"Root":3,"Element":4,"TERMINATOR":5,"ElementIdentifier":6,"IDENTIFIER":7,"#":8,"[":9,"]":10,"PropertyList":11,"WHITESPACE":12,"InlineChild":13,"INDENT":14,"ChildList":15,"OUTDENT":16,"STRING_LITERAL":17,"Child":18,"Instruction":19,"Property":20,"=":21,"!":22,":":23,"-":24,"InstructionArgument":25,"$accept":0,"$end":1},
terminals_: {2:"error",5:"TERMINATOR",7:"IDENTIFIER",8:"#",9:"[",10:"]",12:"WHITESPACE",14:"INDENT",16:"OUTDENT",17:"STRING_LITERAL",21:"=",22:"!",23:":",24:"-"},
productions_: [0,[3,0],[3,1],[3,2],[6,1],[6,3],[6,2],[4,1],[4,3],[4,4],[4,3],[4,4],[13,1],[13,1],[15,0],[15,1],[15,3],[18,1],[18,1],[18,1],[11,1],[11,3],[20,3],[20,4],[20,3],[20,3],[19,3],[19,3],[19,4],[25,1],[25,1]],
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
          name: $$[$0]
        };
break;
case 5:this.$ = {
          name: $$[$0-2],
          shortId: $$[$0]
        };
break;
case 6:this.$ = {
          name: 'div',
          shortId: $$[$0]
        };
break;
case 7:this.$ = {
          name: $$[$0].name,
          shortId: $$[$0].shortId,
          properties: [],
          children: [],
          type: 'element'
        };
break;
case 8:this.$ = $$[$0-2];
break;
case 9:this.$ = (function () {
        $$[$0-3].properties = $$[$0-1];
        return $$[$0-3];
      }());
break;
case 10:this.$ = (function () {
        $$[$0-2].children = $$[$0-2].children.concat($$[$0]);
        return $$[$0-2];
      }());
break;
case 11:this.$ = (function () {
        $$[$0-3].children = $$[$0-3].children.concat($$[$0-1]);
        return $$[$0-3];
      }());
break;
case 12:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: true
        };
break;
case 13:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: false
        };
break;
case 14:this.$ = [];
break;
case 15:this.$ = [$$[$0]];
break;
case 16:this.$ = $$[$0-2].concat($$[$0]);
break;
case 17:this.$ = $$[$0];
break;
case 18:this.$ = $$[$0];
break;
case 19:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: false
        };
break;
case 20:this.$ = [$$[$0]];
break;
case 21:this.$ = $$[$0-2].concat($$[$0]);
break;
case 22:this.$ = {
          name: $$[$0-2],
          value: $$[$0],
          bound: true,
          scope: 'attribute'
        };
break;
case 23:this.$ = {
          name: $$[$0-3],
          value: $$[$0-1],
          bound: true,
          scope: 'attribute',
          preventDefault: true
        };
break;
case 24:this.$ = {
          name: $$[$0-2],
          value: $$[$0],
          bound: false,
          scope: 'attribute'
        };
break;
case 25:this.$ = (function () {
        $$[$0].scope = $$[$0-2];
        return $$[$0];
      }());
break;
case 26:this.$ = {
          command: $$[$0],
          arguments: [],
          children: [],
          type: 'instruction'
        };
break;
case 27:this.$ = (function () {
        $$[$0-2].arguments.push($$[$0]);
        return $$[$0-2];
      }());
break;
case 28:this.$ = (function () {
        $$[$0-3].children = $$[$0-1];
        return $$[$0-3];
      }());
break;
case 29:this.$ = $$[$0];
break;
case 30:this.$ = $$[$0];
break;
}
},
table: [{1:[2,1],3:1,4:2,6:3,7:[1,4],8:[1,5]},{1:[3]},{1:[2,2],5:[1,6],9:[1,7],12:[1,8],14:[1,9]},{1:[2,7],5:[2,7],9:[2,7],12:[2,7],14:[2,7],16:[2,7]},{1:[2,4],5:[2,4],8:[1,10],9:[2,4],12:[2,4],14:[2,4],16:[2,4]},{7:[1,11]},{1:[2,3]},{7:[1,15],10:[1,12],11:13,20:14},{7:[1,17],13:16,17:[1,18]},{4:21,5:[2,14],6:3,7:[1,4],8:[1,5],15:19,16:[2,14],17:[1,23],18:20,19:22,24:[1,24]},{7:[1,25]},{1:[2,6],5:[2,6],9:[2,6],12:[2,6],14:[2,6],16:[2,6]},{1:[2,8],5:[2,8],9:[2,8],12:[2,8],14:[2,8],16:[2,8]},{10:[1,26],12:[1,27]},{10:[2,20],12:[2,20]},{21:[1,28],23:[1,29]},{1:[2,10],5:[2,10],9:[2,10],12:[2,10],14:[2,10],16:[2,10]},{1:[2,12],5:[2,12],9:[2,12],12:[2,12],14:[2,12],16:[2,12]},{1:[2,13],5:[2,13],9:[2,13],12:[2,13],14:[2,13],16:[2,13]},{5:[1,31],16:[1,30]},{5:[2,15],16:[2,15]},{5:[2,17],9:[1,7],12:[1,8],14:[1,9],16:[2,17]},{5:[2,18],12:[1,32],14:[1,33],16:[2,18]},{5:[2,19],16:[2,19]},{12:[1,34]},{1:[2,5],5:[2,5],9:[2,5],12:[2,5],14:[2,5],16:[2,5]},{1:[2,9],5:[2,9],9:[2,9],12:[2,9],14:[2,9],16:[2,9]},{7:[1,15],20:35},{7:[1,36],17:[1,37]},{7:[1,15],20:38},{1:[2,11],5:[2,11],9:[2,11],12:[2,11],14:[2,11],16:[2,11]},{4:21,6:3,7:[1,4],8:[1,5],17:[1,23],18:39,19:22,24:[1,24]},{7:[1,41],17:[1,42],25:40},{4:21,5:[2,14],6:3,7:[1,4],8:[1,5],15:43,16:[2,14],17:[1,23],18:20,19:22,24:[1,24]},{7:[1,44]},{10:[2,21],12:[2,21]},{10:[2,22],12:[2,22],22:[1,45]},{10:[2,24],12:[2,24]},{10:[2,25],12:[2,25]},{5:[2,16],16:[2,16]},{5:[2,27],12:[2,27],14:[2,27],16:[2,27]},{5:[2,29],12:[2,29],14:[2,29],16:[2,29]},{5:[2,30],12:[2,30],14:[2,30],16:[2,30]},{5:[1,31],16:[1,46]},{5:[2,26],12:[2,26],14:[2,26],16:[2,26]},{10:[2,23],12:[2,23]},{5:[2,28],12:[2,28],14:[2,28],16:[2,28]}],
defaultActions: {6:[2,3]},
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