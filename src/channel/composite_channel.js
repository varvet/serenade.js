import Channel from "./channel"
import BaseChannel from "./base_channel"
import { deleteItem } from "../helpers"

export default class CompositeChannel extends BaseChannel {
  constructor(parents) {
    super();
    this.parents = parents;
  }

  _activate() {
    this.parents.forEach((parent) => parent.subscribe(this.trigger));
  }

  _deactivate() {
    this.parents.forEach((parent) => parent.unsubscribe(this.trigger));
  }

  get value() {
    return this.parents.map((p) => p.value)
  }
}

Channel.all = function(parents) {
  return new CompositeChannel(parents);
}
