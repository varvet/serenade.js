import BaseChannel from "./base_channel"

export default class Channel extends BaseChannel {
  constructor(value) {
    super()
    this.value = value
  }

  emit(value) {
    this.value = value;
    this.trigger();
  }
}
