/**
 * Serenade.js JavaScript Framework v0.3.0
 * Revision: b2656bb2e5
 * http://github.com/elabs/serenade.js
 *
 * Copyright 2011, Jonas Nicklas, Elabs AB
 * Released under the MIT License
 */
(function(root) {
  /* Jison generated parser */
var parser = (function(){
var parser = {trace: function trace() { },
yy: {},
symbols_: {"error":2,"Root":3,"Element":4,"ElementIdentifier":5,"AnyIdentifier":6,"#":7,".":8,"[":9,"]":10,"PropertyList":11,"WHITESPACE":12,"Text":13,"INDENT":14,"ChildList":15,"OUTDENT":16,"TextList":17,"Bound":18,"STRING_LITERAL":19,"Child":20,"TERMINATOR":21,"IfInstruction":22,"Instruction":23,"Helper":24,"Property":25,"=":26,"!":27,":":28,"-":29,"VIEW":30,"COLLECTION":31,"UNLESS":32,"IN":33,"IDENTIFIER":34,"IF":35,"ElseInstruction":36,"ELSE":37,"@":38,"$accept":0,"$end":1},
terminals_: {2:"error",7:"#",8:".",9:"[",10:"]",12:"WHITESPACE",14:"INDENT",16:"OUTDENT",19:"STRING_LITERAL",21:"TERMINATOR",26:"=",27:"!",28:":",29:"-",30:"VIEW",31:"COLLECTION",32:"UNLESS",33:"IN",34:"IDENTIFIER",35:"IF",37:"ELSE",38:"@"},
productions_: [0,[3,0],[3,1],[5,1],[5,3],[5,2],[5,2],[5,3],[4,1],[4,3],[4,4],[4,3],[4,4],[17,1],[17,3],[13,1],[13,1],[15,1],[15,3],[20,1],[20,1],[20,1],[20,1],[20,1],[11,1],[11,3],[25,3],[25,3],[25,4],[25,4],[25,3],[25,3],[23,5],[23,5],[23,5],[23,5],[23,4],[24,3],[24,3],[24,4],[22,5],[22,4],[22,2],[36,6],[6,1],[6,1],[6,1],[6,1],[6,1],[6,1],[18,2],[18,1]],
performAction: function anonymous(yytext,yyleng,yylineno,yy,yystate,$$,_$) {

var $0 = $$.length - 1;
switch (yystate) {
case 1:this.$ = null;
break;
case 2:return this.$
break;
case 3:this.$ = {
          name: $$[$0],
          classes: []
        };
break;
case 4:this.$ = {
          name: $$[$0-2],
          id: $$[$0],
          classes: []
        };
break;
case 5:this.$ = {
          name: 'div',
          id: $$[$0],
          classes: []
        };
break;
case 6:this.$ = {
          name: 'div',
          classes: [$$[$0]]
        };
break;
case 7:this.$ = (function () {
        $$[$0-2].classes.push($$[$0]);
        return $$[$0-2];
      }());
break;
case 8:this.$ = {
          name: $$[$0].name,
          id: $$[$0].id,
          classes: $$[$0].classes,
          properties: [],
          children: [],
          type: 'element'
        };
break;
case 9:this.$ = $$[$0-2];
break;
case 10:this.$ = (function () {
        $$[$0-3].properties = $$[$0-1];
        return $$[$0-3];
      }());
break;
case 11:this.$ = (function () {
        $$[$0-2].children = $$[$0-2].children.concat($$[$0]);
        return $$[$0-2];
      }());
break;
case 12:this.$ = (function () {
        $$[$0-3].children = $$[$0-3].children.concat($$[$0-1]);
        return $$[$0-3];
      }());
break;
case 13:this.$ = [$$[$0]];
break;
case 14:this.$ = $$[$0-2].concat($$[$0]);
break;
case 15:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: true
        };
break;
case 16:this.$ = {
          type: 'text',
          value: $$[$0],
          bound: false
        };
break;
case 17:this.$ = [].concat($$[$0]);
break;
case 18:this.$ = $$[$0-2].concat($$[$0]);
break;
case 19:this.$ = $$[$0];
break;
case 20:this.$ = $$[$0];
break;
case 21:this.$ = $$[$0];
break;
case 22:this.$ = $$[$0];
break;
case 23:this.$ = $$[$0];
break;
case 24:this.$ = [$$[$0]];
break;
case 25:this.$ = $$[$0-2].concat($$[$0]);
break;
case 26:this.$ = {
          name: $$[$0-2],
          value: $$[$0],
          bound: true,
          scope: 'attribute'
        };
break;
case 27:this.$ = {
          name: $$[$0-2],
          value: $$[$0],
          bound: true,
          scope: 'attribute'
        };
break;
case 28:this.$ = {
          name: $$[$0-3],
          value: $$[$0-1],
          bound: true,
          scope: 'attribute',
          preventDefault: true
        };
break;
case 29:this.$ = {
          name: $$[$0-3],
          value: $$[$0-1],
          bound: true,
          scope: 'attribute',
          preventDefault: true
        };
break;
case 30:this.$ = {
          name: $$[$0-2],
          value: $$[$0],
          bound: false,
          scope: 'attribute'
        };
break;
case 31:this.$ = (function () {
        $$[$0].scope = $$[$0-2];
        return $$[$0];
      }());
break;
case 32:this.$ = {
          children: [],
          type: 'view',
          argument: $$[$0]
        };
break;
case 33:this.$ = {
          children: [],
          type: 'collection',
          argument: $$[$0]
        };
break;
case 34:this.$ = {
          children: [],
          type: 'unless',
          argument: $$[$0]
        };
break;
case 35:this.$ = {
          children: [],
          type: 'in',
          argument: $$[$0]
        };
break;
case 36:this.$ = (function () {
        $$[$0-3].children = $$[$0-1];
        return $$[$0-3];
      }());
break;
case 37:this.$ = {
          command: $$[$0],
          "arguments": [],
          children: [],
          type: 'helper'
        };
break;
case 38:this.$ = (function () {
        $$[$0-2]["arguments"].push($$[$0]);
        return $$[$0-2];
      }());
break;
case 39:this.$ = (function () {
        $$[$0-3].children = $$[$0-1];
        return $$[$0-3];
      }());
break;
case 40:this.$ = {
          children: [],
          type: 'if',
          argument: $$[$0]
        };
break;
case 41:this.$ = (function () {
        $$[$0-3].children = $$[$0-1];
        return $$[$0-3];
      }());
break;
case 42:this.$ = (function () {
        $$[$0-1]["else"] = $$[$0];
        return $$[$0-1];
      }());
break;
case 43:this.$ = {
          "arguments": [],
          children: $$[$0-1],
          type: 'else'
        };
break;
case 44:this.$ = $$[$0];
break;
case 45:this.$ = $$[$0];
break;
case 46:this.$ = $$[$0];
break;
case 47:this.$ = $$[$0];
break;
case 48:this.$ = $$[$0];
break;
case 49:this.$ = $$[$0];
break;
case 50:this.$ = $$[$0];
break;
case 51:this.$ = (function () {}());
break;
}
},
table: [{1:[2,1],3:1,4:2,5:3,6:4,7:[1,5],8:[1,6],30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9]},{1:[3]},{1:[2,2],9:[1,13],12:[1,14],14:[1,15]},{1:[2,8],8:[1,16],9:[2,8],12:[2,8],14:[2,8],16:[2,8],21:[2,8]},{1:[2,3],7:[1,17],8:[2,3],9:[2,3],12:[2,3],14:[2,3],16:[2,3],21:[2,3]},{6:18,30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9]},{6:19,30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9]},{1:[2,44],7:[2,44],8:[2,44],9:[2,44],10:[2,44],12:[2,44],14:[2,44],16:[2,44],21:[2,44],26:[2,44],27:[2,44],28:[2,44],29:[2,44]},{1:[2,45],7:[2,45],8:[2,45],9:[2,45],10:[2,45],12:[2,45],14:[2,45],16:[2,45],21:[2,45],26:[2,45],27:[2,45],28:[2,45],29:[2,45]},{1:[2,46],7:[2,46],8:[2,46],9:[2,46],10:[2,46],12:[2,46],14:[2,46],16:[2,46],21:[2,46],26:[2,46],27:[2,46],28:[2,46],29:[2,46]},{1:[2,47],7:[2,47],8:[2,47],9:[2,47],10:[2,47],12:[2,47],14:[2,47],16:[2,47],21:[2,47],26:[2,47],27:[2,47],28:[2,47],29:[2,47]},{1:[2,48],7:[2,48],8:[2,48],9:[2,48],10:[2,48],12:[2,48],14:[2,48],16:[2,48],21:[2,48],26:[2,48],27:[2,48],28:[2,48],29:[2,48]},{1:[2,49],7:[2,49],8:[2,49],9:[2,49],10:[2,49],12:[2,49],14:[2,49],16:[2,49],21:[2,49],26:[2,49],27:[2,49],28:[2,49],29:[2,49]},{6:23,10:[1,20],11:21,25:22,30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9]},{13:24,18:25,19:[1,26],38:[1,27]},{4:30,5:3,6:4,7:[1,5],8:[1,6],13:36,15:28,17:34,18:25,19:[1,26],20:29,22:31,23:32,24:33,29:[1,35],30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9],38:[1,27]},{6:37,30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9]},{6:38,30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9]},{1:[2,5],8:[2,5],9:[2,5],12:[2,5],14:[2,5],16:[2,5],21:[2,5]},{1:[2,6],8:[2,6],9:[2,6],12:[2,6],14:[2,6],16:[2,6],21:[2,6]},{1:[2,9],9:[2,9],12:[2,9],14:[2,9],16:[2,9],21:[2,9]},{10:[1,39],12:[1,40]},{10:[2,24],12:[2,24]},{26:[1,41],28:[1,42]},{1:[2,11],9:[2,11],12:[2,11],14:[2,11],16:[2,11],21:[2,11]},{1:[2,15],9:[2,15],12:[2,15],14:[2,15],16:[2,15],21:[2,15]},{1:[2,16],9:[2,16],12:[2,16],14:[2,16],16:[2,16],21:[2,16]},{1:[2,51],6:43,9:[2,51],10:[2,51],12:[2,51],14:[2,51],16:[2,51],21:[2,51],27:[2,51],29:[2,51],30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9]},{16:[1,44],21:[1,45]},{16:[2,17],21:[2,17]},{9:[1,13],12:[1,14],14:[1,15],16:[2,19],21:[2,19]},{14:[1,46],16:[2,20],21:[2,20],29:[1,48],36:47},{14:[1,49],16:[2,21],21:[2,21]},{12:[1,50],14:[1,51],16:[2,22],21:[2,22]},{12:[1,52],16:[2,23],21:[2,23]},{12:[1,53]},{12:[2,13],16:[2,13],21:[2,13]},{1:[2,7],8:[2,7],9:[2,7],12:[2,7],14:[2,7],16:[2,7],21:[2,7]},{1:[2,4],8:[2,4],9:[2,4],12:[2,4],14:[2,4],16:[2,4],21:[2,4]},{1:[2,10],9:[2,10],12:[2,10],14:[2,10],16:[2,10],21:[2,10]},{6:23,25:54,30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9]},{6:55,18:56,19:[1,57],30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9],38:[1,27]},{6:23,25:58,30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9]},{1:[2,50],9:[2,50],10:[2,50],12:[2,50],14:[2,50],16:[2,50],21:[2,50],27:[2,50],29:[2,50]},{1:[2,12],9:[2,12],12:[2,12],14:[2,12],16:[2,12],21:[2,12]},{4:30,5:3,6:4,7:[1,5],8:[1,6],13:36,17:34,18:25,19:[1,26],20:59,22:31,23:32,24:33,29:[1,35],30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9],38:[1,27]},{4:30,5:3,6:4,7:[1,5],8:[1,6],13:36,15:60,17:34,18:25,19:[1,26],20:29,22:31,23:32,24:33,29:[1,35],30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9],38:[1,27]},{14:[2,42],16:[2,42],21:[2,42],29:[2,42]},{12:[1,61]},{4:30,5:3,6:4,7:[1,5],8:[1,6],13:36,15:62,17:34,18:25,19:[1,26],20:29,22:31,23:32,24:33,29:[1,35],30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9],38:[1,27]},{13:63,18:25,19:[1,26],38:[1,27]},{4:30,5:3,6:4,7:[1,5],8:[1,6],13:36,15:64,17:34,18:25,19:[1,26],20:29,22:31,23:32,24:33,29:[1,35],30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9],38:[1,27]},{13:65,18:25,19:[1,26],38:[1,27]},{30:[1,67],31:[1,68],32:[1,69],33:[1,70],34:[1,71],35:[1,66]},{10:[2,25],12:[2,25]},{10:[2,26],12:[2,26],27:[1,72]},{10:[2,27],12:[2,27],27:[1,73]},{10:[2,30],12:[2,30]},{10:[2,31],12:[2,31]},{16:[2,18],21:[2,18]},{16:[1,74],21:[1,45]},{37:[1,75]},{16:[1,76],21:[1,45]},{12:[2,38],14:[2,38],16:[2,38],21:[2,38]},{16:[1,77],21:[1,45]},{12:[2,14],16:[2,14],21:[2,14]},{12:[1,78]},{12:[1,79]},{12:[1,80]},{12:[1,81]},{12:[1,82]},{12:[2,37],14:[2,37],16:[2,37],21:[2,37]},{10:[2,28],12:[2,28]},{10:[2,29],12:[2,29]},{14:[2,41],16:[2,41],21:[2,41],29:[2,41]},{14:[1,83]},{14:[2,36],16:[2,36],21:[2,36]},{12:[2,39],14:[2,39],16:[2,39],21:[2,39]},{18:84,38:[1,27]},{19:[1,85]},{18:86,38:[1,27]},{18:87,38:[1,27]},{18:88,38:[1,27]},{4:30,5:3,6:4,7:[1,5],8:[1,6],13:36,15:89,17:34,18:25,19:[1,26],20:29,22:31,23:32,24:33,29:[1,35],30:[1,7],31:[1,8],32:[1,10],33:[1,11],34:[1,12],35:[1,9],38:[1,27]},{14:[2,40],16:[2,40],21:[2,40],29:[2,40]},{14:[2,32],16:[2,32],21:[2,32]},{14:[2,33],16:[2,33],21:[2,33]},{14:[2,34],16:[2,34],21:[2,34]},{14:[2,35],16:[2,35],21:[2,35]},{16:[1,90],21:[1,45]},{14:[2,43],16:[2,43],21:[2,43],29:[2,43]}],
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
;function Parser () { this.yy = {}; }Parser.prototype = parser;parser.Parser = Parser;
return new Parser;
})();
if (typeof require !== 'undefined' && typeof exports !== 'undefined') {
exports.parser = parser;
exports.Parser = parser.Parser;
exports.parse = function () { return parser.parse.apply(parser, arguments); }
exports.main = function commonjsMain(args) {
    if (!args[1])
        throw new Error('Usage: '+args[0]+' FILE');
    var source, cwd;
    if (typeof process !== 'undefined') {
        source = require('fs').readFileSync(require('path').resolve(args[1]), "utf8");
    } else {
        source = require("file").path(require("file").cwd()).join(args[1]).read({charset: "utf-8"});
    }
    return exports.parser.parse(source);
}
if (typeof module !== 'undefined' && require.main === module) {
  exports.main(typeof process !== 'undefined' ? process.argv.slice(1) : require("system").args);
}
}var AssociationCollection, COMMENT, Cache, Collection, Compile, DynamicNode, Event, IDENTIFIER, KEYWORDS, LITERAL, Lexer, MULTI_DENT, Model, Node, Property, PropertyAccessor, PropertyDefinition, STRING, Serenade, View, WHITESPACE, capitalize, compile, compileAll, def, defineEvent, defineProperty, extend, format, getValue, globalDependencies, idCounter, isArray, isArrayIndex, normalize, pairToObject, safeDelete, safePush, serializeObject, settings, triggerGlobal,
  __hasProp = {}.hasOwnProperty,
  __slice = [].slice,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

