import DynamicView from "./dynamic_view"
import { def, settings } from "../helpers"
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
    fragment.remove = this.remove.bind(this);
    return fragment;
  }
}

export default TemplateView;
