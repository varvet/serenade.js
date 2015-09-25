import BaseChannel from "./base_channel"

export default class DerivedChannel extends BaseChannel {
  constructor(parent, fn) {
    super();
    this.parent = parent;
    this.handler = this.handler.bind(this);
  }

  handler() {
    this.trigger()
  }

  get value() {
    return this.parent.value;
  }

  _activate() {
    this.parent.subscribe(this.handler)
  }

  _deactivate() {
    this.parent.unsubscribe(this.handler)
  }
}
