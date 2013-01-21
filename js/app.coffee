baseJs = """
  var model = { name: "Kim" }
  var controller = { alert: function() { alert("hello") } }
  var element = Serenade.view(view).render(model, controller)
  document.body.appendChild(element);
"""

$("div.xhighlight").each ->
  node = $(this)
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
