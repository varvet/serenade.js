(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;

  Monkey.Renderer = (function() {

    Renderer._eventNames = ['click', 'mouseover', 'mouseout', 'change'];

    Renderer._views = {};

    Renderer.render = function(name, model, controller) {
      var renderer;
      renderer = new Monkey.Renderer(model, controller);
      controller.model = model;
      return controller.view = this._views[name](renderer.builderFunction());
    };

    function Renderer(model, controller) {
      this.model = model;
      this.controller = controller;
      this.createElement = __bind(this.createElement, this);
      this.boundTextNode = __bind(this.boundTextNode, this);
    }

    Renderer.prototype.convertNode = function(node) {
      if (node.hasOwnProperty('bind')) {
        return this.boundTextNode(node.bind);
      } else if (typeof node === 'string') {
        return document.createTextNode(node);
      } else {
        return node;
      }
    };

    Renderer.prototype.setAttribute = function(element, name, value) {
      var _this = this;
      if (Monkey.Renderer._eventNames.indexOf(name) >= 0) {
        return element.addEventListener(name, function(e) {
          return _this.controller[value](e);
        });
      } else {
        if (value.hasOwnProperty('bind')) {
          element.setAttribute(name, this.model[value.bind] || '');
          return this.model.bind("change:" + value.bind, function(newValue) {
            if (name === 'value') {
              return element.value = newValue || '';
            } else {
              return element.setAttribute(name, newValue || '');
            }
          });
        } else {
          return element.setAttribute(name, value);
        }
      }
    };

    Renderer.prototype.boundTextNode = function(name) {
      var node;
      node = document.createTextNode(this.model[name] || '');
      this.model.bind("change:" + name, function(value) {
        return node.textContent = value || '';
      });
      return node;
    };

    Renderer.prototype.createElement = function() {
      var attributes, element, name, node, nodes, tagName, value, _i, _len;
      tagName = arguments[0], attributes = arguments[1], nodes = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      element = document.createElement(tagName);
      for (name in attributes) {
        value = attributes[name];
        this.setAttribute(element, name, value);
      }
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        node = nodes[_i];
        element.appendChild(this.convertNode(node));
      }
      return element;
    };

    Renderer.prototype.builderFunction = function() {
      var fun;
      fun = this.createElement;
      fun.text = this.createTextNode;
      fun.attr = this.createAttribute;
      return fun;
    };

    return Renderer;

  })();

}).call(this);
