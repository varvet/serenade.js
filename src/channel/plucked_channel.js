import Channel from "./channel"
import BaseChannel from "./base_channel"
import DerivedChannel from "./derived_channel"

export default class PluckedChannel extends DerivedChannel {
  constructor(parent, property) {
    super(parent);
    this.property = property;
    this.subscribers = [];
  }

  _update(value) {
    Channel.get(this._oldValue, this.property).unsubscribe(this.trigger);
    Channel.get(value, this.property).subscribe(this.trigger);
    this._oldValue = value;
  }

  get value() {
    return Channel.get(this.parent.value, this.property).value
  }
}

BaseChannel.prototype.pluck = function(property) {
  return new PluckedChannel(this, property);
}
