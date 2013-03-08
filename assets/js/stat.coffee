$ ->
    _V_("video").ready ->
        player = @

        playing = false
        play_button = $ '.play'
        play_button.on 'click', ->
            if playing
                player.pause()
                play_button.text 'Resume'
            else
                player.play()
                play_button.text 'Pause'
            playing = not playing


        input = $ '.stat-input'
        log = $ '.log'
        stats = []
        input.on 'keypress', (e) ->
            if e.which == 13
                time = player.currentTime()
                stat = input.val()
                log.append $ "<div><span class='timestamp'>#{time}</span>#{stat}</div>"
                input.val ''
                stats.push {time, stat}
                false
            else
                true

        done_button = $ '.done'
        done_button.on 'click', ->
            video = config.video
            video.stats = stats
            $.post "/video/#{video.id}",  {json: JSON.stringify video}, ->
