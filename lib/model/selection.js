"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _merge = require("../helpers");

exports["default"] = function (name, options) {
  if (!options) options = {};
  if (!options.from) throw new Error("must specify `from` option");

  var propOptions = _merge.merge(options, {
    get: function get() {
      var current = this[options.from];

      var _loop = function (key) {
        var value = options[key];
        if (key === "filter" || key === "map") {
          if (typeof options[key] === "string") {
            current = current[key](function (item) {
              return item[options[key]];
            });
          } else {
            current = current[key](function (item) {
              return options[key](item);
            });
          }
        }
      };

      for (var key in options) {
        _loop(key);
      }
      return current;
    },
    dependsOn: ["" + options.from + ":" + options.filter, "" + options.from + ":" + options.map]
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