settings = {
  async: false
};

def = Object.defineProperty;

extend = function(target, source, enumerable) {
  var key, value, _results;
  if (enumerable == null) {
    enumerable = true;
  }
  _results = [];
  for (key in source) {
    if (!__hasProp.call(source, key)) continue;
    value = source[key];
    if (enumerable) {
      _results.push(target[key] = value);
    } else {
      _results.push(def(target, key, {
        value: value,
        configurable: true
      }));
    }
  }
  return _results;
};

format = function(model, key) {
  if (model[key + "_property"]) {
    return model[key + "_property"].format();
  } else {
    return model[key];
  }
};

isArray = function(object) {
  return Object.prototype.toString.call(object) === "[object Array]";
};

pairToObject = function(one, two) {
  var temp;
  temp = {};
  temp[one] = two;
  return temp;
};

serializeObject = function(object) {
  var item, _i, _len, _results;
  if (object && typeof object.toJSON === 'function') {
    return object.toJSON();
  } else if (isArray(object)) {
    _results = [];
    for (_i = 0, _len = object.length; _i < _len; _i++) {
      item = object[_i];
      _results.push(serializeObject(item));
    }
    return _results;
  } else {
    return object;
  }
};

capitalize = function(word) {
  return word.slice(0, 1).toUpperCase() + word.slice(1);
};

