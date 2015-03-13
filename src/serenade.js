import Model from "./model"
import Cache from "./cache"
import Template from "./template"
import Collection from "./collection"
import defineProperty from "./property"
import defineEvent from "./event"
import { def, extend, settings } from "./helpers"

import BoundViewView from "./views/bound_view_view"
import CollectionView from "./views/collection_view"
import Element from "./views/element"
import HelperView from "./views/helper_view"
import IfView from "./views/if_view"
import InView from "./views/in_view"
import TemplateView from "./views/template_view"
import TextView from "./views/text_view"
import UnlessView from "./views/unless_view"
import View from "./views/view"

function Serenade(wrapped) {
	var key, object, value;
	object = Object.create(wrapped);
	for (key in wrapped) {
		value = wrapped[key];
		defineProperty(object, key, {
			value: value
		});
	}
	return object;
};

settings.document = typeof window !== "undefined" && window !== null ? window.document : void 0,

extend(Serenade, {
	VERSION: '0.5.0',
	views: {},
	templates: {},
	defineProperty: defineProperty,
	defineEvent: defineEvent,
	view: function(name, fn) {
		return this.views[name] = function(ast, context) {
			return new fn(ast, context);
		};
	},
	helper: function(name, fn) {
		return this.views[name] = function(ast, context) {
			return new HelperView(ast, context, fn);
		};
	},
	renderView: function(ast, context) {
		if (this.views[ast.name]) {
			return this.views[ast.name](ast, context);
		} else {
			return new Element(ast, context);
		}
	},
	template: function(nameOrTemplate, template) {
		if (template) {
			return this.templates[nameOrTemplate] = new Template(nameOrTemplate, template);
		} else {
			return new Template(void 0, nameOrTemplate);
		}
	},
	render: function(name, context) {
		return this.templates[name].render(context);
	},
	clearIdentityMap: function() {
		return Cache._identityMap = {};
	},
	clearCache: function() {
		return Serenade.clearIdentityMap();
	},
	unregisterAll: function() {
		Serenade.views = {};
		return Serenade.templates = {};
	},
	Model: Model,
	Collection: Collection,
	Cache: Cache,
	Template: Template,
	View: View,
	Element: Element,
	CollectionView: CollectionView
});

def(Serenade, "async", {
	get: function() {
		return settings.async;
	},
	set: function(value) {
		return settings.async = value;
	}
});

def(Serenade, "document", {
	get: function() {
		return settings.document;
	},
	set: function(value) {
		return settings.document = value;
	}
});

export default Serenade;
