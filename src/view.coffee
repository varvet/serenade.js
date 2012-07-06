{parser} = require './parser'
{Lexer} = require './lexer'
{Nodes} = require './nodes'
{Serenade} = require './serenade'

parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

class View
  constructor: (@name, @view) ->
  parse: ->
    if typeof(@view) is 'string'
      try
        @view = parser.parse(new Lexer().tokenize(@view))
      catch e
        e.message = "In #{@name}: #{e.message}"
        throw e
    else
      @view
  render: (model, controller) ->
    controller or= Serenade.controllerFor(@name, model) if @name
    controller or= {}
    node = Nodes.compile(@parse(), Serenade.document, model, controller)
    controller.model or= model
    controller.view or= node.element
    node.element

exports.View = View
