/**
 * Serenade.js JavaScript Framework v0.1.0
 * http://github.com/elabs/serenade.js
 *
 * Copyright 2011, Jonas Nicklas
 * Released under the MIT License
 */
(function(root) {
  var Serenade = function() {
    function require(path){ return require[path]; }
    require['./events'] = new function() {
  var exports = this;
  (function() {
  var __slice = Array.prototype.slice;

  exports.Events = {
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
      if (typeof recordEvents !== "undefined" && recordEvents !== null) {
        this._triggeredEvents || (this._triggeredEvents = {});
        this._triggeredEvents[ev] = args;
      }
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

};require['./helpers'] = new function() {
  var exports = this;
  (function() {
  var Helpers;

  Helpers = {
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
    get: function(model, value, bound) {
      if (bound == null) bound = true;
      if (bound && (model != null ? model.get : void 0)) {
        return model.get(value);
      } else if (bound) {
        return model != null ? model[value] : void 0;
      } else {
        return value;
      }
    },
    format: function(model, value, bound) {
      if (bound == null) bound = true;
      if (bound && model.format) {
        return model.format(value);
      } else {
        return Helpers.get(model, value, bound);
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
    },
    map: function(collection, fun) {
      var element, _i, _len, _results;
      if (typeof collection.map === 'function') {
        return collection.map(fun);
      } else {
        _results = [];
        for (_i = 0, _len = collection.length; _i < _len; _i++) {
          element = collection[_i];
          _results.push(fun(element));
        }
        return _results;
      }
    },
    isArray: function(object) {
      return toString.call(object) === "[object Array]";
    },
    pairToObject: function(one, two) {
      var temp;
      temp = {};
      temp[one] = two;
      return temp;
    },
    serializeObject: function(object) {
      if (object && typeof object.serialize === 'function') {
        return object.serialize();
      } else if (Helpers.isArray(object)) {
        return Helpers.map(object, function(item) {
          return Helpers.serializeObject(item);
        });
      } else {
        return object;
      }
    },
    deleteItem: function(arr, item) {
      return arr.splice(arr.indexOf(item), 1);
    },
    getFunctionName: function(fun) {
      return fun.name;
    }
  };

  Helpers.extend(exports, Helpers);

}).call(this);

};require['./cache'] = new function() {
  var exports = this;
  (function() {
  var Cache, getFunctionName, serializeObject, _ref;

  _ref = require('./helpers'), serializeObject = _ref.serializeObject, getFunctionName = _ref.getFunctionName;

  Cache = {
    _storage: typeof window !== "undefined" && window !== null ? window.localStorage : void 0,
    _identityMap: {},
    get: function(ctor, id) {
      var name, _ref2;
      name = getFunctionName(ctor);
      if (name && id) {
        return ((_ref2 = this._identityMap[name]) != null ? _ref2[id] : void 0) || this.retrieve(ctor, id);
      }
    },
    set: function(ctor, id, obj) {
      var name, _base;
      name = getFunctionName(ctor);
      if (name && id) {
        (_base = this._identityMap)[name] || (_base[name] = {});
        return this._identityMap[name][id] = obj;
      }
    },
    store: function(ctor, id, obj) {
      var name;
      name = getFunctionName(ctor);
      if (name && id) {
        return this._storage.setItem("" + name + "_" + id, JSON.stringify(serializeObject(obj)));
      }
    },
    retrieve: function(ctor, id) {
      var data, name;
      name = getFunctionName(ctor);
      if (name && id && ctor.localStorage) {
        data = this._storage.getItem("" + name + "_" + id);
        if (data) return new ctor(JSON.parse(data), true);
      }
    }
  };

  exports.Cache = Cache;

}).call(this);

};require['./collection'] = new function() {
  var exports = this;
  (function() {
  var Events, deleteItem, extend, forEach, serializeObject, _ref;

  Events = require('./events').Events;

  _ref = require('./helpers'), extend = _ref.extend, forEach = _ref.forEach, serializeObject = _ref.serializeObject, deleteItem = _ref.deleteItem;

  exports.Collection = (function() {

    extend(Collection.prototype, Events);

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
      this._notIn(this.list[index]);
      this.list[index] = value;
      this._in(value);
      this.trigger("change:" + index, value);
      this.trigger("set", index, value);
      return this.trigger("change", this.list);
    };

    Collection.prototype.push = function(element) {
      this.list.push(element);
      this._in(element);
      this.trigger("add", element);
      return this.trigger("change", this.list);
    };

    Collection.prototype.update = function(list) {
      var element, _i, _j, _len, _len2, _ref2;
      _ref2 = this.list;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        element = _ref2[_i];
        this._notIn(element);
      }
      this.list = list;
      for (_j = 0, _len2 = list.length; _j < _len2; _j++) {
        element = list[_j];
        this._in(element);
      }
      this.trigger("update", list);
      return this.trigger("change", this.list);
    };

    Collection.prototype.forEach = function(fun) {
      return forEach(this.list, fun);
    };

    Collection.prototype.map = function(fun) {
      var item, _i, _len, _ref2, _results;
      _ref2 = this.list;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        item = _ref2[_i];
        _results.push(fun(item));
      }
      return _results;
    };

    Collection.prototype.indexOf = function(item) {
      return this.list.indexOf(item);
    };

    Collection.prototype.deleteAt = function(index) {
      this._notIn(this.list[index]);
      this.list.splice(index, 1);
      this.trigger("delete", index);
      return this.trigger("change", this.list);
    };

    Collection.prototype["delete"] = function(item) {
      return this.deleteAt(this.indexOf(item));
    };

    Collection.prototype.serialize = function() {
      return serializeObject(this.list);
    };

    Collection.prototype.select = function(fun) {
      var item, _i, _len, _ref2, _results;
      _ref2 = this.list;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        item = _ref2[_i];
        if (fun(item)) _results.push(item);
      }
      return _results;
    };

    Collection.prototype._in = function(item) {
      var _ref2;
      if (typeof item === 'object') {
        item._inCollections || (item._inCollections = []);
        return (_ref2 = item._inCollections) != null ? _ref2.push(this) : void 0;
      }
    };

    Collection.prototype._notIn = function(item) {
      if (item != null ? item._inCollections : void 0) {
        return deleteItem(item._inCollections, this);
      }
    };

    return Collection;

  })();

}).call(this);

};require['./association_collection'] = new function() {
  var exports = this;
  (function() {
  var AssociationCollection, Collection,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Collection = require('./collection').Collection;

  AssociationCollection = (function(_super) {

    __extends(AssociationCollection, _super);

    function AssociationCollection(ctor, list) {
      this.ctor = ctor;
      this.list = list;
      AssociationCollection.__super__.constructor.call(this, this.list);
    }

    AssociationCollection.prototype.set = function(index, item) {
      return AssociationCollection.__super__.set.call(this, index, this._convert(item));
    };

    AssociationCollection.prototype.push = function(item) {
      return AssociationCollection.__super__.push.call(this, this._convert(item));
    };

    AssociationCollection.prototype.update = function(list) {
      var item;
      return AssociationCollection.__super__.update.call(this, (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          item = list[_i];
          _results.push(this._convert(item));
        }
        return _results;
      }).call(this));
    };

    AssociationCollection.prototype._convert = function(item) {
      var ctor;
      ctor = this.ctor();
      if (item.constructor === ctor) {
        return item;
      } else {
        return new ctor(item);
      }
    };

    return AssociationCollection;

  })(Collection);

  exports.AssociationCollection = AssociationCollection;

}).call(this);

};require['./associations'] = new function() {
  var exports = this;
  (function() {
  var AssociationCollection, Associations, Collection, extend, get, map, _ref;

  AssociationCollection = require('./association_collection').AssociationCollection;

  Collection = require('./collection').Collection;

  _ref = require('./helpers'), extend = _ref.extend, map = _ref.map, get = _ref.get;

  Associations = (function() {

    function Associations() {}

    Associations.belongsTo = function(name, attributes) {
      var ctor;
      if (attributes == null) attributes = {};
      ctor = attributes.as || (function() {
        return Object;
      });
      extend(attributes, {
        set: function(properties) {
          return this.attributes[name] = new (ctor())(properties);
        }
      });
      this.property(name, attributes);
      return this.property(name + 'Id', {
        get: function() {
          return get(this.get(name), 'id');
        },
        set: function(id) {
          return this.attributes[name] = ctor().find(id);
        },
        dependsOn: name
      });
    };

    Associations.hasMany = function(name, attributes) {
      var ctor;
      if (attributes == null) attributes = {};
      ctor = attributes.as || (function() {
        return Object;
      });
      extend(attributes, {
        get: function() {
          var _this = this;
          if (!this.attributes[name]) {
            this.attributes[name] = new AssociationCollection(ctor, []);
            this.attributes[name].bind('change', function() {
              return _this._triggerChangesTo([name]);
            });
          }
          return this.attributes[name];
        },
        set: function(value) {
          return this.get(name).update(value);
        }
      });
      this.property(name, attributes);
      return this.property(name + 'Ids', {
        get: function() {
          return new Collection(this.get(name).map(function(item) {
            return get(item, 'id');
          }));
        },
        set: function(ids) {
          var objects;
          objects = map(ids, function(id) {
            return ctor().find(id);
          });
          return this.attributes[name] = new AssociationCollection(ctor, objects);
        },
        dependsOn: name
      });
    };

    return Associations;

  })();

  exports.Associations = Associations;

}).call(this);

};require['./serenade'] = new function() {
  var exports = this;
  (function() {
  var Cache, Serenade;

  Cache = require('./cache').Cache;

  Serenade = {
    VERSION: '0.1.0',
    _views: {},
    _controllers: {},
    _formats: {},
    registerView: function(name, template) {
      var View;
      View = require('./view').View;
      return this._views[name] = new View(template);
    },
    render: function(name, model, controller, document) {
      if (document == null) {
        document = typeof window !== "undefined" && window !== null ? window.document : void 0;
      }
      controller || (controller = this.controllerFor(name, model));
      return this._views[name].render(document, model, controller);
    },
    registerController: function(name, klass) {
      return this._controllers[name] = klass;
    },
    controllerFor: function(name, model) {
      if (this._controllers[name]) return new this._controllers[name](model);
    },
    registerFormat: function(name, fun) {
      return this._formats[name] = fun;
    },
    clearIdentityMap: function() {
      return Cache._identityMap = {};
    },
    clearLocalStorage: function() {
      return Cache._storage.clear();
    },
    clearCache: function() {
      Serenade.clearIdentityMap();
      return Serenade.clearLocalStorage();
    },
    unregisterAll: function() {
      Serenade._views = {};
      Serenade._controllers = {};
      return Serenade._formats = {};
    },
    Events: require('./events').Events,
    Collection: require('./collection').Collection,
    Helpers: {}
  };

  exports.Serenade = Serenade;

  exports.compile = function() {
    var document, fs, window;
    document = require("jsdom").jsdom(null, null, {});
    fs = require("fs");
    window = document.createWindow();
    return function(env) {
      var element, model, viewName;
      model = env.model;
      viewName = env.filename.split('/').reverse()[0].replace(/\.serenade$/, '');
      Serenade.registerView(viewName, fs.readFileSync(env.filename).toString());
      element = Serenade.render(viewName, model, {}, document);
      document.body.appendChild(element);
      return document.body.innerHTML;
    };
  };

}).call(this);

};require['./lexer'] = new function() {
  var exports = this;
  (function() {
  var IDENTIFIER, LITERAL, Lexer, MULTI_DENT, STRING, WHITESPACE;

  IDENTIFIER = /^[a-zA-Z][a-zA-Z0-9\-]*/;

  LITERAL = /^[\[\]=\:\-!#\.]/;

  STRING = /^"((?:\\.|[^"])*)"/;

  MULTI_DENT = /^(?:\n[^\n\S]*)+/;

  WHITESPACE = /^[^\n\S]+/;

  Lexer = (function() {

    function Lexer() {}

    Lexer.prototype.tokenize = function(code, opts) {
      var i, tag;
      if (opts == null) opts = {};
      this.code = code;
      this.line = opts.line || 0;
      this.indent = 0;
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
      var match;
      if (match = LITERAL.exec(this.chunk)) {
        this.token(match[0]);
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

  exports.Lexer = Lexer;

}).call(this);

};require['./nodes'] = new function() {
  var exports = this;
  (function() {
  var Attribute, Collection, CollectionItem, Event, Helper, If, In, Node, Nodes, Serenade, Style, TextNode, View, forEach, format, get, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Serenade = require('./serenade').Serenade;

  _ref = require('./helpers'), format = _ref.format, get = _ref.get, forEach = _ref.forEach;

  Node = (function() {

    function Node(ast, document, model, controller) {
      var child, property, _i, _j, _len, _len2, _ref2, _ref3, _ref4;
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.element = this.document.createElement(this.ast.name);
      if (this.ast.shortId) this.element.setAttribute('id', this.ast.shortId);
      if ((_ref2 = this.ast.shortClasses) != null ? _ref2.length : void 0) {
        this.element.setAttribute('class', this.ast.shortClasses.join(' '));
      }
      _ref3 = this.ast.properties;
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        property = _ref3[_i];
        Nodes.property(property, this, this.document, this.model, this.controller);
      }
      _ref4 = this.ast.children;
      for (_j = 0, _len2 = _ref4.length; _j < _len2; _j++) {
        child = _ref4[_j];
        Nodes.compile(child, this.document, this.model, this.controller).append(this.element);
      }
    }

    Node.prototype.append = function(inside) {
      return inside.appendChild(this.element);
    };

    Node.prototype.insertAfter = function(after) {
      return after.parentNode.insertBefore(this.element, after.nextSibling);
    };

    Node.prototype.remove = function() {
      return this.element.parentNode.removeChild(this.element);
    };

    Node.prototype.lastElement = function() {
      return this.element;
    };

    return Node;

  })();

  Style = (function() {

    function Style(ast, node, document, model, controller) {
      var _base,
        _this = this;
      this.ast = ast;
      this.node = node;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.element = this.node.element;
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
      return format(this.model, this.ast.value, this.ast.bound);
    };

    return Style;

  })();

  Event = (function() {

    function Event(ast, node, document, model, controller) {
      var callback, self;
      this.ast = ast;
      this.node = node;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.element = this.node.element;
      self = this;
      callback = function(e) {
        if (self.ast.preventDefault) e.preventDefault();
        return self.controller[self.ast.value](e);
      };
      this.element.addEventListener(this.ast.name, callback, false);
    }

    return Event;

  })();

  Attribute = (function() {

    function Attribute(ast, node, document, model, controller) {
      var _base,
        _this = this;
      this.ast = ast;
      this.node = node;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.element = this.node.element;
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
      var classes, value;
      value = this.get();
      if (this.ast.name === 'value') {
        return this.element.value = value || '';
      } else if (this.node.ast.name === 'input' && this.ast.name === 'checked') {
        return this.element.checked = !!value;
      } else if (this.ast.name === 'class') {
        classes = this.node.ast.shortClasses;
        if (value !== void 0) classes = classes.concat(value);
        if (classes.length) {
          return this.element.setAttribute(this.ast.name, classes.join(' '));
        } else {
          return this.element.removeAttribute(this.ast.name);
        }
      } else if (value === void 0) {
        return this.element.removeAttribute(this.ast.name);
      } else {
        return this.element.setAttribute(this.ast.name, value);
      }
    };

    Attribute.prototype.get = function() {
      return format(this.model, this.ast.value, this.ast.bound);
    };

    return Attribute;

  })();

  TextNode = (function() {

    function TextNode(ast, document, model, controller) {
      var _this = this;
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.textNode = document.createTextNode(this.get());
      if (this.ast.bound) {
        if (typeof model.bind === "function") {
          model.bind("change:" + this.ast.value, function() {
            return _this.textNode.nodeValue = _this.get();
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

    TextNode.prototype.get = function() {
      return format(this.model, this.ast.value, this.ast.bound) || '';
    };

    return TextNode;

  })();

  View = (function() {

    function View(ast, document, model, parentController) {
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.parentController = parentController;
      this.controller = Serenade.controllerFor(this.ast.arguments[0], this.model);
      if (this.controller) this.controller.parent = this.parentController;
      this.view = Serenade.render(this.ast.arguments[0], this.model, this.controller || this.parentController, this.document);
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

  If = (function() {

    function If(ast, document, model, controller) {
      var _base;
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.build = __bind(this.build, this);
      this.anchor = document.createTextNode('');
      if (typeof (_base = this.model).bind === "function") {
        _base.bind("change:" + this.ast.arguments[0], this.build);
      }
    }

    If.prototype.build = function() {
      var child, i, node, _len, _ref2, _results;
      if (get(this.model, this.ast.arguments[0])) {
        this.nodes || (this.nodes = (function() {
          var _i, _len, _ref2, _results;
          _ref2 = this.ast.children;
          _results = [];
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            child = _ref2[_i];
            _results.push(Nodes.compile(child, this.document, this.model, this.controller));
          }
          return _results;
        }).call(this));
        _ref2 = this.nodes;
        _results = [];
        for (i = 0, _len = _ref2.length; i < _len; i++) {
          node = _ref2[i];
          _results.push(node.insertAfter(this.nodes[i - 1] || this.anchor));
        }
        return _results;
      } else {
        return this.removeNodes();
      }
    };

    If.prototype.append = function(inside) {
      inside.appendChild(this.anchor);
      return this.build();
    };

    If.prototype.insertAfter = function(after) {
      after.parentNode.insertBefore(this.anchor, after.nextSibling);
      return this.build();
    };

    If.prototype.remove = function() {
      this.removeNodes();
      return this.anchor.parentNode.removeChild(this.anchor);
    };

    If.prototype.removeNodes = function() {
      var node, _i, _len, _ref2;
      if (this.nodes) {
        _ref2 = this.nodes;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          node = _ref2[_i];
          node.remove();
        }
      }
      return this.nodes = void 0;
    };

    If.prototype.lastElement = function() {
      return this.nodes[this.nodes.length - 1].lastElement();
    };

    return If;

  })();

  In = (function() {

    function In(ast, document, model, controller) {
      var _base;
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.build = __bind(this.build, this);
      this.anchor = document.createTextNode('');
      if (typeof (_base = this.model).bind === "function") {
        _base.bind("change:" + this.ast.arguments[0], this.build);
      }
    }

    In.prototype.build = function() {
      var child, i, node, subModel, _len, _ref2, _results;
      this.removeNodes();
      subModel = get(this.model, this.ast.arguments[0]);
      this.nodes = (function() {
        var _i, _len, _ref2, _results;
        _ref2 = this.ast.children;
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          child = _ref2[_i];
          _results.push(Nodes.compile(child, this.document, subModel, this.controller));
        }
        return _results;
      }).call(this);
      _ref2 = this.nodes;
      _results = [];
      for (i = 0, _len = _ref2.length; i < _len; i++) {
        node = _ref2[i];
        _results.push(node.insertAfter(this.nodes[i - 1] || this.anchor));
      }
      return _results;
    };

    In.prototype.append = function(inside) {
      inside.appendChild(this.anchor);
      return this.build();
    };

    In.prototype.insertAfter = function(after) {
      after.parentNode.insertBefore(this.anchor, after.nextSibling);
      return this.build();
    };

    In.prototype.remove = function() {
      this.removeNodes();
      return this.anchor.parentNode.removeChild(this.anchor);
    };

    In.prototype.removeNodes = function() {
      var node, _i, _len, _ref2;
      if (this.nodes) {
        _ref2 = this.nodes;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          node = _ref2[_i];
          node.remove();
        }
      }
      return this.nodes = void 0;
    };

    In.prototype.lastElement = function() {
      return this.nodes[this.nodes.length - 1].lastElement();
    };

    return In;

  })();

  Collection = (function() {

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

    Collection.prototype.rebuild = function() {
      var item, _i, _len, _ref2;
      _ref2 = this.items;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        item = _ref2[_i];
        item.remove();
      }
      return this.build();
    };

    Collection.prototype.build = function() {
      var _this = this;
      this.items = [];
      return forEach(this.collection, function(item) {
        return _this.appendItem(item);
      });
    };

    Collection.prototype.appendItem = function(item) {
      var node;
      node = new CollectionItem(this.ast.children, this.document, item, this.controller);
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
      var item, _i, _len, _ref2, _results;
      this.anchor.parentNode.removeChild(this.anchor);
      _ref2 = this.items;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        item = _ref2[_i];
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
      return get(this.model, this.ast.arguments[0]);
    };

    return Collection;

  })();

  Helper = (function() {

    function Helper(ast, document, model, controller) {
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.render = __bind(this.render, this);
      this.helperFunction = Serenade.Helpers[this.ast.command] || (function() {
        throw SyntaxError("no helper " + this.ast.command + " defined");
      }).call(this);
      this.context = {
        document: this.document,
        render: this.render,
        model: this.model,
        controller: this.controller
      };
      this.element = this.helperFunction.apply(this.context, this.ast.arguments);
    }

    Helper.prototype.render = function(element, model, controller) {
      var child, node, _i, _len, _ref2, _results;
      if (model == null) model = this.model;
      if (controller == null) controller = this.controller;
      _ref2 = this.ast.children;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        child = _ref2[_i];
        node = Nodes.compile(child, this.document, model, controller);
        _results.push(node.append(element));
      }
      return _results;
    };

    Helper.prototype.lastElement = function() {
      var item;
      item = this.lastItem();
      if (item) {
        return item.lastElement();
      } else {
        return this.anchor;
      }
    };

    Helper.prototype.remove = function() {
      var item, _i, _len, _ref2, _results;
      this.element.parentNode.removeChild(this.element);
      _ref2 = this.items;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        item = _ref2[_i];
        _results.push(item.remove());
      }
      return _results;
    };

    Helper.prototype.append = function(inside) {
      return inside.appendChild(this.element);
    };

    Helper.prototype.insertAfter = function(after) {
      return after.parentNode.insertBefore(this.element, after.nextSibling);
    };

    return Helper;

  })();

  CollectionItem = (function() {

    function CollectionItem(children, document, model, controller) {
      var child;
      this.children = children;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.nodes = (function() {
        var _i, _len, _ref2, _results;
        _ref2 = this.children;
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          child = _ref2[_i];
          _results.push(Nodes.compile(child, this.document, this.model, this.controller));
        }
        return _results;
      }).call(this);
    }

    CollectionItem.prototype.insertAfter = function(element) {
      var last, node, _i, _len, _ref2, _results;
      last = element;
      _ref2 = this.nodes;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        node = _ref2[_i];
        node.insertAfter(last);
        _results.push(last = node.lastElement());
      }
      return _results;
    };

    CollectionItem.prototype.lastElement = function() {
      return this.nodes[this.nodes.length - 1].lastElement();
    };

    CollectionItem.prototype.remove = function() {
      var node, _i, _len, _ref2, _results;
      _ref2 = this.nodes;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        node = _ref2[_i];
        _results.push(node.remove());
      }
      return _results;
    };

    return CollectionItem;

  })();

  Nodes = {
    compile: function(ast, document, model, controller) {
      switch (ast.type) {
        case 'element':
          return new Node(ast, document, model, controller);
        case 'text':
          return new TextNode(ast, document, model, controller);
        case 'instruction':
          switch (ast.command) {
            case "view":
              return new View(ast, document, model, controller);
            case "collection":
              return new Collection(ast, document, model, controller);
            case "if":
              return new If(ast, document, model, controller);
            case "in":
              return new In(ast, document, model, controller);
            default:
              return new Helper(ast, document, model, controller);
          }
          break;
        default:
          throw SyntaxError("unknown type '" + ast.type + "'");
      }
    },
    property: function(ast, node, document, model, controller) {
      switch (ast.scope) {
        case "attribute":
          return new Attribute(ast, node, document, model, controller);
        case "style":
          return new Style(ast, node, document, model, controller);
        case "event":
          return new Event(ast, node, document, model, controller);
        default:
          throw SyntaxError("" + ast.scope + " is not a valid scope");
      }
    }
  };

  exports.Nodes = Nodes;

}).call(this);

};require['./parser'] = new function() {
  var exports = this;
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
};require['./properties'] = new function() {
  var exports = this;
  (function() {
  var Collection, Events, Serenade, exp, extend, map, pairToObject, prexix, serializeObject, _ref,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Serenade = require('./serenade').Serenade;

  Collection = require('./collection').Collection;

  Events = require('./events').Events;

  _ref = require('./helpers'), pairToObject = _ref.pairToObject, serializeObject = _ref.serializeObject, extend = _ref.extend, map = _ref.map;

  prexix = "_prop_";

  exp = /^_prop_/;

  Serenade.Properties = {
    property: function(name, options) {
      if (options == null) options = {};
      this[prexix + name] = options;
      this[prexix + name].name = name;
      Object.defineProperty(this, name, {
        get: function() {
          return Serenade.Properties.get.call(this, name);
        },
        set: function(value) {
          return Serenade.Properties.set.call(this, name, value);
        }
      });
      if (typeof options.serialize === 'string') {
        return this.property(options.serialize, {
          get: (function() {
            return this.get(name);
          }),
          set: (function(v) {
            return this.set(name, v);
          })
        });
      }
    },
    collection: function(name, options) {
      return this.property(name, {
        get: function() {
          var _this = this;
          if (!this.attributes[name]) {
            this.attributes[name] = new Collection([]);
            this.attributes[name].bind('change', function() {
              return _this._triggerChangesTo([name]);
            });
            this.attributes[name]._deferTo = pairToObject(name, this);
          }
          return this.attributes[name];
        },
        set: function(value) {
          return this.get(name).update(value);
        }
      });
    },
    set: function(attributes, value) {
      var name, names, _ref2;
      if (typeof attributes === 'string') {
        attributes = pairToObject(attributes, value);
      }
      names = [];
      for (name in attributes) {
        value = attributes[name];
        this._undefer(name);
        names.push(name);
        this.attributes || (this.attributes = {});
        if ((_ref2 = this[prexix + name]) != null ? _ref2.set : void 0) {
          this[prexix + name].set.call(this, value);
        } else {
          this.attributes[name] = value;
        }
        this._defer(name);
      }
      return this._triggerChangesTo(names);
    },
    get: function(name) {
      var _ref2;
      this.attributes || (this.attributes = {});
      if ((_ref2 = this[prexix + name]) != null ? _ref2.get : void 0) {
        return this[prexix + name].get.call(this);
      } else {
        return this.attributes[name];
      }
    },
    format: function(name) {
      var format, _ref2;
      format = (_ref2 = this[prexix + name]) != null ? _ref2.format : void 0;
      if (typeof format === 'string') {
        return Serenade._formats[format].call(this, this.get(name));
      } else if (typeof format === 'function') {
        return format.call(this, this.get(name));
      } else {
        return this.get(name);
      }
    },
    serialize: function() {
      var key, name, options, serialized, value, _ref2;
      serialized = {};
      for (name in this) {
        options = this[name];
        if (name.match(exp)) {
          if (typeof options.serialize === 'string') {
            serialized[options.serialize] = serializeObject(this.get(options.name));
          } else if (typeof options.serialize === 'function') {
            _ref2 = options.serialize.call(this), key = _ref2[0], value = _ref2[1];
            serialized[key] = serializeObject(value);
          } else if (options.serialize) {
            serialized[options.name] = serializeObject(this.get(options.name));
          }
        }
      }
      return serialized;
    },
    _defer: function(name) {
      var deferred, _ref2;
      deferred = this.get(name);
      if (typeof deferred === 'object') {
        deferred._deferTo || (deferred._deferTo = {});
        return (_ref2 = deferred._deferTo) != null ? _ref2[name] = this : void 0;
      }
    },
    _undefer: function(name) {
      var deferred;
      deferred = this.get(name);
      if (deferred != null ? deferred._deferTo : void 0) {
        return delete deferred._deferTo[name];
      }
    },
    _triggerChangesTo: function(changedProperties) {
      var allDefers, changes, checkDependenciesFor, collection, deferName, deferObject, keys, name, normalizeDeps, prop, value, _i, _j, _k, _len, _len2, _len3, _ref2, _results,
        _this = this;
      normalizeDeps = function(deps) {
        return [].concat(deps);
      };
      checkDependenciesFor = function(toCheck) {
        var name, property, _ref2, _results;
        _results = [];
        for (name in _this) {
          property = _this[name];
          if (name.match(exp) && property.dependsOn) {
            if (__indexOf.call(normalizeDeps(property.dependsOn), toCheck) >= 0 && (_ref2 = property.name, __indexOf.call(changedProperties, _ref2) < 0)) {
              changedProperties.push(property.name);
              _results.push(checkDependenciesFor(property.name));
            } else {
              _results.push(void 0);
            }
          }
        }
        return _results;
      };
      for (_i = 0, _len = changedProperties.length; _i < _len; _i++) {
        prop = changedProperties[_i];
        checkDependenciesFor(prop);
      }
      changes = {};
      for (_j = 0, _len2 = changedProperties.length; _j < _len2; _j++) {
        name = changedProperties[_j];
        value = this.get(name);
        this.trigger("change:" + name, value);
        changes[name] = value;
      }
      this.trigger("change", changes);
      allDefers = this._deferTo || [];
      if (this._inCollections) {
        _ref2 = this._inCollections;
        for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
          collection = _ref2[_k];
          extend(allDefers, collection._deferTo);
        }
      }
      _results = [];
      for (deferName in allDefers) {
        deferObject = allDefers[deferName];
        if (!(allDefers.hasOwnProperty(deferName))) continue;
        keys = map(changedProperties, function(prop) {
          return "" + deferName + "." + prop;
        });
        _results.push(deferObject._triggerChangesTo(keys));
      }
      return _results;
    }
  };

  extend(Serenade.Properties, Events);

}).call(this);

};require['./model'] = new function() {
  var exports = this;
  (function() {
  var Associations, Cache, Serenade, extend;

  Serenade = require('./serenade').Serenade;

  Cache = require('./cache').Cache;

  Associations = require('./associations').Associations;

  extend = require('./helpers').extend;

  Serenade.Model = (function() {

    extend(Model.prototype, Serenade.Properties);

    extend(Model.prototype, Associations);

    Model.property = function() {
      var _ref;
      return (_ref = this.prototype).property.apply(_ref, arguments);
    };

    Model.collection = function() {
      var _ref;
      return (_ref = this.prototype).collection.apply(_ref, arguments);
    };

    Model.belongsTo = function() {
      var _ref;
      return (_ref = this.prototype).belongsTo.apply(_ref, arguments);
    };

    Model.hasMany = function() {
      var _ref;
      return (_ref = this.prototype).hasMany.apply(_ref, arguments);
    };

    Model.find = function(id) {
      return Cache.get(this, id) || new this({
        id: id
      });
    };

    Model.property('id', {
      serialize: true
    });

    function Model(attributes, bypassCache) {
      var fromCache,
        _this = this;
      if (bypassCache == null) bypassCache = false;
      if (!bypassCache) {
        if (attributes != null ? attributes.id : void 0) {
          fromCache = Cache.get(this.constructor, attributes.id);
          if (fromCache) {
            fromCache.set(attributes);
            return fromCache;
          } else {
            Cache.set(this.constructor, attributes.id, this);
          }
        }
      }
      if (this.constructor.localStorage === 'save') {
        this.bind('saved', function() {
          return Cache.store(_this.constructor, _this.get('id'), _this);
        });
      } else if (this.constructor.localStorage) {
        this.bind('change', function() {
          return Cache.store(_this.constructor, _this.get('id'), _this);
        });
      }
      this.set(attributes);
    }

    Model.prototype.save = function() {
      return this.trigger('saved');
    };

    return Model;

  })();

}).call(this);

};require['./view'] = new function() {
  var exports = this;
  (function() {
  var Lexer, Nodes, View, parser;

  parser = require('./parser').parser;

  Lexer = require('./lexer').Lexer;

  Nodes = require('./nodes').Nodes;

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

    function View(string) {
      this.string = string;
    }

    View.prototype.parse = function() {
      return parser.parse(new Lexer().tokenize(this.string));
    };

    View.prototype.render = function(document, model, controller) {
      var node;
      node = Nodes.compile(this.parse(), document, model, controller);
      controller.model = model;
      return controller.view = node.element;
    };

    return View;

  })();

  exports.View = View;

}).call(this);

};
    return require['./serenade'].Serenade
  }();

  if(typeof define === 'function' && define.amd) {
    define(function() { return Serenade });
  } else { root.Serenade = Serenade }
}(this));