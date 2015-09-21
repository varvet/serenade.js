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
    set: function set(model) {
      var valueName = "_" + name;
      if (model && model.constructor === Object && options.as) {
        model = new (options.as())(model);
      }
      var previous = this[valueName];
      this[valueName] = model;
      if (options.inverseOf) {
        if (previous) {
          previous[options.inverseOf]["delete"](this);
        }
        if (model) {
          var newCollection = model[options.inverseOf];
          if (newCollection.indexOf(this) === -1) newCollection.push(this);
        }
      }
    }
  });

  this.property(name, propOptions);
  this.property(name + "Id", {
    get: function get() {
      return this[name] && this[name].id;
    },
    set: function set(id) {
      if (id) this[name] = options.as().find(id);
    },
    dependsOn: name,
    serialize: options.serializeId
  });
};

;
module.exports = exports["default"];
