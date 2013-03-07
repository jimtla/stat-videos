url = require 'url'

redis_url = url.parse process.env.REDISTOGO_URL ? 'redis://localhost:6379'
redis = (require 'redis').createClient redis_url.port, redis_url.hostname

if redis_url.auth
    [redis_db, redis_password] = redis_url.auth.split ':'
    redis.auth redis_password

set = (key, value, callback) ->
    redis.set key, value, callback

get = (key, callback) ->
    redis.get key, (err, res) ->
        if err?
            callback err
        else
            callback null, res

set_json = (key, value, callback) ->
    set key, (JSON.stringify value), callback

get_json = (key, callback) ->
    get key, (err, res) ->
        if err?
            callback err
        else
            [err, json_res] = try
                    [null, JSON.parse res]
                catch e
                    ["Invalid JSON at key #{key}", null]
            callback err, json_res

module.exports = { set, get, set_json, get_json, redis }
