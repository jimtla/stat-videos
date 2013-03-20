module.exports = (app) ->
    {die_on_error} = require './util'
    rest = require './rest'
    fs = require 'fs'
    ftp = require 'ftp'
    _ = require 'underscore'


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
            video.stats ?= []
            res.render 'stat', {vid: video}

    app.get '/view/:id', (req, res) ->
        console.log req.params.id
        video_type.get req.params.id, die_on_error res, (video) ->
            console.log video
            for stat in video.stats
                # Subtract 3 seconds because the stat is entered after the play
                stat.time = Math.max 0, stat.time - 5

            players = _.uniq _(video.stats).map (stat) ->
                stat.stat.player
            skill_names  = _.uniq _(video.stats).map (stat) ->
                stat.stat.skill

            skills = _.map skill_names, (name) ->
                relevant_stats = _(video.stats).filter (stat) -> stat.stat.skill == name
                details = {}
                for stat in relevant_stats
                    for detail, value of stat.stat.details
                        details[detail] ?= []
                        if value not in details[detail]
                             details[detail].push value

                {name, details}
            split_url = video.url.split('.')
            vid.flashurl = (split_url[0...split_url.length].join'.')+.flv
            res.render 'view', {vid: video, players, skills}



