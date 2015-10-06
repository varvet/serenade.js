import DynamicView from "./dynamic_view"
import View from "./view"
import TemplateView from "./template_view"
import Collection from "../collection"
import { settings } from "../helpers"
import Compile from "../compile"
import Channel from "../channel"

class HelperView extends DynamicView {
  constructor(ast, context, helper) {
    super();
    this.ast = ast;
    this.context = context;

    this.helper = helper;

    let argChannels = this.ast.arguments.map((property) => Compile.parameter(property, context));
    this.bind(Channel.all(argChannels), (args) => {
      let result = this.helper.apply({
        context: this.context,
        render: this.render.bind(this),
      }, args);

      if(!result) {
        this.clear();
      } else if(result.isView) {
        this.replace([result]);
      } else {
        this.replace(new View(result));
      }
    });
  }

  render(context) {
    return new TemplateView(this.ast.children, context).fragment;
  }
}

Compile.helper = function(ast, context) {
  return settings.views[ast.command](ast, context);
};


export default HelperView;
