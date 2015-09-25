"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.defineChannel = defineChannel;
exports.defineAttribute = defineAttribute;
exports.defineProperty = defineProperty;

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

var _channelAttribute_channel = require("./channel/attribute_channel");

var _channelAttribute_channel2 = _interopRequireDefault(_channelAttribute_channel);

function normalizeOptions(object, name) {
  var options = arguments.length <= 2 || arguments[2] === undefined ? {} : arguments[2];

  if (!("changed" in options)) {
    options.changed = function (oldVal, newVal) {
      return oldVal !== newVal;
    };
  } else if (typeof options.changed !== "function") {
    (function () {
      var value = options.changed;
      options.changed = function () {
        return value;
      };
    })();
  }
  options.channelName = options.channelName || "@" + name;
  return options;
}

function defineChannel(object, name) {
  var options = arguments.length <= 2 || arguments[2] === undefined ? {} : arguments[2];

  var privateChannelName = "@" + name;
  var getter = options.channel || function () {
    return new _channel2["default"]();
  };

  Object.defineProperty(object, name, {
    get: function get() {
      if (!this.hasOwnProperty(privateChannelName)) {
        var channel = getter.call(this);
        Object.defineProperty(this, privateChannelName, {
          value: channel,
          configurable: true
        });
      }
      return this[privateChannelName];
    },
    configurable: true
  });
}

function defineAttribute(object, name, options) {
  options = normalizeOptions(object, name, options);

  defineChannel(object, options.channelName, {
    channel: function channel() {
      return new _channelAttribute_channel2["default"](this, options);
    }
  });

  function define(object) {
    Object.defineProperty(object, name, {
      get: function get() {
        return this[options.channelName].value;
      },
      set: function set(value) {
        define(this);
        this[options.channelName].emit(value);
      },
      enumerable: options && "enumerable" in options ? options.enumerable : true,
      configurable: options && "configurable" in options ? options.configurable : true
    });
  };

  define(object);

  if (options && "value" in options) {
    object[name] = options.value;
  }
}

;

function defineProperty(object, name, options) {
  options = normalizeOptions(object, name, options);
  var deps = options.dependsOn;
  var getter = options.get || function () {};

  if (deps) {
    deps = [].concat(deps);
    defineChannel(object, options.channelName, { channel: function channel() {
        var _this = this;

        var dependentChannels = deps.map(function (d) {
          return _channel2["default"].pluck(_this, d);
        });
        var channel = _channel2["default"].all(dependentChannels).map(function (args) {
          return getter.apply(_this, args);
        });
        return channel;
      } });
  } else {
    defineChannel(object, options.channelName, { channel: function channel() {
        return _channel2["default"]["static"](getter.call(this));
      } });
  }

  function define(object) {
    Object.defineProperty(object, name, {
      get: function get() {
        return this[options.channelName].value;
      },
      set: options.set,
      enumerable: options && "enumerable" in options ? options.enumerable : true,
      configurable: options && "configurable" in options ? options.configurable : true
    });
  };

  define(object);
}

;
