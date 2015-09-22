"use strict";

var _interopRequireDefault = function (obj) { return obj && obj.__esModule ? obj : { "default": obj }; };

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _merge = require("../helpers");

var _Collection = require("../collection");

var _Collection2 = _interopRequireDefault(_Collection);

exports["default"] = function (name, options) {
  if (!options) options = {};

  var propOptions = _merge.merge(options, {
    changed: true,
    get: function get() {
      var valueName = "_" + name;
      if (!this[valueName]) {
        this[valueName] = new _Collection2["default"]([]);
        this[valueName].change.bind(this[name + "_property"].trigger);
      }
      return this[valueName];
    },
    set: function set(value) {
      this[name].update(value);
    }
  });

  this.property(name, propOptions);
  this.property(name + "Count", {
    get: function get() {
      return this[name].length;
    },
    dependsOn: name
  });
};

;
module.exports = exports["default"];
