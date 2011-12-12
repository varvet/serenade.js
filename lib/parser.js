/* Jison generated parser */
var parser = (function(){
undefined
var parser = {trace: function trace() { },
yy: {},
symbols_: {"error":2,"Root":3,"Element":4,"IDENTIFIER":5,"AttributeArgument":6,"INDENT":7,"ChildList":8,"OUTDENT":9,"WHITESPACE":10,"InlineChildList":11,"InlineChild":12,"STRING_LITERAL":13,"Child":14,"TERMINATOR":15,"Instruction":16,"LPAREN":17,"RPAREN":18,"AttributeList":19,"Attribute":20,"ASSIGN":21,"INSTRUCT":22,"InstructionArgumentsList":23,"InstructionArgument":24,"$accept":0,"$end":1},
terminals_: {2:"error",5:"IDENTIFIER",7:"INDENT",9:"OUTDENT",10:"WHITESPACE",13:"STRING_LITERAL",15:"TERMINATOR",17:"LPAREN",18:"RPAREN",21:"ASSIGN",22:"INSTRUCT"},
productions_: [0,[3,0],[3,1],[4,2],[4,5],[4,4],[11,1],[11,3],[12,1],[12,1],[8,0],[8,1],[8,3],[14,1],[14,1],[14,1],[6,0],[6,2],[6,3],[19,1],[19,3],[20,3],[20,3],[16,5],[16,4],[23,1],[23,3],[24,1],[24,1]],
performAction: function anonymous(yytext,yyleng,yylineno,yy,yystate,$$,_$) {

var $0 = $$.length - 1;
switch (yystate) {
case 1:this.$ = null;
break;
case 2:return this.$
break;
case 3:this.$ = new yy.Monkey.Element($$[$0-1], $$[$0]);
break;
case 4:this.$ = new yy.Monkey.Element($$[$0-4], $$[$0-3], $$[$0-1]);
break;
case 5:this.$ = new yy.Monkey.Element($$[$0-3], $$[$0-2], $$[$0]);
break;
case 6:this.$ = [$$[$0]];
break;
case 7:this.$ = $$[$0-2].concat($$[$0]);
break;
case 8:this.$ = new yy.Monkey.TextNode($$[$0], true);
break;
case 9:this.$ = new yy.Monkey.TextNode($$[$0], false);
break;
case 10:this.$ = [];
break;
case 11:this.$ = [$$[$0]];
break;
case 12:this.$ = $$[$0-2].concat($$[$0]);
break;
case 13:this.$ = $$[$0];
break;
case 14:this.$ = $$[$0];
break;
case 15:this.$ = new yy.Monkey.TextNode($$[$0], false);
break;
case 16:this.$ = [];
break;
case 17:this.$ = [];
break;
case 18:this.$ = $$[$0-1];
break;
case 19:this.$ = [$$[$0]];
break;
case 20:this.$ = $$[$0-2].concat($$[$0]);
break;
case 21:this.$ = new yy.Monkey.Attribute($$[$0-2], $$[$0], true);
break;
case 22:this.$ = new yy.Monkey.Attribute($$[$0-2], $$[$0], false);
break;
case 23:this.$ = new yy.Monkey.Instruction($$[$0-2], $$[$0]);
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
table: [{1:[2,1],3:1,4:2,5:[1,3]},{1:[3]},{1:[2,2]},{1:[2,16],6:4,7:[2,16],9:[2,16],10:[2,16],15:[2,16],17:[1,5]},{1:[2,3],7:[1,6],9:[2,3],10:[1,7],15:[2,3]},{5:[1,11],18:[1,8],19:9,20:10},{4:14,5:[1,3],8:12,9:[2,10],13:[1,16],14:13,15:[2,10],16:15,22:[1,17]},{5:[1,20],11:18,12:19,13:[1,21]},{1:[2,17],7:[2,17],9:[2,17],10:[2,17],15:[2,17]},{10:[1,23],18:[1,22]},{10:[2,19],18:[2,19]},{21:[1,24]},{9:[1,25],15:[1,26]},{9:[2,11],15:[2,11]},{9:[2,13],15:[2,13]},{7:[1,27],9:[2,14],15:[2,14]},{9:[2,15],15:[2,15]},{10:[1,28]},{1:[2,5],9:[2,5],10:[1,29],15:[2,5]},{1:[2,6],9:[2,6],10:[2,6],15:[2,6]},{1:[2,8],9:[2,8],10:[2,8],15:[2,8]},{1:[2,9],9:[2,9],10:[2,9],15:[2,9]},{1:[2,18],7:[2,18],9:[2,18],10:[2,18],15:[2,18]},{5:[1,11],20:30},{5:[1,31],13:[1,32]},{1:[2,4],9:[2,4],15:[2,4]},{4:14,5:[1,3],13:[1,16],14:33,16:15,22:[1,17]},{4:14,5:[1,3],8:34,9:[2,10],13:[1,16],14:13,15:[2,10],16:15,22:[1,17]},{5:[1,35]},{5:[1,20],12:36,13:[1,21]},{10:[2,20],18:[2,20]},{10:[2,21],18:[2,21]},{10:[2,22],18:[2,22]},{9:[2,12],15:[2,12]},{9:[1,37],15:[1,26]},{10:[1,38]},{1:[2,7],9:[2,7],10:[2,7],15:[2,7]},{7:[2,24],9:[2,24],15:[2,24]},{5:[1,41],13:[1,42],23:39,24:40},{7:[2,23],9:[2,23],10:[1,43],15:[2,23]},{7:[2,25],9:[2,25],10:[2,25],15:[2,25]},{7:[2,27],9:[2,27],10:[2,27],15:[2,27]},{7:[2,28],9:[2,28],10:[2,28],15:[2,28]},{5:[1,41],13:[1,42],24:44},{7:[2,26],9:[2,26],10:[2,26],15:[2,26]}],
defaultActions: {2:[2,2]},
parseError: function parseError(str, hash) {
    throw new Error(str);
},
parse: function parse(input) {
    var self = this,
        stack = [0],
        vstack = [null], // semantic value stack
        lstack = [], // location stack
        table = this.table,
        yytext = '',
        yylineno = 0,
        yyleng = 0,
        recovering = 0,
        TERROR = 2,
        EOF = 1;

    //this.reductionCount = this.shiftCount = 0;

    this.lexer.setInput(input);
    this.lexer.yy = this.yy;
    this.yy.lexer = this.lexer;
    if (typeof this.lexer.yylloc == 'undefined')
        this.lexer.yylloc = {};
    var yyloc = this.lexer.yylloc;
    lstack.push(yyloc);

    if (typeof this.yy.parseError === 'function')
        this.parseError = this.yy.parseError;

    function popStack (n) {
        stack.length = stack.length - 2*n;
        vstack.length = vstack.length - n;
        lstack.length = lstack.length - n;
    }

    function lex() {
        var token;
        token = self.lexer.lex() || 1; // $end = 1
        // if token isn't its numeric value, convert
        if (typeof token !== 'number') {
            token = self.symbols_[token] || token;
        }
        return token;
    };

    var symbol, preErrorSymbol, state, action, a, r, yyval={},p,len,newState, expected;
    while (true) {
        // retreive state number from top of stack
        state = stack[stack.length-1];

        // use default actions if available
        if (this.defaultActions[state]) {
            action = this.defaultActions[state];
        } else {
            if (symbol == null)
                symbol = lex();
            // read action for current state and first input
            action = table[state] && table[state][symbol];
        }

        // handle parse error
        if (typeof action === 'undefined' || !action.length || !action[0]) {

            if (!recovering) {
                // Report error
                expected = [];
                for (p in table[state]) if (this.terminals_[p] && p > 2) {
                    expected.push("'"+this.terminals_[p]+"'");
                }
                var errStr = '';
                if (this.lexer.showPosition) {
                    errStr = 'Parse error on line '+(yylineno+1)+":\n"+this.lexer.showPosition()+'\nExpecting '+expected.join(', ');
                } else {
                    errStr = 'Parse error on line '+(yylineno+1)+": Unexpected " +
                                  (symbol == 1 /*EOF*/ ? "end of input" :
                                              ("'"+(this.terminals_[symbol] || symbol)+"'"));
                }
                this.parseError(errStr,
                    {text: this.lexer.match, token: this.terminals_[symbol] || symbol, line: this.lexer.yylineno, loc: yyloc, expected: expected});
            }

            // just recovered from another error
            if (recovering == 3) {
                if (symbol == EOF) {
                    throw new Error(errStr || 'Parsing halted.');
                }

                // discard current lookahead and grab another
                yyleng = this.lexer.yyleng;
                yytext = this.lexer.yytext;
                yylineno = this.lexer.yylineno;
                yyloc = this.lexer.yylloc;
                symbol = lex();
            }

            // try to recover from error
            while (1) {
                // check for error recovery rule in this state
                if ((TERROR.toString()) in table[state]) {
                    break;
                }
                if (state == 0) {
                    throw new Error(errStr || 'Parsing halted.');
                }
                popStack(1);
                state = stack[stack.length-1];
            }

            preErrorSymbol = symbol; // save the lookahead token
            symbol = TERROR;         // insert generic error symbol as new lookahead
            state = stack[stack.length-1];
            action = table[state] && table[state][TERROR];
            recovering = 3; // allow 3 real symbols to be shifted before reporting a new error
        }

        // this shouldn't happen, unless resolve defaults are off
        if (action[0] instanceof Array && action.length > 1) {
            throw new Error('Parse Error: multiple actions possible at state: '+state+', token: '+symbol);
        }

        switch (action[0]) {

            case 1: // shift
                //this.shiftCount++;

                stack.push(symbol);
                vstack.push(this.lexer.yytext);
                lstack.push(this.lexer.yylloc);
                stack.push(action[1]); // push state
                symbol = null;
                if (!preErrorSymbol) { // normal execution/no error
                    yyleng = this.lexer.yyleng;
                    yytext = this.lexer.yytext;
                    yylineno = this.lexer.yylineno;
                    yyloc = this.lexer.yylloc;
                    if (recovering > 0)
                        recovering--;
                } else { // error just occurred, resume old lookahead f/ before error
                    symbol = preErrorSymbol;
                    preErrorSymbol = null;
                }
                break;

            case 2: // reduce
                //this.reductionCount++;

                len = this.productions_[action[1]][1];

                // perform semantic action
                yyval.$ = vstack[vstack.length-len]; // default to $$ = $1
                // default location, uses first token for firsts, last for lasts
                yyval._$ = {
                    first_line: lstack[lstack.length-(len||1)].first_line,
                    last_line: lstack[lstack.length-1].last_line,
                    first_column: lstack[lstack.length-(len||1)].first_column,
                    last_column: lstack[lstack.length-1].last_column
                };
                r = this.performAction.call(yyval, yytext, yyleng, yylineno, this.yy, action[1], vstack, lstack);

                if (typeof r !== 'undefined') {
                    return r;
                }

                // pop off stack
                if (len) {
                    stack = stack.slice(0,-1*len*2);
                    vstack = vstack.slice(0, -1*len);
                    lstack = lstack.slice(0, -1*len);
                }

                stack.push(this.productions_[action[1]][0]);    // push nonterminal (reduce)
                vstack.push(yyval.$);
                lstack.push(yyval._$);
                // goto new state = table[STATE][NONTERMINAL]
                newState = table[stack[stack.length-2]][stack[stack.length-1]];
                stack.push(newState);
                break;

            case 3: // accept
                return true;
        }

    }

    return true;
}};
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