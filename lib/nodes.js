(function() {
  var Attribute, Collection, CollectionItem, Element, Event, Monkey, Nodes, Style, TextNode, View, forEach, format, get, _ref;

  Monkey = require('./monkey').Monkey;

  _ref = require('./helpers'), format = _ref.format, get = _ref.get, forEach = _ref.forEach;

  Element = (function() {

    function Element(ast, document, model, controller) {
      var child, property, _i, _j, _len, _len2, _ref2, _ref3;
      this.ast = ast;
      this.document = document;
      this.model = model;
      this.controller = controller;
      this.element = this.document.createElement(this.ast.name);
      _ref2 = this.ast.properties;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        property = _ref2[_i];
        Nodes.property(property, this.element, this.document, this.model, this.controller);
      }
      _ref3 = this.ast.children;
      for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
        child = _ref3[_j];
        Nodes.compile(child, this.document, this.model, this.controller).append(this.element);
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

  Style = (function() {

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
      return format(this.model, this.ast.value, this.ast.bound);
    };

    return Style;

  })();

  Event = (function() {

    function Event(ast, element, document, model, controller) {
      var callback,
        _this = this;
      this.ast = ast;
      this.element = element;
      this.document = document;
      this.model = model;
      this.controller = controller;
      callback = function(e) {
        if (_this.ast.preventDefault) e.preventDefault();
        return _this.controller[_this.ast.value](e);
      };
      this.element.addEventListener(this.ast.name, callback, false);
    }

    return Event;

  })();

  Attribute = (function() {

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
      return format(this.model, this.ast.value, this.ast.bound);
    };

    return TextNode;

  })();

  View = (function() {

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
          return new Element(ast, document, model, controller);
        case 'text':
          return new TextNode(ast, document, model, controller);
        case 'instruction':
          switch (ast.command) {
            case "view":
              return new View(ast, document, model, controller);
            case "collection":
              return new Collection(ast, document, model, controller);
          }
          break;
        default:
          throw SyntaxError("unknown type " + ast.type);
      }
    },
    property: function(ast, element, document, model, controller) {
      switch (ast.scope) {
        case "attribute":
          return new Attribute(ast, element, document, model, controller);
        case "style":
          return new Style(ast, element, document, model, controller);
        case "event":
          return new Event(ast, element, document, model, controller);
        default:
          throw SyntaxError("" + ast.scope + " is not a valid scope");
      }
    }
  };

  exports.Nodes = Nodes;

}).call(this);