safePush = function(object, collection, item) {
  if (!object[collection] || object[collection].indexOf(item) === -1) {
    if (object.hasOwnProperty(collection)) {
      return object[collection].push(item);
    } else if (object[collection]) {
      return def(object, collection, {
        value: [item].concat(object[collection])
      });
    } else {
      return def(object, collection, {
        value: [item]
      });
    }
  }
};

safeDelete = function(object, collection, item) {
  var index;
  if (object[collection] && (index = object[collection].indexOf(item)) !== -1) {
    if (!object.hasOwnProperty(collection)) {
      def(object, collection, {
        value: [].concat(object[collection])
      });
    }
    return object[collection].splice(index, 1);
  }
};

Event = (function() {

  function Event(object, name, options) {
    this.object = object;
    this.name = name;
    this.options = options;
    this.prop = "_s_" + this.name + "_listeners";
    this.queueName = "_s_" + name + "_queue";
    this.async = "async" in this.options ? this.options.async : settings.async;
  }

  Event.prototype.trigger = function() {
    var args, _base,
      _this = this;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this.queue.push(args);
    if (this.async) {
      return (_base = this.queue).timeout || (_base.timeout = setTimeout((function() {
        return _this.resolve();
      }), 0));
    } else {
      return this.resolve();
    }
  };

  Event.prototype.bind = function(fun) {
    if (this.options.bind) {
      this.options.bind.call(this.object, fun);
    }
    return safePush(this.object, this.prop, fun);
  };

  Event.prototype.one = function(fun) {
    var unbind,
      _this = this;
    unbind = function(fun) {
      return _this.unbind(fun);
    };
    return this.bind(function() {
      unbind(arguments.callee);
      return fun.apply(this, arguments);
    });
  };

  Event.prototype.unbind = function(fun) {
    safeDelete(this.object, this.prop, fun);
    if (this.options.unbind) {
      return this.options.unbind.call(this.object, fun);
    }
  };

  Event.prototype.resolve = function() {
    var args, perform, _i, _len, _ref,
      _this = this;
    perform = function(args) {
      if (_this.object[_this.prop]) {
        return _this.object[_this.prop].forEach(function(fun) {
          return fun.apply(_this.object, args);
        });
      }
    };
    if (this.options.optimize) {
      perform(this.options.optimize(this.queue));
    } else {
      _ref = this.queue;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        args = _ref[_i];
        perform(args);
      }
    }
    return this.queue = [];
  };

  def(Event.prototype, "listeners", {
    get: function() {
      return this.object[this.prop];
    }
  });

  def(Event.prototype, "queue", {
    get: function() {
      if (!this.object.hasOwnProperty(this.queueName)) {
        this.queue = [];
      }
      return this.object[this.queueName];
    },
    set: function(val) {
      return def(this.object, this.queueName, {
        value: val,
        configurable: true
      });
    }
  });

  return Event;

})();

defineEvent = function(object, name, options) {
  if (options == null) {
    options = {};
  }
  return def(object, name, {
    configurable: true,
    get: function() {
      return new Event(this, name, options);
    }
  });
};

Cache = {
  _identityMap: {},
  get: function(ctor, id) {
    var name, _ref;
    name = ctor.uniqueId();
    if (name && id) {
      return (_ref = this._identityMap[name]) != null ? _ref[id] : void 0;
    }
  },
  set: function(ctor, id, obj) {
    var name, _base;
    name = ctor.uniqueId();
    if (name && id) {
      (_base = this._identityMap)[name] || (_base[name] = {});
      return this._identityMap[name][id] = obj;
    }
  },
  unset: function(ctor, id) {
    var name, _base;
    name = ctor.uniqueId();
    if (name && id) {
      (_base = this._identityMap)[name] || (_base[name] = {});
      return delete this._identityMap[name][id];
    }
  }
};

isArrayIndex = function(index) {
  return ("" + index).match(/^\d+$/);
};

