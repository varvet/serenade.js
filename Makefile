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
	$(BABEL) $< -o $@ --modules common

lib/grammar.js: src/grammar.jison
	@mkdir -p $(@D)
	$(JISON) $< -m commonjs -o $@

build: $(LIB) lib/grammar.js

test: build
	$(MOCHA) test/*.spec.coffee test/**/*.spec.coffee

target/serenade.js: build
	@mkdir -p $(@D)
	$(BROWSERIFY) lib/serenade -o $@ -i file -i system -s Serenade

target/serenade.min.js: target/serenade.js
	@mkdir -p $(@D)
	$(UGLIFY) -o $@ $<

target/serenade.min.js.gz: target/serenade.min.js
	@mkdir -p $(@D)
	gzip -kf $<

test/%: build
	mocha $@

.PHONY: test test/%
