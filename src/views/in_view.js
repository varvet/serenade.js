import DynamicView from "./dynamic_view"
import TemplateView from "./template_view"
import Compile from "../compile"

class InView extends DynamicView {
  constructor(ast, context) {
    super(ast, context)
    this._bindToModel(ast.argument, (value) => {
      if (value) {
        this.replace([new TemplateView(ast.children, value)]);
      } else {
        this.clear();
      }
    });
  }
}

Compile.in = function(ast, context) {
  return new InView(ast, context);
};

export default InView;
