import StaticChannel from "./static_channel"
import { deleteItem } from "../helpers"

export default class MappedChannel extends StaticChannel {
  constructor(parent, fn) {
    super(undefined);
    this.subscribers = []
    this.fn = fn;
    this.parent = parent;
    this.handler = (value) => {
      this.subscribers.forEach((callback) => {
        callback(this.value);
      });
    };
  }

  subscribe(callback) {
    if(!this.subscribers.length) {
      this.parent.subscribe(this.handler)
    }
    this.subscribers.push(callback);
  }

  unsubscribe(callback) {
    deleteItem(this.subscribers, callback)
    if(!this.subscribers.length) {
      this.parent.unsubscribe(this.handler)
    }
  }

  get value() {
    return this.fn(this.parent.value);
  }

  set value(value) {
    // No op
  }
}

StaticChannel.prototype.map = function(fn) {
  return new MappedChannel(this, fn);
}
