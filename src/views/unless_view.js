import DynamicView from "./dynamic_view"
import TemplateView from "./template_view"
import Compile from "../compile"

class UnlessView extends DynamicView {
  constructor(ast, context) {
    super(ast, context);

    if(ast.arguments.length !== 1) {
      throw(new Error("`if` must take exactly one argument"))
    }

    this._bind(Compile.parameter(ast.arguments[0], context), (value) => {
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
