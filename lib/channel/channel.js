"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(object, property, receiver) { var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _inherits = function (subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) subClass.__proto__ = superClass; };

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _StaticChannel2 = require("./static_channel");

var _StaticChannel3 = _interopRequireDefault(_StaticChannel2);

var _deleteItem = require("../helpers");

var Channel = (function (_StaticChannel) {
  function Channel(value) {
    var options = arguments[1] === undefined ? {} : arguments[1];

    _classCallCheck(this, Channel);

    _get(Object.getPrototypeOf(Channel.prototype), "constructor", this).call(this, value);
    this.options = options;
    this.subscribers = [];
  }

  _inherits(Channel, _StaticChannel);

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
      _deleteItem.deleteItem(this.subscribers, callback);
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
  }], [{
    key: "of",
    value: function of(value) {
      return new Channel(value);
    }
  }, {
    key: "static",
    value: function _static(value) {
      return new _StaticChannel3["default"](value);
    }
  }, {
    key: "get",
    value: function get(object, name) {
      var channelName = "@" + name;
      if (!object) {
        return new _StaticChannel3["default"]();
      } else if (object[channelName]) {
        return object[channelName];
      } else {
        return new _StaticChannel3["default"](object[name]);
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

  return Channel;
})(_StaticChannel3["default"]);

exports["default"] = Channel;
module.exports = exports["default"];
