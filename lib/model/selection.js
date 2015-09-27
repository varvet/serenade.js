"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _helpers = require("../helpers");

exports["default"] = function (name, options) {
  if (!options) options = {};
  if (!options.from) throw new Error("must specify `from` option");

  var dependencies = [options.from].concat(options.dependsOn || []);

  if (typeof options.filter === "string") dependencies.push(options.from + ":" + options.filter);
  if (typeof options.map === "string") dependencies.push(options.from + ":" + options.map);

  var propertyOptions = (0, _helpers.merge)(options, {
    get: function get() {
      var collection = this[options.from];

      var _loop = function (key) {
        var value = options[key];
        if (key === "filter" || key === "map") {
          if (typeof options[key] === "string") {
            collection = collection[key](function (item) {
              return item[options[key]];
            });
          } else {
            collection = collection[key](function (item) {
              return options[key](item);
            });
          }
        }
      };

      for (var key in options) {
        _loop(key);
      }
      return collection;
    },
    dependsOn: dependencies
  });

  this.property(name, propertyOptions);
  this.property(name + 'Count', {
    get: function get() {
      return this[name].length;
    },
    dependsOn: name
  });
};

;
module.exports = exports["default"];
