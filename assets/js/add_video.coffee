$ ->
    form = $ '.by-link'
    form.on 'submit', ->
        video = { video: $('.link').val() }
        $.post "/videos",  {json: JSON.stringify video}, (response) ->
            {id} = JSON.parse response
            window.location.href = "/stat/#{id}"
        false
