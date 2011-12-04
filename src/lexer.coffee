{Monkey} = require './monkey'

IDENTIFIER = /^[a-zA-Z][a-zA-Z0-9\-]*/

LITERAL = /^[\[\]=]/

STRING = /^"((?:\\.|[^"])*)"/

MULTI_DENT = /^(?:\n[^\n\S]*)+/

WHITESPACE = /^[^\n\S]+/

class Monkey.Lexer

  tokenize: (code, opts = {}) ->
    @code    = code           # The remainder of the source code.
    @line    = opts.line or 0 # The current line.
    @indent  = 0              # The current indentation level.
    @indebt  = 0              # The over-indentation at the current level.
    @outdebt = 0              # The under-outdentation at the current level.
    @indents = []             # The stack of all current indentation levels.
    @ends    = []             # The stack for pairing up tokens.
    @tokens  = []             # Stream of parsed tokens in the form `['TYPE', value, line]`.

    i = 0
    while @chunk = code.slice i
      i += @identifierToken() or
           #@commentToken()    or
           @whitespaceToken() or
           @lineToken()       or
           @stringToken()     or
           @literalToken()

    while tag = @ends.pop()
      if tag is 'OUTDENT'
        @token 'OUTDENT'
      else
        @error "missing #{tag}"
    @tokens

  whitespaceToken: ->
    if match = WHITESPACE.exec @chunk
      @token 'WHITESPACE', match[0].length
      match[0].length
    else
      0

  token: (tag, value) ->
    @tokens.push [tag, value, @line]

  identifierToken: ->
    if match = IDENTIFIER.exec @chunk
      @token 'IDENTIFIER', match[0]
      match[0].length
    else
      0

  stringToken: ->
    if match = STRING.exec @chunk
      @token 'STRING_LITERAL', match[1]
      match[0].length
    else
      0

  lineToken: ->
    return 0 unless match = MULTI_DENT.exec @chunk


    indent = match[0]
    @line += @count indent, '\n'
    prev = @last @tokens, 1
    size = indent.length - 1 - indent.lastIndexOf '\n'

    if size is @indent
      @newlineToken()
    else if size > @indent
      diff = size - @indent
      @token 'INDENT', diff
      @ends.push 'OUTDENT'
    else
      @error('Should be an OUTDENT, yo') unless @last(@ends) is 'OUTDENT'
      @ends.pop
      @token 'OUTDENT', diff
    @indent = size
    indent.length


  literalToken: ->
    if match = LITERAL.exec @chunk
      id = match[0]
      switch id
        when "[" then @token('LPAREN', id)
        when "]" then @token('RPAREN', id)
        when "=" then @token('ASSIGN', id)
      1
    else
      @error("WUT??? is '#{@chunk.charAt(0)}'")

  newlineToken: ->
    @token 'TERMINATOR', '\n' unless @tag() is 'TERMINATOR'

  tag: (index, tag) ->
    (tok = @last @tokens, index) and if tag then tok[0] = tag else tok[0]

  value: (index, val) ->
    (tok = @last @tokens, index) and if val then tok[1] = val else tok[1]

  error: (message) ->
    throw SyntaxError "#{message} on line #{ @line + 1}"

  count: (string, substr) ->
    num = pos = 0
    return 1/0 unless substr.length
    num++ while pos = 1 + string.indexOf substr, pos
    num

  last: (array, back) -> array[array.length - (back or 0) - 1]
