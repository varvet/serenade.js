import DynamicView from "./dynamic_view"
import View from "./view"
import TemplateView from "./template_view"
import Collection from "../collection"
import { def } from "../helpers"

function normalize(val) {
  var reduction;
  if (!val) {
    return [];
  }
  reduction = function(aggregate, element) {
    var child, div, _i, _j, _len, _len1, _ref, _ref1;
    if (typeof element === "string") {
      div = Serenade.document.createElement("div");
      div.innerHTML = element;
      _ref = div.childNodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        aggregate.push(new View(child));
      }
    } else if (element.nodeName === "#document-fragment") {
      if (element.view) {
        aggregate = aggregate.concat(element.view);
      } else {
        _ref1 = element.childNodes;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          child = _ref1[_j];
          aggregate.push(new View(child));
        }
      }
    } else {
      aggregate.push(new View(element));
    }
    return aggregate;
  };
  return new Collection([].concat(val).reduce(reduction, []));
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
