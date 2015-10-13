import Model from "./model"
import Cache from "./cache"
import Template from "./template"
import Collection from "./collection"
import { defineProperty, defineAttribute, defineChannel } from "./property"
import { extend, settings } from "./helpers"
import Channel from "./channel"
import EventManager from "./event_manager"

import CollectionView from "./views/collection_view"
import Element from "./views/element"
import View from "./views/view"
import DynamicView from "./views/dynamic_view"
import GlobalContext from "./context"
import * as Decorators from "./decorators"

function Serenade(wrapped) {
  let object = Object.create(wrapped);
  for(let key in wrapped) {
    defineAttribute(object, key, { value: wrapped[key] });
  }
  return object;
};

if(typeof(window) !== "undefined") {
  settings.document = window.document;
}

settings.eventManager = EventManager.default();

extend(Serenade, {
  VERSION: '0.5.0',
  defineProperty: defineProperty,
  defineAttribute: defineAttribute,
  defineChannel: defineChannel,
  Context: GlobalContext,
  Decorators: Decorators,

  helper: function(name, fn) {
    GlobalContext[name] = function(...args) {
      return Channel.all(args).map((args) => {
        return fn.apply(this, args)
      });
    }
  },

  template: function(ast) {
    return new Template(ast);
  },

  clearIdentityMap: function() {
    Cache._identityMap = {};
  },

  clearCache: function() {
    Serenade.clearIdentityMap();
  },

  Model: Model,
  Collection: Collection,
  Cache: Cache,
  Template: Template,
  View: View,
  Element: Element,
  CollectionView: CollectionView,
  Channel: Channel,

  get async() {
    return settings.async;
  },

  set async(value) {
    settings.async = value;
  },

  get document() {
    return settings.document;
  },

  set document(value) {
    settings.document = value;
  },

  get eventManager() {
    return settings.eventManager;
  },

  set eventManager(value) {
    settings.eventManager = value;
  },
});


export default Serenade;
