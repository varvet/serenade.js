"use strict";

export var settings = {
  async: false,
  views: {},
  templates: {},
};

export function extend(target, source) {
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

export function merge(...args) {
  return args.reduce(((ack, object) => extend(ack, object)), {})
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

export var addItem = function (collection, item) {
  let index = collection.indexOf(item);

  if(index === -1) {
    collection.push(item);
  }
};

export var deleteItem = function (collection, item) {
  let index = collection.indexOf(item);

  if(index !== -1) {
    collection.splice(index, 1);
  }
};

export function format(model, key, value) {
  if(model && model[key + "_property"]) {
    if(arguments.length === 3) {
      return model[key + "_property"].format(value);
    } else {
      return model[key + "_property"].format();
    }
  } else {
    if(arguments.length === 3) {
      return value;
    } else {
      return model && model[key];
    }
  }
}

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

class Maybe {
  constructor(value) {
    this.value = value;
  }

  // Maybe(a) :: (a -> b) -> Maybe(b)
  map(fn) {
    if(this.value) {
      return new Maybe(fn(this.value))
    } else {
      return this;
    }
  }

  prop(name) {
    return this.map((value) => value[name])
  }

  call(name, ...args) {
    return this.prop(name).map((fn) => fn.apply(this.value, args))
  }
}

export function maybe(value) {
  return new Maybe(value);
}
