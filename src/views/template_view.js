import { settings } from "../helpers"

import DynamicView from "./dynamic_view"

import Collection from "../collection"
import { instruction } from "../compile"

class TemplateView extends DynamicView {
  constructor(asts, context) {
    super();
    this.context = context;
    this.children = new Collection(asts.map((ast) => instruction(ast, context)));
  }

  get fragment() {
    let fragment = settings.document.createDocumentFragment();
    this.append(fragment);
    fragment.view = this;
    fragment.isView = true;
    fragment.remove = this.remove.bind(this);
    fragment.append = this.append.bind(this);
    fragment.insertAfter = this.insertAfter.bind(this);
    fragment.detach = this.detach.bind(this);
    Object.defineProperty(fragment, "lastElement", { get: () => this.lastElement })
    return fragment;
  }
}

export default TemplateView;
