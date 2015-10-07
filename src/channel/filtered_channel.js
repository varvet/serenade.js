import DerivedChannel from "./derived_channel"

export default class FilteredChannel extends DerivedChannel {
  constructor(parent, fn) {
    super(parent);
    this.fn = typeof(fn) === "function" ? fn : () => fn;
  }

  _handler(value) {
    if(this.fn(value)) {
      this.trigger(value);
    }
  }
}
