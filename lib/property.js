"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.defineChannel = defineChannel;
exports.defineAttribute = defineAttribute;
exports.defineProperty = defineProperty;

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _helpers = require("./helpers");

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

var _channelAttribute_channel = require("./channel/attribute_channel");

var _channelAttribute_channel2 = _interopRequireDefault(_channelAttribute_channel);

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
  options = (0, _helpers.merge)({ channelName: "@" + name }, options);

  defineChannel(object, options.channelName, {
    channel: function channel() {
      if (options.channel) {
        return options.channel.call(this, options);
      } else {
        return new _channelAttribute_channel2["default"](this, options);
      }
    }
  });

  function define(object) {
    Object.defineProperty(object, name, {
      get: function get() {
        if (options.get) {
          return options.get.call(this);
        } else {
          return this[options.channelName].value;
        }
      },
      set: function set(value) {
        define(this);
        if (options.set) {
          options.set.call(this, value);
        } else {
          this[options.channelName].emit(value);
        }
      },
      enumerable: "enumerable" in options ? options.enumerable : true,
      configurable: true
    });
  };

  define(object);

  if ("value" in options) {
    object[name] = options.value;
  }
}

;

function defineProperty(object, name, options) {
  options = (0, _helpers.merge)({ channelName: "@" + name }, options);

  var deps = options.dependsOn;
  var getter = options.get || function () {};

  defineChannel(object, options.channelName, { channel: function channel() {
      var _this = this;

      var channel = undefined;
      if (deps) {
        deps = [].concat(deps);
        var dependentChannels = deps.map(function (d) {
          return _channel2["default"].pluck(_this, d);
        });
        channel = _channel2["default"].all(dependentChannels).map(function (args) {
          return getter.apply(_this, args);
        });
      } else {
        channel = _channel2["default"]["static"](this).map(function (val) {
          return getter.call(val);
        })["static"]();
      }
      if (options.cache) {
        channel = channel.cache();
      }
      channel = channel.async("property");
      return channel;
    } });

  options.get = function () {
    return this[options.channelName].value;
  };
  options.configurable = true;

  if (options.returnDescriptor) {
    return options;
  } else {
    Object.defineProperty(object, name, options);
  }
}

;
