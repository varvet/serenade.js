import Collection from "../collection"

class View {
  constructor(node, channel, fn) {
    this.node = node;
    this.children = [];
    this.channels = new Collection();
    this.bind(channel, fn);
  }

  append(inside) {
    inside.appendChild(this.node);
  }

  insertAfter(after) {
    after.parentNode.insertBefore(this.node, after.nextSibling);
  }

  remove() {
    if (this.node.parentNode) {
      this.node.parentNode.removeChild(this.node);
    }
    this.detach();
  }

  detach() {
    this.children.forEach((child) => child.detach())

    this.channels.forEach(({ channel, fun }) => channel.unsubscribe(fun))
  }

  get lastElement() {
    return this.node;
  }

  bind(channel, fun) {
    if(channel) {
      this.channels.push({ channel, fun });
      channel.bind(fun);
    }
  }

  _subscribe(channel, fun) {
    if(channel) {
      this.channels.push({ channel, fun });
      channel.subscribe(fun);
    }
  }

  _unsubscribe(channel, fun) {
    if(channel) {
      this.channels.delete(fun);
      channel.unsubscribe(fun);
    }
  }
}

View.prototype.isView = true;

export default View;
