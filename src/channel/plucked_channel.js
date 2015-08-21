import Channel from "./channel"
import StaticChannel from "./static_channel"
import { deleteItem } from "../helpers"

export default class PluckedChannel extends StaticChannel {
  constructor(parent, property) {
    var oldValue;
    super(undefined);
    this.parent = parent;
    this.property = property;
    this.appliedHandler = (value) => {
      this.subscribers.forEach((cb) => cb(this.value));
    };
    this.handler = (value) => {
      Channel.get(oldValue, property).unsubscribe(this.appliedHandler);
      Channel.get(value, property).bind(this.appliedHandler);
      oldValue = value;
    };
    this.subscribers = [];
    this.handler(parent.value);
  }

  subscribe(cb) {
    if(!this.subscribers.length) {
      this.parent.subscribe(this.handler)
    }
    this.subscribers.push(cb);
  }

  unsubscribe(cb) {
    deleteItem(this.subscribers, cb);
    if(!this.subscribers.length) {
      this.parent.unsubscribe(this.handler)
    }
  }

  get value() {
    return Channel.get(this.parent.value, this.property).value
  }

  set value(value) {
    // No op
  }
}

StaticChannel.prototype.pluck = function(property) {
  return new PluckedChannel(this, property);
}
