(function() {
  var Monkey;
  var __slice = Array.prototype.slice, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Monkey = require('./monkey').Monkey;
  Monkey.AST = {};
  Monkey.Nodes = {};
  Monkey.AST.Element = (function() {
    Element.prototype.type = 'element';
    function Element(name, properties, children) {
      this.name = name;
      this.properties = properties;
      this.children = children;
      this.properties || (this.properties = []);
      this.children || (this.children = []);
    }
    Element.prototype.compile = function(document, model, controller) {
      return new Monkey.Nodes.Element(this, document, model, controller);
    };
    return Element;
  })();
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
        property.attach(this.element, this.document, this.model, this.controller);
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
  Monkey.AST.Property = (function() {
    function Property(name, value, bound, scope) {
      this.name = name;
      this.value = value;
      this.bound = bound;
      this.scope = scope != null ? scope : "attribute";
    }
    Property.prototype.attach = function() {
      switch (this.scope) {
        case "attribute":
          return (function(func, args, ctor) {
            ctor.prototype = func.prototype;
            var child = new ctor, result = func.apply(child, args);
            return typeof result == "object" ? result : child;
          })(Monkey.Nodes.Attribute, [this].concat(__slice.call(arguments)), function() {});
        case "style":
          return (function(func, args, ctor) {
            ctor.prototype = func.prototype;
            var child = new ctor, result = func.apply(child, args);
            return typeof result == "object" ? result : child;
          })(Monkey.Nodes.Style, [this].concat(__slice.call(arguments)), function() {});
        case "event":
          return (function(func, args, ctor) {
            ctor.prototype = func.prototype;
            var child = new ctor, result = func.apply(child, args);
            return typeof result == "object" ? result : child;
          })(Monkey.Nodes.Event, [this].concat(__slice.call(arguments)), function() {});
      }
    };
    return Property;
  })();
  Monkey.Nodes.Style = (function() {
    function Style(ast, element, document, model, controller) {
      var _base;
      this.ast = ast;
      this.element = element;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.update();
      if (this.ast.bound) {
        if (typeof (_base = this.model).bind == "function") {
          _base.bind("change:" + this.ast.value, __bind(function(value) {
            return this.update();
          }, this));
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
      var callback;
      this.ast = ast;
      this.element = element;
      this.document = document;
      this.model = model;
      this.controller = controller;
      callback = __bind(function(e) {
        return this.controller[this.ast.value](e);
      }, this);
      this.element.addEventListener(this.ast.name, callback, false);
    }
    return Event;
  })();
  Monkey.Nodes.Attribute = (function() {
    function Attribute(ast, element, document, model, controller) {
      var _base;
      this.ast = ast;
      this.element = element;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.update();
      if (this.ast.bound) {
        if (typeof (_base = this.model).bind == "function") {
          _base.bind("change:" + this.ast.value, __bind(function(value) {
            return this.update();
          }, this));
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
