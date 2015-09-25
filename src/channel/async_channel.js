import { settings } from "../helpers"

import DerivedChannel from "./derived_channel"
import BaseChannel from "./base_channel"

export default class AsyncChannel extends DerivedChannel {
  constructor(parent, queueName) {
    super(parent);
    this.queue = settings.eventManager.queues[queueName];
    this.isEnqueued = false;
  }

  _handler() {
    if(!this.isEnqueued) {
      this.isEnqueued = true;
      this.queue.enqueue(this);
    }
  }

  reset() {
    this.isEnqueued = false;
  }
}

BaseChannel.prototype.async = function(queue) {
  return new AsyncChannel(this, queue);
}

