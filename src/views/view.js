import Collection from "../collection"

class View {
  constructor(node) {
    this.node = node;
    this.children = [];
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

    if (this.boundEvents) {
      this.boundEvents.forEach(({ event, fun }) => event.unbind(fun))
    }
  }

  get lastElement() {
    return this.node;
  }

  _bindEvent(event, fun) {
    if(event) {
      this.boundEvents || (this.boundEvents = new Collection());
      this.boundEvents.push({ event, fun });
      event.bind(fun);
    }
  }

  _unbindEvent(event, fun) {
    if(event) {
      this.boundEvents || (this.boundEvents = new Collection());
      this.boundEvents.delete(fun);
      event.unbind(fun);
    }
  }

  _bindToModel(name, fun) {
    let value = this.context[name];
    let property = this.context["" + name + "_property"];
    if(property && property.registerGlobal) {
      property.registerGlobal(value);
    }
    this._bindEvent(property, (_, value) => fun(value));
    fun(value);
  }
}

export default View;
