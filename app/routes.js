// Generated by CoffeeScript 1.3.3
var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = function(app) {
  var characters, die_on_error, fs, ftp, random_name, request, rest, video_type, _;
  die_on_error = require('./util').die_on_error;
  rest = require('./rest');
  fs = require('fs');
  ftp = require('ftp');
  request = require('request');
  _ = require('underscore');
  characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  random_name = function(length) {
    var chars, i;
    chars = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= length ? _i < length : _i > length; i = 0 <= length ? ++_i : --_i) {
        _results.push(characters[Math.floor(Math.random() * characters.length)]);
      }
      return _results;
    })();
    return chars.join('');
  };
  video_type = rest.add_type(app, 'video', {});
  app.get('/add_video', function(req, res) {
    return res.render('add_video');
  });
  app.post('/add_video', function(req, res) {
    return fs.readFile(req.files.video.path, function(err, data) {
      var client;
      client = new ftp();
      client.on('ready', function() {
        var key;
        key = "videos/" + (random_name(16)) + ".mp4";
        return client.put(data, key, die_on_error(res, function() {
          client.end();
          return video_type.add({
            video: "http://acsvolleyball.com/" + key
          }, die_on_error(res, function(video) {
            return res.redirect("/stat/" + video.id);
          }));
        }));
      });
      client.on('error', function(err) {
        return res.send(err);
      });
      return client.connect({
        host: 'acsvolleyball.com',
        user: 'acsvolleyball',
        password: 'Voll3yball'
      });
    });
  });
  app.get('/stat/:id', function(req, res) {
    console.log(req.params.id);
    return video_type.get(req.params.id, die_on_error(res, function(video) {
      var _ref;
      console.log(video);
      if ((_ref = video.stats) == null) {
        video.stats = [];
      }
      return res.render('stat', {
        vid: video
      });
    }));
  });
  app.get('/view/:id', function(req, res) {
    console.log(req.params.id);
    return video_type.get(req.params.id, die_on_error(res, function(video) {
      var players, skill_names, skills, split_url, stat, _i, _len, _ref;
      console.log(video);
      _ref = video.stats;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        stat = _ref[_i];
        stat.time = Math.max(0, stat.time - 5);
      }
      players = _.uniq(_(video.stats).map(function(stat) {
        return stat.stat.player;
      }));
      skill_names = _.uniq(_(video.stats).map(function(stat) {
        return stat.stat.skill;
      }));
      skills = _.map(skill_names, function(name) {
        var detail, details, relevant_stats, value, _j, _len1, _ref1, _ref2;
        relevant_stats = _(video.stats).filter(function(stat) {
          return stat.stat.skill === name;
        });
        details = {};
        for (_j = 0, _len1 = relevant_stats.length; _j < _len1; _j++) {
          stat = relevant_stats[_j];
          _ref1 = stat.stat.details;
          for (detail in _ref1) {
            value = _ref1[detail];
            if ((_ref2 = details[detail]) == null) {
              details[detail] = [];
            }
            if (__indexOf.call(details[detail], value) < 0) {
              details[detail].push(value);
            }
          }
        }
        return {
          name: name,
          details: details
        };
      });
      split_url = video.video.split('.');
      video.flashurl = (split_url.slice(0, split_url.length).join('.')) + '.flv';
      return res.render('view', {
        vid: video,
        players: players,
        skills: skills
      });
    }));
  });
  app.get('/ipad', function(req, res) {
    return request.get({
      uri: 'http://ipad-stats.herokuapp.com/games',
      json: true
    }, die_on_error(res, function(response, games) {
      return res.render('ipad_games', {
        games: games
      });
    }));
  });
  app.get('/ipad/:game', function(req, res) {
    var id;
    id = req.params.game;
    return res.render('ipad_game', {
      id: id
    });
  });
  app.post('/ipad', function(req, res) {
    var id, offset, url, _ref;
    _ref = req.body, id = _ref.id, url = _ref.url, offset = _ref.offset;
    console.log(id);
    return request.get({
      uri: "http://ipad-stats.herokuapp.com/game/" + id,
      json: true
    }, die_on_error(res, function(response, game) {
      var play, start_time, stat, stats, video;
      console.log(game);
      stats = _.flatten((function() {
        var _i, _len, _ref1, _results;
        _ref1 = game.plays;
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          play = _ref1[_i];
          _results.push(play.stats);
        }
        return _results;
      })());
      start_time = stats[0].timestamp - parseInt(offset, 10);
      video = {
        video: url,
        stats: []
      };
      video.stats = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = stats.length; _i < _len; _i++) {
          stat = stats[_i];
          _results.push({
            time: stat.timestamp - start_time,
            stat: {
              player: stat.player,
              skill: stat.skill,
              details: stat.details
            }
          });
        }
        return _results;
      })();
      return video_type.add(video, die_on_error(res, function(video) {
        return res.redirect("/view/" + video.id);
      }));
    }));
  });
  app.get('/old', function(req, res) {
    return res.render('old', {});
  });
  return app.post('/old', function(req, res) {
    var add_stat, line, lines, offset, other, parse_time, player, result, skill, start_time, stats, team, time, url, video, _i, _len, _ref, _ref1, _ref2, _ref3;
    _ref = req.body, url = _ref.url, lines = _ref.lines, offset = _ref.offset;
    stats = [];
    start_time = null;
    parse_time = function(time_string) {
      var hours, minutes, seconds, time, _ref1;
      _ref1 = time_string.split(':'), hours = _ref1[0], minutes = _ref1[1], seconds = _ref1[2];
      console.log(hours, minutes, seconds);
      time = ((parseInt(hours, 10)) * 60 + (parseInt(minutes, 10))) * 60 + parseFloat(seconds, 10);
      console.log(time);
      if (start_time == null) {
        start_time = time - offset;
      }
      console.log(start_time);
      return time - start_time;
    };
    add_stat = function(skill, team, player, time, result, details) {
      if (details == null) {
        details = {};
      }
      details.result = result;
      details.team = team;
      return stats.push({
        time: parse_time(time),
        stat: {
          player: player,
          skill: skill,
          details: details
        }
      });
    };
    _ref1 = lines.split('\n');
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      line = _ref1[_i];
      if (!(line != null)) {
        continue;
      }
      console.log(line.split("\t"));
      _ref2 = line.split("\t"), skill = _ref2[0], player = _ref2[1], other = _ref2[2], result = _ref2[3], time = _ref2[4];
      if (skill === 'ftp' || skill === 'game') {
        continue;
      }
      _ref3 = skill, skill = _ref3[0], team = _ref3[1];
      if (team === "t") {
        team = 1;
      } else {
        team = 0;
      }
      switch (skill) {
        case 's':
          add_stat("serve", team, player, time, result);
          add_stat("pass", 1 - team, other, time, result);
          break;
        case 'h':
          add_stat("hit", team, player, time, result, {
            hands: other
          });
          break;
        case 'd':
          time = other;
          add_stat("dig", team, player, time, '');
          break;
        case 'b':
          time = result;
          result = other;
          add_stat("block", team, player, time, result);
      }
    }
    video = {
      video: url,
      stats: stats
    };
    return video_type.add(video, die_on_error(res, function(video) {
      return res.redirect("/view/" + video.id);
    }));
  });
};
