import DynamicView from "./dynamic_view"
import { settings } from "../helpers"
import Compile from "../compile"
import Collection from "../collection"

class TemplateView extends DynamicView {
  constructor(asts, context) {
    super(asts, context)
    this.children = new Collection(asts.map((ast) => Compile[ast.type](ast, context)));
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