Collection = (function() {
  var fun, _i, _len, _ref;

  defineEvent(Collection.prototype, "change_set");

  defineEvent(Collection.prototype, "change_add");

  defineEvent(Collection.prototype, "change_update");

  defineEvent(Collection.prototype, "change_insert");

  defineEvent(Collection.prototype, "change_delete");

  defineEvent(Collection.prototype, "change");

  function Collection(list) {
    var index, val, _i, _len;
    if (list == null) {
      list = [];
    }
    for (index = _i = 0, _len = list.length; _i < _len; index = ++_i) {
      val = list[index];
      this[index] = val;
    }
    this.length = (list != null ? list.length : void 0) || 0;
  }

  Collection.prototype.get = function(index) {
    return this[index];
  };

  Collection.prototype.set = function(index, value) {
    this[index] = value;
    if (isArrayIndex(index)) {
      this.length = Math.max(this.length, index + 1);
    }
    this.change_set.trigger(index, value);
    this.change.trigger(this);
    return value;
  };

  Collection.prototype.update = function(list) {
    var index, old, val, _, _i, _len;
    old = this.clone();
    for (index in this) {
      _ = this[index];
      if (isArrayIndex(index)) {
        delete this[index];
      }
    }
    for (index = _i = 0, _len = list.length; _i < _len; index = ++_i) {
      val = list[index];
      this[index] = val;
    }
    this.length = (list != null ? list.length : void 0) || 0;
    this.change_update.trigger(old, this);
    this.change.trigger(this);
    return list;
  };

  Collection.prototype.sortBy = function(attribute) {
    return this.sort(function(a, b) {
      if (a[attribute] < b[attribute]) {
        return -1;
      } else {
        return 1;
      }
    });
  };

  Collection.prototype.includes = function(item) {
    return this.indexOf(item) >= 0;
  };

  Collection.prototype.find = function(fun) {
    var item, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      item = this[_i];
      if (fun(item)) {
        return item;
      }
    }
  };

  Collection.prototype.insertAt = function(index, value) {
    Array.prototype.splice.call(this, index, 0, value);
    this.change_insert.trigger(index, value);
    this.change.trigger(this);
    return value;
  };

  Collection.prototype.deleteAt = function(index) {
    var value;
    value = this[index];
    Array.prototype.splice.call(this, index, 1);
    this.change_delete.trigger(index, value);
    this.change.trigger(this);
    return value;
  };

  Collection.prototype["delete"] = function(item) {
    var index;
    index = this.indexOf(item);
    if (index !== -1) {
      return this.deleteAt(index);
    }
  };

  Collection.prototype.first = function() {
    return this[0];
  };

  Collection.prototype.last = function() {
    return this[this.length - 1];
  };

  Collection.prototype.toArray = function() {
    var array, index, val;
    array = [];
    for (index in this) {
      val = this[index];
      if (isArrayIndex(index)) {
        array[index] = val;
      }
    }
    return array;
  };

  Collection.prototype.clone = function() {
    return new Collection(this.toArray());
  };

  Collection.prototype.push = function(element) {
    this[this.length++] = element;
    this.change_add.trigger(element);
    this.change.trigger(this);
    return element;
  };

  Collection.prototype.pop = function() {
    return this.deleteAt(this.length - 1);
  };

  Collection.prototype.unshift = function(item) {
    return this.insertAt(0, item);
  };

  Collection.prototype.shift = function() {
    return this.deleteAt(0);
  };

  Collection.prototype.splice = function() {
    var deleteCount, deleted, list, old, start;
    start = arguments[0], deleteCount = arguments[1], list = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    old = this.clone();
    deleted = Array.prototype.splice.apply(this, [start, deleteCount].concat(__slice.call(list)));
    this.change_update.trigger(old, this);
    this.change.trigger(this);
    return new Collection(deleted);
  };

  Collection.prototype.sort = function(fun) {
    var old;
    old = this.clone();
    Array.prototype.sort.call(this, fun);
    this.change_update.trigger(old, this);
    this.change.trigger(this);
    return this;
  };

  Collection.prototype.reverse = function() {
    var old;
    old = this.clone();
    Array.prototype.reverse.call(this);
    this.change_update.trigger(old, this);
    this.change.trigger(this);
    return this;
  };

  _ref = ["forEach", "indexOf", "lastIndexOf", "join", "every", "some", "reduce", "reduceRight"];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    fun = _ref[_i];
    Collection.prototype[fun] = Array.prototype[fun];
  }

  Collection.prototype.map = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return new Collection(Array.prototype.map.apply(this, args));
  };

  Collection.prototype.filter = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return new Collection(Array.prototype.filter.apply(this, args));
  };

  Collection.prototype.slice = function() {
    var args, _ref1;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return new Collection((_ref1 = this.toArray()).slice.apply(_ref1, args));
  };

  Collection.prototype.concat = function() {
    var arg, args, _ref1;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    args = (function() {
      var _j, _len1, _results;
      _results = [];
      for (_j = 0, _len1 = args.length; _j < _len1; _j++) {
        arg = args[_j];
        if (arg instanceof Collection) {
          _results.push(arg.toArray());
        } else {
          _results.push(arg);
        }
      }
      return _results;
    })();
    return new Collection((_ref1 = this.toArray()).concat.apply(_ref1, args));
  };

  Collection.prototype.toString = function() {
    return this.toArray().toString();
  };

  Collection.prototype.toLocaleString = function() {
    return this.toArray().toLocaleString();
  };

  Collection.prototype.toJSON = function() {
    return serializeObject(this.toArray());
  };

  return Collection;

})();

AssociationCollection = (function(_super) {

  __extends(AssociationCollection, _super);

  function AssociationCollection(owner, options, list) {
    var _this = this;
    this.owner = owner;
    this.options = options;
    this._convert.apply(this, __slice.call(list).concat([function() {
      var items;
      items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return AssociationCollection.__super__.constructor.call(_this, items);
    }]));
  }

  AssociationCollection.prototype.set = function(index, item) {
    var _this = this;
    return this._convert(item, function(item) {
      return AssociationCollection.__super__.set.call(_this, index, item);
    });
  };

  AssociationCollection.prototype.push = function(item) {
    var _this = this;
    return this._convert(item, function(item) {
      return AssociationCollection.__super__.push.call(_this, item);
    });
  };

  AssociationCollection.prototype.update = function(list) {
    var _this = this;
    return this._convert.apply(this, __slice.call(list).concat([function() {
      var items;
      items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return AssociationCollection.__super__.update.call(_this, items);
    }]));
  };

  AssociationCollection.prototype.splice = function() {
    var deleteCount, list, start,
      _this = this;
    start = arguments[0], deleteCount = arguments[1], list = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    return this._convert.apply(this, __slice.call(list).concat([function() {
      var items;
      items = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return AssociationCollection.__super__.splice.apply(_this, [start, deleteCount].concat(__slice.call(items)));
    }]));
  };

  AssociationCollection.prototype.insertAt = function(index, item) {
    var _this = this;
    return this._convert(item, function(item) {
      return AssociationCollection.__super__.insertAt.call(_this, index, item);
    });
  };

  AssociationCollection.prototype._convert = function() {
    var fn, item, items, returnValue, _i, _j, _len;
    items = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), fn = arguments[_i++];
    items = (function() {
      var _j, _len, _results;
      _results = [];
      for (_j = 0, _len = items.length; _j < _len; _j++) {
        item = items[_j];
        if ((item != null ? item.constructor : void 0) === Object && this.options.as) {
          _results.push(item = new (this.options.as())(item));
        } else {
          _results.push(item);
        }
      }
      return _results;
    }).call(this);
    returnValue = fn.apply(null, items);
    for (_j = 0, _len = items.length; _j < _len; _j++) {
      item = items[_j];
      if (this.options.inverseOf && item[this.options.inverseOf] !== this.owner) {
        item[this.options.inverseOf] = this.owner;
      }
    }
    return returnValue;
  };

  return AssociationCollection;

})(Collection);

globalDependencies = {};

triggerGlobal = function(target, names) {
  var dependency, name, object, subname, type, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = names.length; _i < _len; _i++) {
    name = names[_i];
    if (globalDependencies.hasOwnProperty(name)) {
      _results.push((function() {
        var _j, _len1, _ref, _ref1, _ref2, _ref3, _results1;
        _ref = globalDependencies[name];
        _results1 = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          _ref1 = _ref[_j], name = _ref1.name, type = _ref1.type, object = _ref1.object, subname = _ref1.subname, dependency = _ref1.dependency;
          if (type === "singular") {
            if (target === object[name]) {
              _results1.push((_ref2 = object[dependency + "_property"]) != null ? typeof _ref2.trigger === "function" ? _ref2.trigger(object) : void 0 : void 0);
            } else {
              _results1.push(void 0);
            }
          } else if (type === "collection") {
            if (__indexOf.call(object[name], target) >= 0) {
              _results1.push((_ref3 = object[dependency + "_property"]) != null ? typeof _ref3.trigger === "function" ? _ref3.trigger(object) : void 0 : void 0);
            } else {
              _results1.push(void 0);
            }
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      })());
    } else {
      _results.push(void 0);
    }
  }
  return _results;
};

PropertyDefinition = (function() {

  function PropertyDefinition(name, options) {
    var _i, _len, _ref;
    this.name = name;
    extend(this, options);
    this.dependencies = [];
    this.localDependencies = [];
    this.globalDependencies = [];
    if (this.dependsOn) {
      _ref = [].concat(this.dependsOn);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        this.addDependency(name);
      }
    }
    this.async = "async" in options ? options.async : settings.async;
    this.eventOptions = {
      async: this.async,
      bind: function() {
        return this[name];
      },
      optimize: function(queue) {
        return queue[queue.length - 1];
      }
    };
  }

  PropertyDefinition.prototype.addDependency = function(name) {
    var subname, type, _ref, _ref1;
    if (this.dependencies.indexOf(name) === -1) {
      this.dependencies.push(name);
      if (name.match(/\./)) {
        type = "singular";
        _ref = name.split("."), name = _ref[0], subname = _ref[1];
      } else if (name.match(/:/)) {
        type = "collection";
        _ref1 = name.split(":"), name = _ref1[0], subname = _ref1[1];
      }
      this.localDependencies.push(name);
      if (this.localDependencies.indexOf(name) === -1) {
        this.localDependencies.push(name);
      }
      if (type) {
        return this.globalDependencies.push({
          subname: subname,
          name: name,
          type: type
        });
      }
    }
  };

  return PropertyDefinition;

})();

