"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

var View = (function () {
  function View(node) {
    _classCallCheck(this, View);

    this.node = node;
    this.children = [];
    this.channels = new _collection2["default"]();
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

      this.channels.forEach(function (_ref) {
        var channel = _ref.channel;
        var fun = _ref.fun;
        return channel.unsubscribe(fun);
      });
    }
  }, {
    key: "_bind",
    value: function _bind(channel, fun) {
      if (channel) {
        this.channels.push({ channel: channel, fun: fun });
        channel.bind(fun);
      }
    }
  }, {
    key: "_subscribe",
    value: function _subscribe(channel, fun) {
      if (channel) {
        this.channels.push({ channel: channel, fun: fun });
        channel.subscribe(fun);
      }
    }
  }, {
    key: "_unsubscribe",
    value: function _unsubscribe(channel, fun) {
      if (channel) {
        this.channels["delete"](fun);
        channel.unsubscribe(fun);
      }
    }
  }, {
    key: "lastElement",
    get: function get() {
      return this.node;
    }
  }]);

  return View;
})();

View.prototype.isView = true;

exports["default"] = View;
module.exports = exports["default"];
