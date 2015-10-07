import DerivedChannel from "./derived_channel"

export default class MappedChannel extends DerivedChannel {
  constructor(parent, fn) {
    super(parent);
    this.fn = fn;
  }

  get value() {
    return this.fn(this.parent.value);
  }
}
