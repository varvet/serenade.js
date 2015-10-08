module.exports = (function() { /* Jison generated parser */
var grammar = (function(){
var parser = {trace: function trace() { },
yy: {},
symbols_: {"error":2,"Root":3,"ChildList":4,"Child":5,"TERMINATOR":6,"ElementIdentifier":7,"AnyIdentifier":8,"HASH":9,"DOT":10,"Element":11,"LBRACKET":12,"RBRACKET":13,"PropertyList":14,"WHITESPACE":15,"Content":16,"INDENT":17,"OUTDENT":18,"ContentList":19,"Bound":20,"STRING_LITERAL":21,"IfInstruction":22,"Instruction":23,"Property":24,"EQUALS":25,"PropertyArgument":26,"COLON":27,"PropertyArgumentList":28,"BANG":29,"LPAREN":30,"RPAREN":31,"DASH":32,"IDENTIFIER":33,"InstructionArgumentList":34,"IF":35,"ElseInstruction":36,"ELSE":37,"InstructionArgument":38,"AT":39,"DOLLAR":40,"$accept":0,"$end":1},
terminals_: {2:"error",6:"TERMINATOR",9:"HASH",10:"DOT",12:"LBRACKET",13:"RBRACKET",15:"WHITESPACE",17:"INDENT",18:"OUTDENT",21:"STRING_LITERAL",25:"EQUALS",27:"COLON",29:"BANG",30:"LPAREN",31:"RPAREN",32:"DASH",33:"IDENTIFIER",35:"IF",37:"ELSE",39:"AT",40:"DOLLAR"},
productions_: [0,[3,1],[4,1],[4,3],[7,1],[7,3],[7,2],[7,2],[7,3],[11,1],[11,3],[11,4],[11,3],[11,4],[19,1],[19,3],[16,1],[16,1],[5,1],[5,1],[5,1],[5,1],[14,1],[14,3],[24,3],[24,3],[28,1],[28,3],[26,1],[26,1],[26,2],[26,2],[26,1],[26,4],[23,3],[23,5],[23,4],[22,5],[22,4],[22,2],[36,6],[34,1],[34,3],[38,1],[38,1],[8,1],[8,1],[8,1],[20,2],[20,2],[20,1]],
performAction: function anonymous(yytext,yyleng,yylineno,yy,yystate,$$,_$
/**/) {

var $0 = $$.length - 1;
switch (yystate) {
case 1: return $$[$0] 
break;
case 2: this.$ = [].concat($$[$0]) 
break;
case 3: this.$ = $$[$0-2].concat($$[$0]) 
break;
case 4: this.$ = { name: $$[$0], type: "element" } 
break;
case 5: this.$ = { name: $$[$0-2], options: [{ name: "id", property: $$[$0] }], type: "element" } 
break;
case 6: this.$ = { name: "div", options: [{ name: "id", property: $$[$0] }], type: "element" } 
break;
case 7: this.$ = { name: "div", classes: [$$[$0]], type: "element" } 
break;
case 8: $$[$0-2].classes = ($$[$0-2].classes || []).concat($$[$0]); this.$ = $$[$0-2] 
break;
case 9: this.$ = $$[$0] 
break;
case 10: this.$ = $$[$0-2] 
break;
case 11: $$[$0-3].options = $$[$0-1]; this.$ = $$[$0-3] 
break;
case 12: $$[$0-2].children = ($$[$0-2].children || []).concat($$[$0]); this.$ = $$[$0-2] 
break;
case 13: $$[$0-3].children = ($$[$0-3].children || []).concat($$[$0-1]); this.$ = $$[$0-3] 
break;
case 14: this.$ = [$$[$0]] 
break;
case 15: this.$ = $$[$0-2].concat($$[$0]) 
break;
case 16: this.$ = { type: "content", arguments: [{ property: $$[$0], bound: true }] } 
break;
case 17: this.$ = { type: "content", arguments: [{ property: $$[$0] }] } 
break;
case 18: this.$ = $$[$0] 
break;
case 19: this.$ = $$[$0] 
break;
case 20: this.$ = $$[$0] 
break;
case 21: this.$ = $$[$0] 
break;
case 22: this.$ = [$$[$0]] 
break;
case 23: this.$ = $$[$0-2].concat($$[$0]) 
break;
case 24: $$[$0].name = $$[$0-2]; this.$ = $$[$0] 
break;
case 25: $$[$0].scope = $$[$0-2]; this.$ = $$[$0] 
break;
case 26: this.$ = [$$[$0]] 
break;
case 27: this.$ = $$[$0-2].concat($$[$0]) 
break;
case 28: this.$ = { bound: true, property: $$[$0] } 
break;
case 29: this.$ = { bound: true, property: $$[$0] } 
break;
case 30: this.$ = { bound: true, property: $$[$0-1], preventDefault: true } 
break;
case 31: this.$ = { bound: true, property: $$[$0-1], preventDefault: true } 
break;
case 32: this.$ = { property: $$[$0] } 
break;
case 33: this.$ = { filter: $$[$0-3], arguments: $$[$0-1] } 
break;
case 34: this.$ = { type: $$[$0] } 
break;
case 35: this.$ = { type: $$[$0-2], arguments: $$[$0] } 
break;
case 36: $$[$0-3].children = $$[$0-1]; this.$ = $$[$0-3] 
break;
case 37: this.$ = { arguments: $$[$0], type: "if" } 
break;
case 38: $$[$0-3].children = $$[$0-1]; this.$ = $$[$0-3] 
break;
case 39: $$[$0-1].else = $$[$0]; this.$ = $$[$0-1] 
break;
case 40: this.$ = { children: $$[$0-1], type: "else" } 
break;
case 41: this.$ = [$$[$0]] 
break;
case 42: this.$ = $$[$0-2].concat($$[$0]) 
break;
case 43: this.$ = { property: $$[$0], bound: true } 
break;
case 44: this.$ = { property: $$[$0] } 
break;
case 45: this.$ = $$[$0] 
break;
case 46: this.$ = $$[$0] 
break;
case 47: this.$ = $$[$0] 
break;
case 48: this.$ = "@" + $$[$0] 
break;
case 49: this.$ = $$[$0] 
break;
case 50: this.$ = "this" 
break;
}
},
table: [{3:1,4:2,5:3,7:8,8:11,9:[1,12],10:[1,13],11:4,16:10,19:7,20:14,21:[1,15],22:5,23:6,32:[1,9],33:[1,18],35:[1,16],37:[1,17],39:[1,19],40:[1,20]},{1:[3]},{1:[2,1],6:[1,21]},{1:[2,2],6:[2,2],18:[2,2]},{1:[2,18],6:[2,18],12:[1,22],15:[1,23],17:[1,24],18:[2,18]},{1:[2,19],6:[2,19],17:[1,25],18:[2,19],32:[1,27],36:26},{1:[2,20],6:[2,20],17:[1,28],18:[2,20]},{1:[2,21],6:[2,21],15:[1,29],18:[2,21]},{1:[2,9],6:[2,9],10:[1,30],12:[2,9],15:[2,9],17:[2,9],18:[2,9]},{15:[1,31]},{1:[2,14],6:[2,14],15:[2,14],18:[2,14]},{1:[2,4],6:[2,4],9:[1,32],10:[2,4],12:[2,4],15:[2,4],17:[2,4],18:[2,4]},{8:33,33:[1,18],35:[1,16],37:[1,17]},{8:34,33:[1,18],35:[1,16],37:[1,17]},{1:[2,16],6:[2,16],12:[2,16],15:[2,16],17:[2,16],18:[2,16]},{1:[2,17],6:[2,17],12:[2,17],15:[2,17],17:[2,17],18:[2,17]},{1:[2,45],6:[2,45],9:[2,45],10:[2,45],12:[2,45],13:[2,45],15:[2,45],17:[2,45],18:[2,45],25:[2,45],27:[2,45],29:[2,45],30:[2,45],31:[2,45],32:[2,45]},{1:[2,46],6:[2,46],9:[2,46],10:[2,46],12:[2,46],13:[2,46],15:[2,46],17:[2,46],18:[2,46],25:[2,46],27:[2,46],29:[2,46],30:[2,46],31:[2,46],32:[2,46]},{1:[2,47],6:[2,47],9:[2,47],10:[2,47],12:[2,47],13:[2,47],15:[2,47],17:[2,47],18:[2,47],25:[2,47],27:[2,47],29:[2,47],30:[2,47],31:[2,47],32:[2,47]},{1:[2,50],6:[2,50],8:35,12:[2,50],13:[2,50],15:[2,50],17:[2,50],18:[2,50],29:[2,50],31:[2,50],32:[2,50],33:[1,18],35:[1,16],37:[1,17]},{8:36,33:[1,18],35:[1,16],37:[1,17]},{5:37,7:8,8:11,9:[1,12],10:[1,13],11:4,16:10,19:7,20:14,21:[1,15],22:5,23:6,32:[1,9],33:[1,18],35:[1,16],37:[1,17],39:[1,19],40:[1,20]},{8:41,13:[1,38],14:39,24:40,33:[1,18],35:[1,16],37:[1,17]},{16:42,20:14,21:[1,15],39:[1,19],40:[1,20]},{4:43,5:3,7:8,8:11,9:[1,12],10:[1,13],11:4,16:10,19:7,20:14,21:[1,15],22:5,23:6,32:[1,9],33:[1,18],35:[1,16],37:[1,17],39:[1,19],40:[1,20]},{4:44,5:3,7:8,8:11,9:[1,12],10:[1,13],11:4,16:10,19:7,20:14,21:[1,15],22:5,23:6,32:[1,9],33:[1,18],35:[1,16],37:[1,17],39:[1,19],40:[1,20]},{1:[2,39],6:[2,39],17:[2,39],18:[2,39],32:[2,39]},{15:[1,45]},{4:46,5:3,7:8,8:11,9:[1,12],10:[1,13],11:4,16:10,19:7,20:14,21:[1,15],22:5,23:6,32:[1,9],33:[1,18],35:[1,16],37:[1,17],39:[1,19],40:[1,20]},{16:47,20:14,21:[1,15],39:[1,19],40:[1,20]},{8:48,33:[1,18],35:[1,16],37:[1,17]},{33:[1,50],35:[1,49]},{8:51,33:[1,18],35:[1,16],37:[1,17]},{1:[2,6],6:[2,6],10:[2,6],12:[2,6],15:[2,6],17:[2,6],18:[2,6]},{1:[2,7],6:[2,7],10:[2,7],12:[2,7],15:[2,7],17:[2,7],18:[2,7]},{1:[2,48],6:[2,48],12:[2,48],13:[2,48],15:[2,48],17:[2,48],18:[2,48],29:[2,48],31:[2,48],32:[2,48]},{1:[2,49],6:[2,49],12:[2,49],13:[2,49],15:[2,49],17:[2,49],18:[2,49],29:[2,49],31:[2,49],32:[2,49]},{1:[2,3],6:[2,3],18:[2,3]},{1:[2,10],6:[2,10],12:[2,10],15:[2,10],17:[2,10],18:[2,10]},{13:[1,52],15:[1,53]},{13:[2,22],15:[2,22]},{25:[1,54],27:[1,55]},{1:[2,12],6:[2,12],12:[2,12],15:[2,12],17:[2,12],18:[2,12]},{6:[1,21],18:[1,56]},{6:[1,21],18:[1,57]},{37:[1,58]},{6:[1,21],18:[1,59]},{1:[2,15],6:[2,15],15:[2,15],18:[2,15]},{1:[2,8],6:[2,8],10:[2,8],12:[2,8],15:[2,8],17:[2,8],18:[2,8]},{15:[1,60]},{1:[2,34],6:[2,34],15:[1,61],17:[2,34],18:[2,34]},{1:[2,5],6:[2,5],10:[2,5],12:[2,5],15:[2,5],17:[2,5],18:[2,5]},{1:[2,11],6:[2,11],12:[2,11],15:[2,11],17:[2,11],18:[2,11]},{8:41,24:62,33:[1,18],35:[1,16],37:[1,17]},{8:64,20:65,21:[1,66],26:63,33:[1,18],35:[1,16],37:[1,17],39:[1,19],40:[1,20]},{8:41,24:67,33:[1,18],35:[1,16],37:[1,17]},{1:[2,13],6:[2,13],12:[2,13],15:[2,13],17:[2,13],18:[2,13]},{1:[2,38],6:[2,38],17:[2,38],18:[2,38],32:[2,38]},{17:[1,68]},{1:[2,36],6:[2,36],17:[2,36],18:[2,36]},{20:71,21:[1,72],34:69,38:70,39:[1,19],40:[1,20]},{20:71,21:[1,72],34:73,38:70,39:[1,19],40:[1,20]},{13:[2,23],15:[2,23]},{13:[2,24],15:[2,24]},{13:[2,28],15:[2,28],29:[1,74],30:[1,75],31:[2,28]},{13:[2,29],15:[2,29],29:[1,76],31:[2,29]},{13:[2,32],15:[2,32],31:[2,32]},{13:[2,25],15:[2,25]},{4:77,5:3,7:8,8:11,9:[1,12],10:[1,13],11:4,16:10,19:7,20:14,21:[1,15],22:5,23:6,32:[1,9],33:[1,18],35:[1,16],37:[1,17],39:[1,19],40:[1,20]},{1:[2,37],6:[2,37],15:[1,78],17:[2,37],18:[2,37],32:[2,37]},{1:[2,41],6:[2,41],15:[2,41],17:[2,41],18:[2,41],32:[2,41]},{1:[2,43],6:[2,43],15:[2,43],17:[2,43],18:[2,43],32:[2,43]},{1:[2,44],6:[2,44],15:[2,44],17:[2,44],18:[2,44],32:[2,44]},{1:[2,35],6:[2,35],15:[1,78],17:[2,35],18:[2,35]},{13:[2,30],15:[2,30],31:[2,30]},{8:64,20:65,21:[1,66],26:80,28:79,33:[1,18],35:[1,16],37:[1,17],39:[1,19],40:[1,20]},{13:[2,31],15:[2,31],31:[2,31]},{6:[1,21],18:[1,81]},{20:71,21:[1,72],38:82,39:[1,19],40:[1,20]},{15:[1,84],31:[1,83]},{15:[2,26],31:[2,26]},{1:[2,40],6:[2,40],17:[2,40],18:[2,40],32:[2,40]},{1:[2,42],6:[2,42],15:[2,42],17:[2,42],18:[2,42],32:[2,42]},{13:[2,33],15:[2,33],31:[2,33]},{8:64,20:65,21:[1,66],26:85,33:[1,18],35:[1,16],37:[1,17],39:[1,19],40:[1,20]},{15:[2,27],31:[2,27]}],
defaultActions: {},
parseError: function parseError(str, hash) {
    throw new Error(str);
},
parse: function parse(input) {
    var self = this, stack = [0], vstack = [null], lstack = [], table = this.table, yytext = "", yylineno = 0, yyleng = 0, recovering = 0, TERROR = 2, EOF = 1;
    this.lexer.setInput(input);
    this.lexer.yy = this.yy;
    this.yy.lexer = this.lexer;
    this.yy.parser = this;
    if (typeof this.lexer.yylloc == "undefined")
        this.lexer.yylloc = {};
    var yyloc = this.lexer.yylloc;
    lstack.push(yyloc);
    var ranges = this.lexer.options && this.lexer.options.ranges;
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
            if (symbol === null || typeof symbol == "undefined") {
                symbol = lex();
            }
            action = table[state] && table[state][symbol];
        }
        if (typeof action === "undefined" || !action.length || !action[0]) {
            var errStr = "";
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
            if (ranges) {
                yyval._$.range = [lstack[lstack.length - (len || 1)].range[0], lstack[lstack.length - 1].range[1]];
            }
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
function Parser () { this.yy = {}; }Parser.prototype = parser;parser.Parser = Parser;
return new Parser;
})();; return grammar; })();
