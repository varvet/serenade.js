import { settings } from "./helpers"
import Collection from "./collection"
import EventQueue from "./event_queue"

export default class EventManager {
  static default() {
    let manager = new EventManager();
    manager.push("attribute")
    manager.push("property")
    manager.push("render")
    return manager;
  }

  constructor() {
    this.tick = this.tick.bind(this);
    this.queues = {};
    this.list = [];
  }

  push(name) {
    let queue = new EventQueue(this, name);
    this.list.push(queue);
    this.queues[name] = queue;
  }

  tick() {
    this.frame = null;
    this.list.forEach((queue) => queue.tick());
  }

  ping() {
    if(settings.async) {
      if(!this.frame) {
        this.frame = requestAnimationFrame(this.tick);
      }
    } else {
      this.tick();
    }
  }
}
