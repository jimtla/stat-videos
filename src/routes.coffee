module.exports = (app) ->
    {add_type} = require './rest'
    thread_type = add_type app, 'thread', {}

    app.get '/add_video', (req, res) ->
        res.render 'add_video'

    app.post '/add_video', (req, res) ->
        res.send req.files.video

