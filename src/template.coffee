parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

class Template
  constructor: (@name, @view) ->

  parse: ->
    if typeof(@view) is 'string'
      try
        @view = parser.parse(new Lexer().tokenize(@view))
      catch e
        e.message = "In view '#{@name}': #{e.message}" if @name
        throw e
    else
      @view

  render: (model, controller) ->
    controller or= Serenade.controllers[@name] or {}
    if typeof(controller) is "function"
      controller = new controller(model)

    new TemplateView(this.parse(), model, controller).element
