titles =
  javascript: "JavaScript"
  coffeescript: "CoffeeScript"
  view: "Serenade view"

$("div.highlight").each ->
  node = $(this)

  if node.text().trim().match(/^#!/)
    node.addClass "interactive"
    blocks = node.text().trim().split(/^#!/mg).slice(1)
    editors = {}

    code = $("<div class='code'></div>").appendTo(node)

    iframe = $("<iframe class='sandbox' src='sandbox.html'/>").appendTo(node).get(0)

    menu = $('ul').appendTo(code)

    run = ->
      for child in iframe.contentDocument.body.children
        iframe.contentDocument.body.removeChild(child)
      iframe.contentWindow.view = editors["view"].getValue() if editors["view"]
      try
        iframe.contentWindow.eval(editors["javascript"].getValue())
      catch e
        null

    for block in blocks
      mode = block.match(/^\w+/)[0]
      text = block.match(/^\w+\s*([^$]+)$/)[1]

      element = $("<div></div>").text(text).appendTo(code)

      editor = ace.edit(element.get(0))
      if mode is "javascript"
        editor.getSession().setMode("ace/mode/javascript")

      editor.on "change", run
      editors[mode] = editor

      li = $("li").text(titles[mode]).appendTo(menu)

    iframe.addEventListener "load", run
