import Channel from "./channel"
import StaticChannel from "./static_channel"

export default class MappedChannel extends StaticChannel {
  constructor(parent, fn) {
    super(undefined);
    this.fn = fn;
    this.parent = parent;
    this.handler = (value) => {
      this.channel.emit(this.value);
    };
    this.channel = new Channel(this.value);
  }

  subscribe(callback) {
    if(!this.channel._subscribers.length) {
      this.parent.subscribe(this.handler)
    }
    this.channel.subscribe(callback);
  }

  unsubscribe(callback) {
    this.channel.unsubscribe(callback);
    if(!this.channel._subscribers.length) {
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
