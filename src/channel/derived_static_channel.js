import BaseChannel from "./base_channel"
import DerivedChannel from "./derived_channel"

export default class DerivedStaticChannel extends DerivedChannel {
  constructor(parent) {
    super(parent)
  }

  subscribe() {}
  unsubscribe() {}
  trigger() {}
}

BaseChannel.prototype.static = function() {
  return new DerivedStaticChannel(this);
};
