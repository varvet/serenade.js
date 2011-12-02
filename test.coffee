Lexer = require("./lexer").Lexer
Parser = require("./parser").Parser

lexer = new Lexer()
#result = lexer.tokenize '''
#div[foo="bar"]
  #p[test=mox]
    #a[href="schmoo"]
    #span "Monkey" bar "Baz"
#'''
result = lexer.tokenize('div')

console.log result
console.log Parser.parse(result)
