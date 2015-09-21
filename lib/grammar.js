module.exports = (function() { /* Jison generated parser */
var grammar = (function(){
var parser = {trace: function trace() { },
yy: {},
symbols_: {"error":2,"Root":3,"ChildList":4,"Child":5,"TERMINATOR":6,"ElementIdentifier":7,"AnyIdentifier":8,"HASH":9,"DOT":10,"Element":11,"LBRACKET":12,"RBRACKET":13,"PropertyList":14,"WHITESPACE":15,"Content":16,"INDENT":17,"OUTDENT":18,"ContentList":19,"Bound":20,"STRING_LITERAL":21,"IfInstruction":22,"Instruction":23,"Helper":24,"Property":25,"EQUALS":26,"PropertyArguments":27,"COLON":28,"BANG":29,"DASH":30,"VIEW":31,"COLLECTION":32,"UNLESS":33,"IN":34,"IDENTIFIER":35,"HelperArgument":36,"IF":37,"ElseInstruction":38,"ELSE":39,"AT":40,"$accept":0,"$end":1},
terminals_: {2:"error",6:"TERMINATOR",9:"HASH",10:"DOT",12:"LBRACKET",13:"RBRACKET",15:"WHITESPACE",17:"INDENT",18:"OUTDENT",21:"STRING_LITERAL",26:"EQUALS",28:"COLON",29:"BANG",30:"DASH",31:"VIEW",32:"COLLECTION",33:"UNLESS",34:"IN",35:"IDENTIFIER",37:"IF",39:"ELSE",40:"AT"},
productions_: [0,[3,1],[4,1],[4,3],[7,1],[7,3],[7,2],[7,2],[7,3],[11,1],[11,3],[11,4],[11,3],[11,4],[19,1],[19,3],[16,1],[16,1],[5,1],[5,1],[5,1],[5,1],[5,1],[14,1],[14,3],[25,3],[25,3],[27,1],[27,1],[27,2],[27,2],[27,1],[23,5],[23,5],[23,5],[23,5],[23,5],[23,4],[24,3],[24,3],[24,4],[36,1],[36,1],[36,1],[22,5],[22,4],[22,2],[38,6],[8,1],[8,1],[8,1],[8,1],[8,1],[8,1],[20,2],[20,1]],
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
case 4: this.$ = { name: $$[$0], classes: [] } 
break;
case 5: this.$ = { name: $$[$0-2], id: $$[$0], classes: [] } 
break;
case 6: this.$ = { name: "div", id: $$[$0], classes: [] } 
break;
case 7: this.$ = { name: "div", classes: [$$[$0]] } 
break;
case 8: $$[$0-2].classes.push($$[$0]); this.$ = $$[$0-2] 
break;
case 9: this.$ = { name: $$[$0].name, id: $$[$0].id, classes: $$[$0].classes, properties: [], children: [], type: "element" } 
break;
case 10: this.$ = $$[$0-2] 
break;
case 11: $$[$0-3].properties = $$[$0-1]; this.$ = $$[$0-3] 
break;
case 12: $$[$0-2].children = $$[$0-2].children.concat($$[$0]); this.$ = $$[$0-2] 
break;
case 13: $$[$0-3].children = $$[$0-3].children.concat($$[$0-1]); this.$ = $$[$0-3] 
break;
case 14: this.$ = [$$[$0]] 
break;
case 15: this.$ = $$[$0-2].concat($$[$0]) 
break;
case 16: this.$ = { type: "content", value: $$[$0], bound: true } 
break;
case 17: this.$ = { type: "content", value: $$[$0] } 
break;
case 18: this.$ = $$[$0] 
break;
case 19: this.$ = $$[$0] 
break;
case 20: this.$ = $$[$0] 
break;
case 21: this.$ = $$[$0] 
break;
case 22: this.$ = $$[$0] 
break;
case 23: this.$ = [$$[$0]] 
break;
case 24: this.$ = $$[$0-2].concat($$[$0]) 
break;
case 25: this.$ = { name: $$[$0-2], arguments: $$[$0] } 
break;
case 26: $$[$0].scope = $$[$0-2]; this.$ = $$[$0] 
break;
case 27: this.$ = [{ static: true, value: $$[$0] }] 
break;
case 28: this.$ = [{ bound: true, value: $$[$0] }] 
break;
case 29: this.$ = [{ static: true, value: $$[$0-1], preventDefault: true }] 
break;
case 30: this.$ = [{ bound: true, value: $$[$0-1], preventDefault: true }] 
break;
case 31: this.$ = [{ value: $$[$0] }] 
break;
case 32: this.$ = { children: [], type: "view", argument: $$[$0] } 
break;
case 33: this.$ = { children: [], type: "view", argument: $$[$0], bound: true } 
break;
case 34: this.$ = { children: [], type: "collection", argument: $$[$0] } 
break;
case 35: this.$ = { children: [], type: "unless", argument: $$[$0] } 
break;
case 36: this.$ = { children: [], type: "in", argument: $$[$0] } 
break;
case 37: $$[$0-3].children = $$[$0-1]; this.$ = $$[$0-3] 
break;
case 38: this.$ = { command: $$[$0], arguments: [], children: [], type: "helper" } 
break;
case 39: $$[$0-2].arguments.push($$[$0]); this.$ = $$[$0-2] 
break;
case 40: $$[$0-3].children = $$[$0-1]; this.$ = $$[$0-3] 
break;
case 41: this.$ = { value: $$[$0], bound: true } 
break;
case 42: this.$ = { value: $$[$0], static: true } 
break;
case 43: this.$ = { value: $$[$0] } 
break;
case 44: this.$ = { children: [], type: "if", argument: $$[$0] } 
break;
case 45: $$[$0-3].children = $$[$0-1]; this.$ = $$[$0-3] 
break;
case 46: $$[$0-1].else = $$[$0]; this.$ = $$[$0-1] 
break;
case 47: this.$ = { arguments: [], children: $$[$0-1], type: "else" } 
break;
case 48: this.$ = $$[$0] 
break;
case 49: this.$ = $$[$0] 
break;
case 50: this.$ = $$[$0] 
break;
case 51: this.$ = $$[$0] 
break;
case 52: this.$ = $$[$0] 
break;
case 53: this.$ = $$[$0] 
break;
case 54: this.$ = $$[$0] 
break;
case 55: this.$ = undefined 
break;
}
},
table: [{3:1,4:2,5:3,7:9,8:12,9:[1,13],10:[1,14],11:4,16:11,19:8,20:15,21:[1,16],22:5,23:6,24:7,30:[1,10],31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19],40:[1,23]},{1:[3]},{1:[2,1],6:[1,24]},{1:[2,2],6:[2,2],18:[2,2]},{1:[2,18],6:[2,18],12:[1,25],15:[1,26],17:[1,27],18:[2,18]},{1:[2,19],6:[2,19],17:[1,28],18:[2,19],30:[1,30],38:29},{1:[2,20],6:[2,20],17:[1,31],18:[2,20]},{1:[2,21],6:[2,21],15:[1,32],17:[1,33],18:[2,21]},{1:[2,22],6:[2,22],15:[1,34],18:[2,22]},{1:[2,9],6:[2,9],10:[1,35],12:[2,9],15:[2,9],17:[2,9],18:[2,9]},{15:[1,36]},{1:[2,14],6:[2,14],15:[2,14],18:[2,14]},{1:[2,4],6:[2,4],9:[1,37],10:[2,4],12:[2,4],15:[2,4],17:[2,4],18:[2,4]},{8:38,31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19]},{8:39,31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19]},{1:[2,16],6:[2,16],12:[2,16],15:[2,16],17:[2,16],18:[2,16]},{1:[2,17],6:[2,17],12:[2,17],15:[2,17],17:[2,17],18:[2,17]},{1:[2,48],6:[2,48],9:[2,48],10:[2,48],12:[2,48],13:[2,48],15:[2,48],17:[2,48],18:[2,48],26:[2,48],28:[2,48],29:[2,48],30:[2,48]},{1:[2,49],6:[2,49],9:[2,49],10:[2,49],12:[2,49],13:[2,49],15:[2,49],17:[2,49],18:[2,49],26:[2,49],28:[2,49],29:[2,49],30:[2,49]},{1:[2,50],6:[2,50],9:[2,50],10:[2,50],12:[2,50],13:[2,50],15:[2,50],17:[2,50],18:[2,50],26:[2,50],28:[2,50],29:[2,50],30:[2,50]},{1:[2,51],6:[2,51],9:[2,51],10:[2,51],12:[2,51],13:[2,51],15:[2,51],17:[2,51],18:[2,51],26:[2,51],28:[2,51],29:[2,51],30:[2,51]},{1:[2,52],6:[2,52],9:[2,52],10:[2,52],12:[2,52],13:[2,52],15:[2,52],17:[2,52],18:[2,52],26:[2,52],28:[2,52],29:[2,52],30:[2,52]},{1:[2,53],6:[2,53],9:[2,53],10:[2,53],12:[2,53],13:[2,53],15:[2,53],17:[2,53],18:[2,53],26:[2,53],28:[2,53],29:[2,53],30:[2,53]},{1:[2,55],6:[2,55],8:40,12:[2,55],13:[2,55],15:[2,55],17:[2,55],18:[2,55],29:[2,55],30:[2,55],31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19]},{5:41,7:9,8:12,9:[1,13],10:[1,14],11:4,16:11,19:8,20:15,21:[1,16],22:5,23:6,24:7,30:[1,10],31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19],40:[1,23]},{8:45,13:[1,42],14:43,25:44,31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19]},{16:46,20:15,21:[1,16],40:[1,23]},{4:47,5:3,7:9,8:12,9:[1,13],10:[1,14],11:4,16:11,19:8,20:15,21:[1,16],22:5,23:6,24:7,30:[1,10],31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19],40:[1,23]},{4:48,5:3,7:9,8:12,9:[1,13],10:[1,14],11:4,16:11,19:8,20:15,21:[1,16],22:5,23:6,24:7,30:[1,10],31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19],40:[1,23]},{1:[2,46],6:[2,46],17:[2,46],18:[2,46],30:[2,46]},{15:[1,49]},{4:50,5:3,7:9,8:12,9:[1,13],10:[1,14],11:4,16:11,19:8,20:15,21:[1,16],22:5,23:6,24:7,30:[1,10],31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19],40:[1,23]},{8:53,20:52,21:[1,54],31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],36:51,37:[1,19],40:[1,23]},{4:55,5:3,7:9,8:12,9:[1,13],10:[1,14],11:4,16:11,19:8,20:15,21:[1,16],22:5,23:6,24:7,30:[1,10],31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19],40:[1,23]},{16:56,20:15,21:[1,16],40:[1,23]},{8:57,31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19]},{31:[1,59],32:[1,60],33:[1,61],34:[1,62],35:[1,63],37:[1,58]},{8:64,31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19]},{1:[2,6],6:[2,6],10:[2,6],12:[2,6],15:[2,6],17:[2,6],18:[2,6]},{1:[2,7],6:[2,7],10:[2,7],12:[2,7],15:[2,7],17:[2,7],18:[2,7]},{1:[2,54],6:[2,54],12:[2,54],13:[2,54],15:[2,54],17:[2,54],18:[2,54],29:[2,54],30:[2,54]},{1:[2,3],6:[2,3],18:[2,3]},{1:[2,10],6:[2,10],12:[2,10],15:[2,10],17:[2,10],18:[2,10]},{13:[1,65],15:[1,66]},{13:[2,23],15:[2,23]},{26:[1,67],28:[1,68]},{1:[2,12],6:[2,12],12:[2,12],15:[2,12],17:[2,12],18:[2,12]},{6:[1,24],18:[1,69]},{6:[1,24],18:[1,70]},{39:[1,71]},{6:[1,24],18:[1,72]},{1:[2,39],6:[2,39],15:[2,39],17:[2,39],18:[2,39]},{1:[2,41],6:[2,41],15:[2,41],17:[2,41],18:[2,41]},{1:[2,42],6:[2,42],15:[2,42],17:[2,42],18:[2,42]},{1:[2,43],6:[2,43],15:[2,43],17:[2,43],18:[2,43]},{6:[1,24],18:[1,73]},{1:[2,15],6:[2,15],15:[2,15],18:[2,15]},{1:[2,8],6:[2,8],10:[2,8],12:[2,8],15:[2,8],17:[2,8],18:[2,8]},{15:[1,74]},{15:[1,75]},{15:[1,76]},{15:[1,77]},{15:[1,78]},{1:[2,38],6:[2,38],15:[2,38],17:[2,38],18:[2,38]},{1:[2,5],6:[2,5],10:[2,5],12:[2,5],15:[2,5],17:[2,5],18:[2,5]},{1:[2,11],6:[2,11],12:[2,11],15:[2,11],17:[2,11],18:[2,11]},{8:45,25:79,31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19]},{8:81,20:82,21:[1,83],27:80,31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19],40:[1,23]},{8:45,25:84,31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19]},{1:[2,13],6:[2,13],12:[2,13],15:[2,13],17:[2,13],18:[2,13]},{1:[2,45],6:[2,45],17:[2,45],18:[2,45],30:[2,45]},{17:[1,85]},{1:[2,37],6:[2,37],17:[2,37],18:[2,37]},{1:[2,40],6:[2,40],15:[2,40],17:[2,40],18:[2,40]},{20:86,40:[1,23]},{20:88,21:[1,87],40:[1,23]},{20:89,40:[1,23]},{20:90,40:[1,23]},{20:91,40:[1,23]},{13:[2,24],15:[2,24]},{13:[2,25],15:[2,25]},{13:[2,27],15:[2,27],29:[1,92]},{13:[2,28],15:[2,28],29:[1,93]},{13:[2,31],15:[2,31]},{13:[2,26],15:[2,26]},{4:94,5:3,7:9,8:12,9:[1,13],10:[1,14],11:4,16:11,19:8,20:15,21:[1,16],22:5,23:6,24:7,30:[1,10],31:[1,17],32:[1,18],33:[1,20],34:[1,21],35:[1,22],37:[1,19],40:[1,23]},{1:[2,44],6:[2,44],17:[2,44],18:[2,44],30:[2,44]},{1:[2,32],6:[2,32],17:[2,32],18:[2,32]},{1:[2,33],6:[2,33],17:[2,33],18:[2,33]},{1:[2,34],6:[2,34],17:[2,34],18:[2,34]},{1:[2,35],6:[2,35],17:[2,35],18:[2,35]},{1:[2,36],6:[2,36],17:[2,36],18:[2,36]},{13:[2,29],15:[2,29]},{13:[2,30],15:[2,30]},{6:[1,24],18:[1,95]},{1:[2,47],6:[2,47],17:[2,47],18:[2,47],30:[2,47]}],
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
