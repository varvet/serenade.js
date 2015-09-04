import DynamicView from "./dynamic_view"
import View from "./view"
import TemplateView from "./template_view"
import Collection from "../collection"
import { settings } from "../helpers"
import Compile from "../compile"
import Channel from "../channel/channel"

function normalize(val) {
  if(!val) return [];

  return new Collection([].concat(val).reduce((aggregate, element) => {
    if(typeof element === "string") {
      let div = settings.document.createElement("div");
      div.innerHTML = element;
      Array.prototype.forEach.call(div.childNodes, (child) => {
        aggregate.push(new View(child));
      });
    } else if(element.nodeName === "#document-fragment") {
      if (element.view) {
        aggregate = aggregate.concat(element.view);
      } else {
        Array.prototype.forEach.call(element.childNodes, (child) => {
          aggregate.push(new View(child));
        });
      }
    } else {
      aggregate.push(new View(element));
    }
    return aggregate;
  }, []));
};

class HelperView extends DynamicView {
  constructor(ast, context, helper) {
    super(ast, context);

    this.helper = helper;

    let propertyChannels = this.ast.properties.map((property) => Compile.parameter(property, context));
    let channel = Channel.all(propertyChannels).bind((args) => {
      this.children = normalize(this.helper.call({
        context: this.context,
        render: this.render.bind(this),
      }, args));
      this.rebuild();
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
