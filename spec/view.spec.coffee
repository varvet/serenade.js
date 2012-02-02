{View} = require '../src/view'

describe 'View', ->
  describe '#parse', ->
    parse = (view) ->
      new View(view).parse()

    it 'parses a single tag', ->
      expect(parse('div').name).toEqual('div')

    it 'echoes back out a view which is passed as JSON', ->
      expect(parse({ name: 'div' }).name).toEqual('div')

    it 'parses a single tag with extra linebreaks', ->
      expect(parse('div\n\n').name).toEqual('div')

    it 'parses a single tag with extra whitespace before it', ->
      expect(parse('\n\tdiv').name).toEqual('div')

    it 'parses a tag with an attribute', ->
      result = parse('div[id="foo"]')
      expect(result.name).toEqual('div')
      expect(result.properties[0].scope).toEqual('attribute')
      expect(result.properties[0].name).toEqual('id')
      expect(result.properties[0].value).toEqual('foo')
      expect(result.properties[0].bound).toEqual(false)

    it 'parses a tag with a bound attribute', ->
      result = parse('div[id=foo]')
      expect(result.name).toEqual('div')
      expect(result.properties[0].scope).toEqual('attribute')
      expect(result.properties[0].name).toEqual('id')
      expect(result.properties[0].value).toEqual('foo')
      expect(result.properties[0].bound).toEqual(true)

    it 'parses a tag with a bound attribute with optional @', ->
      result = parse('div[id=@foo]')
      expect(result.name).toEqual('div')
      expect(result.properties[0].scope).toEqual('attribute')
      expect(result.properties[0].name).toEqual('id')
      expect(result.properties[0].value).toEqual('foo')
      expect(result.properties[0].bound).toEqual(true)

    it 'parses a tag with a scoped attribute', ->
      result = parse('div[style:color="foo"]')
      expect(result.name).toEqual('div')
      expect(result.properties[0].scope).toEqual('style')
      expect(result.properties[0].name).toEqual('color')
      expect(result.properties[0].value).toEqual('foo')
      expect(result.properties[0].bound).toEqual(false)

    it 'parses a tag with multiple properties', ->
      result = parse('div[id="foo" class=schmoo]')
      expect(result.name).toEqual('div')
      expect(result.properties[0].name).toEqual('id')
      expect(result.properties[0].value).toEqual('foo')
      expect(result.properties[0].bound).toEqual(false)
      expect(result.properties[1].name).toEqual('class')
      expect(result.properties[1].value).toEqual('schmoo')
      expect(result.properties[1].bound).toEqual(true)

    it 'parses a tag with a bound scoped attribute', ->
      result = parse('div[style:color=foo]')
      expect(result.name).toEqual('div')
      expect(result.properties[0].scope).toEqual('style')
      expect(result.properties[0].name).toEqual('color')
      expect(result.properties[0].value).toEqual('foo')
      expect(result.properties[0].bound).toEqual(true)

    it 'parses a tag with an attribute with the prevent default flag', ->
      result = parse('div[event:click=foo!]')
      expect(result.name).toEqual('div')
      expect(result.properties[0].scope).toEqual('event')
      expect(result.properties[0].name).toEqual('click')
      expect(result.properties[0].value).toEqual('foo')
      expect(result.properties[0].bound).toEqual(true)
      expect(result.properties[0].preventDefault).toEqual(true)

    it 'parses child tags', ->
      result = parse("div\n\tp\n\tspan")
      expect(result.name).toEqual('div')
      expect(result.children[0].name).toEqual('p')
      expect(result.children[1].name).toEqual('span')

    it 'can indent back', ->
      result = parse """
        div
          p
            a
          p
      """
      expect(result.name).toEqual('div')
      expect(result.children[0].name).toEqual('p')
      expect(result.children[0].children[0].name).toEqual('a')
      expect(result.children[1].name).toEqual('p')

    it 'parses string literals as children on separate lines', ->
      result = parse("div\n\t\"Loca\"\n\tspan")
      expect(result.name).toEqual('div')
      expect(result.children[0].type).toEqual('text')
      expect(result.children[0].value).toEqual('Loca')
      expect(result.children[1].name).toEqual('span')

    it 'parses string literals as children on separate lines with arguments', ->
      result = parse """
        div[id=foo]
          "Loca"
          span[class=bar]
      """
      expect(result.name).toEqual('div')
      expect(result.children[0].type).toEqual('text')
      expect(result.children[0].value).toEqual('Loca')
      expect(result.children[1].name).toEqual('span')

    it 'parses string literals as children on the same line', ->
      result = parse """
        div "Loca"
      """
      expect(result.name).toEqual('div')
      expect(result.children[0].type).toEqual('text')
      expect(result.children[0].value).toEqual('Loca')

    it 'parses string literals as children on the same line with arguments', ->
      result = parse """
        div[id=foo] "Loca" "schmoo"
      """
      expect(result.name).toEqual('div')
      expect(result.children[0].type).toEqual('text')
      expect(result.children[0].value).toEqual('Loca')
      expect(result.children[0].bound).toEqual(false)
      expect(result.children[1].type).toEqual('text')
      expect(result.children[1].value).toEqual('schmoo')
      expect(result.children[1].bound).toEqual(false)

    it 'parses bound strings on the same line with arguments', ->
      result = parse """
        div[id=foo] @baz @bar
      """
      expect(result.name).toEqual('div')
      expect(result.children[0].value).toEqual('baz')
      expect(result.children[0].bound).toEqual(true)
      expect(result.children[1].value).toEqual('bar')
      expect(result.children[1].bound).toEqual(true)

    it 'parses bound strings on new line', ->
      result = parse """
        div
          @baz
          "schmoo"
          span
          @bar
      """
      expect(result.name).toEqual('div')
      expect(result.children[0].value).toEqual('baz')
      expect(result.children[0].bound).toEqual(true)
      expect(result.children[1].value).toEqual('schmoo')
      expect(result.children[1].bound).toEqual(false)
      expect(result.children[2].name).toEqual('span')
      expect(result.children[3].value).toEqual('bar')
      expect(result.children[3].bound).toEqual(true)

    it 'parses multiple things as children', ->
      result = parse """
        div
          @baz "schmoo" @bar
          span
      """
      expect(result.name).toEqual('div')
      expect(result.children[0].value).toEqual('baz')
      expect(result.children[0].bound).toEqual(true)
      expect(result.children[1].value).toEqual('schmoo')
      expect(result.children[1].bound).toEqual(false)
      expect(result.children[2].value).toEqual('bar')
      expect(result.children[2].bound).toEqual(true)
      expect(result.children[3].name).toEqual('span')

    it 'parses instructions', ->
      result = parse """
        div[id=foo]
          - view @example
            span
      """
      expect(result.name).toEqual('div')
      expect(result.children[0].command).toEqual('view')
      expect(result.children[0].arguments).toEqual(['example'])
      expect(result.children[0].children[0].name).toEqual('span')

    it 'does indentation for collections correctly', ->
      result = parse """
        div
          ul
            - collection @foo
              - view @comment
          form
      """
      expect(result.name).toEqual('div')
      expect(result.children[0].name).toEqual('ul')
      expect(result.children[1].name).toEqual('form')
