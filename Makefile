SRC = $(shell find src -name '*.js')
LIB = $(SRC:src/%.js=lib/%.js)
BIN = node_modules/.bin
BABEL = $(BIN)/babel
JISON = $(BIN)/jison
BROWSERIFY = $(BIN)/browserify
UGLIFY = $(BIN)/uglifyjs
MOCHA = $(BIN)/mocha

default: target/serenade.js target/serenade.min.js target/serenade.min.js.gz

lib: $(LIB)
lib/%.js: src/%.js
	@mkdir -p $(@D)
	$(BABEL) $< -o $@ --modules common --optional es7.decorators

lib/grammar.js: src/grammar.jison
	@mkdir -p $(@D)
	$(JISON) $< -m js -o $@
	@echo "module.exports = (function() { `cat $@`; return `basename -s .js $@`; })();" > $@

build: $(LIB) lib/grammar.js

test: build
	$(MOCHA) test/*.spec.{js,coffee} test/**/*.spec.coffee test/

target/serenade.js: build
	@mkdir -p $(@D)
	$(BROWSERIFY) lib/serenade -o $@ -s Serenade

target/serenade.min.js: target/serenade.js
	@mkdir -p $(@D)
	$(UGLIFY) -o $@ $<

target/serenade.min.js.gz: target/serenade.min.js
	@mkdir -p $(@D)
	gzip -kf $<

test/%: build
	mocha $@

clean:
	rm -rf lib
	rm -rf target

.PHONY: test test/%
