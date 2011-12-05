(function() {
  var EVENTS, Monkey, extract_from_model;
  var __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; };

  Monkey = require('./monkey').Monkey;

  EVENTS = ['click', 'blur', 'focus', 'change', 'mouseover', 'mouseout'];

  extract_from_model = function(model, value, bound) {
    if (bound && model.get) {
      return model.get(value);
    } else if (bound) {
      return model[value];
    } else {
      return value;
    }
  };

  Monkey.Element = (function() {

    function Element(name, attributes, children) {
      this.name = name;
      this.attributes = attributes;
      this.children = children;
      this.attributes || (this.attributes = []);
      this.children || (this.children = []);
    }

    Element.prototype.compile = function(document, model, controller) {
      var attribute, child, childNode, element, node, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
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
        childNode = child.compile(document, model, controller);
        if (childNode.nodeName) {
          element.appendChild(childNode);
        } else {
          for (_k = 0, _len3 = childNode.length; _k < _len3; _k++) {
            node = childNode[_k];
            element.appendChild(node);
          }
        }
      }
      return element;
    };

    return Element;

  })();

  Monkey.Attribute = (function() {

    function Attribute(name, value, bound) {
      this.name = name;
      this.value = value;
      this.bound = bound;
    }

    Attribute.prototype.compile = function(element, model, constructor) {
      var computed;
      var _this = this;
      computed = this.compute(model);
      if (computed !== void 0) element.setAttribute(this.name, computed);
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

    Attribute.prototype.compute = function(model) {
      return extract_from_model(model, this.value, this.bound);
    };

    return Attribute;

  })();

  Monkey.TextNode = (function() {

    function TextNode(value, bound) {
      this.value = value;
      this.bound = bound;
    }

    TextNode.prototype.name = 'text';

    TextNode.prototype.compile = function(document, model, controller) {
      var textNode;
      var _this = this;
      textNode = document.createTextNode(this.compute(model) || '');
      if (this.bound) {
        if (typeof model.bind === "function") {
          model.bind("change:" + this.value, function(value) {
            return textNode.nodeValue = value || '';
          });
        }
      }
      return textNode;
    };

    TextNode.prototype.compute = function(model) {
      return extract_from_model(model, this.value, this.bound);
    };

    return TextNode;

  })();

  Monkey.Instruction = (function() {

    function Instruction(command, _arguments, children) {
      this.command = command;
      this.arguments = _arguments;
      this.children = children;
    }

    Instruction.prototype.compile = function(document, model, controller) {
      return this[this.command](document, model, controller);
    };

    Instruction.prototype.collection = function(document, model, controller) {
      var child, elements, item, _i, _j, _len, _len2, _ref, _ref2;
      elements = [];
      _ref = this.compute(model);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _ref2 = this.children;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          child = _ref2[_j];
          elements.push(child.compile(document, item, controller));
        }
      }
      return elements;
    };

    Instruction.prototype.compute = function(model) {
      return extract_from_model(model, this.arguments[0], true);
    };

    return Instruction;

  })();

}).call(this);
