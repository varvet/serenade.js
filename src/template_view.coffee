class TemplateView extends CollectionView
  constructor: (asts, model, controller) ->
    super
    @views = for ast in asts
      Compile[ast.type](ast, model, controller)
    @views = new Collection(@views)

  def @prototype, "fragment", get: ->
    fragment = Serenade.document.createDocumentFragment()
    @append(fragment)
    fragment.view = this
    fragment.remove = @remove.bind(this)
    fragment
