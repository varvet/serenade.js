import { merge } from "../helpers"

export default function(name, options) {
  if(!options) options = {};
  if(!options.from) throw new Error("must specify `from` option");

  let propOptions = merge(options, {
    get: function() {
      let current = this[options.from];
      for(let key in options) {
        let value = options[key];
        if(key === "filter" || key === "map") {
          if(typeof options[key] === "string") {
            current = current[key]((item) => item[options[key]]);
          } else {
            current = current[key]((item) => options[key](item));
          }
        }
      }
      return current;
    },
    dependsOn: [`${options.from}:${options.filter}`, `${options.from}:${options.map}`]
  });
  this.property(name, propOptions);
  this.property(name + 'Count', {
    get: function() {
      return this[name].length;
    },
    dependsOn: name
  });
};
