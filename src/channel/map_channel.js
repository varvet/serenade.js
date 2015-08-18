import Channel from "./channel"
import StaticChannel from "./static_channel"

export default class MapChannel extends StaticChannel {
  constructor(parent, fn) {
    super(undefined);
    this.parent = parent;
    this.handler = (value) => {
      this.channel.emit(fn(value));
    };
    this.channel = new Channel(fn(parent.value));
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
    return this.channel.value;
  }

  set value(value) {
    // No op
  }
}

StaticChannel.prototype.map = function(fn) {
  return new MapChannel(this, fn);
}
