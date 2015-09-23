"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

var _static_channel = require("./static_channel");

var _static_channel2 = _interopRequireDefault(_static_channel);

var _helpers = require("../helpers");

var PluckedChannel = (function (_StaticChannel) {
  _inherits(PluckedChannel, _StaticChannel);

  function PluckedChannel(parent, property) {
    var _this = this;

    _classCallCheck(this, PluckedChannel);

    var oldValue;
    _get(Object.getPrototypeOf(PluckedChannel.prototype), "constructor", this).call(this, undefined);
    this.parent = parent;
    this.property = property;
    this.appliedHandler = function (value) {
      _this.subscribers.forEach(function (cb) {
        return cb(_this.value);
      });
    };
    this.handler = function (value) {
      _channel2["default"].get(oldValue, property).unsubscribe(_this.appliedHandler);
      _channel2["default"].get(value, property).bind(_this.appliedHandler);
      oldValue = value;
    };
    this.subscribers = [];
  }

  _createClass(PluckedChannel, [{
    key: "subscribe",
    value: function subscribe(cb) {
      if (!this.subscribers.length) {
        this.parent.bind(this.handler);
      }
      this.subscribers.push(cb);
    }
  }, {
    key: "unsubscribe",
    value: function unsubscribe(cb) {
      (0, _helpers.deleteItem)(this.subscribers, cb);
      if (!this.subscribers.length) {
        this.parent.unsubscribe(this.handler);
        this.handler(undefined);
      }
    }
  }, {
    key: "value",
    get: function get() {
      return _channel2["default"].get(this.parent.value, this.property).value;
    },
    set: function set(value) {
      // No op
    }
  }]);

  return PluckedChannel;
})(_static_channel2["default"]);

exports["default"] = PluckedChannel;

_static_channel2["default"].prototype.pluck = function (property) {
  return new PluckedChannel(this, property);
};
module.exports = exports["default"];
