import BaseChannel from "./base_channel"

export default class DerivedChannel extends BaseChannel {
  constructor(parent, fn) {
    super();
    this.parent = parent;
  }

  _activate() {
    this.parent.subscribe(this.trigger)
  }

  _deactivate() {
    this.parent.unsubscribe(this.trigger)
  }
}
