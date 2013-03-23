$ ->
    _V_("video").ready ->
        player = @

        playing = false
        play_button = $ '.play'
        play_button.on 'click', ->
            if playing
                player.pause()
            else
                player.play()
            playing = not playing

        player.addEvent 'play', -> play_button.text 'Pause'
        player.addEvent 'pause', -> play_button.text 'Resume'

        $('.stat').on 'click', ->
            stat = $ @
            player.currentTime stat.data "time"
            player.play()

        stat_at_time = (time) ->
            stats = config.video.stats
            for stat, idx in stats
                if stat.time > time
                    return Math.max 0, idx - 1
            return stats.length - 1

        current_stat = -1
        player.addEvent 'timeupdate', () ->
            time = player.currentTime()
            new_current_stat = stat_at_time time
            console.log new_current_stat, current_stat
            if new_current_stat != current_stat
                $("#stat-#{current_stat}").removeClass 'current'
                current_stat = new_current_stat
                $("#stat-#{current_stat}").addClass 'current'

    do -> # Filtering
        all_stats = config.video.stats
        for stat, idx in all_stats
            stat.node = $ "#stat-#{idx}"

        filtered_stats = all_stats
        show_all = ->
            filterted_stats = all_stats
            
            $('.stat').show()


        show_filtered = (test) ->
            filtered_stats = (stat for stat in all_stats when test stat.stat)
            kills = 0
            errors = 0
            us = 0
            them = 0
            for current_stat in filtered_stats
                console.log current_stat
                
                if current_stat.stat.details.result != undefined
                    console.log 'here'
                    if current_stat.stat.details.result == "k"
                        console.log 'kills'
                        kills+=1
                    if current_stat.stat.details.result == "e"
                        console.log 'errors'
                        errors+=1
                    if current_stat.stat.details.result == "u"
                        console.log 'us'
                        us+=1
                    if current_stat.stat.details.result == "t"
                        console.log 'them'
                        them+=1
            console.log "kills" + kills
            console.log (kills-errors)/(kills+errors+us+them)
       
            $('.stat').hide()
            for stat in filtered_stats
                stat.node.show()


        controls = $ '.controls'
        player_checkboxes = controls.find '.players .player-checkbox'
        skill_checkboxes  = controls.find '.skills .skill-checkbox'
        detail_checkboxes = controls.find '.skills .detail-checkbox'

        do_filter = ->
            filter =
                player: {}
                skill: {}
                details: {}
                required:
                    details: {}

            get_filters = (type, checkboxes) ->
                filters = {}
                any = false
                for e in checkboxes
                    box = $ e
                    checked = box.is ':checked'
                    filters[box.data type] = checked
                    if checked
                        any = true
                if not any
                    for key of filters
                        filters[key] = true
                [filters, any]

            load_details_of = (skill) ->
                details = {}
                details_div = controls.find ".#{skill} .details"
                filter.required.details[skill] = []
                for e in details_div.find '.detail'
                    detail_div = $ e
                    boxes = detail_div.find '.detail-checkbox'
                    [values, required] = get_filters 'detail', boxes
                    name = detail_div.data 'name'
                    details[name] = values
                    if required
                        filter.required.details[skill].push name
                details
                

            [filter.player] = get_filters 'player', player_checkboxes
            [filter.skill] = get_filters 'skill', skill_checkboxes

            for skill, checked of filter.skill
                if checked
                    filter.details[skill] = load_details_of skill

                
                    
  
            show_filtered (stat) ->
                if filter.player[stat.player] and filter.skill[stat.skill]
                    for detail in filter.required.details[stat.skill]
                        if not stat.details[detail]? or not filter.details[stat.skill][detail][stat.details[detail]]
                            return false
                    true
                else
                    false


        player_checkboxes.on 'change click', do_filter
        skill_checkboxes.on 'change click', do_filter
        detail_checkboxes.on 'change click', do_filter

        filter_box  = $ '.filter'
        filter_box.on 'change keydown', -> _.defer ->
            filter = filter_box.val()
            if /^\s*$/.test filter
                show_all()
            else
                show_filtered filter


