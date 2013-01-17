titles =
  javascript: "JavaScript"
  coffeescript: "CoffeeScript"
  view: "Serenade view"

$("div.highlight").each ->
  node = $(this)

  if node.text().trim().match(/^#!/)
    node.addClass "interactive"
    editors = {}

    menu = $("<ul class='menu'></ul>").appendTo(node)

    code = $("<div class='code'></div>").appendTo(node)

    iframe = $("<iframe class='sandbox' src='sandbox.html'/>").appendTo(node).get(0)


    run = ->
      for child in iframe.contentDocument.body.children
        iframe.contentDocument.body.removeChild(child)
      view = Block.byMode("view")?.text
      js = Block.byMode("javascript")?.text
      try
        iframe.contentWindow.eval('"use strict"; var view = ' + JSON.stringify(view) + ';' + js)
      catch e
        console.log "#{e}: #{e.message}"
        null

    class Block
      @all: []
      @byMode: (mode) -> return block for block in @all when block.mode == mode
      constructor: (block) ->
        @mode = block.match(/^\w+/)[0]
        @text = block.match(/^\w+\s*([^$]+)$/)[1]

        @wrapper = $("<div></div>").appendTo(code)

        @li = $("<li></li>").text(titles[@mode]).appendTo(menu)
        @li.click => @show()

      show: ->
        block.hide() for block in Block.all
        @li.addClass("active")
        element = $("<div></div>").text(@text).appendTo(@wrapper)

        @editor = ace.edit(element.get(0))
        if @mode is "javascript"
          @editor.getSession().setMode("ace/mode/javascript")

        @editor.on "change", =>
          @text = @editor.getValue()
          run()

      hide: ->
        @li.removeClass("active")
        @wrapper.empty()
        @editor = null

    Block.all = node.text().trim().split(/^#!/mg).slice(1).map (block) -> new Block(block)
    Block.all[0].show()

    iframe.addEventListener "load", run
