import Channel from "./channel"
import StaticChannel from "./static_channel"

export default class CompositeChannel extends StaticChannel {
  constructor(parents) {
    super(undefined);
    this.parents = parents;

    let value = () => parents.map((p) => p.value)
    this.handler = () => this.channel.emit(value());

    this.channel = new Channel(value())
  }

  subscribe(callback) {
    if(!this.channel._subscribers.length) {
      this.parents.forEach((parent) => parent.subscribe(this.handler));
    }
    this.channel.subscribe(callback);
  }

  unsubscribe(callback) {
    this.channel.unsubscribe(callback);
    if(!this.channel._subscribers.length) {
      this.parents.forEach((parent) => parent.unsubscribe(this.handler));
    }
  }

  get value() {
    return this.channel.value;
  }

  set value(value) {
    // No op
  }
}

Channel.all = function(parents) {
  return new CompositeChannel(parents);
}