PropertyAccessor = (function() {

  function PropertyAccessor(definition, object) {
    this.definition = definition;
    this.object = object;
    this.name = this.definition.name;
    this.valueName = "_s_" + this.name + "_val";
    this.event = new Event(this.object, this.name + "_change", this.definition.eventOptions);
  }

  PropertyAccessor.prototype.set = function(value) {
    if (typeof value === "function") {
      return this.definition.get = value;
    } else {
      if (this.definition.set) {
        this.definition.set.call(this.object, value);
      } else {
        def(this.object, this.valueName, {
          value: value,
          configurable: true
        });
      }
      return this.trigger();
    }
  };

  PropertyAccessor.prototype.get = function() {
    var listener, value,
      _this = this;
    this.registerGlobal();
    if (this.definition.get) {
      listener = function(name) {
        return _this.definition.addDependency(name);
      };
      if (!("dependsOn" in this.definition)) {
        this.object._s_property_access.bind(listener);
      }
      value = this.definition.get.call(this.object);
      if (!("dependsOn" in this.definition)) {
        this.object._s_property_access.unbind(listener);
      }
    } else {
      value = this.object[this.valueName];
    }
    this.object._s_property_access.trigger(this.name);
    return value;
  };

  PropertyAccessor.prototype.format = function() {
    if (typeof this.definition.format === "function") {
      return this.definition.format.call(this.object, this.get());
    } else {
      return this.get();
    }
  };

  PropertyAccessor.prototype.registerGlobal = function() {
    var name, subname, type, _i, _len, _ref, _ref1, _results;
    if (!this.object["_s_glb_" + this.name]) {
      def(this.object, "_s_glb_" + this.name, {
        value: true,
        configurable: true
      });
      _ref = this.definition.globalDependencies;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], name = _ref1.name, type = _ref1.type, subname = _ref1.subname;
        globalDependencies[subname] || (globalDependencies[subname] = []);
        _results.push(globalDependencies[subname].push({
          object: this.object,
          subname: subname,
          name: name,
          type: type,
          dependency: this.name
        }));
      }
      return _results;
    }
  };

  PropertyAccessor.prototype.trigger = function() {
    var changes, name, names, value, _i, _len, _ref, _results;
    names = [this.name].concat(this.dependents);
    changes = {};
    for (_i = 0, _len = names.length; _i < _len; _i++) {
      name = names[_i];
      changes[name] = this.object[name];
    }
    if ((_ref = this.object.changed) != null) {
      if (typeof _ref.trigger === "function") {
        _ref.trigger(changes);
      }
    }
    triggerGlobal(this.object, names);
    _results = [];
    for (name in changes) {
      if (!__hasProp.call(changes, name)) continue;
      value = changes[name];
      _results.push(this.object[name + "_property"].event.trigger(value));
    }
    return _results;
  };

  PropertyAccessor.prototype.bind = function(fun) {
    return this.event.bind(fun);
  };

  PropertyAccessor.prototype.unbind = function(fun) {
    return this.event.unbind(fun);
  };

  PropertyAccessor.prototype.one = function(fun) {
    return this.event.one(fun);
  };

  def(PropertyAccessor.prototype, "dependents", {
    get: function() {
      var deps, findDependencies,
        _this = this;
      deps = [];
      findDependencies = function(name) {
        var property, _i, _len, _ref, _ref1, _results;
        _ref = _this.object._s_properties;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          property = _ref[_i];
          if ((_ref1 = property.name, __indexOf.call(deps, _ref1) < 0) && __indexOf.call(property.localDependencies, name) >= 0) {
            deps.push(property.name);
            _results.push(findDependencies(property.name));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
      findDependencies(this.name);
      return deps;
    }
  });

  def(PropertyAccessor.prototype, "listeners", {
    get: function() {
      return this.event.listeners;
    }
  });

  return PropertyAccessor;

})();

defineProperty = function(object, name, options) {
  var definition;
  if (options == null) {
    options = {};
  }
  definition = new PropertyDefinition(name, options);
  safePush(object, "_s_properties", definition);
  defineEvent(object, "_s_property_access");
  def(object, name, {
    get: function() {
      return this[name + "_property"].get();
    },
    set: function(value) {
      return this[name + "_property"].set(value);
    },
    configurable: true,
    enumerable: "enumerable" in options ? options.enumerable : true
  });
  def(object, name + "_property", {
    get: function() {
      return new PropertyAccessor(definition, this);
    },
    configurable: true
  });
  if (typeof options.serialize === 'string') {
    defineProperty(object, options.serialize, {
      get: function() {
        return this[name];
      },
      set: function(v) {
        return this[name] = v;
      },
      configurable: true
    });
  }
  if ("value" in options) {
    return object[name] = options.value;
  }
};

idCounter = 1;

