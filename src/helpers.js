"use strict";

export var settings = {
  async: false
};

export var def = Object.defineProperty;

export var hasProp = Object.hasOwnProperty;

export var primitiveTypes = ["undefined", "boolean", "number", "string"];

export function defineOptions(object, name) {
  return def(object, name, {
    get: function get() {
      var options;
      if (!this.hasOwnProperty("_" + name)) {
        options = name in Object.getPrototypeOf(this) ? Object.create(Object.getPrototypeOf(this)[name]) : {};
        def(this, "_" + name, {
          configurable: true,
          writable: true,
          value: options
        });
      }
      return this["_" + name];
    }
  });
};

export function extend(target, source, enumerable) {
  var key, value;
  if (enumerable == null) {
    enumerable = true;
  }
  for (key in source) {
    if (!hasProp.call(source, key)) continue;
    value = source[key];
    if (enumerable) {
      target[key] = value;
    } else {
      def(target, key, { value: value, configurable: true });
    }
  }
  return target;
};

export var assignUnlessEqual = function (object, prop, value) {
  if (object[prop] !== value) {
    return object[prop] = value;
  }
};

export var merge = function (target, source, enumerable) {
  if (enumerable == null) {
    enumerable = true;
  }
  return extend(extend({}, target, enumerable), source, enumerable);
};

export var isArray = function (object) {
  return Object.prototype.toString.call(object) === "[object Array]";
};

export var pairToObject = function (one, two) {
  var temp;
  temp = {};
  temp[one] = two;
  return temp;
};

export var serializeObject = function (object) {
  var item, _i, _len, _results;
  if (object && typeof object.toJSON === "function") {
    return object.toJSON();
  } else if (isArray(object)) {
    _results = [];
    for (_i = 0, _len = object.length; _i < _len; _i++) {
      item = object[_i];
      _results.push(serializeObject(item));
    }
    return _results;
  } else {
    return object;
  }
};

export var capitalize = function (word) {
  return word.slice(0, 1).toUpperCase() + word.slice(1);
};

var hash_current = 0;

var hash_prefix = "";

const hash_max = Math.pow(10, 12);

export var hash = function (value) {
  var key;
  key = value instanceof Object ? (!("_s_hash" in value) ? (hash_current >= hash_max ? hash_prefix = Math.random().toString(36) : void 0, def(value, "_s_hash", {
    value: hash_prefix + ++hash_current
  })) : void 0, value._s_hash) : value;
  return typeof value + " " + key;
};

export function safePush(object, collection, item) {
  if (!object[collection] || object[collection].indexOf(item) === -1) {
    if (object.hasOwnProperty(collection)) {
      return object[collection].push(item);
    } else if (object[collection]) {
      return def(object, collection, {
        value: [item].concat(object[collection])
      });
    } else {
      return def(object, collection, {
        value: [item]
      });
    }
  }
};

export var safeDelete = function (object, collection, item) {
  var index;
  if (object[collection] && (index = object[collection].indexOf(item)) !== -1) {
    if (!object.hasOwnProperty(collection)) {
      def(object, collection, {
        value: [].concat(object[collection])
      });
    }
    return object[collection].splice(index, 1);
  }
};

var nextTickTimeout = null;

var nextTickList = [];

export var nextTick = function (fn) {
  nextTickList.push(fn);
  return nextTickTimeout || (nextTickTimeout = setTimeout(function () {
    var thisTickList, _i, _len, _results;
    thisTickList = nextTickList;
    nextTickTimeout = null;
    nextTickList = [];
    _results = [];
    for (_i = 0, _len = thisTickList.length; _i < _len; _i++) {
      fn = thisTickList[_i];
      _results.push(fn());
    }
    return _results;
  }, 0));
};

export var notImplemeted = function () {
  throw new Error("not implemented");
};
