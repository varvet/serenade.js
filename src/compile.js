import { extend } from "./helpers"

import Channel from "./channel"
import DynamicView from "./views/dynamic_view"
import View from "./views/view"
import TextView from "./views/text_view"
import GlobalContext from "./context"
import Template from "./template"

export function callAction(context, name, args) {
  let action = (context && context[name]) || GlobalContext[name];

  if(!action) {
    console.error("No such action in context:", name, context);
    throw(new Error("No such action in context: " + name));
  }

  return action.apply(context, args);
}

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

  return toView(callAction(context, ast.type, args));
}

export function parameter(ast, context) {
  let channel;
  if(ast.filter) {
    let args = ast.arguments.map((arg) => parameter(arg, context));
    channel = callAction(context, ast.filter, args);
  } else if(ast.bound) {
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
