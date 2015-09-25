"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

exports.extend = extend;
exports.assignUnlessEqual = assignUnlessEqual;
exports.merge = merge;
exports.format = format;
exports.maybe = maybe;

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var settings = {
  async: false,
  views: {},
  templates: {}
};

exports.settings = settings;

function extend(target, source) {
  for (var key in source) {
    if (Object.hasOwnProperty.call(source, key)) {
      Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key));
    }
  }
  return target;
}

;

function assignUnlessEqual(object, prop, value) {
  if (object[prop] !== value) {
    object[prop] = value;
  }
}

;

function merge() {
  for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
    args[_key] = arguments[_key];
  }

  return args.reduce(function (ack, object) {
    return extend(ack, object);
  }, {});
}

;

var capitalize = function capitalize(word) {
  return word.slice(0, 1).toUpperCase() + word.slice(1);
};

exports.capitalize = capitalize;
var hash_current = 0;

var hash_prefix = "";

var hash_max = Math.pow(10, 12);

var hash = function hash(value) {
  var key = undefined;
  if (value instanceof Object) {
    if (!("_s_hash" in value)) {
      if (hash_current >= hash_max) {
        hash_prefix = Math.random().toString(36);
      };
      Object.defineProperty(value, "_s_hash", { value: hash_prefix + ++hash_current });
    }
    key = value._s_hash;
  } else {
    key = value;
  }
  return typeof value + " " + key;
};

exports.hash = hash;
var deleteItem = function deleteItem(collection, item) {
  var index = collection.indexOf(item);

  if (index !== -1) {
    collection.splice(index, 1);
  }
};

exports.deleteItem = deleteItem;

function format(model, key, value) {
  if (model && model[key + "_property"]) {
    if (arguments.length === 3) {
      return model[key + "_property"].format(value);
    } else {
      return model[key + "_property"].format();
    }
  } else {
    if (arguments.length === 3) {
      return value;
    } else {
      return model && model[key];
    }
  }
}

var nextTickTimeout = null;

var nextTickList = [];

var nextTick = function nextTick(fn) {
  nextTickList.push(fn);
  if (!nextTickTimeout) {
    nextTickTimeout = setTimeout(function () {
      var thisTickList = nextTickList;
      nextTickTimeout = null;
      nextTickList = [];
      thisTickList.forEach(function (fn) {
        return fn();
      });
    }, 0);
  }
};

exports.nextTick = nextTick;

var Maybe = (function () {
  function Maybe(value) {
    _classCallCheck(this, Maybe);

    this.value = value;
  }

  // Maybe(a) :: (a -> b) -> Maybe(b)

  _createClass(Maybe, [{
    key: "map",
    value: function map(fn) {
      if (this.value) {
        return new Maybe(fn(this.value));
      } else {
        return this;
      }
    }
  }, {
    key: "prop",
    value: function prop(name) {
      return this.map(function (value) {
        return value[name];
      });
    }
  }, {
    key: "call",
    value: function call(name) {
      var _this = this;

      for (var _len2 = arguments.length, args = Array(_len2 > 1 ? _len2 - 1 : 0), _key2 = 1; _key2 < _len2; _key2++) {
        args[_key2 - 1] = arguments[_key2];
      }

      return this.prop(name).map(function (fn) {
        return fn.apply(_this.value, args);
      });
    }
  }]);

  return Maybe;
})();

function maybe(value) {
  return new Maybe(value);
}
