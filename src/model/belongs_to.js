import { merge } from "../helpers"
import Collection from "../collection"

export default function(name, options) {
  if(!options) options = {};

  let propOptions = merge(options, {
    set: function(model) {
      let valueName = "_" + name;
      if(model && model.constructor === Object && options.as) {
        model = new (options.as())(model);
      }
      let previous = this[valueName];
      this[valueName] = model;
      if (options.inverseOf) {
        if(previous !== model) {
          if(previous) {
            previous[options.inverseOf].delete(this);
          }
          if(model) {
            let newCollection = model[options.inverseOf];
            if(newCollection.indexOf(this) === -1) newCollection.push(this);
          }
        }
      }
    }
  });

  this.property(name, propOptions);
  this.property(name + 'Id', {
    get: function() {
      return this[name] && this[name].id;
    },
    set: function(id) {
      if(id) this[name] = options.as().find(id);
    },
    dependsOn: name,
    serialize: options.serializeId
  });
};
