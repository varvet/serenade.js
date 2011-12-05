(function() {
  var EVENTS, Monkey;
  var __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; };

  Monkey = require('./monkey').Monkey;

  EVENTS = ['click', 'blur', 'focus', 'change', 'mouseover', 'mouseout'];

  Monkey.Element = (function() {

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
        childNode = child.compile(document, model, controller);
        element.appendChild(childNode);
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
      if (this.bound && model.get) {
        return model.get(this.value);
      } else if (this.bound) {
        return model[this.value];
      } else {
        return this.value;
      }
    };

    return Attribute;

  })();

  Monkey.TextNode = (function() {

    function TextNode(value, bound) {
      this.value = value;
      this.bound = bound;
    }

    TextNode.prototype.name = 'text';

    TextNode.prototype.compile = function(document, model, constructor) {
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
      if (this.bound && model.get) {
        return model.get(this.value);
      } else if (this.bound) {
        return model[this.value];
      } else {
        return this.value;
      }
    };

    return TextNode;

  })();

}).call(this);
