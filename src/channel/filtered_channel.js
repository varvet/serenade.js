import BaseChannel from "./base_channel"
import { deleteItem } from "../helpers"

export default class FilteredChannel extends BaseChannel {
  constructor(parent, fn) {
    super(undefined);
    this.fn = typeof(fn) === "function" ? fn : () => fn;
    this.subscribers = [];
    this.parent = parent;
    this.handler = (value) => {
      if(this.fn(value)) {
        this.subscribers.forEach((callback) => {
          callback(this.value);
        });
      }
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
    return this.parent.value;
  }

  set value(value) {
    // No op
  }
}

BaseChannel.prototype.filter = function(fn) {
  return new FilteredChannel(this, fn);
}
