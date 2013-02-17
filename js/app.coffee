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
  Object.defineProperty @prototype, "text",
    get: -> @ace.getValue()
    set: (val) ->
      @ace.setValue(val)
      @ace.clearSelection()
  Serenade.defineEvent @prototype, "change"

  constructor: (@element, @mode, @name, @options={}) ->
    @ace = ace.edit(@element)
    @ace.setHighlightActiveLine(false)
    @ace.setHighlightGutterLine(false)
    @ace.setShowPrintMargin(false)
    @ace.getSession().setMode("ace/mode/javascript") if @mode is "javascript"
    @ace.getSession().setMode("ace/mode/serenade") if @mode is "view"
    @ace.getSession().setMode("ace/mode/html") if @mode is "html"
    @ace.on("change", => @change.trigger())
    if @options.adjustHeight
      @change.bind => @updateHeight()
      @updateHeight()

    @ace.setReadOnly(true) if @options.readOnly

  updateHeight: ->
    newHeight = @ace.getSession().getScreenLength() * @ace.renderer.lineHeight + @ace.renderer.scrollBar.getWidth()
    newHeight = Math.max(100, newHeight)
    $(@element).height(newHeight.toString() + "px")
    @ace.resize()

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
        request.name = name
        requests.push(request)
    if example.js
      request = $.ajax(url: example.js, dataType: "text")
      request.label = "javascript"
      request.mode = "javascript"
      requests.push(request)

    $.when(frameLoaded, requests...).then ->
      editors = for request in requests
        $("<h3 class='label'></h3>").text(request.label).appendTo(code)
        element = $("<div class='editor'></div>").text(request.responseText).appendTo(code)
        editor = new Editor(element.get(0), request.mode, request.name, adjustHeight: true)
        editor.change.bind -> run()
        editor

      run = ->
        $(iframe).css(height: 0)
        error.hide()
        for child in iframe.contentDocument.body.children
          iframe.contentDocument.body.removeChild(child)
        try
          for editor in editors
            if editor.mode is "javascript"
              iframe.contentWindow.eval('"use strict"; ' + editor.text)
            else
              iframe.contentWindow.Serenade.view(editor.name, editor.text)
        catch e
          error.text(e).show()
        $(iframe).css(height: iframe.contentDocument.body.scrollHeight)

      run()

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


$(".reference #content").each ->
  content = $(this)

  headers = content.find("h2, h3").get().reduce (agg, h) ->
    h.text = h.textContent.split(/[:\(]/)[0]
    id = h.text.replace(/\s+/, "-").replace(/[^a-z0-9-]/gi, "").toLowerCase()
    if h.localName is "h2"
      h.setAttribute("id", id)
      h.link = "#"+id
      agg.push({ group: h, items: [] })
    else
      id = agg[agg.length-1].group.getAttribute("id") + "-" + id
      h.setAttribute("id", id)
      h.link = "#"+id
      agg[agg.length-1].items.push(h)
    agg
  , []
  # remove all h2 headers without following h3 headers
  headers = headers.filter((h) -> h.items.length)

  content.find("h1").after Serenade.view("""
  ol.index
      - collection @headers
        li
          - in @group
            a[href=@link] @text
          ol.items
            - collection @items
              li
                a[href=@link] @text

  """).render(headers: headers)

$("#convert").each ->
  container = $(this)
  source = new Editor(container.find(".source").get(0), "html", "source")
  target = new Editor(container.find(".target").get(0), "view", "target", readOnly: true)

  convert = ->
    div = document.createElement("div")
    div.innerHTML = source.text

    walkChildren = (children) ->
      tokens = []
      for child in children
        switch child.nodeName
          when "#text"
            if child.nodeValue.match(/\S/)
              tokens.push('"' + child.nodeValue.replace(/\s+/m, " ").trim() + '"')
          when "#comment"
            tokens.push("// " + child.nodeValue)
          else
            tokens = tokens.concat(walk(child))
      tokens

    walk = (node) ->
      tokens = walkChildren(node.childNodes)
      tokens = ("  " + token for token in tokens)
      name = if node.localName is "div" then "" else node.localName
      attributes = []
      for attribute in node.attributes
        switch attribute.name
          when "class"
            name += "." + attribute.value.split(/\s+/).join(".")
          when "id"
            name += "#" + attribute.value
          else
            attributes.push("#{attribute.name}=\"#{attribute.value}\"")
      name = "#{name}[#{attributes.join(" ")}]" if attributes.length
      tokens.unshift(name)
      tokens

    target.text = walkChildren(div.childNodes).join("\n")

  source.change.bind(convert)
  convert()
