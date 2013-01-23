$(".examples").each ->
  examples = $(this)

  code = $("<div class='code'></div>").appendTo(examples)
  preview = $("<div class='code'></div>").appendTo(examples)

  open = (example) ->
    code.empty()
    preview.empty()
    if example.js
      $.ajax url: example.js, dataType: "text", complete: (response) ->
        element = $("<div class='editor'></div>").text(response.responseText).appendTo(code)
        editor = ace.edit(element.get(0))
        editor.setHighlightActiveLine(false)
        editor.setHighlightGutterLine(false)
        editor.getSession().setMode("ace/mode/javascript")

  $.get "/examples.json", (data) ->
    ul = Serenade.view("""
      ul
        - collection @examples
          li
            a[href="#" event:click=open!] @name
    """).render({ examples: data }, { open: (link, example) -> open(example) })
    examples.prepend(ul)
    open(data[0])

  return


  content = node.find("pre code")

  if content.prop("className") in ["javascript", "html"]
    node.addClass "interactive"
    editors = {}

    code = $("<div class='code'></div>").appendTo(node)

    iframe = $("<iframe class='sandbox' src='sandbox.html'/>").appendTo(node).get(0)

    run = ->
      for child in iframe.contentDocument.body.children
        iframe.contentDocument.body.removeChild(child)
      text = editor.getValue()
      try
        switch mode
          when "javascript"
            iframe.contentWindow.eval('"use strict"; ' + text)
          when "html"
            iframe.contentWindow.eval('"use strict"; var view = ' + JSON.stringify(text) + ';' + baseJs)
      catch e
        console.log "#{e}: #{e.message}"
        null

    mode = content.prop("className")
    text = content.text()

    wrapper = $("<div></div>").appendTo(code)
    element = $("<div></div>").text(text).appendTo(wrapper)

    editor = ace.edit(element.get(0))
    editor.setHighlightActiveLine(false)
    editor.setHighlightGutterLine(false)

    updateHeight = =>
      newHeight = editor.getSession().getScreenLength() * editor.renderer.lineHeight + editor.renderer.scrollBar.getWidth()
      newHeight = Math.max(100, newHeight)
      $(element).height(newHeight.toString() + "px")
      editor.resize()

    updateHeight()

    if mode is "javascript"
      editor.getSession().setMode("ace/mode/javascript")

    editor.on "change", =>
      run()
      updateHeight()

    iframe.addEventListener "load", run
