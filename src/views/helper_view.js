import DynamicView from "./dynamic_view"
import View from "./view"
import TemplateView from "./template_view"
import Collection from "../collection"

function normalize(val) {
  if(!val) return [];

  return new Collection([].concat(val).reduce((aggregate, element) => {
    if(typeof element === "string") {
      let div = Serenade.document.createElement("div");
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
    this.ast = ast;
    this.context = context;
    this.helper = helper;
    this.render = this.render.bind(this);
    this.update = this.update.bind(this);

    super(ast, context);

    this.update();

    this.ast.properties.forEach((property) => {
      if (property.bound === true) {
        this._bindEvent(context["" + property.value + "_property"], this.update);
      }
    });
  }

  update() {
    this.clear();
    this.children = normalize(this.helper.call({
      context: this.context,
      render: this.render
    }, this.arguments));
    this.rebuild();
  }

  get arguments() {
    let args = {};
    this.ast.properties.forEach((property) => {
      if(property.scope !== "attribute") {
        throw new SyntaxError("scope '" + property.scope + "' is not allowed for custom helpers");
      }
      args[property.name] = (property.static || property.bound) ? this.context[property.value] : property.value;
    });
    return args;
  }

  render(context) {
    return new TemplateView(this.ast.children, context).fragment;
  }
}

export default HelperView;
