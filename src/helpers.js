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
      if(!this.hasOwnProperty("_" + name)) {
        let options;
        if(name in Object.getPrototypeOf(this)) {
          options = Object.create(Object.getPrototypeOf(this)[name]);
        }
        Object.defineProperty(this, "_" + name, { configurable: true, writable: true, value: options || {} });
      }
      return this["_" + name];
    }
  });
};

export function extend(target, source, enumerable) {
  if(enumerable == null) {
    enumerable = true;
  }
  for(let key in source) {
    if(Object.hasOwnProperty.call(source, key)) {
      Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key));
    }
  }
  return target;
};

export function assignUnlessEqual(object, prop, value) {
  if(object[prop] !== value) {
    object[prop] = value;
  }
};

export function merge(target, source, enumerable) {
  if (enumerable == null) {
    enumerable = true;
  }
  return extend(extend({}, target, enumerable), source, enumerable);
};

function isArray(object) {
  return Object.prototype.toString.call(object) === "[object Array]";
};

export function serializeObject(object) {
  if(object && typeof(object.toJSON) === "function") {
    return object.toJSON();
  } else if(isArray(object)) {
    return object.map((item) => serializeObject(item))
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
  let key;
  if(value instanceof Object) {
    if(!("_s_hash" in value)) {
      if(hash_current >= hash_max) { hash_prefix = Math.random().toString(36) };
      Object.defineProperty(value, "_s_hash", { value: hash_prefix + (++hash_current) });
    }
    key = value._s_hash;
  } else {
    key = value;
  }
  return typeof(value) + " " + key;
};

export function safePush(object, collection, item) {
  if (!object[collection] || object[collection].indexOf(item) === -1) {
    if(object.hasOwnProperty(collection)) {
      object[collection].push(item);
    } else if(object[collection]) {
      def(object, collection, { value: [item].concat(object[collection]) });
    } else {
      def(object, collection, { value: [item] });
    }
  }
};

export var safeDelete = function (object, collection, item) {
  if(!object[collection]) return;

  let index = object[collection].indexOf(item);

  if(index !== -1) {
    if(!object.hasOwnProperty(collection)) {
      def(object, collection, { value: [].concat(object[collection]) });
    }
    object[collection].splice(index, 1);
  }
};

var nextTickTimeout = null;

var nextTickList = [];

export var nextTick = function (fn) {
  nextTickList.push(fn);
  if(!nextTickTimeout) {
    nextTickTimeout = setTimeout(function () {
      let thisTickList = nextTickList;
      nextTickTimeout = null;
      nextTickList = [];
      thisTickList.forEach((fn) => fn())
    }, 0);
  }
};