Model = (function() {

  defineEvent(Model.prototype, "saved");

  defineEvent(Model.prototype, "changed", {
    optimize: function(queue) {
      var item, result, _i, _len;
      result = {};
      for (_i = 0, _len = queue.length; _i < _len; _i++) {
        item = queue[_i];
        extend(result, item[0]);
      }
      return [result];
    }
  });

  Model.belongsTo = function() {
    var _ref;
    return (_ref = this.prototype).belongsTo.apply(_ref, arguments);
  };

  Model.hasMany = function() {
    var _ref;
    return (_ref = this.prototype).hasMany.apply(_ref, arguments);
  };

  Model.identityMap = true;

  Model.find = function(id) {
    return Cache.get(this, id) || new this({
      id: id
    });
  };

  Model.extend = function(ctor) {
    var New;
    return New = (function(_super) {

      __extends(New, _super);

      function New() {
        var val;
        val = New.__super__.constructor.apply(this, arguments);
        if (val) {
          return val;
        }
        if (ctor) {
          ctor.apply(this, arguments);
        }
      }

      return New;

    })(this);
  };

  Model.property = function() {
    var name, names, options, _i, _j, _len, _results;
    names = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), options = arguments[_i++];
    if (typeof options === "string") {
      names.push(options);
      options = {};
    }
    _results = [];
    for (_j = 0, _len = names.length; _j < _len; _j++) {
      name = names[_j];
      _results.push(defineProperty(this.prototype, name, options));
    }
    return _results;
  };

  Model.properties = function() {
    var name, names, _i, _len, _results;
    names = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _results = [];
    for (_i = 0, _len = names.length; _i < _len; _i++) {
      name = names[_i];
      _results.push(this.property(name));
    }
    return _results;
  };

  Model.delegate = function() {
    var names, options, to, _i,
      _this = this;
    names = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), options = arguments[_i++];
    to = options.to;
    return names.forEach(function(name) {
      var propName;
      propName = name;
      if (options.prefix === true) {
        propName = to + capitalize(name);
      } else if (options.prefix) {
        propName = options.prefix + capitalize(name);
      }
      if (options.suffix === true) {
        propName = propName + capitalize(to);
      } else if (options.suffix) {
        propName = propName + options.suffix;
      }
      return _this.property(propName, {
        dependsOn: "" + to + "." + name,
        get: function() {
          var _ref;
          return (_ref = this[to]) != null ? _ref[name] : void 0;
        },
        set: function(value) {
          var _ref;
          return (_ref = this[to]) != null ? _ref[name] = value : void 0;
        }
      });
    });
  };

  Model.collection = function(name, options) {
    if (options == null) {
      options = {};
    }
    extend(options, {
      get: function() {
        var valueName,
          _this = this;
        valueName = "_s_" + name + "_val";
        if (!this[valueName]) {
          this[valueName] = new Collection([]);
          this[valueName].change.bind(function() {
            return _this[name + "_property"].trigger();
          });
        }
        return this[valueName];
      },
      set: function(value) {
        return this[name].update(value);
      }
    });
    this.property(name, options);
    return this.property(name + 'Count', {
      get: function() {
        return this[name].length;
      },
      dependsOn: name
    });
  };

  Model.belongsTo = function(name, attributes) {
    if (attributes == null) {
      attributes = {};
    }
    extend(attributes, {
      set: function(model) {
        var previous, valueName;
        valueName = "_s_" + name + "_val";
        if (model && model.constructor === Object && attributes.as) {
          model = new (attributes.as())(model);
        }
        previous = this[valueName];
        this[valueName] = model;
        if (attributes.inverseOf && !model[attributes.inverseOf].includes(this)) {
          if (previous) {
            previous[attributes.inverseOf]["delete"](this);
          }
          return model[attributes.inverseOf].push(this);
        }
      }
    });
    this.property(name, attributes);
    return this.property(name + 'Id', {
      get: function() {
        var _ref;
        return (_ref = this[name]) != null ? _ref.id : void 0;
      },
      set: function(id) {
        if (id != null) {
          return this[name] = attributes.as().find(id);
        }
      },
      dependsOn: name,
      serialize: attributes.serializeId
    });
  };

  Model.hasMany = function(name, attributes) {
    if (attributes == null) {
      attributes = {};
    }
    extend(attributes, {
      get: function() {
        var valueName,
          _this = this;
        valueName = "_s_" + name + "_val";
        if (!this[valueName]) {
          this[valueName] = new AssociationCollection(this, attributes, []);
          this[valueName].change.bind(function() {
            return _this[name + "_property"].trigger();
          });
        }
        return this[valueName];
      },
      set: function(value) {
        return this[name].update(value);
      }
    });
    this.property(name, attributes);
    this.property(name + 'Ids', {
      get: function() {
        return new Collection(this[name]).map(function(item) {
          return item != null ? item.id : void 0;
        });
      },
      set: function(ids) {
        var id, objects;
        objects = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = ids.length; _i < _len; _i++) {
            id = ids[_i];
            _results.push(attributes.as().find(id));
          }
          return _results;
        })();
        return this[name].update(objects);
      },
      dependsOn: name,
      serialize: attributes.serializeIds
    });
    return this.property(name + 'Count', {
      get: function() {
        return this[name].length;
      },
      dependsOn: name
    });
  };

  Model.selection = function(name, options) {
    if (options == null) {
      options = {};
    }
    this.property(name, {
      get: function() {
        return this[options.from].filter(function(item) {
          return item[options.filter];
        });
      },
      dependsOn: "" + options.from + ":" + options.filter
    });
    return this.property(name + 'Count', {
      get: function() {
        return this[name].length;
      },
      dependsOn: name
    });
  };

  Model.uniqueId = function() {
    if (!(this._uniqueId && this._uniqueGen === this)) {
      this._uniqueId = (idCounter += 1);
      this._uniqueGen = this;
    }
    return this._uniqueId;
  };

  Model.property('id', {
    serialize: true,
    set: function(val) {
      Cache.unset(this.constructor, this.id);
      Cache.set(this.constructor, val, this);
      return def(this, "_s_id_val", {
        value: val,
        configurable: true
      });
    },
    get: function() {
      return this._s_id_val;
    }
  });

  function Model(attributes) {
    var fromCache;
    if (this.constructor.identityMap && (attributes != null ? attributes.id : void 0)) {
      fromCache = Cache.get(this.constructor, attributes.id);
      if (fromCache) {
        fromCache.set(attributes);
        return fromCache;
      } else {
        Cache.set(this.constructor, attributes.id, this);
      }
    }
    this.set(attributes);
  }

  Model.prototype.set = function(attributes) {
    var name, value, _results;
    _results = [];
    for (name in attributes) {
      if (!__hasProp.call(attributes, name)) continue;
      value = attributes[name];
      if (!(name in this)) {
        defineProperty(this, name);
      }
      _results.push(this[name] = value);
    }
    return _results;
  };

  Model.prototype.save = function() {
    return this.saved.trigger();
  };

  Model.prototype.toJSON = function() {
    var key, property, serialized, value, _i, _len, _ref, _ref1;
    serialized = {};
    _ref = this._s_properties;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      property = _ref[_i];
      if (typeof property.serialize === 'string') {
        serialized[property.serialize] = serializeObject(this[property.name]);
      } else if (typeof property.serialize === 'function') {
        _ref1 = property.serialize.call(this), key = _ref1[0], value = _ref1[1];
        serialized[key] = serializeObject(value);
      } else if (property.serialize) {
        serialized[property.name] = serializeObject(this[property.name]);
      }
    }
    return serialized;
  };

  Model.prototype.toString = function() {
    return JSON.stringify(this.toJSON());
  };

  return Model;

})();

IDENTIFIER = /^[a-zA-Z][a-zA-Z0-9\-_]*/;

LITERAL = /^[\[\]=\:\-!#\.@]/;

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
      this.token('STRING_LITERAL', match[1]);
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
    if (match = LITERAL.exec(this.chunk)) {
      this.token(match[0]);
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

Node = (function() {

  defineEvent(Node.prototype, "load");

  defineEvent(Node.prototype, "unload");

  function Node(ast, element) {
    this.ast = ast;
    this.element = element;
    this.children = new Collection([]);
    this.boundClasses = new Collection([]);
  }

  Node.prototype.append = function(inside) {
    return inside.appendChild(this.element);
  };

  Node.prototype.insertAfter = function(after) {
    return after.parentNode.insertBefore(this.element, after.nextSibling);
  };

  Node.prototype.remove = function() {
    var _ref;
    this.unbindEvents();
    return (_ref = this.element.parentNode) != null ? _ref.removeChild(this.element) : void 0;
  };

  Node.prototype.lastElement = function() {
    return this.element;
  };

  Node.prototype.nodes = function() {
    return this.children;
  };

  Node.prototype.bindEvent = function(event, fun) {
    if (event) {
      this.boundEvents || (this.boundEvents = []);
      this.boundEvents.push({
        event: event,
        fun: fun
      });
      return event.bind(fun);
    }
  };

  Node.prototype.unbindEvents = function() {
    var event, fun, node, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results;
    this.unload.trigger();
    _ref = this.nodes();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      node.unbindEvents();
    }
    if (this.boundEvents) {
      _ref1 = this.boundEvents;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        _ref2 = _ref1[_j], event = _ref2.event, fun = _ref2.fun;
        _results.push(event.unbind(fun));
      }
      return _results;
    }
  };

  Node.prototype.updateClass = function() {
    var classes;
    classes = this.ast.classes;
    if (this.attributeClasses) {
      classes = classes.concat(this.attributeClasses);
    }
    if (this.boundClasses.length) {
      classes = classes.concat(this.boundClasses.toArray());
    }
    if (classes.length) {
      return this.element.className = classes.join(' ');
    } else {
      return this.element.removeAttribute("class");
    }
  };

  return Node;

})();

