(function() {
  var EVENTS, Monkey;
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; };

  Monkey = require('./monkey').Monkey;

  EVENTS = ['click', 'blur', 'focus', 'change', 'mouseover', 'mouseout'];

  Monkey.Element = (function() {

    Element.prototype.type = 'element';

    function Element(name, attributes, children) {
      this.name = name;
      this.attributes = attributes;
      this.children = children;
      this.attributes || (this.attributes = []);
      this.children || (this.children = []);
    }

    Element.prototype.compile = function(document, model, controller) {
      var attribute, child, element, _i, _j, _len, _len2, _ref, _ref2;
      element = document.createElement(this.name);
      _ref = this.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attribute = _ref[_i];
        attribute.append(element, document, model, controller);
      }
      _ref2 = this.children;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        child = _ref2[_j];
        child.append(element, document, model, controller);
      }
      return element;
    };

    Element.prototype.append = function() {
      var args, element;
      element = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return element.appendChild(this.compile.apply(this, args));
    };

    Element.prototype.insertAfter = function() {
      var args, element, newEl;
      element = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      newEl = this.compile.apply(this, args);
      element.parentNode.insertBefore(newEl, element.nextSibling);
      return function() {
        return [newEl];
      };
    };

    return Element;

  })();

  Monkey.Attribute = (function() {

    Attribute.prototype.type = 'attribute';

    function Attribute(name, value, bound) {
      this.name = name;
      this.value = value;
      this.bound = bound;
    }

    Attribute.prototype.attribute = function(element, document, model, constructor) {
      var value;
      var _this = this;
      value = this.get(model);
      if (value !== void 0) element.setAttribute(this.name, value);
      if (this.bound) {
        return typeof model.bind === "function" ? model.bind("change:" + this.value, function(value) {
          if (_this.name === 'value') {
            return element.value = value || '';
          } else if (value === void 0) {
            return element.removeAttribute(_this.name);
          } else {
            return element.setAttribute(_this.name, value);
          }
        }) : void 0;
      }
    };

    Attribute.prototype.event = function(element, document, model, controller) {
      var callback;
      var _this = this;
      callback = function(e) {
        return controller[_this.value](e);
      };
      return element.addEventListener(this.name, callback, false);
    };

    Attribute.prototype.append = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (_ref = this.name, __indexOf.call(EVENTS, _ref) >= 0) {
        return this.event.apply(this, args);
      } else {
        return this.attribute.apply(this, args);
      }
    };

    Attribute.prototype.get = function(model) {
      return Monkey.get(model, this.value, this.bound);
    };

    return Attribute;

  })();

  Monkey.TextNode = (function() {

    TextNode.prototype.type = 'text';

    function TextNode(value, bound) {
      this.value = value;
      this.bound = bound;
    }

    TextNode.prototype.name = 'text';

    TextNode.prototype.compile = function(document, model, controller) {
      var textNode;
      var _this = this;
      textNode = document.createTextNode(this.get(model) || '');
      if (this.bound) {
        if (typeof model.bind === "function") {
          model.bind("change:" + this.value, function(value) {
            return textNode.nodeValue = value || '';
          });
        }
      }
      return textNode;
    };

    TextNode.prototype.append = function() {
      var args, element;
      element = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return element.appendChild(this.compile.apply(this, args));
    };

    TextNode.prototype.get = function(model) {
      return Monkey.get(model, this.value, this.bound);
    };

    TextNode.prototype.insertAfter = function() {
      var args, element, newEl;
      element = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      newEl = this.compile.apply(this, args);
      element.parentNode.insertBefore(newEl, element.nextSibling);
      return function() {
        return [newEl];
      };
    };

    return TextNode;

  })();

  Monkey.Instruction = (function() {

    Instruction.prototype.type = 'instruction';

    function Instruction(command, _arguments, children) {
      this.command = command;
      this.arguments = _arguments;
      this.children = children;
    }

    Instruction.prototype.append = function(element, document, model, controller) {
      var anchor;
      anchor = document.createTextNode('');
      element.appendChild(anchor);
      return this[this.command](anchor, document, model, controller);
    };

    Instruction.prototype.insertAfter = function(element, document, model, controller) {
      var anchor;
      anchor = document.createTextNode('');
      element.parentNode.insertBefore(anchor, element.nextSibling);
      return this[this.command](anchor, document, model, controller);
    };

    Instruction.prototype.collection = function(anchor, document, model, controller) {
      var collection, vc;
      collection = this.get(model);
      vc = new Monkey.ViewCollection(anchor, document, collection, controller, this.children);
      return function() {
        return [anchor].concat(__slice.call(vc.roots));
      };
    };

    Instruction.prototype.view = function(anchor, document, model, controller) {
      var newController, view;
      newController = Monkey.controllerFor(this.arguments[0]);
      newController.parent = controller;
      view = Monkey._views[this.arguments[0]].compile(document, model, newController);
      anchor.parentNode.insertBefore(view, anchor.nextSibling);
      return function() {
        return [anchor, view];
      };
    };

    Instruction.prototype.get = function(model) {
      return Monkey.get(model, this.arguments[0]);
    };

    return Instruction;

  })();

  Monkey.ViewCollection = (function() {

    function ViewCollection(anchor, document, collection, controller, children) {
      var _this = this;
      this.anchor = anchor;
      this.document = document;
      this.collection = collection;
      this.controller = controller;
      this.children = children;
      this.roots = [];
      this.build();
      if (this.collection.bind) {
        this.collection.bind('change', function() {
          return _this.rebuild();
        });
      }
    }

    ViewCollection.prototype.rebuild = function() {
      var element, root, _i, _j, _len, _len2, _ref, _ref2;
      _ref = this.roots;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        root = _ref[_i];
        _ref2 = root();
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          element = _ref2[_j];
          element.parentNode.removeChild(element);
        }
      }
      this.roots = [];
      return this.build();
    };

    ViewCollection.prototype.build = function() {
      var _this = this;
      return Monkey.each(this.collection, function(item) {
        var child, _i, _len, _ref, _results;
        _ref = _this.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          _results.push(_this.roots.push(child.insertAfter(_this.anchor, _this.document, item, _this.controller)));
        }
        return _results;
      });
    };

    return ViewCollection;

  })();

}).call(this);
