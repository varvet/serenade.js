$(".examples").each ->
  examples = $(this)
  editors = {}

  code = $("<div class='code'></div>").appendTo(examples)
  preview = $("<div class='preview'></div>").appendTo(examples)

  open = (example) ->
    code.empty()
    preview.empty()

    frameLoaded = $.Deferred()
    iframe = $("<iframe class='sandbox' src='/sandbox.html'/>").appendTo(preview).get(0)
    iframe.addEventListener "load", -> frameLoaded.resolve()

    requests = []
    if example.js
      jsRequest = $.ajax url: example.js, dataType: "text", complete: (response) ->
        element = $("<div class='editor'></div>").text(response.responseText).appendTo(code)
        editors.js = ace.edit(element.get(0))
        editors.js.setHighlightActiveLine(false)
        editors.js.setHighlightGutterLine(false)
        editors.js.getSession().setMode("ace/mode/javascript")
      requests.push(jsRequest)
    $.when(frameLoaded, requests...).then ->
      editors.js.on("change", run) if editors.js
      run()

    run = ->
      for child in iframe.contentDocument.body.children
        iframe.contentDocument.body.removeChild(child)
      try
        iframe.contentWindow.eval('"use strict"; ' + editors.js.getValue())
        #iframe.contentWindow.eval('"use strict"; var view = ' + JSON.stringify(text) + ';' + baseJs)
      catch e
        console.log "#{e}: #{e.message}"
        null

  $.get "/examples.json", (data) ->
    model = Serenade(examples: data, open: data[0])
    ul = Serenade.view("""
      div
        button.btn "Previous"
        div.btn-group
          a.btn.dropdown-toggle[href="#" data-toggle="dropdown"]
            - in @open
              @label
            span.caret
          ul.dropdown-menu
            - collection @examples
              li
                a[href="#" event:click=open!] @label
        button.btn "Next"
    """).render model, open: (link, example) ->
      model.open = example
      open(example)
    examples.prepend(ul)
    open(data[0])
