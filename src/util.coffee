_ = require 'underscore'

fail_on_error = (error, success) -> (err, rest...) ->
    if err? error err
    else success rest...

die_on_error = (res, fn) ->
    fail_on_error ((err) -> res.send 500, err), fn

arg_map = (fn, args..., arg_object) ->
    fn _(args).map((arg) -> arg_object[arg])...

module.exports = { fail_on_error, die_on_error, arg_map}
