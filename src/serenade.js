import Model from "./model"
import Cache from "./cache"
import Template from "./template"
import Collection from "./collection"
import defineProperty from "./property"
import defineEvent from "./event"
import { extend, settings } from "./helpers"

import BoundViewView from "./views/bound_view_view"
import CollectionView from "./views/collection_view"
import Element from "./views/element"
import HelperView from "./views/helper_view"
import IfView from "./views/if_view"
import InView from "./views/in_view"
import TemplateView from "./views/template_view"
import TextView from "./views/text_view"
import ContentView from "./views/content_view"
import UnlessView from "./views/unless_view"
import View from "./views/view"

function Serenade(wrapped) {
	let object = Object.create(wrapped);
	for(let key in wrapped) {
		defineProperty(object, key, { value: wrapped[key] });
	}
	return object;
};

if(typeof(window) !== "undefined") {
  settings.document = window.document;
}

extend(Serenade, {
	VERSION: '0.5.0',
	defineProperty: defineProperty,
	defineEvent: defineEvent,

	view: function(name, fn) {
		return this.views[name] = (ast, context) => new fn(ast, context);
	},

	helper: function(name, fn) {
		return this.views[name] = (ast, context) => new HelperView(ast, context, fn);
	},

	template: function(nameOrTemplate, template) {
		if(template) {
			return this.templates[nameOrTemplate] = new Template(nameOrTemplate, template);
		} else {
			return new Template(void 0, nameOrTemplate);
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
});


export default Serenade;
