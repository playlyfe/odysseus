((root, factory) ->

  # AMD. Register as anonymous module.
  if typeof define is 'function' and define.amd
    define (require, exports, module) ->
      _ = require('lodash')
      moment = require('moment')
      BigNumber = require('bignumber')    # bignumber.js is not a valid name
      factory(exports, _, moment, BigNumber)
      exports.Odysseus

  # CommonJS. As a node module.
  else if typeof exports is 'object'
    factory exports, require('lodash'), require('moment'), require('bignumber.js')

  return
)(this, (exports, _, moment, BigNumber) ->
  # Override the templating delimiters to distinguish from HTML tags
  _.templateSettings.interpolate = /@\{([\s\S]+?)\}@/g
  _.templateSettings.escape = /\{\{([\s\S]+?)\}\}/g
  _.templateSettings.evaluate = /\$\{([\s\S]+?)\}\$/g
  _.templateSettings.variable = 'od'
  _.templateSettings.imports = {
    '_': _            # Pass the default lodash object
    'moment': moment    # Pass moment for time transformations
    'ONE': new BigNumber(1)   # In this scenario, BigNumber isnt really required.
                              # Just send ONE for idempotency and
                              # to enable bignumber operations.
  };

  class Odysseus
    ###*
     * A map of the default markup tags to be inserted into the rendered HTML
     * in-case no object is supplied in the constructor
     * @type {Object}
    ###
    @default_markup: {
      actor: "od-actor",
      target: "od-target",
      object: "od-object",
      role_list: "od-role-list",
      role: "od-role",
      lane: "od-lane",
      timestamp: "od-ts"
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
        text: "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}} created "+
              "the {{od.ctx.isTeam ? 'team' : 'process'}} "+
              "'{{od.story.team ? od.story.team.name || od.story.team.id :"+
                "od.story.process.name || od.story.process.id}}'.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span> created the {{od.ctx.isTeam ? 'team' : 'process'}} "+
              "<span class='@{od.markup.object}@'>"+
                "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                "od.story.process.name || od.story.process.id}}"+
              "</span>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "delete": {
        text: "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}} deleted "+
              "the {{od.ctx.isTeam ? 'team' : 'process'}} "+
              "'{{od.story.team ? od.story.team.name || od.story.team.id :"+
                "od.story.process.name || od.story.process.id}}'.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span> deleted the {{od.ctx.isTeam ? 'team' : 'process'}} "+
              "<span class='@{od.markup.object}@'>"+
                "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                "od.story.process.name || od.story.process.id}}"+
              "</span>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "join": {
        text: "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}} joined "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$ as "+
              "${ if (od.ctx.isTeam) { }$"+
                "{{_.keys(od.story.roles).join(', ')}}"+
              "${ } else if (od.ctx.isProcess) { }$"+
                "{{_.reduce(od.story.roles, function(list, role, lane) {"+
                  "list.push(["+
                    "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                  "]);"+
                  "return list;"+
                "}, []).join(', ')}}"+
              "${ } }$.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span> joined "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$ as "+
              "<ul class='@{od.markup.role_list}@'>"+
              "${ if (od.ctx.isTeam) { }$"+
                "${ _.forEach(od.story.roles, function(enabled, role) { }$"+
                  "<li class='@{od.markup.role}@'>{{role}}</li>"+
                "${ }) }$"+
              "${ } else if (od.ctx.isProcess) { }$"+
                "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                  "<li>"+
                    "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                    "<span class='@{od.markup.lane}@'>"+
                      "{{lane === '*' ? 'All': lane }}"+
                    "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                  "</li>"+
                "${ })}$"+
              "${ } }$</ul>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "leave": {
        text: "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}} left "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span> left "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "kick": {
        text: "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}} kicked "+
              "{{od.ctx.isPlayer ? 'you' : od.story.player.alias||od.story.player.id}} from "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span> kicked "+
              "<span class='@{od.markup.target}@'>"+
                "{{od.ctx.isPlayer ? 'you' : od.story.player.alias||od.story.player.id}}"+
              "</span> from "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "join:request:accept": {
        text: "{{od.ctx.isPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}} "+
              "request to join "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$ has been accepted by "+
              "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.target}@'>"+
                "{{od.ctx.isPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}}"+
              "</span> request to join "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$ has been accepted by "+
              "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'you' : od.story.actor.alias||od.story.actor.id}}"+
              "</span>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "join:request:reject": {
        text: "{{od.ctx.isPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}} "+
              "request to join "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$ has been rejected by "+
              "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.target}@'>"+
                "{{od.ctx.isPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}}"+
              "</span> request to join "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$ has been rejected by "+
              "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'you' : od.story.actor.alias||od.story.actor.id}}"+
              "</span>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "invite:accept": {
        text: "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}} "+
              "accepted "+
              "{{od.ctx.isInviter ? 'your' : (od.story.inviter.alias||od.story.inviter.id) + '\u2019s'}} "+
              "invitation to join "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$ as "+
              "${ if (od.ctx.isTeam) { }$"+
                "{{_.keys(od.story.roles).join(', ')}}"+
              "${ } else if (od.ctx.isProcess) { }$"+
                "{{_.reduce(od.story.roles, function(list, role, lane) {"+
                  "list.push(["+
                    "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                  "]);"+
                  "return list;"+
                "}, []).join(', ')}}"+
              "${ } }$.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span> accepted "+
              "<span class='@{od.markup.target}@'>"+
                "{{od.ctx.isInviter ? 'your' : (od.story.inviter.alias||od.story.inviter.id) + '\u2019s'}}"+
              "</span> invitation to join "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$ as "+
              "<ul class='@{od.markup.role_list}@'>"+
              "${ if (od.ctx.isTeam) { }$"+
                "${ _.forEach(od.story.roles, function(enabled, role) { }$"+
                  "<li class='@{od.markup.role}@'>{{role}}</li>"+
                "${ }) }$"+
              "${ } else if (od.ctx.isProcess) { }$"+
                "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                  "<li>"+
                    "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                    "<span class='@{od.markup.lane}@'>"+
                      "{{lane === '*' ? 'All': lane }}"+
                    "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                  "</li>"+
                "${ })}$"+
              "${ } }$</ul>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "invite:reject": {
        text: "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}} "+
              "rejected "+
              "{{od.ctx.isInviter ? 'your' : (od.story.inviter.alias||od.story.inviter.id) + '\u2019s'}} "+
              "invitation to join "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$ as "+
              "${ if (od.ctx.isTeam) { }$"+
                "{{_.keys(od.story.roles).join(', ')}}"+
              "${ } else if (od.ctx.isProcess) { }$"+
                "{{_.reduce(od.story.roles, function(list, role, lane) {"+
                  "list.push(["+
                    "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                  "]);"+
                  "return list;"+
                "}, []).join(', ')}}"+
              "${ } }$.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span> rejected "+
              "<span class='@{od.markup.target}@'>"+
                "{{od.ctx.isInviter ? 'your' : (od.story.inviter.alias||od.story.inviter.id) + '\u2019s'}}"+
              "</span> invitation to join "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$ as "+
              "<ul class='@{od.markup.role_list}@'>"+
              "${ if (od.ctx.isTeam) { }$"+
                  "${ _.forEach(od.story.roles, function(enabled, role) { }$"+
                    "<li class='@{od.markup.role}@'>{{role}}</li>"+
                  "${ }) }$"+
              "${ } else if (od.ctx.isProcess) { }$"+
                "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                  "<li>"+
                    "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                    "<span class='@{od.markup.lane}@'>"+
                      "{{lane === '*' ? 'All': lane }}"+
                    "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                  "</li>"+
                "${ })}$"+
              "${ } }$</ul>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "role:request:accept": {
        text: "{{od.ctx.isPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}} "+
              "request for a change of roles in "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$ has been accepted by "+
              "{{od.ctx.isActor ? 'you' : od.story.actor.alias||od.story.actor.id}}.\n"+
              "Changes:"+
              "${ if (od.ctx.isTeam) {"+
                "_.forEach(od.story.changes, function(diff, role) { }$"+
                  "\n  [{{ !diff.old ? '+' : '-'}}] {{role}}"+
                "${ }); }$"+
              "${ } else if (od.ctx.isProcess) {"+
                "_.forEach(od.story.changes, function(diff, lane) {"+
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
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.target}@'>"+
                "{{od.ctx.isPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}}"+
              "</span> request for a change of roles in "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$ has been accepted by "+
              "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'you' : od.story.actor.alias||od.story.actor.id}}"+
              "</span>."+
              "<ul class='@{od.markup.role_list}@ @{od.markup.diff_list}@'>"+
                "<li class='@{od.markup.list_header}@'>Changes</li>"+
                "${ if (od.ctx.isTeam) {"+
                  "_.forEach(od.story.changes, function(diff, role) { }$"+
                    "<li class='@{od.markup.role}@ @{od.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                      "{{role}}"+
                    "</li>"+
                  "${ }); }$"+
                "${ } else if (od.ctx.isProcess) {"+
                  "_.forEach(od.story.changes, function(diff, lane) {"+
                    # if both new and old keys exist, the role was changed
                    "if(!!diff['old'] && !!diff['new']) { }$"+
                      "<li class='@{od.markup.diff_change}@'>"+
                        "<span class='@{od.markup.role}@ @{od.markup.diff_add}@'>{{diff['new']}}</span> from "+
                        "<span class='@{od.markup.role}@ @{od.markup.diff_rem}@'>{{diff['old']}}</span> in "+
                        "<span class='@{od.markup.lane}@'>{{lane}}</span> lane"+
                      "</li>"+
                    "${ } else { }$"+
                      "<li class='@{od.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                        "<span class='@{od.markup.role}@'>{{diff['new'] || diff['old']}}</span> in "+
                        "<span class='@{od.markup.lane}@'>"+
                          "{{lane === '*' ? 'All' : lane}}"+
                        "</span> lane{{lane === '*' ? 's' : ''}}"+
                      "</li>"+
                    "${ } }$"+
                  "${ }); }$"+
                "${ } }$"+
              "</ul>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "role:request:reject": {
        text: "{{od.ctx.isPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}} "+
              "request for a change of roles in "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$ has been rejected by "+
              "{{od.ctx.isActor ? 'you' : od.story.actor.alias||od.story.actor.id}}.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.target}@'>"+
                "{{od.ctx.isPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}}"+
              "</span> request for a change of roles in "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$ has been rejected by "+
              "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'you' : od.story.actor.alias||od.story.actor.id}}"+
              "</span>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "role:change": {
        text: "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}} "+
              "{{od.ctx.isActor ? 'have' : 'has'}} changed roles in "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$.\n"+
              "Changes:"+
              "${ if (od.ctx.isTeam) {"+
                "_.forEach(od.story.changes, function(diff, role) { }$"+
                  "\n  [{{ !diff.old ? '+' : '-'}}] {{role}}"+
                "${ }); }$"+
              "${ } else if (od.ctx.isProcess) {"+
                "_.forEach(od.story.changes, function(diff, lane) {"+
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
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span> {{od.ctx.isActor ? 'have' : 'has'}} changed roles in "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$."+
              "<ul class='@{od.markup.role_list}@ @{od.markup.diff_list}@'>"+
                "<li class='@{od.markup.list_header}@'>Changes</li>"+
                "${ if (od.ctx.isTeam) {"+
                  "_.forEach(od.story.changes, function(diff, role) { }$"+
                    "<li class='@{od.markup.role}@ @{od.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                      "{{role}}"+
                    "</li>"+
                  "${ }); }$"+
                "${ } else if (od.ctx.isProcess) {"+
                  "_.forEach(od.story.changes, function(diff, lane) {"+
                    # if both new and old keys exist, the role was changed
                    "if(!!diff['old'] && !!diff['new']) { }$"+
                      "<li class='@{od.markup.diff_change}@'>"+
                        "<span class='@{od.markup.role}@ @{od.markup.diff_add}@'>{{diff['new']}}</span> from "+
                        "<span class='@{od.markup.role}@ @{od.markup.diff_rem}@'>{{diff['old']}}</span> in "+
                        "<span class='@{od.markup.lane}@'>{{lane}}</span> lane"+
                      "</li>"+
                    "${ } else { }$"+
                      "<li class='@{od.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                        "<span class='@{od.markup.role}@'>{{diff['new'] || diff['old']}}</span> in "+
                        "<span class='@{od.markup.lane}@'>"+
                          "{{lane === '*' ? 'All' : lane}}"+
                        "</span> lane{{lane === '*' ? 's' : ''}}"+
                      "</li>"+
                    "${ } }$"+
                  "${ }); }$"+
                "${ } }$"+
              "</ul>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "role:assign": {
        text: "{{od.ctx.isPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}} "+
              "roles in "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
              "${ } }$ have been changed by "+
              "{{od.ctx.isActor ? 'you' : od.story.actor.alias||od.story.actor.id}}.\n"+
              "Changes:"+
              "${ if (od.ctx.isTeam) {"+
                "_.forEach(od.story.changes, function(diff, role) { }$"+
                  "\n  [{{ !diff.old ? '+' : '-'}}] {{role}}"+
                "${ }); }$"+
              "${ } else if (od.ctx.isProcess) {"+
                "_.forEach(od.story.changes, function(diff, lane) {"+
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
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.target}@'>"+
                "{{od.ctx.isPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}}"+
              "</span> roles in "+
              "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!od.ctx.isItem) { }$"+
                " <span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>"+
              "${ } }$ have been changed by "+
              "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'you' : od.story.actor.alias||od.story.actor.id}}"+
              "</span>."+
              "<ul class='@{od.markup.role_list}@ @{od.markup.diff_list}@'>"+
                "<li class='@{od.markup.list_header}@'>Changes</li>"+
                "${ if (od.ctx.isTeam) {"+
                  "_.forEach(od.story.changes, function(diff, role) { }$"+
                    "<li class='@{od.markup.role}@ @{od.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                      "{{role}}"+
                    "</li>"+
                  "${ }); }$"+
                "${ } else if (od.ctx.isProcess) {"+
                  "_.forEach(od.story.changes, function(diff, lane) {"+
                    # if both new and old keys exist, the role was changed
                    "if(!!diff['old'] && !!diff['new']) { }$"+
                      "<li class='@{od.markup.diff_change}@'>"+
                        "<span class='@{od.markup.role}@ @{od.markup.diff_add}@'>{{diff['new']}}</span> from "+
                        "<span class='@{od.markup.role}@ @{od.markup.diff_rem}@'>{{diff['old']}}</span> in "+
                        "<span class='@{od.markup.lane}@'>{{lane}}</span> lane"+
                      "</li>"+
                    "${ } else { }$"+
                      "<li class='@{od.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                        "<span class='@{od.markup.role}@'>{{diff['new'] || diff['old']}}</span> in "+
                        "<span class='@{od.markup.lane}@'>"+
                          "{{lane === '*' ? 'All' : lane}}"+
                        "</span> lane{{lane === '*' ? 's' : ''}}"+
                      "</li>"+
                    "${ } }$"+
                  "${ }); }$"+
                "${ } }$"+
              "</ul>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "join:request": {
        text: "${ if(od.story.state === 'PENDING') { }$"+
                "${ if(od.ctx.isActor) { }$"+
                  "Your request to join "+
                "${ } else { }$"+
                  "{{od.story.actor.alias||od.story.actor.id}} wants to join "+
                "${ } }$"+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}'"+
                "${ } }$ as "+
                "${ if (od.ctx.isTeam) { }$"+
                  "{{_.keys(od.story.roles).join(', ')}}"+
                "${ } else if (od.ctx.isProcess) { }$"+
                  "{{_.reduce(od.story.roles, function(list, role, lane) {"+
                    "list.push(["+
                      "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                    "]);"+
                    "return list;"+
                  "}, []).join(', ')}}"+
                "${ } }$"+
                "{{ od.ctx.isActor ? ' is pending' : '' }}.\n"+
                "[{{moment(od.story.timestamp).format('llll')}}]"+
              "${ } else if(od.story.state === 'CANCELLED') { }$"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                " cancelled the request to join "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}'"+
                "${ } }$.\n"+
                "[{{moment(od.story.cancelled_at).format('llll')}}]"+
              "${ } else if(od.story.state === 'ACCEPTED') { }$"+
                "{{od.ctx.isActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
                " request to join "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}'"+
                "${ } }$ has been accepted by "+
                "{{od.story.accepted_by.alias||od.story.accepted_by.id}}.\n"+
                "[{{moment(od.story.accepted_at).format('llll')}}]"+
              "${ } else if(od.story.state === 'REJECTED') { }$"+
                "{{od.ctx.isActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
                " request to join "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}'"+
                "${ } }$ has been rejected by "+
                "{{od.story.rejected_by.alias||od.story.rejected_by.id}}.\n"+
                "[{{moment(od.story.rejected_at).format('llll')}}]"+
              "${ } }$",

        html: "${ if(od.story.state === 'PENDING') { }$"+
                "${ if(od.ctx.isActor) { }$"+
                  "<span class='@{od.markup.actor}@'>Your</span> request to join "+
                "${ } else { }$"+
                  "<span class='@{od.markup.actor}@'>"+
                    "{{od.story.actor.alias||od.story.actor.id}}"+
                  "</span> wants to join "+
                "${ } }$"+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$ as "+
                "<ul class='@{od.markup.role_list}@'>"+
                "${ if (od.ctx.isTeam) { }$"+
                  "${ _.forEach(od.story.roles, function(enabled, role) { }$"+
                    "<li class='@{od.markup.role}@'>{{role}}</li>"+
                  "${ }) }$"+
                "${ } else if (od.ctx.isProcess) { }$"+
                    "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                      "<li>"+
                        "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                        "<span class='@{od.markup.lane}@'>"+
                          "{{lane === '*' ? 'All': lane }}"+
                        "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                      "</li>"+
                    "${ })}$"+
                "${ } }$</ul>"+
                "{{ od.ctx.isActor ? ' is pending' : '' }}."+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'CANCELLED') { }$"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                "</span>"+
                " cancelled the request to join "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$."+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.cancelled_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'ACCEPTED') { }$"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.isActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
                "</span> request to join "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been accepted by "+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.story.accepted_by.alias||od.story.accepted_by.id}}"+
                "</span>."+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.accepted_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'REJECTED') { }$"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.isActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
                "</span> request to join "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been rejected by "+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.story.rejected_by.alias||od.story.rejected_by.id}}"+
                "</span>."+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.rejected_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } }$"
      },
      "invite": {
        text: "${ if(od.story.state === 'PENDING') { }$"+
                "${ if(od.ctx.isActor) { }$"+
                  "Your invitation to {{od.story.invitee.alias||od.story.invitee.id}}"+
                  " to join "+
                "${ } else { }$"+
                  "{{od.story.actor.alias||od.story.actor.id}} invited you to join "+
                "${ } }$"+
                "the {{od.ctx.isTeam ? 'team' : 'process'}}"+
                  " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}'"+
                " as "+
                "${ if (od.ctx.isTeam) {   }$"+
                  "{{_.keys(od.story.roles).join(', ')}}"+
                "${ } else if (od.ctx.isProcess) {  }$"+
                  "{{_.reduce(od.story.roles, function(list, role, lane) {"+
                    "list.push(["+
                      "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                    "]);"+
                    "return list;"+
                  "}, []).join(', ')}}"+
                "${ } }$"+
                "{{ od.ctx.isActor ? ' is pending' : '' }}.\n"+
                "[{{moment(od.story.timestamp).format('llll')}}]"+
              "${ } else if(od.story.state === 'CANCELLED') { }$"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                " cancelled the invitation for "+
                "{{od.ctx.isInvitee ? 'you' : od.story.invitee.alias||od.story.invitee.id}}"+
                " to join "+
                "the {{od.ctx.isTeam ? 'team' : 'process'}}"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
                ".\n"+
                "[{{moment(od.story.cancelled_at).format('llll')}}]"+
              "${ } else if(od.story.state === 'ACCEPTED' || od.story.state === 'REJECTED') { }$"+
                "{{od.story.invitee.alias||od.story.invitee.id}} "+
                "{{od.story.accepted_at ? 'accepted' : 'rejected'}}"+
                " your invitation to join"+
                " the {{od.ctx.isTeam ? 'team' : 'process'}}"+
                " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}'"+
                " as "+
                "${ if (od.ctx.isTeam) { }$"+
                  "{{_.keys(od.story.roles).join(', ')}}"+
                "${ } else if (od.ctx.isProcess) { }$"+
                  "{{_.reduce(od.story.roles, function(list, role, lane) {"+
                    "list.push(["+
                      "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                    "]);"+
                    "return list;"+
                  "}, []).join(', ')}}"+
                "${ } }$.\n"+
                "[{{moment(od.story.accepted_at||od.story.rejected_at).format('llll')}}]"+
              "${ } }$",

        html: "${ if(od.story.state === 'PENDING') { }$"+
                "${ if(od.ctx.isActor) { }$"+
                  "<span class='@{od.markup.actor}@'>Your</span> invitation to "+
                  "<span class='@{od.markup.target}@'>{{od.story.invitee.alias||od.story.invitee.id}}</span>"+
                  " to join "+
                "${ } else { }$"+
                  "<span class='@{od.markup.actor}@'>{{od.story.actor.alias||od.story.actor.id}}</span> "+
                  "invited <span class='@{od.markup.target}@'>you</span> to join "+
                "${ } }$"+
                "the {{od.ctx.isTeam ? 'team' : 'process'}}"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                " as "+
                "<ul class='@{od.markup.role_list}@'>"+
                "${ if (od.ctx.isTeam) { }$"+
                  "${ _.forEach(od.story.roles, function(enabled, role) { }$"+
                    "<li class='@{od.markup.role}@'>{{role}}</li>"+
                  "${ }) }$"+
                "${ } else if (od.ctx.isProcess) { }$"+
                  "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                      "<span class='@{od.markup.lane}@'>"+
                        "{{lane === '*' ? 'All': lane }}"+
                      "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                    "</li>"+
                  "${ })}$"+
                "${ } }$</ul>"+
                "{{ od.ctx.isActor ? ' is pending' : '' }}."+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'CANCELLED') { }$"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                "</span>"+
                " cancelled the invitation for "+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.ctx.isInvitee ? 'you' : od.story.invitee.alias||od.story.invitee.id}}"+
                "</span>"+
                " to join "+
                "the {{od.ctx.isTeam ? 'team' : 'process'}}"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>."+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.cancelled_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'ACCEPTED' || od.story.state === 'REJECTED') { }$"+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.story.invitee.alias||od.story.invitee.id}}"+
                "</span> {{od.story.accepted_at ? 'accepted' : 'rejected'}} "+
                "<span class='@{od.markup.actor}@'>your</span>"+
                " invitation to join "+
                "the {{od.ctx.isTeam ? 'team' : 'process'}}"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                " as "+
                "<ul class='@{od.markup.role_list}@'>"+
                "${ if (od.ctx.isTeam) { }$"+
                  "${ _.forEach(od.story.roles, function(enabled, role) { }$"+
                    "<li class='@{od.markup.role}@'>{{role}}</li>"+
                  "${ }) }$"+
                "${ } else if (od.ctx.isProcess) { }$"+
                  "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                      "<span class='@{od.markup.lane}@'>"+
                        "{{lane === '*' ? 'All': lane }}"+
                      "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                    "</li>"+
                  "${ })}$"+
                "${ } }$</ul>."+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.accepted_at||od.story.rejected_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } }$"
      },
      "role:request": {
        text: "${ if(od.story.state === 'PENDING') { }$"+
                "${ if(od.ctx.isActor) { }$"+
                  "Your request for change of roles in "+
                "${ } else { }$"+
                  "{{od.story.actor.alias||od.story.actor.id}} wants to change roles in "+
                "${ } }$"+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}'"+
                "${ } }$"+
                "{{ od.ctx.isActor ? ' is pending' : '' }}.\n"+
                "New Roles:\n"+
                "${ if (od.ctx.isTeam) { }$"+
                  "  [*] {{_.keys(od.story.roles).join(', ')}}"+
                "${ } else if (od.ctx.isProcess) { }$"+
                  "  [*] {{_.reduce(od.story.roles, function(list, role, lane) {"+
                    "list.push(["+
                      "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                    "]);"+
                    "return list;"+
                  "}, []).join(', ')}}"+
                "${ } }$\n"+
                "[{{moment(od.story.timestamp).format('llll')}}]"+
              "${ } else if(od.story.state === 'CANCELLED') { }$"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                " cancelled the request for change of roles in "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}'"+
                "${ } }$.\n"+
                "[{{moment(od.story.cancelled_at).format('llll')}}]"+
              "${ } else if(od.story.state === 'ACCEPTED') { }$"+
                "{{od.ctx.isActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
                " request for change of roles in "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}'"+
                "${ } }$ has been accepted by "+
                "{{od.story.accepted_by.alias||od.story.accepted_by.id}}.\n"+
                "[{{moment(od.story.accepted_at).format('llll')}}]"+
              "${ } else if(od.story.state === 'REJECTED') { }$"+
                "{{od.ctx.isActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
                " request for change of roles in "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " '{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}'"+
                "${ } }$ has been rejected by "+
                "{{od.story.rejected_by.alias||od.story.rejected_by.id}}.\n"+
                "[{{moment(od.story.rejected_at).format('llll')}}]"+
              "${ } }$",

        html: "${ if(od.story.state === 'PENDING') { }$"+
                "${ if(od.ctx.isActor) { }$"+
                  "<span class='@{od.markup.actor}@'>Your</span> request for change of roles in "+
                "${ } else { }$"+
                  "<span class='@{od.markup.actor}@'>"+
                    "{{od.story.actor.alias||od.story.actor.id}}"+
                  "</span> wants to change roles in "+
                "${ } }$"+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$"+
                "{{ od.ctx.isActor ? ' is pending' : '' }}."+
                "<ul class='@{od.markup.role_list}@'>"+
                  "<li class='@{od.markup.list_header}@'>New Roles</li>"+
                "${ if (od.ctx.isTeam) {"+
                  "_.forEach(od.story.roles, function(enabled, role) { }$"+
                    "<li class='@{od.markup.role}@'>{{role}}</li>"+
                  "${ })"+
                "} else if (od.ctx.isProcess) {"+
                  "_.forEach(od.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                      "<span class='@{od.markup.lane}@'>"+
                        "{{lane === '*' ? 'All': lane }}"+
                      "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                    "</li>"+
                  "${ })"+
                "} }$"+
                "</ul>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'CANCELLED') { }$"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                "</span>"+
                " cancelled the request for change of roles in "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$."+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.cancelled_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'ACCEPTED') { }$"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.isActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
                "</span> request for change of roles in "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been accepted by "+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.story.accepted_by.alias||od.story.accepted_by.id}}"+
                "</span>."+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.accepted_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'REJECTED') { }$"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.isActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
                "</span> request for change of roles in "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been rejected by "+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.story.rejected_by.alias||od.story.rejected_by.id}}"+
                "</span>."+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.rejected_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } }$"
      },
      "progress": {
        text: "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}} completed "+
              "'{{od.story.activity.name}}' in "+
              "{{od.ctx.isItem ? 'this' : 'the'}} process"+
              "${ if(!od.ctx.isItem) { }$"+
                " '{{od.story.process.name || od.story.process.id}}'"+
              "${ } }$.\n"+
              "{{od.story.changes ? 'Changes:' : '' }}"+
              "${ _.forEach(od.story.changes, function (change) {"+
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
              "{{od.story.changes ? '\\n' : '' }}"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span> completed "+
              "<span class='@{od.markup.score_activity}@'>"+
                "{{od.story.activity.name}}"+
              "</span>."+
              "${ if(od.story.changes) { }$"+
                "<table class='@{od.markup.score_table}@'>"+
              "${ }"+
              "_.forEach(od.story.changes, function(change) {"+
                "if (change.metric.type === 'point') {"+
                   "diff = ONE.times(change.delta['new']).minus(change.delta['old']);"+
                   "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                "}$"+
                  "<tbody class='@{od.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td>"+
                      "<span class='@{od.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                    "<td>"+
                      "<span class='@{od.markup.score_delta_value}@'>"+
                        "{{diff}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                "${ } else if(change.metric.type === 'set') { }$"+
                  "<tbody class='@{od.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td colspan='2'>"+
                      "<span class='@{od.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                  "<tbody class='@{od.markup.score_table_body}@'>"+
                  "${ _.forEach(change.delta, function(delta, item) {"+
                    "diff = ONE.times(delta['new']).minus(delta['old']);"+
                    "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                  "}$"+
                    "<tr>"+
                      "<td>"+
                        "<span class='@{od.markup.score_delta_item}@'>"+
                          "{{item}}"+
                        "</span>"+
                      "</td>"+
                      "<td>"+
                        "<span class='@{od.markup.score_delta_value}@'>"+
                          "{{diff}}"+
                        "</span>"+
                      "</td>"+
                    "</tr>"+
                  "${ }); }$"+
                  "</tbody>"+
                "${ } else if(change.metric.type === 'state') { }$"+
                  "<tbody class='@{od.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td colspan='2'>"+
                      "<span class='@{od.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                  "<tbody class='@{od.markup.score_table_body}@'>"+
                  "<tr>"+
                    "<td>"+
                      "<span class='@{od.markup.score_delta_value}@ @{od.markup.diff_add}@'>"+
                        "{{change.delta['new']}}"+
                      "</span>"+
                    "</td>"+
                    "<td>"+
                      "<span class='@{od.markup.score_delta_value}@ @{od.markup.diff_rem}@'>"+
                        "{{change.delta['old']}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                "${ }"+
              "});"+
              "if(od.story.changes) { }$"+
                "</table>"+
              "${ }"+
              "if(!od.ctx.isItem) { }$"+
                "<footer class='pl-footer'>"+
                  "<span class='@{od.markup.object}@'>"+
                    "{{od.story.process.name||od.story.process.id}}"+
                  "</span>"+
                "</footer>"+
              "${ } }$"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "resolution": {
        text: "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}} completed "+
              "'{{od.story.activity.name}}' in "+
              "{{od.ctx.isItem ? 'this' : 'the'}} process"+
              "${ if(!od.ctx.isItem) { }$"+
                " '{{od.story.process.name || od.story.process.id}}'"+
              "${ } }$ and credited "+
              "{{od.ctx.isPlayer ? 'you' : od.story.deferred.actor.alias||od.story.deferred.actor.id}}"+
              " for completing '{{od.story.deferred.activity.name}}'.\n"+
              "Changes:"+
              "${ _.forEach(od.story.deferred.changes, function (change) {"+
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
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span> completed "+
              "<span class='@{od.markup.score_activity}@'>"+
                "{{od.story.activity.name}}"+
              "</span> and credited "+
              "<span class='@{od.markup.target}@'>"+
                "{{od.ctx.isPlayer ? 'you' : od.story.deferred.actor.alias||od.story.deferred.actor.id}}"+
              "</span> for completing "+
              "<span class='@{od.markup.score_activity}@'>"+
                "{{od.story.deferred.activity.name}}"+
              "</span>."+
              "<table class='@{od.markup.score_table}@'>"+
              "${ _.forEach(od.story.deferred.changes, function(change) {"+
                "if(change.metric.type === 'point') {"+
                   "diff = ONE.times(change.delta['new']).minus(change.delta['old']);"+
                   "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                "}$"+
                  "<tbody class='@{od.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td>"+
                      "<span class='@{od.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                    "<td>"+
                      "<span class='@{od.markup.score_delta_value}@'>"+
                        "{{diff}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                "${ } else if(change.metric.type === 'set') { }$"+
                  "<tbody class='@{od.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td colspan='2'>"+
                      "<span class='@{od.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                  "<tbody class='@{od.markup.score_table_body}@'>"+
                  "${ _.forEach(change.delta, function(delta, item) {"+
                    "diff = ONE.times(delta['new']).minus(delta['old']);"+
                    "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                  "}$"+
                    "<tr>"+
                      "<td>"+
                        "<span class='@{od.markup.score_delta_item}@'>"+
                          "{{item}}"+
                        "</span>"+
                      "</td>"+
                      "<td>"+
                        "<span class='@{od.markup.score_delta_value}@'>"+
                          "{{diff}}"+
                        "</span>"+
                      "</td>"+
                    "</tr>"+
                  "${ }); }$"+
                  "</tbody>"+
                "${ } else if(change.metric.type === 'state') { }$"+
                  "<tbody class='@{od.markup.score_table_header}@'>"+
                  "<tr>"+
                    "<td colspan='2'>"+
                      "<span class='@{od.markup.score_metric}@'>"+
                        "{{change.metric.name}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                  "<tbody class='@{od.markup.score_table_body}@'>"+
                  "<tr>"+
                    "<td>"+
                      "<span class='@{od.markup.score_delta_value}@ @{od.markup.diff_add}@'>"+
                        "{{change.delta['new']}}"+
                      "</span>"+
                    "</td>"+
                    "<td>"+
                      "<span class='@{od.markup.score_delta_value}@ @{od.markup.diff_rem}@'>"+
                        "{{change.delta['old']}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                  "</tbody>"+
                "${ }"+
              "}); }$"+
              "</table>"+
              "${ if(!od.ctx.isItem) { }$"+
                "<footer class='pl-footer'>"+
                  "<span class='@{od.markup.object}@'>"+
                    "{{od.story.process.name||od.story.process.id}}"+
                  "</span>"+
                "</footer>"+
              "${ } }$"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "level": {
        text: "{{od.ctx.isActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}} "+
              "${ change = od.story.changes[0]; }$"+
              "'{{change.metric.name}}' level changed to "+
              "'{{change.delta['new']}}' from '{{change.delta['old']}}'.\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
              "</span>"+
              "${ change = od.story.changes[0]; }$"+
              " <span class='@{od.markup.score_metric}@'>{{change.metric.name}}</span>"+
              " level changed to "+
              "<span class='@{od.markup.score_delta_value}@ @{od.markup.diff_add}@'>"+
                "{{change.delta['new']}}"+
              "</span> from "+
              "<span class='@{od.markup.score_delta_value}@ @{od.markup.diff_rem}@'>"+
                "{{change.delta['old']}}"+
              "</span>."+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "achievement": {
        text: "{{od.ctx.isActor ? 'Congratulations! You' : od.story.actor.alias||od.story.actor.id}}"+
              " unlocked an achievement.\n"+
              "Changes:"+
              "${ _.forEach(od.story.changes, function(change) { }$"+
                "\n[>] {{change.metric.name}}"+
                "${ _.forEach(change.delta, function(delta, item) {"+
                  "diff = ONE.times(delta['new']).minus(delta['old']);"+
                  "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                "}$"+
                "\n  [*] {{diff}} {{item}}"+
                "${ }); }$"+
              "${ }); }$\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "{{od.ctx.isActor ? 'Congratulations! ' : ''}}<span class='@{od.markup.actor}@'>"+
                "{{od.ctx.isActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
              "</span>"+
              " unlocked an achievement."+
              "<table class='@{od.markup.score_table}@ @{od.markup.achievement_table}@'>"+
              "${ _.forEach(od.story.changes, function(change) { }$"+
                "<tbody class='@{od.markup.score_table_header}@'>"+
                "<tr>"+
                  "<td colspan='2'>"+
                    "<span class='@{od.markup.score_metric}@'>"+
                      "{{change.metric.name}}"+
                    "</span>"+
                  "</td>"+
                "</tr>"+
                "</tbody>"+
                "<tbody class='@{od.markup.score_table_body}@'>"+
                  "${ _.forEach(change.delta, function(delta, item) {"+
                    "diff = ONE.times(delta['new']).minus(delta['old']);"+
                    "diff = (diff.gt(0) ? '+' : '') + diff.toString()"+
                  "}$"+
                  "<tr>"+
                    "<td>"+
                      "<span class='@{od.markup.score_delta_item}@'>"+
                        "{{item}}"+
                      "</span>"+
                    "</td>"+
                    "<td>"+
                      "<span class='@{od.markup.score_delta_value}@'>"+
                        "{{diff}}"+
                      "</span>"+
                    "</td>"+
                  "</tr>"+
                "${ }); }$"+
                "</tbody>"+
              "${ }); }$"+
              "</table>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      },
      "escalation": {
        text: "{{od.story.message}}\n"+
              "[{{moment(od.story.timestamp).format('llll')}}]",

        html: "{{od.story.message}}"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
      }
    }

    constructor: (options) ->
      options = options or {}
      @options = _.defaults options, {
        markup: Odysseus.default_markup
        external: {}
      }

    Odysseus::buildContext = (story, ext) ->
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
      unless (tpl_collection = Odysseus.stored_templates[evt])?
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

  exports.Odysseus = Odysseus;
)
