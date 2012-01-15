/* Jison generated parser */
var parser = (function(){
undefined
var parser = {trace: function trace() { },
yy: {},
symbols_: {"error":2,"Root":3,"Element":4,"TERMINATOR":5,"ElementIdentifier":6,"IDENTIFIER":7,"#":8,".":9,"[":10,"]":11,"PropertyList":12,"WHITESPACE":13,"InlineChild":14,"INDENT":15,"ChildList":16,"OUTDENT":17,"STRING_LITERAL":18,"Child":19,"Instruction":20,"Property":21,"=":22,"!":23,":":24,"-":25,"InstructionArgument":26,"$accept":0,"$end":1},
terminals_: {2:"error",5:"TERMINATOR",7:"IDENTIFIER",8:"#",9:".",10:"[",11:"]",13:"WHITESPACE",15:"INDENT",17:"OUTDENT",18:"STRING_LITERAL",22:"=",23:"!",24:":",25:"-"},
productions_: [0,[3,0],[3,1],[3,2],[6,1],[6,3],[6,2],[6,2],[6,3],[4,1],[4,3],[4,4],[4,3],[4,4],[14,1],[14,1],[16,0],[16,1],[16,3],[19,1],[19,1],[19,1],[12,1],[12,3],[21,3],[21,4],[21,3],[21,3],[20,3],[20,3],[20,4],[26,1],[26,1]],
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
          shortClasses: []
        };
break;
case 5:this.$ = {
          name: $$[$0-2],
          shortId: $$[$0],
          shortClasses: []
        };
break;
case 6:this.$ = {
          name: 'div',
          shortId: $$[$0],
          shortClasses: []
        };
break;
case 7:this.$ = {
          name: 'div',
          shortClasses: [$$[$0]]
        };
break;
case 8:this.$ = (function () {
        $$[$0-2].shortClasses.push($$[$0]);
        return $$[$0-2];
      }());
break;
case 9:this.$ = {
          name: $$[$0].name,
          shortId: $$[$0].shortId,
          shortClasses: $$[$0].shortClasses,
          properties: [],
          children: [],
          type: 'element'
        };
break;
case 10:this.$ = $$[$0-2];
break;
case 11:this.$ = (function () {
        $$[$0-3].properties = $$[$0-1];
        return $$[$0-3];
      }());
break;
case 12:this.$ = (function () {
        $$[$0-2].children = $$[$0-2].children.concat($$[$0]);
        return $$[$0-2];
      }());
break;
case 13:this.$ = (function () {
        $$[$0-3].children = $$[$0-3].children.concat($$[$0-1]);
        return $$[$0-3];
      }());
break;
case 14:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: true
        };
break;
case 15:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: false
        };
break;
case 16:this.$ = [];
break;
case 17:this.$ = [$$[$0]];
break;
case 18:this.$ = $$[$0-2].concat($$[$0]);
break;
case 19:this.$ = $$[$0];
break;
case 20:this.$ = $$[$0];
break;
case 21:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: false
        };
break;
case 22:this.$ = [$$[$0]];
break;
case 23:this.$ = $$[$0-2].concat($$[$0]);
break;
case 24:this.$ = {
          name: $$[$0-2],
          value: $$[$0],
          bound: true,
          scope: 'attribute'
        };
break;
case 25:this.$ = {
          name: $$[$0-3],
          value: $$[$0-1],
          bound: true,
          scope: 'attribute',
          preventDefault: true
        };
break;
case 26:this.$ = {
          name: $$[$0-2],
          value: $$[$0],
          bound: false,
          scope: 'attribute'
        };
break;
case 27:this.$ = (function () {
        $$[$0].scope = $$[$0-2];
        return $$[$0];
      }());
break;
case 28:this.$ = {
          command: $$[$0],
          arguments: [],
          children: [],
          type: 'instruction'
        };
break;
case 29:this.$ = (function () {
        $$[$0-2].arguments.push($$[$0]);
        return $$[$0-2];
      }());
