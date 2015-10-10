import Channel from "./channel"
import { defineAttribute, defineProperty } from "./property"

export function helper(object, name, descriptor) {
  let fn = descriptor.value;

  descriptor.value = function(...args) {
    return Channel.all(args).map((args) => {
      return fn.apply(this, args)
    });
  };

  return descriptor;
}

export function attribute(...names) {
  let options = typeof(names[names.length - 1]) === "string" ? {} : names.pop();
  return function(klass) {
    names.forEach((name) => {
      defineAttribute(klass.prototype, name, options)
    });
    return klass;
  }
}

export function property(options = {}) {
  return function(object, name, descriptor) {
    options.get = descriptor.value;
    options.returnDescriptor = true;
    return defineProperty(object, name, options, true);
  }
}
