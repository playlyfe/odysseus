/*jshint multistr: true, eqnull: true, expr: true */
var _ = require('lodash');
var moment = require('moment');

_.templateSettings.interpolate = /#\{([\s\S]+?)\}#/g;
_.templateSettings.escape = /\{\{([\s\S]+?)\}\}/g;
_.templateSettings.evaluate = /\$\{([\s\S]+?)\}\$/g;
_.templateSettings.variable = 'ath';
_.templateSettings.imports = {
  '_': _,
  'moment': moment
};


var Athena = (function() {
  /**
   * A map of the default markup tags to be inserted into the rendered HTML
   * in-case no object is supplied in the constructor
   * @type {Object}
   */
  var default_markup = {
    actor: "ath-actor",
    target: "ath-target",
    object: "ath-object",
    role_list: "ath-role-list",
    role: "ath-role",
    lane: "ath-lane",
    timestamp: "ath-ts"
  };

  /**
   * A list of all the available templates
   * @type {Object}
   */
  var stored_templates = {
    /**
     * Activity Templates
     */
    "create": {
      text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} created "+
            "the {{ath.ctx.isTeam ? 'team' : 'process'}} "+
            "'{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
              "ath.story.process.name || ath.story.process.id}}'.\n"+
            "[{{moment(ath.story.timestamp).format('llll')}}]",

      html: "<span class='#{ath.markup.actor}#'>"+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
            "</span> created the {{ath.ctx.isTeam ? 'team' : 'process'}} "+
            "<span class='#{ath.markup.object}#'>"+
              "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
              "ath.story.process.name || ath.story.process.id}}"+
            "</span>."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
              "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
              "{{ts.fromNow()}}</time>"
    },
    "delete": {
      text: "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} deleted "+
            "the {{ath.ctx.isTeam ? 'team' : 'process'}} "+
            "'{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
              "ath.story.process.name || ath.story.process.id}}'.\n"+
            "[{{moment(ath.story.timestamp).format('llll')}}]",

      html: "<span class='#{ath.markup.actor}#'>"+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
            "</span> deleted the {{ath.ctx.isTeam ? 'team' : 'process'}} "+
            "<span class='#{ath.markup.object}#'>"+
              "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
              "ath.story.process.name || ath.story.process.id}}"+
            "</span>."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
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

      html: "<span class='#{ath.markup.actor}#'>"+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
            "</span> joined "+
            "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
            "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
              "</span>"+
            "${ } }$ as "+
            "${ if (ath.ctx.isTeam) { }$"+
              "<ul class='#{ath.markup.role_list}#'>"+
                "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                  "<li class='#{ath.markup.role}#'>{{role}}</li>"+
                "${ }) }$"+
              "</ul>"+
            "${ } else if (ath.ctx.isProcess) { }$"+
              "<ul class='#{ath.markup.role_list}#'>"+
                "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                  "<li>"+
                    "<span class='#{ath.markup.role}#'>{{role}}</span> in "+
                    "<span class='#{ath.markup.lane}#'>"+
                      "{{lane === '*' ? 'All': lane }}"+
                    "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                  "</li>"+
                "${ })}$"+
              "</ul>"+
            "${ } }$."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
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

      html: "<span class='#{ath.markup.actor}#'>"+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
            "</span> left "+
            "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
            "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
              "</span>"+
            "${ } }$."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
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

      html: "<span class='#{ath.markup.actor}#'>"+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
            "</span> kicked "+
            "<span class='#{ath.markup.target}#'>"+
              "{{ath.ctx.isPlayer ? 'you' : ath.story.player.alias||ath.story.player.id}}"+
            "</span> from "+
            "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
            "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
              "</span>"+
            "${ } }$."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
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

      html: "<span class='#{ath.markup.target}#'>"+
              "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}}"+
            "</span> request to join "+
            "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
            "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
              "</span>"+
            "${ } }$ has been accepted by "+
            "<span class='#{ath.markup.actor}#'>"+
              "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}"+
            "</span>."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
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

      html: "<span class='#{ath.markup.actor}#'>"+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
            "</span> accepted "+
            "<span class='#{ath.markup.target}#'>"+
              "{{ath.ctx.isInviter ? 'your' : (ath.story.inviter.alias||ath.story.inviter.id) + '\u2019s'}}"+
            "</span> invitation to join "+
            "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
            "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
              "</span>"+
            "${ } }$ as "+
            "${ if (ath.ctx.isTeam) { }$"+
              "<ul class='#{ath.markup.role_list}#'>"+
                "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                  "<li class='#{ath.markup.role}#'>{{role}}</li>"+
                "${ }) }$"+
              "</ul>"+
            "${ } else if (ath.ctx.isProcess) { }$"+
              "<ul class='#{ath.markup.role_list}#'>"+
                "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                  "<li>"+
                    "<span class='#{ath.markup.role}#'>{{role}}</span> in "+
                    "<span class='#{ath.markup.lane}#'>"+
                      "{{lane === '*' ? 'All': lane }}"+
                    "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                  "</li>"+
                "${ })}$"+
              "</ul>"+
            "${ } }$."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
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
                "if(!!diff['old'] && !!diff['new']) { }$"+    // if both new and old keys exist, the role was changed
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
      html: "<span class='#{ath.markup.target}#'>"+
              "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}}"+
            "</span> request for a change of roles in "+
            "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
            "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
              "</span>"+
            "${ } }$ has been accepted by "+
            "<span class='#{ath.markup.actor}#'>"+
              "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}"+
            "</span>."+
            "<ul class='#{ath.markup.role_list}# #{ath.markup.diff_list}#'>"+
              "<li class='#{ath.markup.list_header}#'>Changes</li>"+
              "${ if (ath.ctx.isTeam) {"+
                "_.forEach(ath.story.changes, function(diff, role) { }$"+
                  "<li class='#{ath.markup.role}# #{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}#'>"+
                    "{{role}}"+
                  "</li>"+
                "${ }); }$"+
              "${ } else if (ath.ctx.isProcess) {"+
                "_.forEach(ath.story.changes, function(diff, lane) {"+
                  "if(!!diff['old'] && !!diff['new']) { }$"+    // if both new and old keys exist, the role was changed
                    "<li class='#{ath.markup.diff_change}#'>"+
                      "<span class='#{ath.markup.role}# #{ath.markup.diff_add}#'>{{diff['new']}}</span> from "+
                      "<span class='#{ath.markup.role}# #{ath.markup.diff_rem}#'>{{diff['old']}}</span> in "+
                      "<span class='#{ath.markup.lane}#'>{{lane}}</span> lane"+
                    "</li>"+
                  "${ } else { }$"+
                    "<li class='#{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}#'>"+
                      "<span class='#{ath.markup.role}#'>{{diff['new'] || diff['old']}}</span> in "+
                      "<span class='#{ath.markup.lane}#'>"+
                        "{{lane === '*' ? 'All' : lane}}"+
                      "</span> lane{{lane === '*' ? 's' : ''}}"+
                    "</li>"+
                  "${ } }$"+
                "${ }); }$"+
              "${ } }$"+
            "</ul>."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
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
                "if(!!diff['old'] && !!diff['new']) { }$"+    // if both new and old keys exist, the role was changed
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
      html: "<span class='#{ath.markup.actor}#'>"+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
            "</span> {{ath.ctx.isActor ? 'have' : 'has'}} changed roles in "+
            "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
            "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
              "</span>"+
            "${ } }$."+
            "<ul class='#{ath.markup.role_list}# #{ath.markup.diff_list}#'>"+
              "<li class='#{ath.markup.list_header}#'>Changes</li>"+
              "${ if (ath.ctx.isTeam) {"+
                "_.forEach(ath.story.changes, function(diff, role) { }$"+
                  "<li class='#{ath.markup.role}# #{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}#'>"+
                    "{{role}}"+
                  "</li>"+
                "${ }); }$"+
              "${ } else if (ath.ctx.isProcess) {"+
                "_.forEach(ath.story.changes, function(diff, lane) {"+
                  "if(!!diff['old'] && !!diff['new']) { }$"+    // if both new and old keys exist, the role was changed
                    "<li class='#{ath.markup.diff_change}#'>"+
                      "<span class='#{ath.markup.role}# #{ath.markup.diff_add}#'>{{diff['new']}}</span> from "+
                      "<span class='#{ath.markup.role}# #{ath.markup.diff_rem}#'>{{diff['old']}}</span> in "+
                      "<span class='#{ath.markup.lane}#'>{{lane}}</span> lane"+
                    "</li>"+
                  "${ } else { }$"+
                    "<li class='#{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}#'>"+
                      "<span class='#{ath.markup.role}#'>{{diff['new'] || diff['old']}}</span> in "+
                      "<span class='#{ath.markup.lane}#'>"+
                        "{{lane === '*' ? 'All' : lane}}"+
                      "</span> lane{{lane === '*' ? 's' : ''}}"+
                    "</li>"+
                  "${ } }$"+
                "${ }); }$"+
              "${ } }$"+
            "</ul>."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
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
      html: "<span class='#{ath.markup.target}#'>"+
              "{{ath.ctx.isPlayer ? 'Your' : (ath.story.player.alias||ath.story.player.id) + '\u2019s'}}"+
            "</span> roles in "+
            "{{ath.ctx.isItem ? 'this' : 'the'}} {{ath.ctx.isTeam ? 'team' : 'process'}}"+
            "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
              "</span>"+
            "${ } }$ have been changed by "+
            "<span class='#{ath.markup.actor}#'>"+
              "{{ath.ctx.isActor ? 'you' : ath.story.actor.alias||ath.story.actor.id}}"+
            "</span>."+
            "<ul class='#{ath.markup.role_list}# #{ath.markup.diff_list}#'>"+
              "<li class='#{ath.markup.list_header}#'>Changes</li>"+
              "${ if (ath.ctx.isTeam) {"+
                "_.forEach(ath.story.changes, function(diff, role) { }$"+
                  "<li class='#{ath.markup.role}# #{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}#'>"+
                    "{{role}}"+
                  "</li>"+
                "${ }); }$"+
              "${ } else if (ath.ctx.isProcess) {"+
                "_.forEach(ath.story.changes, function(diff, lane) {"+
                  "if(!!diff['old'] && !!diff['new']) { }$"+    // if both new and old keys exist, the role was changed
                    "<li class='#{ath.markup.diff_change}#'>"+
                      "<span class='#{ath.markup.role}# #{ath.markup.diff_add}#'>{{diff['new']}}</span> from "+
                      "<span class='#{ath.markup.role}# #{ath.markup.diff_rem}#'>{{diff['old']}}</span> in "+
                      "<span class='#{ath.markup.lane}#'>{{lane}}</span> lane"+
                    "</li>"+
                  "${ } else { }$"+
                    "<li class='#{ath.markup[!diff.old ? 'diff_add' : 'diff_rem']}#'>"+
                      "<span class='#{ath.markup.role}#'>{{diff['new'] || diff['old']}}</span> in "+
                      "<span class='#{ath.markup.lane}#'>"+
                        "{{lane === '*' ? 'All' : lane}}"+
                      "</span> lane{{lane === '*' ? 's' : ''}}"+
                    "</li>"+
                  "${ } }$"+
                "${ }); }$"+
              "${ } }$"+
            "</ul>."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
              "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
              "{{ts.fromNow()}}</time>"
    },



    /**
     * Notification Templates
     */
    "join:request": {
      text: "${ if(story.state === 'PENDING' && !ath.ctx.isActor) { }$"+
              "{{ath.story.actor.alias||ath.story.actor.id}} wants to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} "+
              "{{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
              " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ with the roles "+
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

            "${ } else if(story.state === 'PENDING' && ath.ctx.isActor) { }$"+
              "Your request to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} "+
              "{{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
              " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ with the roles "+
              "${ if (ath.ctx.isTeam) { }$"+
                "{{_.keys(ath.story.roles).join(', ')}}"+
              "${ } else if (ath.ctx.isProcess) { }$"+
                "{{_.reduce(ath.story.roles, function(list, role, lane) {"+
                  "list.push(["+
                    "role + ' in ' + (lane === '*' ? 'All lanes' : (lane + ' lane'))"+
                  "]);"+
                  "return list;"+
                "}, []).join(', ')}}"+
              "${ } }$ is pending"+

            "${ } else if(ath.story.state === 'ACCEPTED') { }$"+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} joined "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} "+
              "{{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
              " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$ with the roles "+
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

            "${ } else if(ath.story.state === 'REJECTED') { }$"+
              "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}} "+
              "{{ath.ctx.isActor ? 'were' : 'was'}} disallowed from joining "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} "+
              "{{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
              " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$"+

            "${ } else if(story.state === 'CANCELLED') { }$"+
              "{{ath.ctx.isActor ? 'You ' : ath.story.actor.alias||ath.story.actor.id}}"+
              " cancelled the request to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} "+
              "{{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
              " '{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}'"+
              "${ } }$"+
            "${ } }$.\n"+
            "[{{moment(ath.story.timestamp).format('llll')}}]",

      html: "${ if(story.state === 'PENDING' && !ath.ctx.isActor) { }$"+
              "<span class='#{ath.markup.actor}#'>{{ath.story.actor.alias||ath.story.actor.id}}</span> "+
              "wants to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} "+
              "{{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ with the roles "+
                "<ul class='#{ath.markup.role_list}#'>"+
                  "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                    "<li class='#{ath.markup.role}#'>{{role}}</li>"+
                  "${ }) }$"+
                "</ul>"+
              "${ } else if (ath.ctx.isProcess) { }$"+
                "<ul class='#{ath.markup.role_list}#'>"+
                  "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='#{ath.markup.role}#'>{{role}}</span> in "+
                      "<span class='#{ath.markup.lane}#'>"+
                        "{{lane === '*' ? 'All': lane }}"+
                      "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                    "</li>"+
                  "${ })}$"+
                "</ul>"+
              "${ } }$"+

            "${ } else if(story.state === 'PENDING' && ath.ctx.isActor) { }$"+
              "<span class='#{ath.markup.actor}#'>Your</span> request to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} "+
              "{{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ with the roles "+
                "<ul class='#{ath.markup.role_list}#'>"+
                  "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                    "<li class='#{ath.markup.role}#'>{{role}}</li>"+
                  "${ }) }$"+
                "</ul>"+
              "${ } else if (ath.ctx.isProcess) { }$"+
                "<ul class='#{ath.markup.role_list}#'>"+
                  "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='#{ath.markup.role}#'>{{role}}</span> in "+
                      "<span class='#{ath.markup.lane}#'>"+
                        "{{lane === '*' ? 'All': lane }}"+
                      "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                    "</li>"+
                  "${ })}$"+
                "</ul>"+
              "${ } }$ is pending"+

              "<span class='#{ath.markup.actor}#'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> joined "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} "+
              "{{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$ with the roles "+
                "<ul class='#{ath.markup.role_list}#'>"+
                  "${ _.forEach(ath.story.roles, function(enabled, role) { }$"+
                    "<li class='#{ath.markup.role}#'>{{role}}</li>"+
                  "${ }) }$"+
                "</ul>"+
              "${ } else if (ath.ctx.isProcess) { }$"+
                "<ul class='#{ath.markup.role_list}#'>"+
                  "${ _.forEach(ath.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='#{ath.markup.role}#'>{{role}}</span> in "+
                      "<span class='#{ath.markup.lane}#'>"+
                        "{{lane === '*' ? 'All': lane }}"+
                      "</span> {{lane === '*' ? 'lanes': 'lane' }}"+
                    "</li>"+
                  "${ })}$"+
                "</ul>"+
              "${ } }$"+

            "${ } else if(ath.story.state === 'REJECTED') { }$"+
              "<span class='#{ath.markup.actor}#'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> {{ath.ctx.isActor ? 'were' : 'was'}} disallowed from joining "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} "+
              "{{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$"+

            "${ } else if(ath.story.state === 'CANCELLED') { }$"+
              "<span class='#{ath.markup.actor}#'>"+
                "{{ath.ctx.isActor ? 'You' : ath.story.actor.alias||ath.story.actor.id}}"+
              "</span> cancelled the request to join "+
              "{{ath.ctx.isItem ? 'this' : 'the'}} "+
              "{{ath.ctx.isTeam ? 'team' : 'process'}}"+
              "${ if (!ath.ctx.isItem) { }$"+
              " <span class='#{ath.markup.object}#'>"+
                "{{ath.story.team ? ath.story.team.name || ath.story.team.id :"+
                "ath.story.process.name || ath.story.process.id}}"+
                "</span>"+
              "${ } }$"+
            "${ } }$."+
            "<time class='#{ath.markup.timestamp}#' title='On "+
              "{{(ts = moment(ath.story.timestamp)).format(\'llll\')}}'>"+
              "{{ts.fromNow()}}</time>"
    }
  };

  Athena = function(options) {
    options = options || {};
    this.options = _.defaults(options, {
      markup: default_markup,
      external: {}
    });
  };

  Athena.prototype.buildContext = function(story, ext) {
    ctx = {};

    // Determine the object in the story
    if (_.contains([
        'create',
        'delete',
        'join',
        'leave',
        'kick',
        'join:request:accept',
        'invite:accept',
        'role:request:accept',
        'role:change',
        'role:assign',
        // 'join:request:reject',
        // 'join:request'
      ], story.event)) {

      // Determine whether the current story is for a team or process
      // to simplify template code.
      if (story.team != null || ext.context === 'team') {
        ctx.isTeam = true;
      } else if (story.process != null || ext.context === 'process') {
        ctx.isProcess = true;
      }
      ctx.isItem = ext.context != null;
    }

    // Determine whether the actor is the current player
    if (_.contains([
        'create',
        'delete',
        'join',
        'leave',
        'kick',
        'join:request:accept',
        'invite:accept',
        'role:request:accept',
        'role:change',
        'role:assign',
        // 'join:request:reject',
        // 'join:request'
      ], story.event)) {
      // Determine whether the current player is the actor
      if (story.actor == null || ext.profile && ext.profile.id === story.actor) {
        ctx.isActor = true;
      }
    }

    // Determine whether the target is the current player
    if (_.contains([
        'kick',
        'join:request:accept',
        'role:request:accept',
        'role:assign',
        // 'join:request',
        // 'join:request:reject',
        // 'role:change:accept'
      ], story.event)) {
      if (story.player == null || ext.profile && ext.profile.id === story.player) {
        ctx.isPlayer = true;
      }
    } else if (_.contains(['invite:accept'], story.event)) {
      if (story.inviter == null || ext.profile && ext.profile.id === story.inviter) {
        ctx.isInviter = true;
      }
    }
    // Finally, return the config object
    return ctx;
  };

  Athena.prototype.compile = function(evt, type) {
    var tpl, tpl_collection;
    if ((tpl_collection = stored_templates[evt]) == null) {
      throw("The "+ evt +" event is not supported");
    }
    if ((tpl = tpl_collection[type]) == null) {
      throw("The "+ type +" template for "+ evt +" event cannot be found");
    }
    // console.log("TEE PEE EL", _.template(tpl).source);
    return _.template(tpl);
  };

  Athena.prototype.toString = function(story, external_data) {
    var template;
    external_data || (external_data = {});
    if (story == null) {
      throw("The story is not available");
    }
    template = this.compile(story.event, 'text');
    context = this.buildContext(story, external_data);
    return template({
      story: story,
      ext: external_data,
      ctx: context
    });
  };

  Athena.prototype.toHTML = function(story, external_data) {
    var template;
    external_data || (external_data = {});
    if (story == null) {
      throw("The story is not available");
    }
    template = this.compile(story.event, 'html');
    context = this.buildContext(story, external_data);
    return template({
      story: story,
      ext: external_data,
      ctx: context,
      markup: this.options.markup
    });
  };
  return Athena;
})();

module.exports = Athena
