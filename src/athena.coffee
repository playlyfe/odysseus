((root, factory) ->

  # AMD. Register as anonymous module.
  if typeof define is 'function' and define.amd
    define (require, exports, module) ->
      _ = require('lodash')
      moment = require('moment')
      BigNumber = require('bignumber')    # bignumber.js is not a valid name
      factory(exports, _, moment, BigNumber)
      exports.Athena

  # CommonJS. As a node module.
  else if typeof exports is 'object'
    factory exports, require('lodash'), require('moment'), require('bignumber.js')

  return
)(this, (exports, _, moment, BigNumber) ->
  # Override the templating delimiters to distinguish from HTML tags
  _.templateSettings.interpolate = /@\{([\s\S]+?)\}@/g
  _.templateSettings.escape = /\{\{([\s\S]+?)\}\}/g
  _.templateSettings.evaluate = /\$\{([\s\S]+?)\}\$/g
  _.templateSettings.variable = 'ath'
  _.templateSettings.imports = {
    '_': _            # Pass the default lodash object
    'moment': moment    # Pass moment for time transformations
    'ONE': new BigNumber(1)   # In this scenario, BigNumber isnt really required.
                              # Just send ONE for idempotency and
                              # to enable bignumber operations.
  };

  class Athena
    ###*
     * A map of the default markup tags to be inserted into the rendered HTML
     * in-case no object is supplied in the constructor
     * @type {Object}
    ###
    @default_markup: {
      actor: "ath-actor",
      target: "ath-target",
      object: "ath-object",
      role_list: "ath-role-list",
      role: "ath-role",
      lane: "ath-lane",
      timestamp: "ath-ts"
    }

    ###*
     * A list of all the available templates
     * @type {Object}
    ###
    @stored_templates: {
      ###*
       * Activity Templates
      ###
      "create": {
        text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} created "+
              "the {{ath.ctx.isTeam ? 'team' : 'process'}} "+
              "'{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}'.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> created the {{ath.ctx.isTeam ? 'team' : 'process'}} "+
              "<span class='@{ath.markup.object}@'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
              "</span>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "delete": {
        text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} deleted "+
              "the {{ath.ctx.isTeam ? 'team' : 'process'}} "+
              "'{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}'.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> deleted the {{ath.ctx.isTeam ? 'team' : 'process'}} "+
              "<span class='@{ath.markup.object}@'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
              "</span>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "join": {
        text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} joined "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ as "+
              "${ if (ath.ctx.isTeam) { }$"+
                "{{_.keys(ath.story.roles).join(', ')}}"+
              "${ } else if (ath.ctx.isProcess) { }$"+
                "{{_.reduce(ath.story.roles, function(list, role, lane) {"+
                  "list.push(["+
                    "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                  "]);"+
                  "return list;"+
                "}, []).join(', ')}}"+
              "${ } }$.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> joined "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ as "+
              "<ul class='@{ath.markup.role_list}@'>"+
              "${ if (ath.ctx.isTeam) { }$"+
                "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                  "<li class='@{ath.markup.role}@'>{{role}}</li>"+
                "${ }) }$"+
              "${ } else if (ath.ctx.isProcess) { }$"+
                "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                  "<li>"+
                    "<span class='@{ath.markup.role}@'>{{role}}</span> in "+
                    "<span class='@{ath.markup.lane}@'>"+
                      "{{lane === '*' ? 'All': lane }}"+
                    "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                  "</li>"+
                "${ })}$"+
              "${ } }$</ul>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "leave": {
        text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} left "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> left "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "kick": {
        text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} kicked "+
              "{{ath.ctx.isPlayer ? 'you' : ath.story.player.alias||ath.story.player.id}} from "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> kicked "+
              "<span class='@{ath.markup.target}@'>"+
                "{{ath.ctx.isPlayer ? 'you' : ath.story.player.alias||ath.story.player.id}}"+
              "</span> from "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "join:request:accept": {
        text: "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}} "+
              "request to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ has been accepted by "+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.target}@'>"+
                "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}}"+
              "</span> request to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ has been accepted by "+
              "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "join:request:reject": {
        text: "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}} "+
              "request to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ has been rejected by "+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.target}@'>"+
                "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}}"+
              "</span> request to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ has been rejected by "+
              "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "invite:accept": {
        text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} "+
              "accepted "+
              "{{ath.ctx.isInviter ? 'your' : (ath.story.inviter.alias||ath.story.inviter.id) + '\u2019s'}} "+
              "invitation to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ as "+
              "${ if (ath.ctx.isTeam) { }$"+
                "{{_.keys(ath.story.roles).join(', ')}}"+
              "${ } else if (ath.ctx.isProcess) { }$"+
                "{{_.reduce(ath.story.roles, function(list, role, lane) {"+
                  "list.push(["+
                    "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                  "]);"+
                  "return list;"+
                "}, []).join(', ')}}"+
              "${ } }$.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> accepted "+
              "<span class='@{ath.markup.target}@'>"+
                "{{ath.ctx.isInviter ? 'your' : (ath.story.inviter.alias||ath.story.inviter.id) + '\u2019s'}}"+
              "</span> invitation to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ as "+
              "<ul class='@{ath.markup.role_list}@'>"+
              "${ if (ath.ctx.isTeam) { }$"+
                "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                  "<li class='@{ath.markup.role}@'>{{role}}</li>"+
                "${ }) }$"+
              "${ } else if (ath.ctx.isProcess) { }$"+
                "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                  "<li>"+
                    "<span class='@{ath.markup.role}@'>{{role}}</span> in "+
                    "<span class='@{ath.markup.lane}@'>"+
                      "{{lane === '*' ? 'All': lane }}"+
                    "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                  "</li>"+
                "${ })}$"+
              "${ } }$</ul>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "invite:reject": {
        text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} "+
              "rejected "+
              "{{ath.ctx.isInviter ? 'your' : (ath.story.inviter.alias||ath.story.inviter.id) + '\u2019s'}} "+
              "invitation to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ as "+
              "${ if (ath.ctx.isTeam) { }$"+
                "{{_.keys(ath.story.roles).join(', ')}}"+
              "${ } else if (ath.ctx.isProcess) { }$"+
                "{{_.reduce(ath.story.roles, function(list, role, lane) {"+
                  "list.push(["+
                    "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                  "]);"+
                  "return list;"+
                "}, []).join(', ')}}"+
              "${ } }$.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> rejected "+
              "<span class='@{ath.markup.target}@'>"+
                "{{ath.ctx.isInviter ? 'your' : (ath.story.inviter.alias||ath.story.inviter.id) + '\u2019s'}}"+
              "</span> invitation to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ as "+
              "<ul class='@{ath.markup.role_list}@'>"+
              "${ if (ath.ctx.isTeam) { }$"+
                  "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                    "<li class='@{ath.markup.role}@'>{{role}}</li>"+
                  "${ }) }$"+
              "${ } else if (ath.ctx.isProcess) { }$"+
                "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                  "<li>"+
                    "<span class='@{ath.markup.role}@'>{{role}}</span> in "+
                    "<span class='@{ath.markup.lane}@'>"+
                      "{{lane === '*' ? 'All': lane }}"+
                    "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                  "</li>"+
                "${ })}$"+
              "${ } }$</ul>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "role:request:accept": {
        text: "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}} "+
              "request for a change of roles in "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ has been accepted by "+
              "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}.\n"+
              "Changes:"+
              "${ if (ath.ctx.isTeam) {"+
                "_.forEach(ath.story.changes, function(diff, role) { }$"+
                  "\n  [{{ !diff.old ? '+' : '-'}}] {{role}}"+
                "${ }); }$"+
              "${ } else if (ath.ctx.isProcess) {"+
                "_.forEach(ath.story.changes, function(diff, lane) {"+
                  # if both new and old keys exist, the role was changed
                  "if(!!diff['old'] && !!diff['new']) { }$"+
                    "\n  [+] {{diff['new']}} in {{lane}} lane"+
                    "\n  [-] {{diff['old']}} in {{lane}} lane"+
                  "${ } else { }$"+
                    "\n  [{{ !diff.old ? '+' : '-'}}] "+
                    "{{diff['new'] || diff['old']}} in "+
                    "{{lane === '*' ? 'All lanes' : lane + ' lane'}}"+
                  "${ }"+
                "});"+
              "} }$\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.target}@'>"+
                "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}}"+
              "</span> request for a change of roles in "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ has been accepted by "+
              "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span>."+
              "<ul class='@{ath.markup.role_list}@ @{ath.markup.diff_list}@'>"+
                "<li class='@{ath.markup.list_header}@'>Changes</li>"+
                "${ if (ath.ctx.isTeam) {"+
                  "_.forEach(ath.story.changes, function(diff, role) { }$"+
                    "<li class='@{ath.markup.role}@ @{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                      "{{role}}"+
                    "</li>"+
                  "${ }); }$"+
                "${ } else if (ath.ctx.isProcess) {"+
                  "_.forEach(ath.story.changes, function(diff, lane) {"+
                    # if both new and old keys exist, the role was changed
                    "if(!!diff['old'] && !!diff['new']) { }$"+
                      "<li class='@{ath.markup.diff_change}@'>"+
                        "<span class='@{ath.markup.role}@ @{ath.markup.diff_add}@'>{{diff['new']}}</span> from "+
                        "<span class='@{ath.markup.role}@ @{ath.markup.diff_rem}@'>{{diff['old']}}</span> in "+
                        "<span class='@{ath.markup.lane}@'>{{lane}}</span> lane"+
                      "</li>"+
                    "${ } else { }$"+
                      "<li class='@{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                        "<span class='@{ath.markup.role}@'>{{diff['new'] || diff['old']}}</span> in "+
                        "<span class='@{ath.markup.lane}@'>"+
                          "{{lane === '*' ? 'All' : lane}}"+
                        "</span> lane{{lane === '*' ? 's' : ''}}"+
                      "</li>"+
                    "${ } }$"+
                  "${ }); }$"+
                "${ } }$"+
              "</ul>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "role:request:reject": {
        text: "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}} "+
              "request for a change of roles in "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ has been rejected by "+
              "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.target}@'>"+
                "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}}"+
              "</span> request for a change of roles in "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ has been rejected by "+
              "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "role:change": {
        text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} "+
              "{{ath.ctx.isActor ? 'have' : 'has'}} changed roles in "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$.\n"+
              "Changes:"+
              "${ if (ath.ctx.isTeam) {"+
                "_.forEach(ath.story.changes, function(diff, role) { }$"+
                  "\n  [{{ !diff.old ? '+' : '-'}}] {{role}}"+
                "${ }); }$"+
              "${ } else if (ath.ctx.isProcess) {"+
                "_.forEach(ath.story.changes, function(diff, lane) {"+
                  # if both new and old keys exist, the role was changed
                  "if(!!diff['old'] && !!diff['new']) { }$"+
                    "\n  [+] {{diff['new']}} in {{lane}} lane"+
                    "\n  [-] {{diff['old']}} in {{lane}} lane"+
                  "${ } else { }$"+
                    "\n  [{{ !diff.old ? '+' : '-'}}] "+
                    "{{diff['new'] || diff['old']}} in "+
                    "{{lane === '*' ? 'All lanes' : lane + ' lane'}}"+
                  "${ }"+
                "});"+
              "} }$\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> {{ath.ctx.isActor ? 'have' : 'has'}} changed roles in "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$."+
              "<ul class='@{ath.markup.role_list}@ @{ath.markup.diff_list}@'>"+
                "<li class='@{ath.markup.list_header}@'>Changes</li>"+
                "${ if (ath.ctx.isTeam) {"+
                  "_.forEach(ath.story.changes, function(diff, role) { }$"+
                    "<li class='@{ath.markup.role}@ @{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                      "{{role}}"+
                    "</li>"+
                  "${ }); }$"+
                "${ } else if (ath.ctx.isProcess) {"+
                  "_.forEach(ath.story.changes, function(diff, lane) {"+
                    # if both new and old keys exist, the role was changed
                    "if(!!diff['old'] && !!diff['new']) { }$"+
                      "<li class='@{ath.markup.diff_change}@'>"+
                        "<span class='@{ath.markup.role}@ @{ath.markup.diff_add}@'>{{diff['new']}}</span> from "+
                        "<span class='@{ath.markup.role}@ @{ath.markup.diff_rem}@'>{{diff['old']}}</span> in "+
                        "<span class='@{ath.markup.lane}@'>{{lane}}</span> lane"+
                      "</li>"+
                    "${ } else { }$"+
                      "<li class='@{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                        "<span class='@{ath.markup.role}@'>{{diff['new'] || diff['old']}}</span> in "+
                        "<span class='@{ath.markup.lane}@'>"+
                          "{{lane === '*' ? 'All' : lane}}"+
                        "</span> lane{{lane === '*' ? 's' : ''}}"+
                      "</li>"+
                    "${ } }$"+
                  "${ }); }$"+
                "${ } }$"+
              "</ul>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "role:assign": {
        text: "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}} "+
              "roles in "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ have been changed by "+
              "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}.\n"+
              "Changes:"+
              "${ if (ath.ctx.isTeam) {"+
                "_.forEach(ath.story.changes, function(diff, role) { }$"+
                  "\n  [{{ !diff.old ? '+' : '-'}}] {{role}}"+
                "${ }); }$"+
              "${ } else if (ath.ctx.isProcess) {"+
                "_.forEach(ath.story.changes, function(diff, lane) {"+
                  "if(!!diff['old'] && !!diff['new']) { }$"+
                    "\n  [+] {{diff['new']}} in {{lane}} lane"+
                    "\n  [-] {{diff['old']}} in {{lane}} lane"+
                  "${ } else { }$"+
                    "\n  [{{ !diff.old ? '+' : '-'}}] "+
                    "{{diff['new'] || diff['old']}} in "+
                    "{{lane === '*' ? 'All lanes' : lane + ' lane'}}"+
                  "${ }"+
                "});"+
              "} }$\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.target}@'>"+
                "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}}"+
              "</span> roles in "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
                " <span class='@{ath.markup.object}@'>"+
                  "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ have been changed by "+
              "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span>."+
              "<ul class='@{ath.markup.role_list}@ @{ath.markup.diff_list}@'>"+
                "<li class='@{ath.markup.list_header}@'>Changes</li>"+
                "${ if (ath.ctx.isTeam) {"+
                  "_.forEach(ath.story.changes, function(diff, role) { }$"+
                    "<li class='@{ath.markup.role}@ @{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                      "{{role}}"+
                    "</li>"+
                  "${ }); }$"+
                "${ } else if (ath.ctx.isProcess) {"+
                  "_.forEach(ath.story.changes, function(diff, lane) {"+
                    # if both new and old keys exist, the role was changed
                    "if(!!diff['old'] && !!diff['new']) { }$"+
                      "<li class='@{ath.markup.diff_change}@'>"+
                        "<span class='@{ath.markup.role}@ @{ath.markup.diff_add}@'>{{diff['new']}}</span> from "+
                        "<span class='@{ath.markup.role}@ @{ath.markup.diff_rem}@'>{{diff['old']}}</span> in "+
                        "<span class='@{ath.markup.lane}@'>{{lane}}</span> lane"+
                      "</li>"+
                    "${ } else { }$"+
                      "<li class='@{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                        "<span class='@{ath.markup.role}@'>{{diff['new'] || diff['old']}}</span> in "+
                        "<span class='@{ath.markup.lane}@'>"+
                          "{{lane === '*' ? 'All' : lane}}"+
                        "</span> lane{{lane === '*' ? 's' : ''}}"+
                      "</li>"+
                    "${ } }$"+
                  "${ }); }$"+
                "${ } }$"+
              "</ul>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "join:request": {
        text: "${ if(ath.story.state === 'PENDING') { }$"+
                "${ if(ath.ctx.isActor) { }$"+
                  "Your request to join "+
                "${ } else { }$"+
                  "{{ath.story.actor.alias||ath.story.actor.id}} wants to join "+
                "${ } }$"+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}'"+
                "${ } }$ as "+
                "${ if (ath.ctx.isTeam) { }$"+
                  "{{_.keys(ath.story.roles).join(', ')}}"+
                "${ } else if (ath.ctx.isProcess) { }$"+
                  "{{_.reduce(ath.story.roles, function(list, role, lane) {"+
                    "list.push(["+
                      "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                    "]);"+
                    "return list;"+
                  "}, []).join(', ')}}"+
                "${ } }$"+
                "{{ ath.ctx.isActor ? ' is pending' : '' }}.\n"+
                "[{{moment(ath.story.timestamp).format('llll')}}]"+
              "${ } else if(ath.story.state === 'CANCELLED') { }$"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
                " cancelled the request to join "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}'"+
                "${ } }$.\n"+
                "[{{moment(ath.story.cancelled_at).format('llll')}}]"+
              "${ } else if(ath.story.state === 'ACCEPTED') { }$"+
                "{{ath.ctx.isActor ? 'Your' : (ath.story.actor.alias||ath.story.actor.id) + '\u2019s'}}"+
                " request to join "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}'"+
                "${ } }$ has been accepted by "+
                "{{ath.story.accepted_by.alias||ath.story.accepted_by.id}}.\n"+
                "[{{moment(ath.story.accepted_at).format('llll')}}]"+
              "${ } else if(ath.story.state === 'REJECTED') { }$"+
                "{{ath.ctx.isActor ? 'Your' : (ath.story.actor.alias||ath.story.actor.id) + '\u2019s'}}"+
                " request to join "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}'"+
                "${ } }$ has been rejected by "+
                "{{ath.story.rejected_by.alias||ath.story.rejected_by.id}}.\n"+
                "[{{moment(ath.story.rejected_at).format('llll')}}]"+
              "${ } }$",

        html: "${ if(ath.story.state === 'PENDING') { }$"+
                "${ if(ath.ctx.isActor) { }$"+
                  "<span class='@{ath.markup.actor}@'>Your</span> request to join "+
                "${ } else { }$"+
                  "<span class='@{ath.markup.actor}@'>"+
                    "{{ath.story.actor.alias||ath.story.actor.id}}"+
                  "</span> wants to join "+
                "${ } }$"+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>"+
                "${ } }$ as "+
                "<ul class='@{ath.markup.role_list}@'>"+
                "${ if (ath.ctx.isTeam) { }$"+
                  "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                    "<li class='@{ath.markup.role}@'>{{role}}</li>"+
                  "${ }) }$"+
                "${ } else if (ath.ctx.isProcess) { }$"+
                    "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                      "<li>"+
                        "<span class='@{ath.markup.role}@'>{{role}}</span> in "+
                        "<span class='@{ath.markup.lane}@'>"+
                          "{{lane === '*' ? 'All': lane }}"+
                        "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                      "</li>"+
                    "${ })}$"+
                "${ } }$</ul>"+
                "{{ ath.ctx.isActor ? ' is pending' : '' }}."+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(ath.story.state === 'CANCELLED') { }$"+
                "<span class='@{ath.markup.actor}@'>"+
                  "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
                "</span>"+
                " cancelled the request to join "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>"+
                "${ } }$."+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.cancelled_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(ath.story.state === 'ACCEPTED') { }$"+
                "<span class='@{ath.markup.actor}@'>"+
                  "{{ath.ctx.isActor ? 'Your' : (ath.story.actor.alias||ath.story.actor.id) + '\u2019s'}}"+
                "</span> request to join "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been accepted by "+
                "<span class='@{ath.markup.target}@'>"+
                  "{{ath.story.accepted_by.alias||ath.story.accepted_by.id}}"+
                "</span>."+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.accepted_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(ath.story.state === 'REJECTED') { }$"+
                "<span class='@{ath.markup.actor}@'>"+
                  "{{ath.ctx.isActor ? 'Your' : (ath.story.actor.alias||ath.story.actor.id) + '\u2019s'}}"+
                "</span> request to join "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been rejected by "+
                "<span class='@{ath.markup.target}@'>"+
                  "{{ath.story.rejected_by.alias||ath.story.rejected_by.id}}"+
                "</span>."+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.rejected_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } }$"
      },
      "invite": {
        text: "${ if(ath.story.state === 'PENDING') { }$"+
                "${ if(ath.ctx.isActor) { }$"+
                  "Your invitation to {{ath.story.invitee.alias||ath.story.invitee.id}}"+
                  " to join "+
                "${ } else { }$"+
                  "{{ath.story.actor.alias||ath.story.actor.id}} invited you to join "+
                "${ } }$"+
                "the {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                  " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}'"+
                " as "+
                "${ if (ath.ctx.isTeam) {   }$"+
                  "{{_.keys(ath.story.roles).join(', ')}}"+
                "${ } else if (ath.ctx.isProcess) {  }$"+
                  "{{_.reduce(ath.story.roles, function(list, role, lane) {"+
                    "list.push(["+
                      "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                    "]);"+
                    "return list;"+
                  "}, []).join(', ')}}"+
                "${ } }$"+
                "{{ ath.ctx.isActor ? ' is pending' : '' }}.\n"+
                "[{{moment(ath.story.timestamp).format('llll')}}]"+
              "${ } else if(ath.story.state === 'CANCELLED') { }$"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
                " cancelled the invitation for "+
                "{{ath.ctx.isInvitee ? 'you' : ath.story.invitee.alias||ath.story.invitee.id}}"+
                " to join "+
                "the {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
                ".\n"+
                "[{{moment(ath.story.cancelled_at).format('llll')}}]"+
              "${ } else if(ath.story.state === 'ACCEPTED' || ath.story.state === 'REJECTED') { }$"+
                "{{ath.story.invitee.alias||ath.story.invitee.id}} "+
                "{{ath.story.accepted_at ? 'accepted' : 'rejected'}}"+
                " your invitation to join"+
                " the {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                  "ath.story.process.name || ath.story.process.id}}'"+
                " as "+
                "${ if (ath.ctx.isTeam) { }$"+
                  "{{_.keys(ath.story.roles).join(', ')}}"+
                "${ } else if (ath.ctx.isProcess) { }$"+
                  "{{_.reduce(ath.story.roles, function(list, role, lane) {"+
                    "list.push(["+
                      "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                    "]);"+
                    "return list;"+
                  "}, []).join(', ')}}"+
                "${ } }$.\n"+
                "[{{moment(ath.story.accepted_at||ath.story.rejected_at).format('llll')}}]"+
              "${ } }$",

        html: "${ if(ath.story.state === 'PENDING') { }$"+
                "${ if(ath.ctx.isActor) { }$"+
                  "<span class='@{ath.markup.actor}@'>Your</span> invitation to "+
                  "<span class='@{ath.markup.target}@'>{{ath.story.invitee.alias||ath.story.invitee.id}}</span>"+
                  " to join "+
                "${ } else { }$"+
                  "<span class='@{ath.markup.actor}@'>{{ath.story.actor.alias||ath.story.actor.id}}</span> "+
                  "invited <span class='@{ath.markup.target}@'>you</span> to join "+
                "${ } }$"+
                "the {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>"+
                " as "+
                "<ul class='@{ath.markup.role_list}@'>"+
                "${ if (ath.ctx.isTeam) { }$"+
                  "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                    "<li class='@{ath.markup.role}@'>{{role}}</li>"+
                  "${ }) }$"+
                "${ } else if (ath.ctx.isProcess) { }$"+
                  "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='@{ath.markup.role}@'>{{role}}</span> in "+
                      "<span class='@{ath.markup.lane}@'>"+
                        "{{lane === '*' ? 'All': lane }}"+
                      "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                    "</li>"+
                  "${ })}$"+
                "${ } }$</ul>"+
                "{{ ath.ctx.isActor ? ' is pending' : '' }}."+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(ath.story.state === 'CANCELLED') { }$"+
                "<span class='@{ath.markup.actor}@'>"+
                  "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
                "</span>"+
                " cancelled the invitation for "+
                "<span class='@{ath.markup.target}@'>"+
                  "{{ath.ctx.isInvitee ? 'you' : ath.story.invitee.alias||ath.story.invitee.id}}"+
                "</span>"+
                " to join "+
                "the {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>."+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.cancelled_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(ath.story.state === 'ACCEPTED' || ath.story.state === 'REJECTED') { }$"+
                "<span class='@{ath.markup.target}@'>"+
                  "{{ath.story.invitee.alias||ath.story.invitee.id}}"+
                "</span> {{ath.story.accepted_at ? 'accepted' : 'rejected'}} "+
                "<span class='@{ath.markup.actor}@'>your</span>"+
                " invitation to join "+
                "the {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>"+
                " as "+
                "<ul class='@{ath.markup.role_list}@'>"+
                "${ if (ath.ctx.isTeam) { }$"+
                  "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                    "<li class='@{ath.markup.role}@'>{{role}}</li>"+
                  "${ }) }$"+
                "${ } else if (ath.ctx.isProcess) { }$"+
                  "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='@{ath.markup.role}@'>{{role}}</span> in "+
                      "<span class='@{ath.markup.lane}@'>"+
                        "{{lane === '*' ? 'All': lane }}"+
                      "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                    "</li>"+
                  "${ })}$"+
                "${ } }$</ul>."+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.accepted_at||ath.story.rejected_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } }$"
      },
      "role:request": {
        text: "${ if(ath.story.state === 'PENDING') { }$"+
                "${ if(ath.ctx.isActor) { }$"+
                  "Your request for change of roles in "+
                "${ } else { }$"+
                  "{{ath.story.actor.alias||ath.story.actor.id}} wants to change roles in "+
                "${ } }$"+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}'"+
                "${ } }$"+
                "{{ ath.ctx.isActor ? ' is pending' : '' }}.\n"+
                "New Roles:\n"+
                "${ if (ath.ctx.isTeam) { }$"+
                  "  [*] {{_.keys(ath.story.roles).join(', ')}}"+
                "${ } else if (ath.ctx.isProcess) { }$"+
                  "  [*] {{_.reduce(ath.story.roles, function(list, role, lane) {"+
                    "list.push(["+
                      "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                    "]);"+
                    "return list;"+
                  "}, []).join(', ')}}"+
                "${ } }$\n"+
                "[{{moment(ath.story.timestamp).format('llll')}}]"+
              "${ } else if(ath.story.state === 'CANCELLED') { }$"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
                " cancelled the request for change of roles in "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}'"+
                "${ } }$.\n"+
                "[{{moment(ath.story.cancelled_at).format('llll')}}]"+
              "${ } else if(ath.story.state === 'ACCEPTED') { }$"+
                "{{ath.ctx.isActor ? 'Your' : (ath.story.actor.alias||ath.story.actor.id) + '\u2019s'}}"+
                " request for change of roles in "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}'"+
                "${ } }$ has been accepted by "+
                "{{ath.story.accepted_by.alias||ath.story.accepted_by.id}}.\n"+
                "[{{moment(ath.story.accepted_at).format('llll')}}]"+
              "${ } else if(ath.story.state === 'REJECTED') { }$"+
                "{{ath.ctx.isActor ? 'Your' : (ath.story.actor.alias||ath.story.actor.id) + '\u2019s'}}"+
                " request for change of roles in "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}'"+
                "${ } }$ has been rejected by "+
                "{{ath.story.rejected_by.alias||ath.story.rejected_by.id}}.\n"+
                "[{{moment(ath.story.rejected_at).format('llll')}}]"+
              "${ } }$",

        html: "${ if(ath.story.state === 'PENDING') { }$"+
                "${ if(ath.ctx.isActor) { }$"+
                  "<span class='@{ath.markup.actor}@'>Your</span> request for change of roles in "+
                "${ } else { }$"+
                  "<span class='@{ath.markup.actor}@'>"+
                    "{{ath.story.actor.alias||ath.story.actor.id}}"+
                  "</span> wants to change roles in "+
                "${ } }$"+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>"+
                "${ } }$"+
                "{{ ath.ctx.isActor ? ' is pending' : '' }}."+
                "<ul class='@{ath.markup.role_list}@'>"+
                  "<li class='@{ath.markup.list_header}@'>New Roles</li>"+
                "${ if (ath.ctx.isTeam) {"+
                  "_.forEach(ath.story.roles, function(enabled, role) { }$"+
                    "<li class='@{ath.markup.role}@'>{{role}}</li>"+
                  "${ })"+
                "} else if (ath.ctx.isProcess) {"+
                  "_.forEach(ath.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='@{ath.markup.role}@'>{{role}}</span> in "+
                      "<span class='@{ath.markup.lane}@'>"+
                        "{{lane === '*' ? 'All': lane }}"+
                      "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                    "</li>"+
                  "${ })"+
                "} }$"+
                "</ul>"+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(ath.story.state === 'CANCELLED') { }$"+
                "<span class='@{ath.markup.actor}@'>"+
                  "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
                "</span>"+
                " cancelled the request for change of roles in "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>"+
                "${ } }$."+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.cancelled_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(ath.story.state === 'ACCEPTED') { }$"+
                "<span class='@{ath.markup.actor}@'>"+
                  "{{ath.ctx.isActor ? 'Your' : (ath.story.actor.alias||ath.story.actor.id) + '\u2019s'}}"+
                "</span> request for change of roles in "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been accepted by "+
                "<span class='@{ath.markup.target}@'>"+
                  "{{ath.story.accepted_by.alias||ath.story.accepted_by.id}}"+
                "</span>."+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.accepted_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(ath.story.state === 'REJECTED') { }$"+
                "<span class='@{ath.markup.actor}@'>"+
                  "{{ath.ctx.isActor ? 'Your' : (ath.story.actor.alias||ath.story.actor.id) + '\u2019s'}}"+
                "</span> request for change of roles in "+
                "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!ath.ctx.isItem) { }$"+
                  " <span class='@{ath.markup.object}@'>"+
                    "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                    "ath.story.process.name || ath.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been rejected by "+
                "<span class='@{ath.markup.target}@'>"+
                  "{{ath.story.rejected_by.alias||ath.story.rejected_by.id}}"+
                "</span>."+
                "<time class='@{ath.markup.timestamp}@' title='On "+
                  "{{(ts = moment(ath.story.rejected_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } }$"
      },
      "progress": {
        text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} completed "+
              "'{{ath.story.activity.name}}' in "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} process"+
              "${ if(!ath.ctx.isItem) { }$"+
                " '{{ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$.\n"+
              "{{ath.story.changes ? 'Changes:' : '' }}"+
              "${ _.forEach(ath.story.changes, function (change) {"+
                "if(change.metric.type === 'point') {"+
                   "diff = ONE.times(change.delta['new']).minus(change.delta['old']);"+
                   "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                "}$"+
                  "\n  [*] {{diff}} {{change.metric.name}}"+
                "${ } else if(change.metric.type === 'set') { }$"+
                  "\n[>] {{change.metric.name}}"+
                  "${ _.forEach(change.delta, function(delta, item) {"+
                    "diff = delta['new'] - delta['old'];"+
                    "diff = (diff > 0 ? '+' : '') + diff"+
                  "}$"+
                    "\n  [*] {{diff}} {{item}}"+
                  "${ }); }$"+
                "${ } else if(change.metric.type === 'state') { }$"+
                  "\n[>] {{change.metric.name}}"+
                  "\n  [+] {{change.delta['new']}}"+
                  "\n  [-] {{change.delta['old']}}"+
                "${ }"+
              "}) }$"+
              "{{ath.story.changes ? '\\n' : '' }}"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> completed "+
              "<span class='@{ath.markup.score_activity}@'>"+
                "{{ath.story.activity.name}}"+
              "</span>."+
              "${ if(ath.story.changes) { }$"+
                "<table class='@{ath.markup.score_table}@'>"+
              "${ }"+
              "_.forEach(ath.story.changes, function(change) {"+
                "if (change.metric.type === 'point') {"+
                   "diff = ONE.times(change.delta['new']).minus(change.delta['old']);"+
                   "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                "}$"+
                  "<tbody class='@{ath.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td>"+
                      "<span class='@{ath.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                    "<td>"+
                      "<span class='@{ath.markup.score_delta_value}@'>"+
                        "{{diff}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                "${ } else if(change.metric.type === 'set') { }$"+
                  "<tbody class='@{ath.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td colspan='2'>"+
                      "<span class='@{ath.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                  "<tbody class='@{ath.markup.score_table_body}@'>"+
                  "${ _.forEach(change.delta, function(delta, item) {"+
                    "diff = ONE.times(delta['new']).minus(delta['old']);"+
                    "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                  "}$"+
                    "<tr>"+
                      "<td>"+
                        "<span class='@{ath.markup.score_delta_item}@'>"+
                          "{{item}}"+
                        "</span>"+
                      "</td>"+
                      "<td>"+
                        "<span class='@{ath.markup.score_delta_value}@'>"+
                          "{{diff}}"+
                        "</span>"+
                      "</td>"+
                    "</tr>"+
                  "${ }); }$"+
                  "</tbody>"+
                "${ } else if(change.metric.type === 'state') { }$"+
                  "<tbody class='@{ath.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td colspan='2'>"+
                      "<span class='@{ath.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                  "<tbody class='@{ath.markup.score_table_body}@'>"+
                  "<tr>"+
                    "<td>"+
                      "<span class='@{ath.markup.score_delta_value}@ @{ath.markup.diff_add}@'>"+
                        "{{change.delta['new']}}"+
                      "</span>"+
                    "</td>"+
                    "<td>"+
                      "<span class='@{ath.markup.score_delta_value}@ @{ath.markup.diff_rem}@'>"+
                        "{{change.delta['old']}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                "${ }"+
              "});"+
              "if(ath.story.changes) { }$"+
                "</table>"+
              "${ }"+
              "if(!ath.ctx.isItem) { }$"+
                "<footer class='pl-footer'>"+
                  "<span class='@{ath.markup.object}@'>"+
                    "{{ath.story.process.name||ath.story.process.id}}"+
                  "</span>"+
                "</footer>"+
              "${ } }$"+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "resolution": {
        text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} completed "+
              "'{{ath.story.activity.name}}' in "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} process"+
              "${ if(!ath.ctx.isItem) { }$"+
                " '{{ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ and credited "+
              "{{ath.ctx.isPlayer ? 'you' : ath.story.deferred.actor.alias||ath.story.deferred.actor.id}}"+
              " for completing '{{ath.story.deferred.activity.name}}'.\n"+
              "Changes:"+
              "${ _.forEach(ath.story.deferred.changes, function (change) {"+
                "if(change.metric.type === 'point') {"+
                   "diff = ONE.times(change.delta['new']).minus(change.delta['old']);"+
                   "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                "}$"+
                  "\n  [*] {{diff}} {{change.metric.name}}"+
                "${ } else if(change.metric.type === 'set') { }$"+
                  "\n[>] {{change.metric.name}}"+
                  "${ _.forEach(change.delta, function(delta, item) {"+
                    "diff = ONE.times(delta['new']).minus(delta['old']);"+
                    "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                  "}$"+
                    "\n  [*] {{diff}} {{item}}"+
                  "${ }); }$"+
                "${ } else if(change.metric.type === 'state') { }$"+
                  "\n[>] {{change.metric.name}}"+
                  "\n  [+] {{change.delta['new']}}"+
                  "\n  [-] {{change.delta['old']}}"+
                "${ }"+
              "}) }$\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> completed "+
              "<span class='@{ath.markup.score_activity}@'>"+
                "{{ath.story.activity.name}}"+
              "</span> and credited "+
              "<span class='@{ath.markup.target}@'>"+
                "{{ath.ctx.isPlayer ? 'you' : ath.story.deferred.actor.alias||ath.story.deferred.actor.id}}"+
              "</span> for completing "+
              "<span class='@{ath.markup.score_activity}@'>"+
                "{{ath.story.deferred.activity.name}}"+
              "</span>."+
              "<table class='@{ath.markup.score_table}@'>"+
              "${ _.forEach(ath.story.deferred.changes, function(change) {"+
                "if(change.metric.type === 'point') {"+
                   "diff = ONE.times(change.delta['new']).minus(change.delta['old']);"+
                   "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                "}$"+
                  "<tbody class='@{ath.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td>"+
                      "<span class='@{ath.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                    "<td>"+
                      "<span class='@{ath.markup.score_delta_value}@'>"+
                        "{{diff}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                "${ } else if(change.metric.type === 'set') { }$"+
                  "<tbody class='@{ath.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td colspan='2'>"+
                      "<span class='@{ath.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                  "<tbody class='@{ath.markup.score_table_body}@'>"+
                  "${ _.forEach(change.delta, function(delta, item) {"+
                    "diff = ONE.times(delta['new']).minus(delta['old']);"+
                    "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                  "}$"+
                    "<tr>"+
                      "<td>"+
                        "<span class='@{ath.markup.score_delta_item}@'>"+
                          "{{item}}"+
                        "</span>"+
                      "</td>"+
                      "<td>"+
                        "<span class='@{ath.markup.score_delta_value}@'>"+
                          "{{diff}}"+
                        "</span>"+
                      "</td>"+
                    "</tr>"+
                  "${ }); }$"+
                  "</tbody>"+
                "${ } else if(change.metric.type === 'state') { }$"+
                  "<tbody class='@{ath.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td colspan='2'>"+
                      "<span class='@{ath.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                  "<tbody class='@{ath.markup.score_table_body}@'>"+
                  "<tr>"+
                    "<td>"+
                      "<span class='@{ath.markup.score_delta_value}@ @{ath.markup.diff_add}@'>"+
                        "{{change.delta['new']}}"+
                      "</span>"+
                    "</td>"+
                    "<td>"+
                      "<span class='@{ath.markup.score_delta_value}@ @{ath.markup.diff_rem}@'>"+
                        "{{change.delta['old']}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                "${ }"+
              "}); }$"+
              "</table>"+
              "${ if(!ath.ctx.isItem) { }$"+
                "<footer class='pl-footer'>"+
                  "<span class='@{ath.markup.object}@'>"+
                    "{{ath.story.process.name||ath.story.process.id}}"+
                  "</span>"+
                "</footer>"+
              "${ } }$"+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "level": {
        text: "{{ath.ctx.isActor ? 'Your' : (ath.story.actor.alias||ath.story.actor.id) + '\u2019s'}} "+
              "${ change = ath.story.changes[0]; }$"+
              "'{{change.metric.name}}' level changed to "+
              "'{{change.delta['new']}}' from '{{change.delta['old']}}'.\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'Your' : (ath.story.actor.alias||ath.story.actor.id) + '\u2019s'}}"+
              "</span>"+
              "${ change = ath.story.changes[0]; }$"+
              " <span class='@{ath.markup.score_metric}@'>{{change.metric.name}}</span>"+
              " level changed to "+
              "<span class='@{ath.markup.score_delta_value}@ @{ath.markup.diff_add}@'>"+
                "{{change.delta['new']}}"+
              "</span> from "+
              "<span class='@{ath.markup.score_delta_value}@ @{ath.markup.diff_rem}@'>"+
                "{{change.delta['old']}}"+
              "</span>."+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "achievement": {
        text: "{{ath.ctx.isActor ? 'Congratulations! You' : ath.story.actor.alias||ath.story.actor.id}}"+
              " unlocked an achievement.\n"+
              "Changes:"+
              "${ _.forEach(ath.story.changes, function(change) { }$"+
                "\n[>] {{change.metric.name}}"+
                "${ _.forEach(change.delta, function(delta, item) {"+
                  "diff = ONE.times(delta['new']).minus(delta['old']);"+
                  "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                "}$"+
                "\n  [*] {{diff}} {{item}}"+
                "${ }); }$"+
              "${ }); }$\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "{{ath.ctx.isActor ? 'Congratulations! ' : ''}}<span class='@{ath.markup.actor}@'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span>"+
              " unlocked an achievement."+
              "<table class='@{ath.markup.score_table}@ @{ath.markup.achievement_table}@'>"+
              "${ _.forEach(ath.story.changes, function(change) { }$"+
                "<tbody class='@{ath.markup.score_table_header}@'>"+
                "<tr>"+
                  "<td colspan='2'>"+
                    "<span class='@{ath.markup.score_metric}@'>"+
                      "{{change.metric.name}}"+
                    "</span>"+
                  "</td>"+
                "</tr>"+
                "</tbody>"+
                "<tbody class='@{ath.markup.score_table_body}@'>"+
                  "${ _.forEach(change.delta, function(delta, item) {"+
                    "diff = ONE.times(delta['new']).minus(delta['old']);"+
                    "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                  "}$"+
                  "<tr>"+
                    "<td>"+
                      "<span class='@{ath.markup.score_delta_item}@'>"+
                        "{{item}}"+
                      "</span>"+
                    "</td>"+
                    "<td>"+
                      "<span class='@{ath.markup.score_delta_value}@'>"+
                        "{{diff}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                "${ }); }$"+
                "</tbody>"+
              "${ }); }$"+
              "</table>"+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "escalation": {
        text: "{{ath.story.message}}\n"+
              "[{{moment(ath.story.timestamp).format('llll')}}]",

        html: "{{ath.story.message}}"+
              "<time class='@{ath.markup.timestamp}@' title='On "+
                "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      }
    }

    constructor: (options) ->
      options = options or {}
      @options = _.defaults options, {
        markup: Athena.default_markup
        external: {}
      }

    Athena::buildContext = (story, ext) ->
      ctx = {}
      ctx.isItem = ext.context?

      # Determine the object in the story.
      if story.event in [
        'create',
        'delete',
        'leave',
        'kick',
        'join',
        'join:request',
        'join:request:accept',
        'join:request:reject',
        'invite',
        'invite:accept',
        'invite:reject',
        'role:request',
        'role:request:accept',
        'role:request:reject',
        'role:change',
        'role:assign',
        'resolution'
      ]
        # Determine whether the current story is for a team or process
        # to simplify template code.
        if story.team? or ext.context is 'team'
          ctx.isTeam = true
        else if story.process? or ext.context is 'process'
          ctx.isProcess = true;

      # Determine whether the actor is the current player
      if story.event in [
        'create',
        'delete',
        'join'
        'leave',
        'kick',
        'join:request',
        'join:request:accept',
        'join:request:reject',
        'invite',
        'invite:accept',
        'invite:reject',
        'role:change',
        'role:request',
        'role:request:accept',
        'role:request:reject',
        'role:assign',
        'progress',
        'level',
        'achievement',
        'resolution'
      ]
        # Determine whether the current player is the actor
        if not story.actor? or (ext.profile and ext.profile.id is story.actor.id)
          ctx.isActor = true

      # Determine whether the target is the current player
      if story.event in [
        'kick',
        'join:request',
        'join:request:accept',
        'join:request:reject',
        'role:request',
        'role:request:accept',
        'role:request:reject',
        'role:assign'
      ]
        if not story.player? or (ext.profile and ext.profile.id is story.player.id)
          ctx.isPlayer = true
      else if story.event in ['invite:accept', 'invite:reject']
        if not story.inviter? or (ext.profile and ext.profile.id is story.inviter.id)
          ctx.isInviter = true
      else if story.event is 'invite'
        if not story.invitee? or (ext.profile and ext.profile.id is story.invitee.id)
          ctx.isInvitee = true
      else if story.event is 'resolution'
        if not story.deferred.actor? or (ext.profile and ext.profile.id is story.deferred.actor.id)
          ctx.isPlayer = true

      # Finally, return the config object
      return ctx

    compile: (evt, type) ->
      unless (tpl_collection = Athena.stored_templates[evt])?
        throw("The #{evt} event is not supported")
      unless (tpl = tpl_collection[type])?
        throw("The #{type} template for #{evt} event cannot be found")
      _.template tpl

    toString: (story, external_data = {}) ->
      unless story?
        throw 'The story is not available'
      template = @compile story.event, 'text'
      context = @buildContext story, external_data
      template({
        story: story
        ext: external_data
        ctx: context
      })

    toHTML: (story, external_data = {}) ->
      unless story?
        throw 'The story is not available'
      template = @compile story.event, 'html'
      context = @buildContext story, external_data
      template({
        story: story,
        ext: external_data,
        ctx: context,
        markup: this.options.markup
      })

  exports.Athena = Athena;
)
