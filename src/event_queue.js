export default class EventQueue {
  constructor(manager, name) {
    this.manager = manager;
    this.name = name;
    this.channels = [];
  }

  tick() {
    for(let i = 0; i < this.channels.length; i++) {
      this.channels[i].trigger();
    }
    this.channels.forEach((channel) => channel.reset());
    this.channels = [];
  }

  enqueue(channel) {
    this.channels.push(channel);
    this.manager.ping();
  }
}