DynamicNode = (function(_super) {

  __extends(DynamicNode, _super);

  function DynamicNode(ast) {
    this.ast = ast;
    this.anchor = Serenade.document.createTextNode('');
    this.nodeSets = new Collection([]);
  }

  DynamicNode.prototype.nodes = function() {
    var node, nodes, set, _i, _j, _len, _len1, _ref;
    nodes = [];
    _ref = this.nodeSets;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      set = _ref[_i];
      for (_j = 0, _len1 = set.length; _j < _len1; _j++) {
        node = set[_j];
        nodes.push(node);
      }
    }
    return nodes;
  };

  DynamicNode.prototype.rebuild = function() {
    var last, node, _i, _len, _ref, _results;
    if (this.anchor.parentNode) {
      last = this.anchor;
      _ref = this.nodes();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        node.insertAfter(last);
        _results.push(last = node.lastElement());
      }
      return _results;
    }
  };

  DynamicNode.prototype.replace = function(sets) {
    var set;
    this.clear();
    this.nodeSets.update((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = sets.length; _i < _len; _i++) {
        set = sets[_i];
        _results.push(new Collection(set));
      }
      return _results;
    })());
    return this.rebuild();
  };

  DynamicNode.prototype.appendNodeSet = function(nodes) {
    return this.insertNodeSet(this.nodeSets.length, nodes);
  };

  DynamicNode.prototype.deleteNodeSet = function(index) {
    var node, _i, _len, _ref;
    _ref = this.nodeSets[index];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      node.remove();
    }
    return this.nodeSets.deleteAt(index);
  };

  DynamicNode.prototype.insertNodeSet = function(index, nodes) {
    var last, node, _i, _len, _ref, _ref1;
    last = ((_ref = this.nodeSets[index - 1]) != null ? (_ref1 = _ref.last()) != null ? _ref1.lastElement() : void 0 : void 0) || this.anchor;
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      node = nodes[_i];
      node.insertAfter(last);
      last = node.lastElement();
    }
    return this.nodeSets.insertAt(index, new Collection(nodes));
  };

  DynamicNode.prototype.clear = function() {
    var node, _i, _len, _ref;
    _ref = this.nodes();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      node.remove();
    }
    return this.nodeSets.update([]);
  };

  DynamicNode.prototype.remove = function() {
    this.unbindEvents();
    this.clear();
    return this.anchor.parentNode.removeChild(this.anchor);
  };

  DynamicNode.prototype.append = function(inside) {
    inside.appendChild(this.anchor);
    return this.rebuild();
  };

  DynamicNode.prototype.insertAfter = function(after) {
    after.parentNode.insertBefore(this.anchor, after.nextSibling);
    return this.rebuild();
  };

  DynamicNode.prototype.lastElement = function() {
    var _ref, _ref1;
    return ((_ref = this.nodeSets.last()) != null ? (_ref1 = _ref.last()) != null ? _ref1.lastElement() : void 0 : void 0) || this.anchor;
  };

  return DynamicNode;

})(Node);

getValue = function(ast, model) {
  if (ast.bound && ast.value) {
    return format(model, ast.value);
  } else if (ast.value != null) {
    return ast.value;
  } else {
    return model;
  }
};

Property = {
  style: function(ast, node, model, controller) {
    var update;
    update = function() {
      return node.element.style[ast.name] = getValue(ast, model);
    };
    update();
    if (ast.bound) {
      return node.bindEvent(model["" + ast.value + "_property"], update);
    }
  },
  event: function(ast, node, model, controller) {
    return node.element.addEventListener(ast.name, function(e) {
      if (ast.preventDefault) {
        e.preventDefault();
      }
      return controller[ast.value](node.element, model, e);
    });
  },
  "class": function(ast, node, model, controller) {
    var update;
    update = function() {
      if (model[ast.value]) {
        node.boundClasses.push(ast.name);
      } else {
        node.boundClasses["delete"](ast.name);
      }
      return node.updateClass();
    };
    update();
    return node.bindEvent(model["" + ast.value + "_property"], update);
  },
  binding: function(ast, node, model, controller) {
    var domUpdated, element, handler, modelUpdated, _ref;
    element = node.element;
    ((_ref = node.ast.name) === "input" || _ref === "textarea" || _ref === "select") || (function() {
      throw SyntaxError("invalid node type " + node.ast.name + " for two way binding");
    })();
    ast.value || (function() {
      throw SyntaxError("cannot bind to whole model, please specify an attribute to bind to");
    })();
    domUpdated = function() {
      return model[ast.value] = element.type === "checkbox" ? element.checked : element.type === "radio" ? element.checked ? element.getAttribute("value") : void 0 : element.value;
    };
    modelUpdated = function() {
      var val;
      val = model[ast.value];
      if (element.type === "checkbox") {
        return element.checked = !!val;
      } else if (element.type === "radio") {
        if (val === element.getAttribute("value")) {
          return element.checked = true;
        }
      } else {
        if (val === void 0) {
          val = "";
        }
        if (element.value !== val) {
          return element.value = val;
        }
      }
    };
    modelUpdated();
    node.bindEvent(model["" + ast.value + "_property"], modelUpdated);
    if (ast.name === "binding") {
      handler = function(e) {
        if (element.form === (e.target || e.srcElement)) {
          return domUpdated();
        }
      };
      Serenade.document.addEventListener("submit", handler, true);
      return node.unload.bind(function() {
        return Serenade.document.removeEventListener("submit", handler, true);
      });
    } else {
      return element.addEventListener(ast.name, domUpdated);
    }
  },
  attribute: function(ast, node, model, controller) {
    var element, update;
    if (ast.name === "binding") {
      return Property.binding(ast, node, model, controller);
    }
    element = node.element;
    update = function() {
      var value;
      value = getValue(ast, model);
      if (ast.name === 'value') {
        return element.value = value || '';
      } else if (node.ast.name === 'input' && ast.name === 'checked') {
        return element.checked = !!value;
      } else if (ast.name === 'class') {
        node.attributeClasses = value;
        return node.updateClass();
      } else if (value === void 0) {
        return element.removeAttribute(ast.name);
      } else {
        if (value === 0) {
          value = "0";
        }
        return element.setAttribute(ast.name, value);
      }
    };
    if (ast.bound) {
      node.bindEvent(model["" + ast.value + "_property"], update);
    }
    return update();
  },
  on: function(ast, node, model, controller) {
    var _ref;
    if ((_ref = ast.name) === "load" || _ref === "unload") {
      return node[ast.name].bind(function() {
        return controller[ast.value](node.element, model);
      });
    } else {
      throw new SyntaxError("unkown lifecycle event '" + ast.name + "'");
    }
  }
};

