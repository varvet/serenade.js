import DynamicView from "./dynamic_view"
import TemplateView from "./template_view"
import Compile from "../compile"

class IfView extends DynamicView {
  constructor(ast, context) {
    super(ast, context);

    if(ast.arguments.length !== 1) {
      throw(new Error("`if` must take exactly one argument"))
    }

    this.bind(Compile.parameter(ast.arguments[0], context), (value) => {
      if(value) {
        this.replace([new TemplateView(ast.children, context)]);
      } else if(ast.else) {
        this.replace([new TemplateView(ast.else.children, context)]);
      } else {
        this.clear();
      }
    });
  }
}

Compile.if = function(ast, context) {
  return new IfView(ast, context);
};

export default IfView;
