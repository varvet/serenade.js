import BaseChannel from "./base_channel"
import DerivedChannel from "./derived_channel"

export default class FilteredChannel extends DerivedChannel {
  constructor(parent, fn) {
    super(parent);
    this.fn = typeof(fn) === "function" ? fn : () => fn;
  }

  handler(value) {
    if(this.fn(value)) {
      this.trigger(value);
    }
  }
}

BaseChannel.prototype.filter = function(fn) {
  return new FilteredChannel(this, fn);
}
