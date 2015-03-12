parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

class Template
  constructor: (@name, @ast) ->
    if typeof(@ast) is 'string'
      try
        @ast = parser.parse(new Lexer().tokenize(@ast))
      catch e
        e.message = "In view '#{@name}': #{e.message}" if @name
        throw e

  render: (model, controller) ->
    new TemplateView(@ast, model, controller).fragment
