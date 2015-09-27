"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _helpers = require("../helpers");

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

var _channelAttribute_channel = require("../channel/attribute_channel");

var _channelAttribute_channel2 = _interopRequireDefault(_channelAttribute_channel);

exports["default"] = function (name, options) {
  options = (0, _helpers.merge)({ channelName: "@" + name }, options);

  var attributeOptions = (0, _helpers.merge)(options, {
    channel: function channel(channelOptions) {
      var collection = new _collection2["default"]();
      return new _channelAttribute_channel2["default"](this, channelOptions, collection).collection();
    },
    set: function set(value) {
      this[options.channelName].value.update(value);
    }
  });

  this.attribute(name, attributeOptions);
  this.property(name + 'Count', {
    get: function get(collection) {
      return collection.length;
    },
    dependsOn: name
  });
};

;
module.exports = exports["default"];
