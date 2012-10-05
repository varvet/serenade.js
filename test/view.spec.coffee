{View} = require '../src/view'
{Serenade} = require '../src/serenade'
{expect} = require('chai')

describe 'View', ->
  describe '#parse', ->
    parse = (view) ->
      new View(undefined, view).parse()

    it 'parses a single tag', ->
      expect(parse('div').name).to.eql('div')

    it 'echoes back out a view which is passed as JSON', ->
      expect(parse({ name: 'div' }).name).to.eql('div')

    it 'parses a single tag with extra linebreaks', ->
      expect(parse('div\n\n').name).to.eql('div')

    it 'parses a single tag with extra whitespace before it', ->
      expect(parse('\n\tdiv').name).to.eql('div')

    it 'raises a syntax error when multiple root nodes are given', ->
      expect(-> parse('div\ndiv')).to.throw(Error)

    it 'raises a syntax error when unexpected token is encountered', ->
      expect(-> parse('div$')).to.throw("Unexpected token '$' on line 1")

    it 'parses a tag with an attribute', ->
      result = parse('div[id="foo"]')
      expect(result.name).to.eql('div')
      expect(result.properties[0].scope).to.eql('attribute')
      expect(result.properties[0].name).to.eql('id')
      expect(result.properties[0].value).to.eql('foo')
      expect(result.properties[0].bound).to.eql(false)

    it 'parses a tag with a bound attribute', ->
      result = parse('div[id=foo]')
      expect(result.name).to.eql('div')
      expect(result.properties[0].scope).to.eql('attribute')
      expect(result.properties[0].name).to.eql('id')
      expect(result.properties[0].value).to.eql('foo')
      expect(result.properties[0].bound).to.eql(true)

    it 'parses a tag with a bound attribute with optional @', ->
      result = parse('div[id=@foo]')
      expect(result.name).to.eql('div')
      expect(result.properties[0].scope).to.eql('attribute')
      expect(result.properties[0].name).to.eql('id')
      expect(result.properties[0].value).to.eql('foo')
      expect(result.properties[0].bound).to.eql(true)

    it 'parses a tag with a scoped attribute', ->
      result = parse('div[style:color="foo"]')
      expect(result.name).to.eql('div')
      expect(result.properties[0].scope).to.eql('style')
      expect(result.properties[0].name).to.eql('color')
      expect(result.properties[0].value).to.eql('foo')
      expect(result.properties[0].bound).to.eql(false)

    it 'parses a tag with multiple properties', ->
      result = parse('div[id="foo" class=schmoo]')
      expect(result.name).to.eql('div')
      expect(result.properties[0].name).to.eql('id')
      expect(result.properties[0].value).to.eql('foo')
      expect(result.properties[0].bound).to.eql(false)
      expect(result.properties[1].name).to.eql('class')
      expect(result.properties[1].value).to.eql('schmoo')
      expect(result.properties[1].bound).to.eql(true)

    it 'parses a tag with a bound scoped attribute', ->
      result = parse('div[style:color=foo]')
      expect(result.name).to.eql('div')
      expect(result.properties[0].scope).to.eql('style')
      expect(result.properties[0].name).to.eql('color')
      expect(result.properties[0].value).to.eql('foo')
      expect(result.properties[0].bound).to.eql(true)

    it 'parses a tag with an attribute with the prevent default flag', ->
      result = parse('div[event:click=foo!]')
      expect(result.name).to.eql('div')
      expect(result.properties[0].scope).to.eql('event')
      expect(result.properties[0].name).to.eql('click')
      expect(result.properties[0].value).to.eql('foo')
      expect(result.properties[0].bound).to.eql(true)
      expect(result.properties[0].preventDefault).to.eql(true)

    it 'parses child tags', ->
      result = parse("div\n\tp\n\tspan")
      expect(result.name).to.eql('div')
      expect(result.children[0].name).to.eql('p')
      expect(result.children[1].name).to.eql('span')

    it 'can indent back', ->
      result = parse """
        div
          p
            a
          p
      """
      expect(result.name).to.eql('div')
      expect(result.children[0].name).to.eql('p')
      expect(result.children[0].children[0].name).to.eql('a')
      expect(result.children[1].name).to.eql('p')

    it 'parses string literals as children on separate lines', ->
      result = parse("div\n\t\"Loca\"\n\tspan")
      expect(result.name).to.eql('div')
      expect(result.children[0].type).to.eql('text')
      expect(result.children[0].value).to.eql('Loca')
      expect(result.children[1].name).to.eql('span')

    it 'parses string literals as children on separate lines with arguments', ->
      result = parse """
        div[id=foo]
          "Loca"
          span[class=bar]
      """
      expect(result.name).to.eql('div')
      expect(result.children[0].type).to.eql('text')
      expect(result.children[0].value).to.eql('Loca')
      expect(result.children[1].name).to.eql('span')

    it 'parses string literals as children on the same line', ->
      result = parse """
        div "Loca"
      """
      expect(result.name).to.eql('div')
      expect(result.children[0].type).to.eql('text')
      expect(result.children[0].value).to.eql('Loca')

    it 'parses string literals as children on the same line with arguments', ->
      result = parse """
        div[id=foo] "Loca" "schmoo"
      """
      expect(result.name).to.eql('div')
      expect(result.children[0].type).to.eql('text')
      expect(result.children[0].value).to.eql('Loca')
      expect(result.children[0].bound).to.eql(false)
      expect(result.children[1].type).to.eql('text')
      expect(result.children[1].value).to.eql('schmoo')
      expect(result.children[1].bound).to.eql(false)

    it 'parses bound strings on the same line with arguments', ->
      result = parse """
        div[id=foo] @baz @bar
      """
      expect(result.name).to.eql('div')
      expect(result.children[0].value).to.eql('baz')
      expect(result.children[0].bound).to.eql(true)
      expect(result.children[1].value).to.eql('bar')
      expect(result.children[1].bound).to.eql(true)

    it 'parses bound strings on new line', ->
      result = parse """
        div
          @baz
          "schmoo"
          span
          @bar
      """
      expect(result.name).to.eql('div')
      expect(result.children[0].value).to.eql('baz')
      expect(result.children[0].bound).to.eql(true)
      expect(result.children[1].value).to.eql('schmoo')
      expect(result.children[1].bound).to.eql(false)
      expect(result.children[2].name).to.eql('span')
      expect(result.children[3].value).to.eql('bar')
      expect(result.children[3].bound).to.eql(true)

    it 'parses multiple things as children', ->
      result = parse """
        div
          @baz "schmoo" @bar
          span
      """
      expect(result.name).to.eql('div')
      expect(result.children[0].value).to.eql('baz')
      expect(result.children[0].bound).to.eql(true)
      expect(result.children[1].value).to.eql('schmoo')
      expect(result.children[1].bound).to.eql(false)
      expect(result.children[2].value).to.eql('bar')
      expect(result.children[2].bound).to.eql(true)
      expect(result.children[3].name).to.eql('span')

    it 'parses instructions', ->
      result = parse """
        div[id=foo]
          - view @example
            span
      """
      expect(result.name).to.eql('div')
      expect(result.children[0].type).to.eql('view')
      expect(result.children[0].arguments).to.eql(['example'])
      expect(result.children[0].children[0].name).to.eql('span')

    it 'does indentation for collections correctly', ->
      result = parse """
        div
          ul
            - collection @foo
              - view @comment
          form
      """
      expect(result.name).to.eql('div')
      expect(result.children[0].name).to.eql('ul')
      expect(result.children[1].name).to.eql('form')

    it 'parses a tag containing an underscore in the short form id', ->
      expect(parse('div#foo_bar').id).to.eql('foo_bar')

    it 'ignores comments', ->
      result = parse """
        // Hello
        // From
        div // this
          // view
        // which
          ul // has
            // lots
            li
            // foo
            p
        // of
        // comments
      """
      expect(result.name).to.eql('div')
      expect(result.children[0].name).to.eql('ul')
      expect(result.children[0].children[0].name).to.eql('li')
      expect(result.children[0].children[1].name).to.eql('p')

    it 'it adds view name to error message', ->
      view = Serenade.view("someView", "div\ndiv")
      expect(-> view.parse()).to.throw(Error, /In view 'someView':/)
