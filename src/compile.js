import { extend } from "./helpers"

import Channel from "./channel"
import DynamicView from "./views/dynamic_view"
import View from "./views/view"
import TextView from "./views/text_view"
import GlobalContext from "./context"
import Template from "./template"

export function instruction(ast, context) {
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

  return toView(result);
}

export function parameter(ast, context) {
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

export function toView(object) {
  if(object && object.isView) {
    return object;
  } else if(object && object.isChannel) {
    let view = new DynamicView();
    view.bind(object, (value) => {
      view.replace([toView(value)]);
    });
    return view;
  } else if(object && object.nodeType === 1) {
    return new View(object);
  } else if(object && object.nodeType === 3) {
    return new TextView(object.nodeValue);
  } else {
    return new TextView(object);
  }
}
