import BaseChannel from "./base_channel"

export default class StaticChannel extends BaseChannel {
  constructor(value) {
    super()
    this.value = value;
  }

  subscribe() {}
  unsubscribe() {}
  trigger() {}
}
