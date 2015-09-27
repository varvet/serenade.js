import { merge } from "../helpers"

export default function(name, options) {
  if(!options) options = {};
  if(!options.from) throw new Error("must specify `from` option");

  let dependencies = [options.from].concat(options.dependsOn || []);

  if(typeof(options.filter) === "string") dependencies.push(`${options.from}:${options.filter}`)
  if(typeof(options.map) === "string") dependencies.push(`${options.from}:${options.map}`)

  let propertyOptions = merge(options, {
    get: function() {
      let collection = this[options.from];
      for(let key in options) {
        let value = options[key];
        if(key === "filter" || key === "map") {
          if(typeof options[key] === "string") {
            collection = collection[key]((item) => item[options[key]]);
          } else {
            collection = collection[key]((item) => options[key](item));
          }
        }
      }
      return collection;
    },
    dependsOn: dependencies
  });

  this.property(name, propertyOptions);
  this.property(name + 'Count', {
    get: function() {
      return this[name].length;
    },
    dependsOn: name
  });
};
