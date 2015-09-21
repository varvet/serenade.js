"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _Collection = require("../collection");

var _Collection2 = _interopRequireDefault(_Collection);

var View = (function () {
  function View(node) {
    _classCallCheck(this, View);

    this.node = node;
    this.children = [];
  }

  _createClass(View, [{
    key: "append",
    value: function append(inside) {
      inside.appendChild(this.node);
    }
  }, {
    key: "insertAfter",
    value: function insertAfter(after) {
      after.parentNode.insertBefore(this.node, after.nextSibling);
    }
  }, {
    key: "remove",
    value: function remove() {
      if (this.node.parentNode) {
        this.node.parentNode.removeChild(this.node);
      }
      this.detach();
    }
  }, {
    key: "detach",
    value: function detach() {
      this.children.forEach(function (child) {
        return child.detach();
      });

      if (this.boundEvents) {
        this.boundEvents.forEach(function (_ref) {
          var event = _ref.event;
          var fun = _ref.fun;
          return event.unbind(fun);
        });
      }
    }
  }, {
    key: "lastElement",
    get: function () {
      return this.node;
    }
  }, {
    key: "_bindEvent",
    value: function _bindEvent(event, fun) {
      if (event) {
        this.boundEvents || (this.boundEvents = new _Collection2["default"]());
        this.boundEvents.push({ event: event, fun: fun });
        event.bind(fun);
      }
    }
  }, {
    key: "_unbindEvent",
    value: function _unbindEvent(event, fun) {
      if (event) {
        this.boundEvents || (this.boundEvents = new _Collection2["default"]());
        this.boundEvents["delete"](fun);
        event.unbind(fun);
      }
    }
  }, {
    key: "_bindToModel",
    value: function _bindToModel(name, fun) {
      var value = this.context[name];
      var property = this.context["" + name + "_property"];
      if (property && property.registerGlobal) {
        property.registerGlobal(value);
      }
      this._bindEvent(property, function (_, value) {
        return fun(value);
      });
      fun(value);
    }
  }]);

  return View;
})();

View.prototype.isView = true;

exports["default"] = View;
module.exports = exports["default"];
