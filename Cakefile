fs            = require 'fs'
{print}       = require 'util'
{spawn, exec} = require 'child_process'

# ANSI Terminal Colors
bold  = '\x1B[0;1m'
red   = '\x1B[0;31m'
green = '\x1B[0;32m'
reset = '\x1B[0m'

pkg = JSON.parse fs.readFileSync('./package.json')
testCmd = pkg.scripts.test
startCmd = pkg.scripts.start


spawned_processes = []
cleanup = (e) ->
    console.log e.message if e?.message?
    while spawned_processes.length > 0
      {spawned, command} = spawned_processes.shift()
      spawned.kill()
      console.log "Killed #{command}"

process.on 'SIGINT', cleanup
process.on 'exit', cleanup
process.on 'uncaughtException', cleanup

log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

spawn_with_stdout = (command, args, callback) ->
  spawned = spawn command, args
  spawned.stdout.pipe process.stdout
  spawned.stderr.pipe process.stderr
  if callback?
    spawned.on 'exit', callback

  spawned_processes.push {command, spawned}
  spawned



# Compiles app.coffee and src directory to the app directory
build = (callback) ->
  spawn_with_stdout 'coffee', ['-c','-b', '-o', 'app', 'src'], callback

# mocha test
test = (callback) ->
  try
    spawn_with_stdout 'mocha', [
      '--compilers'
      'coffee:coffee-script'
      '--colors'
      '--require'
      'should'
      '--require'
      './server'
    ], callback
  catch err
    log err.message, red
    log 'Mocha is not installed - try npm install mocha -g', red

task 'build', ->
  build -> log "Built!", green

task 'test', 'Run Mocha tests', ->
  build -> test -> log "Tests Complete!", green

task 'go', 'Start dev server/compilation', ->
  # watch_coffee
  coffee = spawn_with_stdout 'coffee' , ['-c', '-b', '-w', '-o', 'app', 'src']
  log 'Watching coffee files', green

  # watch_js
  spawn_with_stdout 'node', ['./node_modules/supervisor/lib/cli-wrapper.js','-w','app,views', '-e', 'js|jade', 'server']

  log 'Watching js files and running server', green


