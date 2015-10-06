import { settings, extend } from "../helpers"

import DynamicView from "./dynamic_view"
import TextView from "./text_view"

import Compile from "../compile"
import Collection from "../collection"
import GlobalContext from "../context"
import Channel from "../channel"
import Template from "../template"

function parameter(ast, context) {
  let channel;
  if(ast.bound) {
    if(ast.property === "this") {
      channel = Channel.static(context);
    } else {
      let value = context && context[ast.property];
      if(value && value.isChannel) {
        channel = value;
      } else {
        channel = Channel.static(value);
      }
    }
  } else {
    channel = Channel.static(ast.property);
  }

  extend(channel, ast);

  return channel;
}

class TemplateView extends DynamicView {
  constructor(asts, context) {
    super();
    this.ast = asts;
    this.context = context;

    this.children = new Collection(asts.map((ast) => {
      let args = [];
      let options = {};

      if(ast.arguments) {
        args = ast.arguments.map((arg) => parameter(arg, context));
      }
      if(ast.options) {
        ast.options.forEach((arg) => options[arg.name] = parameter(arg, context));
      }
      if(ast.children && ast.children.length) {
        options.do = new Template(ast.children);
      }
      if(ast.else && ast.else.children.length) {
        options.else = new Template(ast.else.children);
      }
      if(ast.type === "element") {
        args.unshift(ast.name);
      }

      options.classes = ast.classes || [];

      args.push(options)

      let action = (context && context[ast.type]) || GlobalContext[ast.type];

      if(!action) {
        console.error("No such action in context:", ast.type, context);
        throw(new Error("No such action in context: " + ast.type));
      }

      let result = action.apply(context, args);

      if(result && result.isView) {
        return result;
      } else if(result && result.isChannel) {
        let view = new DynamicView();
        view.bind(channel, (value) => {
          view.replace([].concat(value));
        });
        return view;
      } else {
        return new TextView();
      }
    }));
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
