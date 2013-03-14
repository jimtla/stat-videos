$ ->

    parse_stat = (stat) ->
        [skill_character, player, detail_list...] = stat.split ' '
        skill = globals.skills_by_character[skill_character]

        console.log details
        details = {}
        for detail in detail_list
            detail_character = detail[0]
            detail_dict = skill.details[detail_character]
            if detail_dict?
                details[detail_dict.name] = detail[1...]

        {skill: skill.name, player, details}

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
        stats = config.video.stats ? []
        input.on 'keypress', (e) ->
            if e.which == 13
                time = player.currentTime()
                stat = parse_stat input.val()
                log.append $ "<div><span class='timestamp'>#{time} </span>#{JSON.stringify stat}</div>"
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
