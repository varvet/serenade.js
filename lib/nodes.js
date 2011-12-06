(function() {
  var EVENTS, Monkey;
  var __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; };

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
      var attribute, child, childNode, element, _i, _j, _len, _len2, _ref, _ref2, _ref3;
      element = document.createElement(this.name);
      _ref = this.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attribute = _ref[_i];
        if (_ref2 = attribute.name, __indexOf.call(EVENTS, _ref2) >= 0) {
          attribute.event(element, model, controller);
        } else {
          attribute.compile(element, model, controller);
        }
      }
      _ref3 = this.children;
      for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
        child = _ref3[_j];
        if (child.type === 'instruction') {
          child.execute(element, document, model, controller);
        } else {
          childNode = child.compile(document, model, controller);
          element.appendChild(childNode);
        }
      }
      return element;
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

    Attribute.prototype.compile = function(element, model, constructor) {
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

    Attribute.prototype.event = function(element, model, controller) {
      var callback;
      var _this = this;
      callback = function(e) {
        return controller[_this.value](e);
      };
      return element.addEventListener(this.name, callback, false);
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

    TextNode.prototype.get = function(model) {
      return Monkey.get(model, this.value, this.bound);
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

    Instruction.prototype.execute = function(element, document, model, controller) {
      return this[this.command](element, document, model, controller);
    };

    Instruction.prototype.collection = function(element, document, model, controller) {
      var anchor, collection;
      collection = this.get(model);
      anchor = document.createTextNode('');
      element.appendChild(anchor);
      return new Monkey.ViewCollection(anchor, document, collection, controller, this.children);
    };

    Instruction.prototype.get = function(model) {
      return Monkey.get(model, this.arguments[0]);
    };

    return Instruction;

  })();

  Monkey.ViewCollection = (function() {

    function ViewCollection(anchor, document, collection, controller, children) {
      this.anchor = anchor;
      this.document = document;
      this.collection = collection;
      this.controller = controller;
      this.children = children;
      this.build();
    }

    ViewCollection.prototype.build = function() {
      var parent, sibling;
      var _this = this;
      parent = this.anchor.parentNode;
      sibling = this.anchor.nextSibling;
      return Monkey.each(this.collection, function(item) {
        var child, newElement, _i, _len, _ref, _results;
        _ref = _this.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          newElement = child.compile(_this.document, item, _this.controller);
          _results.push(parent.insertBefore(newElement, sibling));
        }
        return _results;
      });
    };

    return ViewCollection;

  })();

}).call(this);
