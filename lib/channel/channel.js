"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(_x2, _x3, _x4) { var _again = true; _function: while (_again) { var object = _x2, property = _x3, receiver = _x4; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x2 = parent; _x3 = property; _x4 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var _static_channel = require("./static_channel");

var _static_channel2 = _interopRequireDefault(_static_channel);

var _helpers = require("../helpers");

var Channel = (function (_StaticChannel) {
  _inherits(Channel, _StaticChannel);

  _createClass(Channel, null, [{
    key: "of",
    value: function of(value) {
      return new Channel(value);
    }
  }, {
    key: "static",
    value: function _static(value) {
      return new _static_channel2["default"](value);
    }
  }, {
    key: "get",
    value: function get(object, name) {
      var channelName = "@" + name;
      if (!object) {
        return new _static_channel2["default"]();
      } else if (object[channelName]) {
        return object[channelName];
      } else {
        return new _static_channel2["default"](object[name]);
      }
    }
  }, {
    key: "pluck",
    value: function pluck(object, name) {
      var parts = name.split(/[\.:]/);

      if (parts.length == 2) {
        if (name.match(/:/)) {
          return Channel.get(object, parts[0]).pluckAll(parts[1]);
        } else {
          return Channel.get(object, parts[0]).pluck(parts[1]);
        }
      } else if (parts.length == 1) {
        return Channel.get(object, name);
      } else {
        throw new Error("cannot pluck more than one level in depth");
      }
    }
  }]);

  function Channel(value) {
    var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];

    _classCallCheck(this, Channel);

    _get(Object.getPrototypeOf(Channel.prototype), "constructor", this).call(this, value);
    this.options = options;
    this.subscribers = [];
  }

  _createClass(Channel, [{
    key: "emit",
    value: function emit(value) {
      this.value = value;
      this.trigger();
    }
  }, {
    key: "trigger",
    value: function trigger() {
      var _this = this;

      if (this.options.async) {
        if (!this.timeout) {
          this.timeout = requestAnimationFrame(function () {
            _this.resolve();
          });
        }
      } else {
        this.resolve();
      }
    }
  }, {
    key: "subscribe",
    value: function subscribe(callback) {
      this.subscribers.push(callback);
    }
  }, {
    key: "unsubscribe",
    value: function unsubscribe(callback) {
      (0, _helpers.deleteItem)(this.subscribers, callback);
    }
  }, {
    key: "resolve",
    value: function resolve() {
      var _this2 = this;

      this.subscribers.map(function (i) {
        return i;
      }).forEach(function (subscriber) {
        subscriber(_this2.value);
      });
    }
  }]);

  return Channel;
})(_static_channel2["default"]);

exports["default"] = Channel;
module.exports = exports["default"];
