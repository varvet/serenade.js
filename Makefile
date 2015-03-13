SRC = $(shell find src -name *.js)
LIB = $(SRC:src/%.js=lib/%.js)

default: target/serenade

lib: $(LIB)
lib/%.js: src/%.js
	@mkdir -p $(@D)
	node_modules/.bin/babel $< -o $@ --modules common

lib/grammar.js: src/grammar.jison
	@mkdir -p $(@D)
	jison $< -m commonjs -o $@

build: $(LIB) lib/grammar.js

test: build
	npm test

target/serenade: build
	@mkdir -p $(@D)
	browserify lib/serenade -o $@

.PHONY: test
