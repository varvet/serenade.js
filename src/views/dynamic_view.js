import View from "./view"
import Collection from "../collection"
import { settings } from "../helpers"

class DynamicView extends View {
  constructor(ast, context) {
    super()
    this.ast = ast;
    this.context = context;
    this.anchor = settings.document.createTextNode('');
    this.items = [];
    this.children = new Collection();
  }

  replace(children) {
    this.clear();
    this.children = new Collection(children);
    this.rebuild();
  }

  rebuild() {
    if (this.anchor.parentNode) {
      let last = this.anchor;
      this.children.forEach((child) => {
        child.insertAfter(last, !this.attached);
        last = child.lastElement;
      });
    }
  }

  clear() {
    this.children.forEach((child) => child.remove())
    this.children.update([]);
  }

  remove() {
    this.detach();
    this.children.forEach((child) => child.remove());
    if (this.anchor.parentNode) {
      this.anchor.parentNode.removeChild(this.anchor);
    }
  }

  append(inside, skipAttach = false) {
    inside.appendChild(this.anchor);
    this.rebuild();
    if(!skipAttach) this.attach();
  }

  insertAfter(after, skipAttach = false) {
    after.parentNode.insertBefore(this.anchor, after.nextSibling);
    this.rebuild();
    if(!skipAttach) this.attach();
  }

  get lastElement() {
    return (this.children.last && this.children.last.lastElement) || this.anchor;
  }
}

export default DynamicView;
