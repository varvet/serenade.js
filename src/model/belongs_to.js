import { merge } from "../helpers"
import Collection from "../collection"

export default function(name, options) {
  let channelName = "@" + name;

  if(!options) options = {};

  let attributeOptions = merge(options, {
    set: function(model) {
      if(model && model.constructor === Object && options.as) {
        model = new (options.as())(model);
      }
      let previous = this[channelName].value;
      this[channelName].emit(model);
      if (options.inverseOf) {
        if(previous) {
          previous[options.inverseOf].delete(this);
        }
        if(model) {
          let newCollection = model[options.inverseOf];
          if(newCollection.indexOf(this) === -1) newCollection.push(this);
        }
      }
    }
  });

  this.attribute(name, attributeOptions);
  this.property(name + 'Id', {
    get: function(object) {
      return object && object.id;
    },
    set: function(id) {
      if(id) {
        this[name] = options.as().find(id);
      }
    },
    dependsOn: name,
    serialize: options.serializeId
  });
};
