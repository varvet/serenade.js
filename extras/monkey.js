/**
 * Monkey.js JavaScript Framework v0.1.0
 * http://github.com/elabs/monkey.js
 *
 * Copyright 2011, Jonas Nicklas
 * Released under the MIT License
 */
(function(root) {
  var Monkey = function() {
    function require(path){ return require[path]; }
    require['./monkey'] = new function() {
  var exports = this;
  (function() {
  var Monkey;

  Monkey = {
    VERSION: '0.1.0',
    _views: [],
    _controllers: [],
    registerView: function(name, template) {
      return this._views[name] = new Monkey.View(template);
    },
    render: function(name, model, controller) {
      controller || (controller = this.controllerFor(name));
      return this._views[name].render(this.document, model, controller);
    },
    registerController: function(name, klass) {
      return this._controllers[name] = klass;
    },
    controllerFor: function(name) {
      if (this._controllers[name]) {
        return new this._controllers[name]();
      } else {
        return {};
      }
    },
    extend: function(target, source) {
      var key, value, _results;
      _results = [];
      for (key in source) {
        value = source[key];
        if (Object.prototype.hasOwnProperty.call(source, key)) {
          _results.push(target[key] = value);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    document: typeof window !== "undefined" && window !== null ? window.document : void 0,
    get: function(model, value, bound) {
      if (bound == null) bound = true;
      if (bound && model.get) {
        return model.get(value);
      } else if (bound) {
        return model[value];
      } else {
        return value;
      }
    },
    forEach: function(collection, fun) {
      var element, _i, _len, _results;
      if (typeof collection.forEach === 'function') {
        return collection.forEach(fun);
      } else {
        _results = [];
        for (_i = 0, _len = collection.length; _i < _len; _i++) {
          element = collection[_i];
          _results.push(fun(element));
        }
        return _results;
      }
    }
  };

  exports.Monkey = Monkey;

}).call(this);

};require['./events'] = new function() {
  var exports = this;
  (function() {
  var Monkey,
    __slice = Array.prototype.slice;

  Monkey = require('./monkey').Monkey;

  Monkey.Events = {
    bind: function(ev, callback) {
      var calls, evs, name, _i, _len;
      evs = ev.split(' ');
      calls = this.hasOwnProperty('_callbacks') && this._callbacks || (this._callbacks = {});
      for (_i = 0, _len = evs.length; _i < _len; _i++) {
        name = evs[_i];
        calls[name] || (calls[name] = []);
        calls[name].push(callback);
      }
      return this;
    },
    one: function(ev, callback) {
      return this.bind(ev, function() {
        this.unbind(ev, arguments.callee);
        return callback.apply(this, arguments);
      });
    },
    trigger: function() {
      var args, callback, ev, list, _i, _len, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      ev = args.shift();
      list = this.hasOwnProperty('_callbacks') && ((_ref = this._callbacks) != null ? _ref[ev] : void 0);
      if (!list) return false;
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        callback = list[_i];
        callback.apply(this, args);
      }
      return true;
    },
    unbind: function(ev, callback) {
      var cb, i, list, _len, _ref;
      if (!ev) {
        this._callbacks = {};
        return this;
      }
      list = (_ref = this._callbacks) != null ? _ref[ev] : void 0;
      if (!list) return this;
      if (!callback) {
        delete this._callbacks[ev];
        return this;
      }
      for (i = 0, _len = list.length; i < _len; i++) {
        cb = list[i];
        if (!(cb === callback)) continue;
        list = list.slice();
        list.splice(i, 1);
        this._callbacks[ev] = list;
        break;
      }
      return this;
    }
  };

}).call(this);

};require['./lexer'] = new function() {
  var exports = this;
  (function() {
  var IDENTIFIER, LITERAL, MULTI_DENT, Monkey, STRING, WHITESPACE;

  Monkey = require('./monkey').Monkey;

  IDENTIFIER = /^[a-zA-Z][a-zA-Z0-9\-]*/;

  LITERAL = /^[\[\]=\:\-]/;

  STRING = /^"((?:\\.|[^"])*)"/;

  MULTI_DENT = /^(?:\n[^\n\S]*)+/;

  WHITESPACE = /^[^\n\S]+/;

  Monkey.Lexer = (function() {

    function Lexer() {}

    Lexer.prototype.tokenize = function(code, opts) {
      var i, tag;
      if (opts == null) opts = {};
      this.code = code;
      this.line = opts.line || 0;
      this.indent = 0;
      this.indebt = 0;
      this.outdebt = 0;
      this.indents = [];
      this.ends = [];
      this.tokens = [];
      i = 0;
      while (this.chunk = code.slice(i)) {
        i += this.identifierToken() || this.whitespaceToken() || this.lineToken() || this.stringToken() || this.literalToken();
      }
      while (tag = this.ends.pop()) {
        if (tag === 'OUTDENT') {
          this.token('OUTDENT');
        } else {
          this.error("missing " + tag);
        }
      }
      return this.tokens;
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
      var match;
      if (match = IDENTIFIER.exec(this.chunk)) {
        this.token('IDENTIFIER', match[0]);
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
      if (!(match = MULTI_DENT.exec(this.chunk))) return 0;
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
          if (this.last(this.ends) !== 'OUTDENT') {
            this.error('Should be an OUTDENT, yo');
          }
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
      var id, match;
      if (match = LITERAL.exec(this.chunk)) {
        id = match[0];
        switch (id) {
          case "[":
            this.token('LPAREN', id);
            break;
          case "]":
            this.token('RPAREN', id);
            break;
          case "=":
            this.token('ASSIGN', id);
            break;
          case "-":
            this.token('INSTRUCT', id);
            break;
          case ":":
            this.token('SCOPE', id);
        }
        return 1;
      } else {
        return this.error("WUT??? is '" + (this.chunk.charAt(0)) + "'");
      }
    };

    Lexer.prototype.newlineToken = function() {
      if (this.tag() !== 'TERMINATOR') return this.token('TERMINATOR', '\n');
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
      throw SyntaxError("" + message + " on line " + (this.line + 1));
    };

    Lexer.prototype.count = function(string, substr) {
      var num, pos;
      num = pos = 0;
      if (!substr.length) return 1 / 0;
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

}).call(this);

};require['./nodes'] = new function() {
  var exports = this;
  (function() {
  var Monkey;

  Monkey = require('./monkey').Monkey;

  Monkey.Nodes = {
    compile: function(ast, document, model, controller) {
      switch (ast.type) {
        case 'element':
          return new Monkey.Nodes.Element(ast, document, model, controller);
        case 'text':
          return new Monkey.Nodes.TextNode(ast, document, model, controller);
        case 'instruction':
          switch (ast.command) {
            case "view":
              return new Monkey.Nodes.View(ast, document, model, controller);
            case "collection":
              return new Monkey.Nodes.Collection(ast, document, model, controller);
          }
          break;
        default:
          throw SyntaxError("unknown type " + ast.type);
      }
    },
    property: function(ast, element, document, model, controller) {
      switch (ast.scope) {
        case "attribute":
          return new Monkey.Nodes.Attribute(ast, element, document, model, controller);
        case "style":
          return new Monkey.Nodes.Style(ast, element, document, model, controller);
        case "event":
          return new Monkey.Nodes.Event(ast, element, document, model, controller);
      }
    }
  };

  Monkey.Nodes.Element = (function() {

    function Element(ast, document, model, controller) {
      var child, property, _i, _j, _len, _len2, _ref, _ref2;
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.element = this.document.createElement(this.ast.name);
      _ref = this.ast.properties;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        property = _ref[_i];
        Monkey.Nodes.property(property, this.element, this.document, this.model, this.controller);
      }
      _ref2 = this.ast.children;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        child = _ref2[_j];
        Monkey.Nodes.compile(child, this.document, this.model, this.controller).append(this.element);
      }
    }

    Element.prototype.append = function(inside) {
      return inside.appendChild(this.element);
    };

    Element.prototype.insertAfter = function(after) {
      return after.parentNode.insertBefore(this.element, after.nextSibling);
    };

    Element.prototype.remove = function() {
      return this.element.parentNode.removeChild(this.element);
    };

    Element.prototype.lastElement = function() {
      return this.element;
    };

    return Element;

  })();

  Monkey.Nodes.Style = (function() {

    function Style(ast, element, document, model, controller) {
      var _base,
        _this = this;
      this.ast = ast;
      this.element = element;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.update();
      if (this.ast.bound) {
        if (typeof (_base = this.model).bind === "function") {
          _base.bind("change:" + this.ast.value, function(value) {
            return _this.update();
          });
        }
      }
    }

    Style.prototype.update = function() {
      return this.element.style[this.ast.name] = this.get();
    };

    Style.prototype.get = function() {
      return Monkey.get(this.model, this.ast.value, this.ast.bound);
    };

    return Style;

  })();

  Monkey.Nodes.Event = (function() {

    function Event(ast, element, document, model, controller) {
      var callback,
        _this = this;
      this.ast = ast;
      this.element = element;
      this.document = document;
      this.model = model;
      this.controller = controller;
      callback = function(e) {
        return _this.controller[_this.ast.value](e);
      };
      this.element.addEventListener(this.ast.name, callback, false);
    }

    return Event;

  })();

  Monkey.Nodes.Attribute = (function() {

    function Attribute(ast, element, document, model, controller) {
      var _base,
        _this = this;
      this.ast = ast;
      this.element = element;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.update();
      if (this.ast.bound) {
        if (typeof (_base = this.model).bind === "function") {
          _base.bind("change:" + this.ast.value, function(value) {
            return _this.update();
          });
        }
      }
    }

    Attribute.prototype.update = function() {
      var value;
      value = this.get();
      if (this.ast.name === 'value') {
        return this.element.value = value || '';
      } else if (value === void 0) {
        return this.element.removeAttribute(this.ast.name);
      } else {
        return this.element.setAttribute(this.ast.name, value);
      }
    };

    Attribute.prototype.get = function() {
      return Monkey.get(this.model, this.ast.value, this.ast.bound);
    };

    return Attribute;

  })();

  Monkey.Nodes.TextNode = (function() {

    function TextNode(ast, document, model, controller) {
      var _this = this;
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.textNode = document.createTextNode(this.get() || '');
      if (this.ast.bound) {
        if (typeof model.bind === "function") {
          model.bind("change:" + this.ast.value, function(value) {
            return _this.textNode.nodeValue = value || '';
          });
        }
      }
    }

    TextNode.prototype.append = function(inside) {
      return inside.appendChild(this.textNode);
    };

    TextNode.prototype.insertAfter = function(after) {
      return after.parentNode.insertBefore(this.textNode, after.nextSibling);
    };

    TextNode.prototype.remove = function() {
      return this.textNode.parentNode.removeChild(this.textNode);
    };

    TextNode.prototype.lastElement = function() {
      return this.textNode;
    };

    TextNode.prototype.get = function(model) {
      return Monkey.get(this.model, this.ast.value, this.ast.bound);
    };

    return TextNode;

  })();

  Monkey.Nodes.View = (function() {

    function View(ast, document, model, parentController) {
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.parentController = parentController;
      this.controller = Monkey.controllerFor(this.ast.arguments[0]);
      this.controller.parent = this.parentController;
      this.view = Monkey._views[this.ast.arguments[0]].render(this.document, this.model, this.controller);
    }

    View.prototype.append = function(inside) {
      return inside.appendChild(this.view);
    };

    View.prototype.insertAfter = function(after) {
      return after.parentNode.insertBefore(this.view, after.nextSibling);
    };

    View.prototype.remove = function() {
      return this.view.parentNode.removeChild(this.view);
    };

    View.prototype.lastElement = function() {
      return this.view;
    };

    return View;

  })();

  Monkey.Nodes.Collection = (function() {

    function Collection(ast, document, model, controller) {
      var _this = this;
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.anchor = document.createTextNode('');
      this.collection = this.get();
      if (this.collection.bind) {
        this.collection.bind('update', function() {
          return _this.rebuild();
        });
        this.collection.bind('set', function() {
          return _this.rebuild();
        });
        this.collection.bind('add', function(item) {
          return _this.appendItem(item);
        });
        this.collection.bind('delete', function(index) {
          return _this["delete"](index);
        });
      }
    }

    Collection.prototype.get = function() {
      return Monkey.get(this.model, this.ast.arguments[0]);
    };

    Collection.prototype.rebuild = function() {
      var item, _i, _len, _ref;
      _ref = this.items;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        item.remove();
      }
      return this.build();
    };

    Collection.prototype.build = function() {
      var _this = this;
      this.items = [];
      return Monkey.forEach(this.collection, function(item) {
        return _this.appendItem(item);
      });
    };

    Collection.prototype.appendItem = function(item) {
      var node;
      node = new Monkey.Nodes.CollectionItem(this.ast.children, this.document, item, this.controller);
      node.insertAfter(this.lastElement());
      return this.items.push(node);
    };

    Collection.prototype["delete"] = function(index) {
      this.items[index].remove();
      return this.items.splice(index, 1);
    };

    Collection.prototype.lastItem = function() {
      return this.items[this.items.length - 1];
    };

    Collection.prototype.lastElement = function() {
      var item;
      item = this.lastItem();
      if (item) {
        return item.lastElement();
      } else {
        return this.anchor;
      }
    };

    Collection.prototype.remove = function() {
      var item, _i, _len, _ref, _results;
      this.anchor.parentNode.removeChild(this.anchor);
      _ref = this.items;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _results.push(item.remove());
      }
      return _results;
    };

    Collection.prototype.append = function(inside) {
      inside.appendChild(this.anchor);
      return this.build();
    };

    Collection.prototype.insertAfter = function(after) {
      after.parentNode.insertBefore(this.anchor, after.nextSibling);
      return this.build();
    };

    Collection.prototype.get = function() {
      return Monkey.get(this.model, this.ast.arguments[0]);
    };

    return Collection;

  })();

  Monkey.Nodes.CollectionItem = (function() {

    function CollectionItem(children, document, model, controller) {
      var child;
      this.children = children;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.nodes = (function() {
        var _i, _len, _ref, _results;
        _ref = this.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          _results.push(Monkey.Nodes.compile(child, this.document, this.model, this.controller));
        }
        return _results;
      }).call(this);
    }

    CollectionItem.prototype.insertAfter = function(element) {
      var last, node, _i, _len, _ref, _results;
      last = element;
      _ref = this.nodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        node.insertAfter(last);
        _results.push(last = node.lastElement());
      }
      return _results;
    };

    CollectionItem.prototype.lastElement = function() {
      return this.nodes[this.nodes.length - 1].lastElement();
    };

    CollectionItem.prototype.remove = function() {
      var node, _i, _len, _ref, _results;
      _ref = this.nodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        _results.push(node.remove());
      }
      return _results;
    };

    return CollectionItem;

  })();

}).call(this);

};require['./parser'] = new function() {
  var exports = this;
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
};require['./properties'] = new function() {
  var exports = this;
  (function() {
  var Monkey, pairToObject,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Monkey = require('./monkey').Monkey;

  pairToObject = function(one, two) {
    var temp;
    temp = {};
    temp[one] = two;
    return temp;
  };

  Monkey.Properties = {
    property: function(name, options) {
      if (options == null) options = {};
      this.properties || (this.properties = {});
      this.properties[name] = options;
      return Object.defineProperty(this, name, {
        get: function() {
          return Monkey.Properties.get.call(this, name);
        },
        set: function(value) {
          return Monkey.Properties.set.call(this, name, value);
        }
      });
    },
    collection: function(name, options) {
      return this.property(name, {
        get: function() {
          var _this = this;
          if (!this.attributes[name]) {
            this.attributes[name] = new Monkey.Collection([]);
            this.attributes[name].bind('change', function() {
              return _this._triggerChangesTo(pairToObject(name, _this.get(name)));
            });
          }
          return this.attributes[name];
        },
        set: function(value) {
          return this.get(name).update(value);
        }
      });
    },
    set: function(attributes, value) {
      var name, _ref, _ref2;
      if (typeof attributes === 'string') {
        attributes = pairToObject(attributes, value);
      }
      for (name in attributes) {
        value = attributes[name];
        this.attributes || (this.attributes = {});
        if ((_ref = this.properties) != null ? (_ref2 = _ref[name]) != null ? _ref2.set : void 0 : void 0) {
          this.properties[name].set.call(this, value);
        } else {
          this.attributes[name] = value;
        }
      }
      return this._triggerChangesTo(attributes);
    },
    get: function(name) {
      var _ref, _ref2;
      this.attributes || (this.attributes = {});
      if ((_ref = this.properties) != null ? (_ref2 = _ref[name]) != null ? _ref2.get : void 0 : void 0) {
        return this.properties[name].get.call(this);
      } else {
        return this.attributes[name];
      }
    },
    _triggerChangesTo: function(attributes) {
      var dependencies, name, property, propertyName, value, _ref;
      for (name in attributes) {
        value = attributes[name];
        if (typeof this.trigger === "function") {
          this.trigger("change:" + name, value);
        }
        if (this.properties) {
          _ref = this.properties;
          for (propertyName in _ref) {
            property = _ref[propertyName];
            if (property.dependsOn) {
              dependencies = typeof property.dependsOn === 'string' ? [property.dependsOn] : property.dependsOn;
              if (__indexOf.call(dependencies, name) >= 0) {
                if (typeof this.trigger === "function") {
                  this.trigger("change:" + propertyName, this.get(propertyName));
                }
              }
            }
          }
        }
      }
      return typeof this.trigger === "function" ? this.trigger("change", attributes) : void 0;
    }
  };

}).call(this);

};require['./model'] = new function() {
  var exports = this;
  (function() {
  var Monkey;

  Monkey = require('./monkey').Monkey;

  Monkey.Model = (function() {

    Monkey.extend(Model.prototype, Monkey.Events);

    Monkey.extend(Model.prototype, Monkey.Properties);

    Model.property = function() {
      var _ref;
      return (_ref = this.prototype).property.apply(_ref, arguments);
    };

    Model.collection = function() {
      var _ref;
      return (_ref = this.prototype).collection.apply(_ref, arguments);
    };

    function Model(attributes) {
      this.set(attributes);
    }

    return Model;

  })();

}).call(this);

};require['./collection'] = new function() {
  var exports = this;
  (function() {
  var Monkey;

  Monkey = require('./monkey').Monkey;

  Monkey.Collection = (function() {

    Collection.prototype.collection = true;

    Monkey.extend(Collection.prototype, Monkey.Events);

    function Collection(list) {
      var _this = this;
      this.list = list;
      this.length = this.list.length;
      this.bind("change", function() {
        return _this.length = _this.list.length;
      });
    }

    Collection.prototype.get = function(index) {
      return this.list[index];
    };

    Collection.prototype.set = function(index, value) {
      this.list[index] = value;
      this.trigger("change:" + index, value);
      this.trigger("set", index, value);
      return this.trigger("change", this.list);
    };

    Collection.prototype.push = function(element) {
      this.list.push(element);
      this.trigger("add", element);
      return this.trigger("change", this.list);
    };

    Collection.prototype.update = function(list) {
      this.list = list;
      this.trigger("update", list);
      return this.trigger("change", this.list);
    };

    Collection.prototype.forEach = function(fun) {
      return Monkey.forEach(this.list, fun);
    };

    Collection.prototype.indexOf = function(item) {
      return this.list.indexOf(item);
    };

    Collection.prototype["delete"] = function(index) {
      this.list.splice(index, 1);
      this.trigger("delete", index);
      return this.trigger("change", this.list);
    };

    return Collection;

  })();

}).call(this);

};require['./view'] = new function() {
  var exports = this;
  (function() {
  var Monkey, parser;

  Monkey = require('./monkey').Monkey;

  parser = require('./parser').parser;

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

  parser.yy = {
    Monkey: Monkey
  };

  Monkey.View = (function() {

    function View(string) {
      this.string = string;
    }

    View.prototype.parse = function() {
      return parser.parse(new Monkey.Lexer().tokenize(this.string));
    };

    View.prototype.render = function(document, model, controller) {
      var node;
      node = Monkey.Nodes.compile(this.parse(), document, model, controller);
      controller.model = model;
      return controller.view = node.element;
    };

    return View;

  })();

}).call(this);

};
    return require['./monkey'].Monkey
  }();

  if(typeof define === 'function' && define.amd) {
    define(function() { return Monkey });
  } else { root.Monkey = Monkey }
}(this));