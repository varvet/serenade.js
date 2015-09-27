"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _helpers = require("../helpers");

var _collection = require("../collection");

var _collection2 = _interopRequireDefault(_collection);

exports["default"] = function (name, options) {
  var channelName = "@" + name;

  if (!options) options = {};

  var attributeOptions = (0, _helpers.merge)(options, {
    set: function set(model) {
      if (model && model.constructor === Object && options.as) {
        model = new (options.as())(model);
      }
      var previous = this[channelName].value;
      this[channelName].emit(model);
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

  this.attribute(name, attributeOptions);
  this.property(name + 'Id', {
    get: function get(object) {
      return object && object.id;
    },
    set: function set(id) {
      if (id) {
        this[name] = options.as().find(id);
      }
    },
    dependsOn: name,
    serialize: options.serializeId
  });
};

;
module.exports = exports["default"];
