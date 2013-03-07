module.exports = (app) ->
    {add_type} = require './rest'
    thread_type = add_type app, 'thread', {}
