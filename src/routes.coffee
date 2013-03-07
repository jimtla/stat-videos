module.exports = (app) ->
    {die_on_error} = require './util'
    {add_type} = require './rest'
    fs = require 'fs'
    ftp = require 'ftp'

    characters = 'abcdefghijklmnopqrstuvwxyz0123456789'
    random_name = (length) ->
        chars =
            for i in [0...length]
                characters[Math.floor(Math.random() * characters.length)]

        chars.join ''

    app.get '/add_video', (req, res) ->
        res.render 'add_video'

    app.post '/add_video', (req, res) ->
        fs.readFile req.files.video.path, (err, data) ->
            client = new ftp()
            client.on 'ready', ->
                client.put data, "videos/#{random_name 16}", die_on_error res, ->
                    client.end()
                    res.send 'okay'

            client.on 'error', (err) -> res.send err

            client.connect
                host: 'acsvolleyball.com'
                user: 'acsvolleyball'
                password: 'Voll3yball'

