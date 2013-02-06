define('ace/mode/serenade', function(require, exports, module) {
  var oop = require("ace/lib/oop");
  var TextMode = require("ace/mode/text").Mode;
  var Tokenizer = require("ace/tokenizer").Tokenizer;
  var SerenadeHighlightRules = require("ace/mode/serenade_highlight_rules").SerenadeHighlightRules;

  var Mode = function() {
      this.$tokenizer = new Tokenizer(new SerenadeHighlightRules().getRules());
  };
  oop.inherits(Mode, TextMode);

  (function() {
      // Extra logic goes here. (see below)
  }).call(Mode.prototype);

  exports.Mode = Mode;
});

define('ace/mode/serenade_highlight_rules', function(require, exports, module) {
  var oop = require("ace/lib/oop");
  var TextHighlightRules = require("ace/mode/text_highlight_rules").TextHighlightRules;

  var SerenadeHighlightRules = function() {
    this.$rules = {
      start: [
        { token: "variable", regex: /@[\w\-_]+/ },
        { token: "string.double", regex: /".*?"/ },
        { token: "comment.line.double-slash", regex: /\/\/.*$/ },
        { token: "keyword", regex: /-\s\w+/ },
      ]
    };
  }

  oop.inherits(SerenadeHighlightRules, TextHighlightRules);

  exports.SerenadeHighlightRules = SerenadeHighlightRules;
});
