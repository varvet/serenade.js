import Channel from "./channel"
import StaticChannel from "./static_channel"
import { deleteItem } from "../helpers"

export default class CompositeChannel extends StaticChannel {
  constructor(parents) {
    super(undefined);
    this.parents = parents;

    this.handler = () => {
      this.subscribers.forEach((callback) => callback(this.value));
    }
    this.subscribers = [];
  }

  subscribe(callback) {
    if(!this.subscribers.length) {
      this.parents.forEach((parent) => parent.subscribe(this.handler));
    }
    this.subscribers.push(callback);
  }

  unsubscribe(callback) {
    deleteItem(this.subscribers, callback);
    if(!this.subscribers.length) {
      this.parents.forEach((parent) => parent.unsubscribe(this.handler));
    }
  }

  get value() {
    return this.parents.map((p) => p.value)
  }

  set value(value) {
    // No op
  }
}

Channel.all = function(parents) {
  return new CompositeChannel(parents);
}
