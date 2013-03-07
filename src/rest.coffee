_ = require 'underscore'
async = require 'async'
{set_json, get_json, redis} = require './persist'
{arg_map, fail_on_error, die_on_error} = require './util'

add_type = (app, type, {after_add, before_del, after_get}) ->
    after_add ?= (model, callback) -> callback()
    before_del ?= (model, callback) -> callback()
    after_get ?= (model, callback) -> callback null, model

    add = (data, callback) ->
        redis.incr "atom:#{type}_count", fail_on_error callback, (id) ->
            data.id = id
            save data, fail_on_error callback, ->
                redis.rpush "atom:#{type}s", id, fail_on_error callback, ->
                    after_add data, fail_on_error callback, ->
                        callback null, data

    save = (data, callback) ->
        set_json "atom:#{type}s:#{data.id}", data, callback

    del = (id, callback) ->
        get id, fail_on_error callback, (model) ->
            before_del model, fail_on_error callback, ->
                redis.del "atom:#{type}s:#{id}"
                redis.lrem "atom:#{type}s", 0, id, callback

    get = (id, callback) ->
        get_json "atom:#{type}s:#{id}", fail_on_error callback, (data) ->
            after_get data, callback

    get_collection = (ids = [], callback) ->
        arg_map async.map, 'array', 'iterator', 'callback',
            array: ids
            iterator: get
            callback: callback

    get_all = (callback) ->
        redis.lrange "atom:#{type}s", 0, -1, fail_on_error callback, (model_ids) ->
            get_collection model_ids, callback

    load_child_list = (model, child, child_type, callback) ->
        redis.lrange "atom:#{type}s:#{model.id}:#{child}", 0, -1,
            fail_on_error callback, (child_ids) ->
                child_type.get_collection child_ids, fail_on_error callback, (children) ->
                    model[child] = children
                    callback null, model

    app.post "/#{type}s", (req, res) ->
        add JSON.parse(req.body.json), die_on_error res, (model) ->
            res.send 200, JSON.stringify model

    app.get "/#{type}s.json", (req, res) ->
        get_all die_on_error res, (models) ->
            res.send 200, JSON.stringify models

    app.get "/#{type}s", (req, res) ->
        get_all die_on_error res, (models) ->
            res.send 200, JSON.stringify models

    app.delete "/#{type}/:id", (req, res) ->
        {id} = req.params
        del id, die_on_error res, (removed) ->
            res.send 200, removed

    app.post "/#{type}/:id", (req, res) ->
        model = JSON.parse(req.body.json)
        model.id = req.params.id
        save model, die_on_error res, (saved) ->
            res.send 200, saved

    {add, save, del, get, get_collection, load_child_list, get_all}

module.exports = { add_type }
