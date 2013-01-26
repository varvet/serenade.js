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
  constructor: (@element, @mode) ->
    @ace = ace.edit(@element)
    @ace.setHighlightActiveLine(false)
    @ace.setHighlightGutterLine(false)
    @ace.setShowPrintMargin(false)
    @ace.getSession().setMode("ace/mode/javascript") if @mode is "javascript"
    @updateHeight()
    @bind => @updateHeight()

  updateHeight: ->
    newHeight = @ace.getSession().getScreenLength() * @ace.renderer.lineHeight + @ace.renderer.scrollBar.getWidth()
    newHeight = Math.max(100, newHeight)
    $(@element).height(newHeight.toString() + "px")
    @ace.resize()

  bind: (fn) ->
    @ace.on("change", fn)

$(".examples").each ->
  examples = $(this)

  main = $("<div class='main'></div>").appendTo(examples)
  code = $("<div class='code'></div>").appendTo(main)
  preview = $("<div class='preview'></div>").appendTo(main)

  open = (example) ->
    code.empty()
    preview.empty()
    $("<h3 class='label'>Live preview</h3>").appendTo(preview)
    error = $("<div class='error'></div>").appendTo(preview)

    frameLoaded = $.Deferred()
    iframe = $("<iframe class='sandbox' src='/sandbox.html'/>").appendTo(preview).get(0)
    iframe.addEventListener "load", -> frameLoaded.resolve()

    requests = []
    if example.views
      for name, url of example.views
        request = $.ajax(url: url, dataType: "text")
        request.label = "view: #{name}"
        request.mode = "view"
        requests.push(request)
    if example.js
      request = $.ajax(url: example.js, dataType: "text")
      request.label = "javascript"
      editors.mode = "javascript"
      requests.push(request)

    $.when(frameLoaded, requests...).then ->
      editors = for request of requests
        $("<h3 class='label'></h3>").text(request.label).appendTo(code)
        element = $("<div class='editor'></div>").text(request.responseText).appendTo(code)
        editor = new Editor(element.get(0), request.mode)
        editor.bind(run)
        editor

      editor.bind(run) for name, editor of editors.views
      run()

      run = ->
        error.hide()
        for child in iframe.contentDocument.body.children
          iframe.contentDocument.body.removeChild(child)
        try
          for editor of editors
            if editor.mode is "javascript"
            iframe.contentWindow.Serenade.view(name, editor.text)
            iframe.contentWindow.eval('"use strict"; ' + editors.js.text) if editors.js
        catch e
          error.text(e).show()

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
      div.controls
        button.btn[event:click=previous class:disabled=@isFirst] "← Previous"
        div.btn-group
          a.btn.dropdown-toggle[href="#" data-toggle="dropdown"]
            - in @current
              @label " "
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
