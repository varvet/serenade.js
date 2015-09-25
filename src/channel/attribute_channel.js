import BaseChannel from "./base_channel"
import StaticChannel from "./static_channel"

export default class AttributeChannel extends BaseChannel {
  constructor(context, options) {
    super()
    this.context = context;
    this.options = options;
  }

  emit(value) {
    let changed = this.options.changed.call(this.context, this.value, value);
    this.value = value;
    if(changed) {
      this.trigger();
    }
  }
}
