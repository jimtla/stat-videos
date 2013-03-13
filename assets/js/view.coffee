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

        current_stat = -1
        player.addEvent 'timeupdate', () ->
            time = player.currentTime()
            new_current_stat = stat_at_time time
            console.log new_current_stat, current_stat
            if new_current_stat != current_stat
                $("#stat-#{current_stat}").removeClass 'current'
                current_stat = new_current_stat
                $("#stat-#{current_stat}").addClass 'current'


        stat_at_time = (time) ->
            stats = config.video.stats
            for stat, idx in stats
                if stat.time > time
                    return Math.max 0, idx - 1
            return stats.length - 1

        for stat, idx in all_stats
            stat.node = $ "#stat-#{idx}"

        filtered_stats = all_stats
        show_all = ->
            filterted_stats = all_stats
            $('.stat').show()

        show_filtered = (filter) ->
            regex = new RegExp filter
            filtered_stats = (stat for stat in all_stats when regex.test stat.stat)
            $('.stat').hide()
            for stat in filtered_stats
                stat.node.show()



        filter_box  = $ '.filter'
        filter_box.on 'change keydown', -> _.defer ->
            filter = filter_box.val()
            if /^\s*$/.test filter
                show_all()
            else
                show_filtered filter

