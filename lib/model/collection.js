"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _helpers = require("../helpers");

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

exports["default"] = function (name, options) {
  if (!options) options = {};

  var propOptions = (0, _helpers.merge)(options, {
    changed: true,
    get: function get() {
      var valueName = "_" + name;
      if (!this[valueName]) {
        this[valueName] = new _collection2["default"]([]);
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
