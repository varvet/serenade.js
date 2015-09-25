import Channel from "./channel"
import BaseChannel from "./base_channel"
import StaticChannel from "./static_channel"

export default class AttributeChannel extends BaseChannel {
  constructor(context, options) {
    super()
    this.write = new Channel();
    this.read = this.write.withOptions(context, options);
  }

  emit(value) {
    this.write.emit(value);
  }

  subscribe(callback) {
    this.read.subscribe(callback);
  }

  unsubscribe(callback) {
    this.read.unsubscribe(callback);
  }

  trigger() {
    this.write.trigger();
  }

  get value() {
    return this.read.value;
  }

  get subscribers() {
    return this.read.subscribers
  }

  set subscribers(value) {
    // no op
  }
}
