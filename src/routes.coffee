module.exports = (app) ->
    {die_on_error} = require './util'
    rest = require './rest'
    fs = require 'fs'
    ftp = require 'ftp'

    characters = 'abcdefghijklmnopqrstuvwxyz0123456789'
    random_name = (length) ->
        chars =
            for i in [0...length]
                characters[Math.floor(Math.random() * characters.length)]

        chars.join ''


    video_type = rest.add_type app, 'video', {}

    app.get '/add_video', (req, res) ->
        res.render 'add_video'

    app.post '/add_video', (req, res) ->
        fs.readFile req.files.video.path, (err, data) ->
            client = new ftp()
            client.on 'ready', ->
                key = "videos/#{random_name 16}.mp4"
                client.put data, key, die_on_error res, ->
                    client.end()
                    video_type.add {video: "http://acsvolleyball.com/#{key}"}, die_on_error res, (video) ->
                            res.redirect "/stat/#{video.id}"

            client.on 'error', (err) -> res.send err

            client.connect
                host: 'acsvolleyball.com'
                user: 'acsvolleyball'
                password: 'Voll3yball'

    app.get '/stat/:id', (req, res) ->
        console.log req.params.id
        video_type.get req.params.id, die_on_error res, (video) ->
            console.log video
            res.render 'stat', {vid: video}

