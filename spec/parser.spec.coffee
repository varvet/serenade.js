{Monkey} = require '../src/monkey'
{View} = require '../src/view'

describe 'Monkey.View', ->
  describe '#parse', ->
    parse = (view) ->
      new View(view).parse()

    it 'parses a single tag', ->
      expect(parse('div').name).toEqual('div')

    it 'parses a single tag with extra linebreaks', ->
      expect(parse('div\n\n').name).toEqual('div')

    it 'parses a tag with an attribute', ->
      result = parse('div[id="foo"]')
      expect(result.name).toEqual('div')
      expect(result.attributes[0].name).toEqual('id')
      expect(result.attributes[0].value).toEqual('foo')
      expect(result.attributes[0].bound).toEqual(false)

    it 'parses a tag with multiple attributes', ->
      result = parse('div[id="foo" class=schmoo]')
      expect(result.name).toEqual('div')
      expect(result.attributes[0].name).toEqual('id')
      expect(result.attributes[0].value).toEqual('foo')
      expect(result.attributes[0].bound).toEqual(false)
      expect(result.attributes[1].name).toEqual('class')
      expect(result.attributes[1].value).toEqual('schmoo')
      expect(result.attributes[1].bound).toEqual(true)

    it 'parses child tags', ->
      result = parse("div\n\tp\n\tspan")
      expect(result.name).toEqual('div')
      expect(result.children[0].name).toEqual('p')
      expect(result.children[1].name).toEqual('span')

    it 'parses string literals as children on separate lines', ->
      result = parse("div\n\t\"Loca\"\n\tspan")
      expect(result.name).toEqual('div')
      expect(result.children[0].name).toEqual('text')
      expect(result.children[0].value).toEqual('Loca')
      expect(result.children[1].name).toEqual('span')

    it 'parses string literals as children on separate lines with arguments', ->
      result = parse("div[id=foo]\n\t\"Loca\"\n\tspan[class=bar]")
      expect(result.name).toEqual('div')
      expect(result.children[0].name).toEqual('text')
      expect(result.children[0].value).toEqual('Loca')
      expect(result.children[1].name).toEqual('span')

    it 'parses string literals as children on the same line', ->
      result = parse("div \"Loca\"")
      expect(result.name).toEqual('div')
      expect(result.children[0].name).toEqual('text')
      expect(result.children[0].value).toEqual('Loca')

    it 'parses string literals as children on the same line with arguments', ->
      result = parse("div[id=foo] \"Loca\" \"schmoo\"")
      expect(result.name).toEqual('div')
      expect(result.children[0].name).toEqual('text')
      expect(result.children[0].value).toEqual('Loca')
      expect(result.children[0].bound).toEqual(false)
      expect(result.children[1].name).toEqual('text')
      expect(result.children[1].value).toEqual('schmoo')
      expect(result.children[1].bound).toEqual(false)

    it 'parses bound strings on the same line with arguments', ->
      result = parse("div[id=foo] baz bar")
      expect(result.name).toEqual('div')
      expect(result.children[0].name).toEqual('text')
      expect(result.children[0].value).toEqual('baz')
      expect(result.children[0].bound).toEqual(true)
      expect(result.children[1].name).toEqual('text')
      expect(result.children[1].value).toEqual('bar')
      expect(result.children[1].bound).toEqual(true)
