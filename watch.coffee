#!./node_modules/.bin/coffee
exec = require('child_process').exec
fs = require('fs')

changedFiles = {}
lastBuild = 0
rebuild = ->
  return if new Date().getTime() < lastBuild + 1000
  (changed = true; console.log "#{file} has changed") for file of changedFiles
  return unless changed
  changedFiles = {}
  console.log "Rebuilding serenade.js..."
  exec './node_modules/.bin/cake build', (error, stdout, stderr)->
    console.log stdout, stderr if error
    console.log if error then 'failed' else 'done'
  lastBuild = new Date().getTime()

setInterval rebuild, 1000

fs.readdirSync('src').forEach (file)->
  return unless /\.coffee$/.test file
  #console.log "watching src/#{file}"
  # for some reason this gets called multiple times for each change
  fs.watch "src/#{file}", -> changedFiles[file] = true

console.log "listening for changes in src/*.coffee"
