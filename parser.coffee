# mygenerator.js
Parser = require("jison").Parser

# a grammar in JSON
grammar =
  lex:
    rules: [
      ["\\s+", "/* skip whitespace */"]
      ["[a-f0-9]+", "return 'HEX';"]
    ]

  bnf:
    hex_strings: ["hex_strings HEX", "HEX"]

parser = new Parser(grammar)

# generate source, ready to be written to disk
parserSource = parser.generate()

# you can also use the parser directly from memory

# returns true
console.log(parser.parse("adfe34bc e82a"))


tokens = [
  ['IDENTIFIER', 'div', 1]
  ['[', '[', 1]
  ['IDENTIFIER', 'id', 1]
  ['=', '=', 1]
  ['STRING_LITERAL', 'testing', 1]
  [']', ']', 1]
]
