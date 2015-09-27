"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _helpers = require("../helpers");

var _association_collection = require("../association_collection");

var _association_collection2 = _interopRequireDefault(_association_collection);

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

exports["default"] = function (name, options) {
  if (!options) options = {};

  var channelName = "@" + name;

  var attributeOptions = (0, _helpers.merge)(options, {
    changed: true,
    get: function get() {
      if (!this[channelName]) {
        this[channelName] = new _association_collection2["default"](this, options, []);
      }
      return this[channelName].collection().value;
    },
    set: function set(value) {
      this[channelName].value.update(value);
    }
  });

  this.attribute(name, attributeOptions);
  this.property(name + 'Ids', {
    get: function get(collection) {
      return collection.map(function (item) {
        return item.id;
      });
    },
    set: function set(ids) {
      var objects = ids.map(function (id) {
        return options.as().find(id);
      });
      this[name].update(objects);
    },
    dependsOn: name,
    serialize: options.serializeIds
  });
  this.property(name + 'Count', {
    get: function get(collection) {
      return collection.length;
    },
    dependsOn: name
  });
};

;
module.exports = exports["default"];