break;
case 30:this.$ = (function () {
        $$[$0-3].children = $$[$0-1];
        return $$[$0-3];
      }());
break;
case 31:this.$ = $$[$0];
break;
case 32:this.$ = $$[$0];
break;
}
},
table: [{1:[2,1],3:1,4:2,6:3,7:[1,4],8:[1,5],9:[1,6]},{1:[3]},{1:[2,2],5:[1,7],10:[1,8],13:[1,9],15:[1,10]},{1:[2,9],5:[2,9],9:[1,11],10:[2,9],13:[2,9],15:[2,9],17:[2,9]},{1:[2,4],5:[2,4],8:[1,12],9:[2,4],10:[2,4],13:[2,4],15:[2,4],17:[2,4]},{7:[1,13]},{7:[1,14]},{1:[2,3]},{7:[1,18],11:[1,15],12:16,21:17},{7:[1,20],14:19,18:[1,21]},{4:24,5:[2,16],6:3,7:[1,4],8:[1,5],9:[1,6],16:22,17:[2,16],18:[1,26],19:23,20:25,25:[1,27]},{7:[1,28]},{7:[1,29]},{1:[2,6],5:[2,6],9:[2,6],10:[2,6],13:[2,6],15:[2,6],17:[2,6]},{1:[2,7],5:[2,7],9:[2,7],10:[2,7],13:[2,7],15:[2,7],17:[2,7]},{1:[2,10],5:[2,10],10:[2,10],13:[2,10],15:[2,10],17:[2,10]},{11:[1,30],13:[1,31]},{11:[2,22],13:[2,22]},{22:[1,32],24:[1,33]},{1:[2,12],5:[2,12],10:[2,12],13:[2,12],15:[2,12],17:[2,12]},{1:[2,14],5:[2,14],10:[2,14],13:[2,14],15:[2,14],17:[2,14]},{1:[2,15],5:[2,15],10:[2,15],13:[2,15],15:[2,15],17:[2,15]},{5:[1,35],17:[1,34]},{5:[2,17],17:[2,17]},{5:[2,19],10:[1,8],13:[1,9],15:[1,10],17:[2,19]},{5:[2,20],13:[1,36],15:[1,37],17:[2,20]},{5:[2,21],17:[2,21]},{13:[1,38]},{1:[2,8],5:[2,8],9:[2,8],10:[2,8],13:[2,8],15:[2,8],17:[2,8]},{1:[2,5],5:[2,5],9:[2,5],10:[2,5],13:[2,5],15:[2,5],17:[2,5]},{1:[2,11],5:[2,11],10:[2,11],13:[2,11],15:[2,11],17:[2,11]},{7:[1,18],21:39},{7:[1,40],18:[1,41]},{7:[1,18],21:42},{1:[2,13],5:[2,13],10:[2,13],13:[2,13],15:[2,13],17:[2,13]},{4:24,6:3,7:[1,4],8:[1,5],9:[1,6],18:[1,26],19:43,20:25,25:[1,27]},{7:[1,45],18:[1,46],26:44},{4:24,5:[2,16],6:3,7:[1,4],8:[1,5],9:[1,6],16:47,17:[2,16],18:[1,26],19:23,20:25,25:[1,27]},{7:[1,48]},{11:[2,23],13:[2,23]},{11:[2,24],13:[2,24],23:[1,49]},{11:[2,26],13:[2,26]},{11:[2,27],13:[2,27]},{5:[2,18],17:[2,18]},{5:[2,29],13:[2,29],15:[2,29],17:[2,29]},{5:[2,31],13:[2,31],15:[2,31],17:[2,31]},{5:[2,32],13:[2,32],15:[2,32],17:[2,32]},{5:[1,35],17:[1,50]},{5:[2,28],13:[2,28],15:[2,28],17:[2,28]},{11:[2,25],13:[2,25]},{5:[2,30],13:[2,30],15:[2,30],17:[2,30]}],
defaultActions: {7:[2,3]},
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