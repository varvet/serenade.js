class Example extends Serenade.Model
  @belongsTo "group", inverseOf: "examples", as: -> ExampleGroup
  @property "name", "label", "js", "views"

  select: ->
    @group.current = this

class ExampleGroup extends Serenade.Model
  @hasMany "examples", inverseOf: "group", as: -> Example
  @property "current"

  @property "isFirst", get: -> @current is @examples[0]
  @property "isLast", get: -> @current is @examples[@examples.length-1]

  next: ->
    @current = @examples[@examples.indexOf(@current) + 1] or @examples.last()

  previous: ->
    @current = @examples[@examples.indexOf(@current) - 1] or @examples.first()

class Editor
  Object.defineProperty @prototype, "text", get: -> @ace.getValue()
  constructor: (element, mode) ->
    @ace = ace.edit(element)
    @ace.setHighlightActiveLine(false)
    @ace.setHighlightGutterLine(false)
    @ace.setShowPrintMargin(false)
    @ace.getSession().setMode("ace/mode/#{mode}") if mode

  bind: (fn) ->
    @ace.on("change", fn)

$(".examples").each ->
  examples = $(this)
  editors = { views: {} }

  code = $("<div class='code'></div>").appendTo(examples)
  preview = $("<div class='preview'></div>").appendTo(examples)

  open = (example) ->
    code.empty()
    preview.empty()

    frameLoaded = $.Deferred()
    iframe = $("<iframe class='sandbox' src='/sandbox.html'/>").appendTo(preview).get(0)
    iframe.addEventListener "load", -> frameLoaded.resolve()

    requests = []
    if example.views
      for name, url of example.views
        request = $.ajax url: url, dataType: "text", complete: (response) ->
          $("<h3 class='editor-label'></h3>").text("view: #{name}").appendTo(code)
          element = $("<div class='editor'></div>").text(response.responseText).appendTo(code)
          editors.views[name] = new Editor(element.get(0))
        requests.push(request)
    if example.js
      request = $.ajax url: example.js, dataType: "text", complete: (response) ->
        $("<h3 class='editor-label'>javascript</h3>").appendTo(code)
        element = $("<div class='editor'></div>").text(response.responseText).appendTo(code)
        editors.js = new Editor(element.get(0), "javascript")
      requests.push(request)
    $.when(frameLoaded, requests...).then ->
      editors.js.bind(run) if editors.js
      editor.bind(run) for name, editor of editors.views
      run()

    run = ->
      for child in iframe.contentDocument.body.children
        iframe.contentDocument.body.removeChild(child)
      try
        iframe.contentWindow.Serenade.view(name, editor.text) for name, editor of editors.views
        iframe.contentWindow.eval('"use strict"; ' + editors.js.text) if editors.js
      catch e
        console.log "#{e}: #{e.message}"
        null

  $.get "/examples.json", (data) ->
    window.model = new ExampleGroup(examples: data)
    controller =
      open: (link, example) ->
        model.current = example
        open(model.current)
      next: ->
        model.next()
        open(model.current)
      previous: ->
        model.previous()
        open(model.current)
    ul = Serenade.view("""
      div
        button.btn[event:click=previous class:disabled=@isFirst] "← Previous"
        div.btn-group
          a.btn.dropdown-toggle[href="#" data-toggle="dropdown"]
            - in @current
              @label
            span.caret
          ul.dropdown-menu
            - collection @examples
              li
                a[href="#" event:click=open!] @label
        button.btn[event:click=next class:disabled=@isLast] "Next →"
    """).render(model, controller)
    examples.prepend(ul)
    model.current = model.examples[0]
    open(model.examples[0])
