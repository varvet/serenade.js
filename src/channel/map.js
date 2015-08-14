import Channel from "../channel"

export default class MapChannel extends Channel {
  constructor(parent) {
    this.parent = parent;
    this.handler = (value) => reduction(this, value);
    this.channel = new Channel()
  }

  subscribe(callback) {
    if(!this.channel._subscribers.length) {
      this.parent.subscribe(this.handler)
    }
    this.channel.subscribe(callback);
  }

  unsubscribe(callback) {
    this.channel.unsubscribe(callback);
    if(!this.channel_subscribers.length) {
      this.parent.unsubscribe(this.handler)
    }
  }
}
