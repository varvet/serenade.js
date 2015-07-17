require './spec_helper'
Serenade = require('../lib/serenade')
{Template} = Serenade

describe 'Template', ->
  describe '#parse', ->
    parse = (view) ->
      new Template(undefined, view).ast[0]

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
      expect(-> Serenade.template("someView", "di'v")).to.throw(SyntaxError, /In view 'someView':/)
