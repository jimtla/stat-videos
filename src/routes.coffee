module.exports = (app) ->
    {add_type} = require './rest'
    fs = require 'fs'
    thread_type = add_type app, 'thread', {}

    app.get '/add_video', (req, res) ->
        res.render 'add_video'

    app.post '/add_video', (req, res) ->
        fs.readFile req.files.video.path, (err, data) ->
            res.send data
