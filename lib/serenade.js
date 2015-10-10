"use strict";

Object.defineProperty(exports, "__esModule", {
	value: true
});

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj["default"] = obj; return newObj; } }

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

var _model = require("./model");

var _model2 = _interopRequireDefault(_model);

var _cache = require("./cache");

var _cache2 = _interopRequireDefault(_cache);

var _template = require("./template");

var _template2 = _interopRequireDefault(_template);

var _collection = require("./collection");

var _collection2 = _interopRequireDefault(_collection);

var _property = require("./property");

var _helpers = require("./helpers");

var _channel = require("./channel");

var _channel2 = _interopRequireDefault(_channel);

var _event_manager = require("./event_manager");

var _event_manager2 = _interopRequireDefault(_event_manager);

var _viewsCollection_view = require("./views/collection_view");

var _viewsCollection_view2 = _interopRequireDefault(_viewsCollection_view);

var _viewsElement = require("./views/element");

var _viewsElement2 = _interopRequireDefault(_viewsElement);

var _viewsView = require("./views/view");

var _viewsView2 = _interopRequireDefault(_viewsView);

var _viewsDynamic_view = require("./views/dynamic_view");

var _viewsDynamic_view2 = _interopRequireDefault(_viewsDynamic_view);

var _context = require("./context");

var _context2 = _interopRequireDefault(_context);

var _decorators = require("./decorators");

var Decorators = _interopRequireWildcard(_decorators);

function Serenade(wrapped) {
	var object = Object.create(wrapped);
	for (var key in wrapped) {
		(0, _property.defineAttribute)(object, key, { value: wrapped[key] });
	}
	return object;
};

if (typeof window !== "undefined") {
	_helpers.settings.document = window.document;
}

_helpers.settings.eventManager = _event_manager2["default"]["default"]();

(0, _helpers.extend)(Serenade, Object.defineProperties({
	VERSION: '0.5.0',
	defineProperty: _property.defineProperty,
	defineAttribute: _property.defineAttribute,
	defineChannel: _property.defineChannel,
	Context: _context2["default"],
	Decorators: Decorators,

	helper: function helper(name, fn) {
		_context2["default"][name] = function () {
			var _this = this;

			for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
				args[_key] = arguments[_key];
			}

			return _channel2["default"].all(args).map(function (args) {
				return fn.apply(_this, args);
			});
		};
	},

	template: function template(ast) {
		return new _template2["default"](ast);
	},

	clearIdentityMap: function clearIdentityMap() {
		_cache2["default"]._identityMap = {};
	},

	clearCache: function clearCache() {
		Serenade.clearIdentityMap();
	},

	Model: _model2["default"],
	Collection: _collection2["default"],
	Cache: _cache2["default"],
	Template: _template2["default"],
	View: _viewsView2["default"],
	Element: _viewsElement2["default"],
	CollectionView: _viewsCollection_view2["default"],
	Channel: _channel2["default"]

}, {
	async: {
		get: function get() {
			return _helpers.settings.async;
		},
		set: function set(value) {
			_helpers.settings.async = value;
		},
		configurable: true,
		enumerable: true
	},
	document: {
		get: function get() {
			return _helpers.settings.document;
		},
		set: function set(value) {
			_helpers.settings.document = value;
		},
		configurable: true,
		enumerable: true
	},
	eventManager: {
		get: function get() {
			return _helpers.settings.eventManager;
		},
		set: function set(value) {
			_helpers.settings.eventManager = value;
		},
		configurable: true,
		enumerable: true
	}
}));

exports["default"] = Serenade;
module.exports = exports["default"];
