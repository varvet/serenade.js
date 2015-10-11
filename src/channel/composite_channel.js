import BaseChannel from "./base_channel"
import Channel from "./channel"

export default class CompositeChannel extends BaseChannel {
  constructor(parents) {
    super();
    this.parents = parents.map((parent) => {
      if(parent && parent.isChannel) {
        return parent;
      } else {
        return Channel.static(parent);
      }
    });
  }

  expire() {
    this.parens.forEach((parent) => parent.expire());
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
