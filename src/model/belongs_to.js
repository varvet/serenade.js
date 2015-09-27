import { merge, addItem, deleteItem } from "../helpers"
import Collection from "../collection"

export default function(name, options = {}) {
  options = merge({ channelName: "@" + name }, options);

  let attributeOptions = merge(options, {
    set: function(model) {
      if(model && model.constructor === Object && options.as) {
        model = new (options.as())(model);
      }
      this[options.channelName].emit(model);
      if (options.inverseOf && model) {
        let collection = model[options.inverseOf];
        addItem(collection, this);
        this[options.channelName].gc(() => deleteItem(collection, this));
      }
    }
  });

  delete attributeOptions.as;

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
