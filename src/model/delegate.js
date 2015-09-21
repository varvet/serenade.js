import { merge, capitalize, format } from "../helpers"

export default function(...names) {
  let options = typeof(names[names.length - 1]) !== "string" ? names.pop() : {};
  let { to } = options;

  names.forEach((name) => {
    let propName = name;
    if (options.prefix === true) {
      propName = to + capitalize(propName);
    } else if (options.prefix) {
      propName = options.prefix + capitalize(propName);
    }
    if (options.suffix === true) {
      propName = propName + capitalize(to);
    } else if (options.suffix) {
      propName = propName + options.suffix;
    }
    let propOptions = merge(options, {
      dependsOn: options.dependsOn || `${to}.${name}`,
      get() {
        return this[to] && this[to][name]
      },
      set(value) {
        if(this[to]) {
          this[to][name] = value;
        }
      },
      format() {
        if(this[to]) {
          return format(this[to], name)
        }
      }
    });

    this.property(propName, propOptions);
  });
};
