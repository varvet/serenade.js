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
        _results.push(Object.prototype.hasOwnProperty.call(source, key) ? target[key] = value : void 0);
      }
      return _results;
    },
    document: typeof window != "undefined" && window !== null ? window.document : void 0,
    get: function(model, value, bound) {
      if (bound == null) {
        bound = true;
      }
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
  var Monkey;
  var __slice = Array.prototype.slice;
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
      if (!list) {
        return false;
      }
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
      if (!list) {
        return this;
      }
      if (!callback) {
        delete this._callbacks[ev];
        return this;
      }
      for (i = 0, _len = list.length; i < _len; i++) {
        cb = list[i];
        if (cb === callback) {
          list = list.slice();
          list.splice(i, 1);
          this._callbacks[ev] = list;
          break;
        }
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
  LITERAL = /^[\[\]=-]/;
  STRING = /^"((?:\\.|[^"])*)"/;
  MULTI_DENT = /^(?:\n[^\n\S]*)+/;
  WHITESPACE = /^[^\n\S]+/;
  Monkey.Lexer = (function() {
    function Lexer() {}
    Lexer.prototype.tokenize = function(code, opts) {
      var i, tag;
      if (opts == null) {
        opts = {};
      }
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
      if (!(match = MULTI_DENT.exec(this.chunk))) {
        return 0;
      }
      indent = match[0];
      this.line += this.count(indent, '\n');
      prev = this.last(this.tokens, 1);
      size = indent.length - 1 - indent.lastIndexOf('\n');
      if (size === this.indent) {
        this.newlineToken();
      } else if (size > this.indent) {
        diff = size - this.indent;
        this.token('INDENT', diff);
        this.ends.push('OUTDENT');
      } else {
        if (this.last(this.ends) !== 'OUTDENT') {
          this.error('Should be an OUTDENT, yo');
        }
        this.ends.pop;
        this.token('OUTDENT', diff);
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
        }
        return 1;
      } else {
        return this.error("WUT??? is '" + (this.chunk.charAt(0)) + "'");
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
      throw SyntaxError("" + message + " on line " + (this.line + 1));
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
}).call(this);

};require['./nodes'] = new function() {
  var exports = this;
  (function() {
  var EVENTS, Monkey;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  Monkey = require('./monkey').Monkey;
  EVENTS = ['click', 'blur', 'focus', 'change', 'mouseover', 'mouseout', 'submit'];
  Monkey.AST = {};
  Monkey.Nodes = {};
  Monkey.AST.Element = (function() {
    Element.prototype.type = 'element';
    function Element(name, attributes, children) {
      this.name = name;
      this.attributes = attributes;
      this.children = children;
      this.attributes || (this.attributes = []);
      this.children || (this.children = []);
    }
    Element.prototype.compile = function(document, model, controller) {
      return new Monkey.Nodes.Element(this, document, model, controller);
    };
    return Element;
  })();
  Monkey.Nodes.Element = (function() {
    function Element(ast, document, model, controller) {
      var attribute, child, _i, _j, _len, _len2, _ref, _ref2;
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.element = this.document.createElement(this.ast.name);
      _ref = this.ast.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attribute = _ref[_i];
        attribute.compile(this.document, this.model, this.controller).apply(this.element);
      }
      _ref2 = this.ast.children;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        child = _ref2[_j];
        child.compile(this.document, this.model, this.controller).append(this.element);
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
  Monkey.AST.Attribute = (function() {
    function Attribute(name, value, bound) {
      this.name = name;
      this.value = value;
      this.bound = bound;
    }
    Attribute.prototype.compile = function(document, model, controller) {
      return new Monkey.Nodes.Attribute(this, document, model, controller);
    };
    return Attribute;
  })();
  Monkey.Nodes.Attribute = (function() {
    function Attribute(ast, document, model, controller) {
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
    }
    Attribute.prototype.updateAttribute = function(element, value) {
      if (this.ast.name === 'value') {
        return element.value = value || '';
      } else if (value === void 0) {
        return element.removeAttribute(this.ast.name);
      } else {
        return element.setAttribute(this.ast.name, value);
      }
    };
    Attribute.prototype.updateStyle = function(element, name, value) {
      return element.style[name] = value;
    };
    Attribute.prototype.attribute = function(element) {
      var _base;
      this.updateAttribute(element, this.get());
      if (this.ast.bound) {
        return typeof (_base = this.model).bind == "function" ? _base.bind("change:" + this.ast.value, __bind(function(value) {
          return this.updateAttribute(element, value);
        }, this)) : void 0;
      }
    };
    Attribute.prototype.event = function(element, name) {
      var callback;
      callback = __bind(function(e) {
        return this.controller[this.ast.value](e);
      }, this);
      return element.addEventListener(name, callback, false);
    };
    Attribute.prototype.style = function(element, name) {
      var _base;
      this.updateStyle(element, name, this.get());
      if (this.ast.bound) {
        return typeof (_base = this.model).bind == "function" ? _base.bind("change:" + this.ast.value, __bind(function(value) {
          return this.updateStyle(element, name, value);
        }, this)) : void 0;
      }
    };
    Attribute.prototype.apply = function(element) {
      var _ref;
      if (_ref = this.ast.name, __indexOf.call(EVENTS, _ref) >= 0) {
        return this.event(element, this.ast.name);
      } else if (this.ast.name.match(/^event-/)) {
        return this.event(element, this.ast.name.replace(/^event-/, ''));
      } else if (this.ast.name.match(/^style-/)) {
        return this.style(element, this.ast.name.replace(/^style-/, ''));
      } else {
        return this.attribute(element);
      }
    };
    Attribute.prototype.get = function() {
      return Monkey.get(this.model, this.ast.value, this.ast.bound);
    };
    return Attribute;
  })();
  Monkey.AST.TextNode = (function() {
    function TextNode(value, bound) {
      this.value = value;
      this.bound = bound;
    }
    TextNode.prototype.name = 'text';
    TextNode.prototype.compile = function(document, model, controller) {
      return new Monkey.Nodes.TextNode(this, document, model, controller);
    };
    return TextNode;
  })();
  Monkey.Nodes.TextNode = (function() {
    function TextNode(ast, document, model, controller) {
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.textNode = document.createTextNode(this.get() || '');
      if (this.ast.bound) {
        if (typeof model.bind == "function") {
          model.bind("change:" + this.ast.value, __bind(function(value) {
            return this.textNode.nodeValue = value || '';
          }, this));
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
  Monkey.AST.Instruction = (function() {
    Instruction.prototype.type = 'instruction';
    function Instruction(command, arguments, children) {
      this.command = command;
      this.arguments = arguments;
      this.children = children;
    }
    Instruction.prototype.compile = function(document, model, controller) {
      switch (this.command) {
        case "view":
          return new Monkey.Nodes.View(this, document, model, controller);
        case "collection":
          return new Monkey.Nodes.Collection(this, document, model, controller);
      }
    };
    return Instruction;
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
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.anchor = document.createTextNode('');
      this.collection = this.get();
      if (this.collection.bind) {
        this.collection.bind('update', __bind(function() {
          return this.rebuild();
        }, this));
        this.collection.bind('set', __bind(function() {
          return this.rebuild();
        }, this));
        this.collection.bind('add', __bind(function(item) {
          return this.appendItem(item);
        }, this));
        this.collection.bind('delete', __bind(function(index) {
          return this["delete"](index);
        }, this));
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
      this.items = [];
      return Monkey.forEach(this.collection, __bind(function(item) {
        return this.appendItem(item);
      }, this));
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
          _results.push(child.compile(this.document, this.model, this.controller));
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
case 3:this.$ = new yy.Monkey.AST.Element($$[$0-1], $$[$0]);
break;
case 4:this.$ = new yy.Monkey.AST.Element($$[$0-4], $$[$0-3], $$[$0-1]);
break;
case 5:this.$ = new yy.Monkey.AST.Element($$[$0-3], $$[$0-2], $$[$0]);
break;
case 6:this.$ = [$$[$0]];
break;
case 7:this.$ = $$[$0-2].concat($$[$0]);
break;
case 8:this.$ = new yy.Monkey.AST.TextNode($$[$0], true);
break;
case 9:this.$ = new yy.Monkey.AST.TextNode($$[$0], false);
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
case 15:this.$ = new yy.Monkey.AST.TextNode($$[$0], false);
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
case 21:this.$ = new yy.Monkey.AST.Attribute($$[$0-2], $$[$0], true);
break;
case 22:this.$ = new yy.Monkey.AST.Attribute($$[$0-2], $$[$0], false);
break;
case 23:this.$ = new yy.Monkey.AST.Instruction($$[$0-2], $$[$0]);
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
};require['./properties'] = new function() {
  var exports = this;
  (function() {
  var Monkey, pairToObject;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  Monkey = require('./monkey').Monkey;
  pairToObject = function(one, two) {
    var temp;
    temp = {};
    temp[one] = two;
    return temp;
  };
  Monkey.Properties = {
    property: function(name, options) {
      if (options == null) {
        options = {};
      }
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
          if (!this.attributes[name]) {
            this.attributes[name] = new Monkey.Collection([]);
            this.attributes[name].bind('change', __bind(function() {
              return this._triggerChangesTo(pairToObject(name, this.get(name)));
            }, this));
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
        if (typeof this.trigger == "function") {
          this.trigger("change:" + name, value);
        }
        if (this.properties) {
          _ref = this.properties;
          for (propertyName in _ref) {
            property = _ref[propertyName];
            if (property.dependsOn) {
              dependencies = typeof property.dependsOn === 'string' ? [property.dependsOn] : property.dependsOn;
              if (__indexOf.call(dependencies, name) >= 0) {
                if (typeof this.trigger == "function") {
                  this.trigger("change:" + propertyName, this.get(propertyName));
                }
              }
            }
          }
        }
      }
      return typeof this.trigger == "function" ? this.trigger("change", attributes) : void 0;
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
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Monkey = require('./monkey').Monkey;
  Monkey.Collection = (function() {
    Collection.prototype.collection = true;
    Monkey.extend(Collection.prototype, Monkey.Events);
    function Collection(list) {
      this.list = list;
      this.length = this.list.length;
      this.bind("change", __bind(function() {
        return this.length = this.list.length;
      }, this));
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
      node = this.parse().compile(document, model, controller);
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