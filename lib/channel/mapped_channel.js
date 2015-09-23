"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var _static_channel = require("./static_channel");

var _static_channel2 = _interopRequireDefault(_static_channel);

var _helpers = require("../helpers");

var MappedChannel = (function (_StaticChannel) {
  _inherits(MappedChannel, _StaticChannel);

  function MappedChannel(parent, fn) {
    var _this = this;

    _classCallCheck(this, MappedChannel);

    _get(Object.getPrototypeOf(MappedChannel.prototype), "constructor", this).call(this, undefined);
    this.subscribers = [];
    this.fn = fn;
    this.parent = parent;
    this.handler = function (value) {
      _this.subscribers.forEach(function (callback) {
        callback(_this.value);
      });
    };
  }

  _createClass(MappedChannel, [{
    key: "subscribe",
    value: function subscribe(callback) {
      if (!this.subscribers.length) {
        this.parent.subscribe(this.handler);
      }
      this.subscribers.push(callback);
    }
  }, {
    key: "unsubscribe",
    value: function unsubscribe(callback) {
      (0, _helpers.deleteItem)(this.subscribers, callback);
      if (!this.subscribers.length) {
        this.parent.unsubscribe(this.handler);
      }
    }
  }, {
    key: "value",
    get: function get() {
      return this.fn(this.parent.value);
    },
    set: function set(value) {
      // No op
    }
  }]);

  return MappedChannel;
})(_static_channel2["default"]);

exports["default"] = MappedChannel;

_static_channel2["default"].prototype.map = function (fn) {
  return new MappedChannel(this, fn);
};
module.exports = exports["default"];
