import DerivedChannel from "./derived_channel"

export default class DerivedStaticChannel extends DerivedChannel {
  constructor(parent) {
    super(parent)
  }

  subscribe() {}
  unsubscribe() {}
  trigger() {}
}
