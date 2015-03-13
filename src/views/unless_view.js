import DynamicView from "./dynamic_view"
import TemplateView from "./template_view"
import Compile from "../compile"

class UnlessView extends DynamicView {
  constructor(ast, context) {
    super(ast, context);
    this._bindToModel(ast.argument, (value) => {
      if (value) {
        return this.clear();
      } else {
        return this.replace([new TemplateView(ast.children, context)]);
      }
    });
  }
}

Compile.unless = function(ast, context) {
  return new UnlessView(ast, context);
};

export default UnlessView;
