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

	view: function(name, fn) {
		return this.views[name] = (ast, context) => new fn(ast, context);
	},

	helper: function(name, fn) {
    GlobalContext[name] = function(...args) {
      let options = args.pop();
      return DynamicView.bind(Channel.all(args), (view, args) => {
        let result = fn.apply({
          context: this,
          render: options.do && options.do.render.bind(options.do),
        }, args);

        if(!result) {
          view.clear();
        } else if(result.isView) {
          view.replace([result]);
        } else {
          view.replace([new View(result)]);
        }
      });
    }
	},

	template: function(nameOrTemplate, template) {
		if(template) {
			return this.templates[nameOrTemplate] = new Template(template);
		} else {
			return new Template(nameOrTemplate);
		}
	},

	render: function(name, context) {
		return this.templates[name].render(context);
	},

	clearIdentityMap: function() {
		Cache._identityMap = {};
	},

	clearCache: function() {
		Serenade.clearIdentityMap();
	},

	unregisterAll: function() {
		Serenade.views = {};
		Serenade.templates = {};
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

  get views() {
		return settings.views;
	},

	set views(value) {
		settings.views = value;
	},

  get templates() {
		return settings.templates;
	},

	set templates(value) {
		settings.templates = value;
	},

  get eventManager() {
		return settings.eventManager;
	},

	set eventManager(value) {
		settings.eventManager = value;
	},
});


export default Serenade;
