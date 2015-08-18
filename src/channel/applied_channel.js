import Channel from "./channel"
import StaticChannel from "./static_channel"

export default class AppliedChannel extends StaticChannel {
  constructor(parent, property) {
    var oldValue;
    super(undefined);
    this.parent = parent;
    this.appliedHandler = (value) => {
      this.channel.emit(value);
    };
    this.handler = (value) => {
      Channel.get(oldValue, property).unsubscribe(this.appliedHandler);
      Channel.get(value, property).bind(this.appliedHandler);
      oldValue = value;
    };
    this.channel = new Channel(undefined);
    this.handler(parent.value);
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

StaticChannel.prototype.apply = function(property) {
  return new AppliedChannel(this, property);
}
