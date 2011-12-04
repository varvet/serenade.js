(function() {
  var EVENTS, Monkey;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
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
      computed = this.compute(model);
      if (computed !== void 0) {
        return element.setAttribute(this.name, computed);
      }
    };
    Attribute.prototype.event = function(element, model, controller) {
      var callback;
      callback = __bind(function(e) {
        return controller[this.value](e);
      }, this);
      return element.addEventListener(this.name, callback, false);
    };
    Attribute.prototype.compute = function(model) {
      if (this.bound) {
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
      return textNode = document.createTextNode(this.compute(model) || '');
    };
    TextNode.prototype.compute = function(model) {
      if (this.bound) {
        return model[this.value];
      } else {
        return this.value;
      }
    };
    return TextNode;
  })();
}).call(this);
