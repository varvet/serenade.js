"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _helpers = require("./helpers");

var _channelBase_channel = require("./channel/base_channel");

var _channelBase_channel2 = _interopRequireDefault(_channelBase_channel);

var _channelChannel = require("./channel/channel");

var _channelChannel2 = _interopRequireDefault(_channelChannel);

var _channelStatic_channel = require("./channel/static_channel");

var _channelStatic_channel2 = _interopRequireDefault(_channelStatic_channel);

var _channelDerived_static_channel = require("./channel/derived_static_channel");

var _channelDerived_static_channel2 = _interopRequireDefault(_channelDerived_static_channel);

var _channelMapped_channel = require("./channel/mapped_channel");

var _channelMapped_channel2 = _interopRequireDefault(_channelMapped_channel);

var _channelAsync_channel = require("./channel/async_channel");

var _channelAsync_channel2 = _interopRequireDefault(_channelAsync_channel);

var _channelCached_channel = require("./channel/cached_channel");

var _channelCached_channel2 = _interopRequireDefault(_channelCached_channel);

var _channelPlucked_channel = require("./channel/plucked_channel");

var _channelPlucked_channel2 = _interopRequireDefault(_channelPlucked_channel);

var _channelCollection_channel = require("./channel/collection_channel");

var _channelCollection_channel2 = _interopRequireDefault(_channelCollection_channel);

var _channelPlucked_collection_channel = require("./channel/plucked_collection_channel");

var _channelPlucked_collection_channel2 = _interopRequireDefault(_channelPlucked_collection_channel);

var _channelComposite_channel = require("./channel/composite_channel");

var _channelComposite_channel2 = _interopRequireDefault(_channelComposite_channel);

var _channelFiltered_channel = require("./channel/filtered_channel");

var _channelFiltered_channel2 = _interopRequireDefault(_channelFiltered_channel);

(0, _helpers.extend)(_channelChannel2["default"], {
  all: function all(parents) {
    return new _channelComposite_channel2["default"](parents);
  },

  of: function of(value) {
    return new _channelChannel2["default"](value);
  },

  "static": function _static(value) {
    return new _channelStatic_channel2["default"](value);
  },

  get: function get(object, name) {
    var channelName = "@" + name;
    if (!object) {
      return new _channelStatic_channel2["default"]();
    } else if (object[channelName]) {
      return object[channelName];
    } else {
      return new _channelStatic_channel2["default"](object[name]);
    }
  },

  pluck: function pluck(object, name) {
    var parts = name.split(/[\.:]/);

    if (parts.length == 2) {
      if (name.match(/:/)) {
        return _channelChannel2["default"].get(object, parts[0]).pluckAll(parts[1]);
      } else {
        return _channelChannel2["default"].get(object, parts[0]).pluck(parts[1]);
      }
    } else if (parts.length == 1) {
      return _channelChannel2["default"].get(object, name);
    } else {
      throw new Error("cannot pluck more than one level in depth");
    }
  }
});

(0, _helpers.extend)(_channelBase_channel2["default"].prototype, {
  map: function map(fn) {
    return new _channelMapped_channel2["default"](this, fn);
  },

  pluckAll: function pluckAll(property) {
    return new _channelPlucked_collection_channel2["default"](this.collection(), property);
  },

  pluck: function pluck(property) {
    return new _channelPlucked_channel2["default"](this, property);
  },

  filter: function filter(fn) {
    return new _channelFiltered_channel2["default"](this, fn);
  },

  "static": function _static() {
    return new _channelDerived_static_channel2["default"](this);
  },

  async: function async(queue) {
    return new _channelAsync_channel2["default"](this, queue);
  },

  cache: function cache(fn) {
    return new _channelCached_channel2["default"](this, fn);
  },

  collection: function collection() {
    return new _channelCollection_channel2["default"](this);
  }
});

exports["default"] = _channelChannel2["default"];
module.exports = exports["default"];
