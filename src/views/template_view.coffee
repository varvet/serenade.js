class TemplateView extends DynamicView
  constructor: (asts, @context) ->
    super
    @children = for ast in asts
      Compile[ast.type](ast, context)
    @children = new Collection(@children)

  def @prototype, "fragment", get: ->
    fragment = Serenade.document.createDocumentFragment()
    @append(fragment)
    fragment.view = this
    fragment.remove = @remove.bind(this)
    fragment
