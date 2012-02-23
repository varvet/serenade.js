{Serenade} = require '../../src/serenade'
fs = require 'fs'

describe 'View file parsing', ->

  beforeEach ->
    @setupDom()

  it 'parses unix format view file', ->
    source = fs.readFileSync("./views/simple_view.serenade").toString()
    @render source
    expect(@body).toHaveElement('div > p')

  it 'parses windows format view file', ->
    source = fs.readFileSync("./views/simple_view_win.serenade").toString()
    @render source
    expect(@body).toHaveElement('div > p')
