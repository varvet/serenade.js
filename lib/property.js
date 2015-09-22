"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.defineChannel = defineChannel;
exports.defineAttribute = defineAttribute;
exports.defineProperty = defineProperty;

var _Channel = require("./channel");

var _Channel2 = _interopRequireDefault(_Channel);

function defineChannel(object, name) {
  var options = arguments[2] === undefined ? {} : arguments[2];

  var privateChannelName = "@" + name;
  var getter = options.channel || function () {
    return new _Channel2["default"](options);
  };

  Object.defineProperty(object, name, {
    get: function get() {
      if (!this.hasOwnProperty(privateChannelName)) {
        Object.defineProperty(this, privateChannelName, {
          value: getter.call(this),
          configurable: true });
      }
      return this[privateChannelName];
    },
    configurable: true
  });
}

function defineAttribute(object, name, options) {
  var channelName = "@" + name;

  defineChannel(object, channelName, options);

  function define(object) {
    Object.defineProperty(object, name, {
      get: function get() {
        return this[channelName].value;
      },
      set: function set(value) {
        define(this);
        if (options.set) {
          value = options.set.call(this, value);
        }
        this[channelName].emit(value);
      },
      enumerable: options && "enumerable" in options ? options.enumerable : true,
      configurable: options && "configurable" in options ? options.configurable : true });
  };

  define(object);

  if (options && "value" in options) {
    object[name] = options.value;
  }
}

;

function defineProperty(object, name, options) {
  var channelName = "@" + name;
  var deps = options.dependsOn;
  var getter = options.get || function () {};

  if (deps) {
    deps = [].concat(deps);
    defineChannel(object, channelName, { channel: function channel() {
        var _this = this;

        var channels = deps.map(function (d) {
          return _Channel2["default"].pluck(_this, d);
        });
        return _Channel2["default"].all(channels).map(function (args) {
          return getter.apply(_this, args);
        });
      } });
  } else {
    defineChannel(object, channelName, { channel: function channel() {
        return _Channel2["default"]["static"](getter.call(this));
      } });
  }

  function define(object) {
    Object.defineProperty(object, name, {
      get: function get() {
        return this[channelName].value;
      },
      set: options.set,
      enumerable: options && "enumerable" in options ? options.enumerable : true,
      configurable: options && "configurable" in options ? options.configurable : true });
  };

  define(object);
}

;
