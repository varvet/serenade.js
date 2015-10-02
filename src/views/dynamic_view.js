import View from "./view"
import Collection from "../collection"
import { settings } from "../helpers"

class DynamicView extends View {
  constructor(channel, fn) {
    super(settings.document.createTextNode(''), channel, fn);
    this.items = [];
    this.children = new Collection();
  }

  replace(children) {
    this.clear();
    this.children = new Collection(children);
    this.rebuild();
  }

  rebuild() {
    if(this.node.parentNode) {
      let last = this.node;
      this.children.forEach((child) => {
        child.insertAfter(last);
        last = child.lastElement;
      });
    }
  }

  clear() {
    this.children.forEach((child) => child.remove())
    this.children.update([]);
  }

  remove() {
    this.children.forEach((child) => child.remove())
    super.remove();
  }

  append(inside) {
    super.append(inside);
    this.rebuild();
  }

  insertAfter(after) {
    super.insertAfter(after);
    this.rebuild();
  }

  get lastElement() {
    return (this.children.last && this.children.last.lastElement) || this.anchor;
  }
}

export default DynamicView;
