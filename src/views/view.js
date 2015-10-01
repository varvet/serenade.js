import Collection from "../collection"

class View {
  constructor(node) {
    this.node = node;
    this.children = [];
    this.attached = false;
  }

  append(inside, skipAttach = false) {
    inside.appendChild(this.node);
    if(!skipAttach) this.attach();
  }

  insertAfter(after, skipAttach = false) {
    after.parentNode.insertBefore(this.node, after.nextSibling);
    if(!skipAttach) this.attach();
  }

  remove() {
    if (this.node.parentNode) {
      this.node.parentNode.removeChild(this.node);
    }
    this.detach();
  }

  attach() {
    this.attached = true;

    this.children.forEach((child) => child.attach());
  }

  detach() {
    this.attached = false;

    this.children.forEach((child) => child.detach());

    if(this.boundEvents) {
      this.boundEvents.forEach(({ event, fun }) => event.unbind(fun))
      this.boundEvents = [];
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

View.prototype.isView = true;

export default View;
