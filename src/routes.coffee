module.exports = (app) ->
    {die_on_error} = require './util'
    rest = require './rest'
    fs = require 'fs'
    ftp = require 'ftp'
    request = require 'request'
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
            split_url = video.video.split('.')
            video.flashurl = (split_url[0...split_url.length].join '.') + '.flv'
            res.render 'view', {vid: video, players, skills}



    app.get '/ipad', (req, res) ->
        request.get {uri:'http://ipad-stats.herokuapp.com/games', json: true},
            die_on_error res, (response, games) ->
                res.render 'ipad_games', {games}

                
    app.get '/ipad/:game', (req, res) ->
        id = req.params.game
        res.render 'ipad_game', {id}

    app.post '/ipad', (req, res) ->
        {id, url, offset} = req.body

        console.log id
        request.get {uri:"http://ipad-stats.herokuapp.com/game/#{id}", json: true},
            die_on_error res, (response, game) ->
                console.log game
                stats = _.flatten (play.stats for play in game.plays)
                start_time = stats[0].timestamp - parseInt offset, 10
                video = {video: url, stats:[]}
                video.stats = 
                    for stat in stats
                        time: stat.timestamp - start_time
                        stat: {player: stat.player, skill:stat.skill, details: stat.details}
                video_type.add video, die_on_error res, (video) ->
                    res.redirect "/view/#{video.id}"

                
    app.get '/old', (req, res) ->
        res.render 'old', {}

    app.post '/old', (req, res) ->
        {url, lines, offset} = req.body

        stats = []
        start_time = null
        parse_time = (time_string) ->
            # Parses time like: HH:MM:SS.MSMSMSMS
            [hours, minutes, seconds] = time_string.split ':'
            console.log hours, minutes, seconds
            time = ((parseInt hours, 10) * 60 + (parseInt minutes, 10)) * 60 + parseFloat seconds, 10
            console.log time
            start_time ?= time - offset
            console.log start_time
            time - start_time

        add_stat = (skill, team, player, time, result, details = {}) ->
            details.result = result
            details.team = team
            stats.push 
                time: parse_time time
                stat: {player, skill, details}

        for line in lines.split '\n'
            if !line?
                continue
            console.log line.split " "
            [skill, player, other, result, time] = line.split " "
            if skill in ['ftp', 'game']
                continue
            [skill, team] = skill
            if team == "t" 
                team = 1
            else 
                team = 0
            switch skill
                when 's'
                    add_stat "serve", team, player, time, result
                    add_stat "pass", 1 - team, other, time, result
                when 'h'
                    add_stat "hit", team, player, time, result, {hands: other}
                when 'd'
                    time = other
                    add_stat "dig", team, player, time, ''
                when 'b'
                    time = result
                    result = other
                    add_stat "block", team, player, time, result

        video = {video: url, stats}

        video_type.add video, die_on_error res, (video) ->
            res.redirect "/view/#{video.id}"