Compile = {
  element: function(ast, model, controller) {
    var action, child, childNode, element, node, property, _i, _j, _len, _len1, _ref, _ref1, _ref2;
    element = Serenade.document.createElement(ast.name);
    node = new Node(ast, element);
    if (ast.id) {
      element.setAttribute('id', ast.id);
    }
    if ((_ref = ast.classes) != null ? _ref.length : void 0) {
      element.setAttribute('class', ast.classes.join(' '));
    }
    _ref1 = ast.children;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      child = _ref1[_i];
      childNode = compile(child, model, controller);
      childNode.append(element);
      node.children.push(childNode);
    }
    _ref2 = ast.properties;
    for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
      property = _ref2[_j];
      action = Property[property.scope];
      if (action) {
        action(property, node, model, controller);
      } else {
        throw SyntaxError("" + property.scope + " is not a valid scope");
      }
    }
    node.load.trigger();
    return node;
  },
  view: function(ast, model, parent) {
    var controller, skipCallback;
    controller = Serenade.controllerFor(ast.argument);
    if (!controller) {
      skipCallback = true;
      controller = parent;
    }
    return Serenade._views[ast.argument].node(model, controller, parent, skipCallback);
  },
  helper: function(ast, model, controller) {
    var argument, context, dynamic, helperFunction, render, update, _i, _len, _ref;
    dynamic = new DynamicNode(ast);
    render = function(model, controller) {
      var child, fragment, node, _i, _len, _ref;
      if (model == null) {
        model = model;
      }
      if (controller == null) {
        controller = controller;
      }
      fragment = Serenade.document.createDocumentFragment();
      _ref = ast.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        node = compile(child, model, controller);
        node.append(fragment);
      }
      return fragment;
    };
    helperFunction = Serenade.Helpers[ast.command] || (function() {
      throw SyntaxError("no helper " + ast.command + " defined");
    })();
    context = {
      render: render,
      model: model,
      controller: controller
    };
    update = function() {
      var args, element, nodes;
      args = ast["arguments"].map(function(a) {
        if (a.bound) {
          return model[a.value];
        } else {
          return a.value;
        }
      });
      nodes = (function() {
        var _i, _len, _ref, _results;
        _ref = normalize(helperFunction.apply(context, args));
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          element = _ref[_i];
          _results.push(new Node(ast, element));
        }
        return _results;
      })();
      return dynamic.replace([nodes]);
    };
    _ref = ast["arguments"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      argument = _ref[_i];
      if (argument.bound === true) {
        dynamic.bindEvent(model["" + argument.value + "_property"], update);
      }
    }
    update();
    return dynamic;
  },
  text: function(ast, model, controller) {
    var getText, node, textNode;
    getText = function() {
      var value;
      value = getValue(ast, model);
      if (value === 0) {
        value = "0";
      }
      return value || "";
    };
    textNode = Serenade.document.createTextNode(getText());
    node = new Node(ast, textNode);
    if (ast.bound) {
      node.bindEvent(model["" + ast.value + "_property"], function() {
        return textNode.nodeValue = getText();
      });
    }
    return node;
  },
  collection: function(ast, model, controller) {
    var collection, compileItem, dynamic, update,
      _this = this;
    compileItem = function(item) {
      return compileAll(ast.children, item, controller);
    };
    update = function(dynamic, collection) {
      var item;
      return dynamic.replace((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = collection.length; _i < _len; _i++) {
          item = collection[_i];
          _results.push(compileItem(item));
        }
        return _results;
      })());
    };
    dynamic = this.bound(ast, model, controller, update);
    collection = model[ast.argument];
    dynamic.bindEvent(collection['change_set'], function() {
      var item;
      return dynamic.replace((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = collection.length; _i < _len; _i++) {
          item = collection[_i];
          _results.push(compileItem(item));
        }
        return _results;
      })());
    });
    dynamic.bindEvent(collection['change_update'], function() {
      var item;
      return dynamic.replace((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = collection.length; _i < _len; _i++) {
          item = collection[_i];
          _results.push(compileItem(item));
        }
        return _results;
      })());
    });
    dynamic.bindEvent(collection['change_add'], function(item) {
      return dynamic.appendNodeSet(compileItem(item));
    });
    dynamic.bindEvent(collection['change_insert'], function(index, item) {
      return dynamic.insertNodeSet(index, compileItem(item));
    });
    dynamic.bindEvent(collection['change_delete'], function(index) {
      return dynamic.deleteNodeSet(index);
    });
    return dynamic;
  },
  "in": function(ast, model, controller) {
    return this.bound(ast, model, controller, function(dynamic, value) {
      if (value) {
        return dynamic.replace([compileAll(ast.children, value, controller)]);
      } else {
        return dynamic.clear();
      }
    });
  },
  "if": function(ast, model, controller) {
    return this.bound(ast, model, controller, function(dynamic, value) {
      if (value) {
        return dynamic.replace([compileAll(ast.children, model, controller)]);
      } else if (ast["else"]) {
        return dynamic.replace([compileAll(ast["else"].children, model, controller)]);
      } else {
        return dynamic.clear();
      }
    });
  },
  unless: function(ast, model, controller) {
    return this.bound(ast, model, controller, function(dynamic, value) {
      var child, nodes;
      if (value) {
        return dynamic.clear();
      } else {
        nodes = (function() {
          var _i, _len, _ref, _results;
          _ref = ast.children;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            child = _ref[_i];
            _results.push(compile(child, model, controller));
          }
          return _results;
        })();
        return dynamic.replace([nodes]);
      }
    });
  },
  bound: function(ast, model, controller, callback) {
    var dynamic, update;
    dynamic = new DynamicNode(ast);
    update = function() {
      var value;
      value = model[ast.argument];
      return callback(dynamic, value);
    };
    update();
    dynamic.bindEvent(model["" + ast.argument + "_property"], update);
    return dynamic;
  }
};

normalize = function(val) {
  var reduction;
  if (!val) {
    return [];
  }
  reduction = function(aggregate, element) {
    var child, div, _i, _len, _ref;
    if (typeof element === "string") {
      div = Serenade.document.createElement("div");
      div.innerHTML = element;
      _ref = div.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        aggregate.push(child);
      }
    } else {
      aggregate.push(element);
    }
    return aggregate;
  };
  return [].concat(val).reduce(reduction, []);
};

compile = function(ast, model, controller) {
  return Compile[ast.type](ast, model, controller);
};

compileAll = function(asts, model, controller) {
  var ast, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = asts.length; _i < _len; _i++) {
    ast = asts[_i];
    _results.push(compile(ast, model, controller));
  }
  return _results;
};

parser.lexer = {
  lex: function() {
    var tag, _ref;
    _ref = this.tokens[this.pos++] || [''], tag = _ref[0], this.yytext = _ref[1], this.yylineno = _ref[2];
    return tag;
  },
  setInput: function(tokens) {
    this.tokens = tokens;
    return this.pos = 0;
  },
  upcomingInput: function() {
    return "";
  }
};

View = (function() {

  function View(name, view) {
    this.name = name;
    this.view = view;
  }

  View.prototype.parse = function() {
    if (typeof this.view === 'string') {
      try {
        return this.view = parser.parse(new Lexer().tokenize(this.view));
      } catch (e) {
        if (this.name) {
          e.message = "In view '" + this.name + "': " + e.message;
        }
        throw e;
      }
    } else {
      return this.view;
    }
  };

  View.prototype.render = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return this.node.apply(this, args).element;
  };

  View.prototype.node = function(model, controller, parent, skipCallback) {
    var node;
    if (this.name) {
      controller || (controller = Serenade.controllerFor(this.name, model));
    }
    controller || (controller = {});
    if (typeof controller === "function") {
      controller = new controller(model, parent);
    }
    node = compile(this.parse(), model, controller);
    if (!skipCallback) {
      if (typeof controller.loaded === "function") {
        controller.loaded(node.element, model);
      }
    }
    return node;
  };

  return View;

})();

Serenade = function(wrapped) {
  var key, object, value;
  object = Object.create(wrapped);
  for (key in wrapped) {
    value = wrapped[key];
    defineProperty(object, key, {
      value: value
    });
  }
  return object;
};

extend(Serenade, {
  VERSION: '0.3.0',
  _views: {},
  _controllers: {},
  document: typeof window !== "undefined" && window !== null ? window.document : void 0,
  format: format,
  defineProperty: defineProperty,
  defineEvent: defineEvent,
  asyncEvents: false,
  view: function(nameOrTemplate, template) {
    if (template) {
      return this._views[nameOrTemplate] = new View(nameOrTemplate, template);
    } else {
      return new View(void 0, nameOrTemplate);
    }
  },
  render: function(name, model, controller, parent, skipCallback) {
    return this._views[name].render(model, controller, parent, skipCallback);
  },
  controller: function(name, klass) {
    return this._controllers[name] = klass;
  },
  controllerFor: function(name) {
    return this._controllers[name];
  },
  clearIdentityMap: function() {
    return Cache._identityMap = {};
  },
  clearLocalStorage: function() {
    return Cache._storage.clear();
  },
  clearCache: function() {
    var key, value, _i, _len, _results;
    Serenade.clearIdentityMap();
    Serenade.clearLocalStorage();
    _results = [];
    for (key = _i = 0, _len = globalDependencies.length; _i < _len; key = ++_i) {
      value = globalDependencies[key];
      _results.push(delete globalDependencies[key]);
    }
    return _results;
  },
  unregisterAll: function() {
    Serenade._views = {};
    return Serenade._controllers = {};
  },
  Model: Model,
  Collection: Collection,
  Cache: Cache,
  View: View,
  Helpers: {}
});

def(Serenade, "async", {
  get: function() {
    return settings.async;
  },
  set: function(value) {
    return settings.async = value;
  }
});
;
  root.Serenade = Serenade;
}(this));