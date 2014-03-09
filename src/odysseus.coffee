((root, factory) ->
  # AMD. Register as anonymous module.
  if typeof define is 'function' and define.amd
    define ['lodash', 'moment', 'bignumber'], factory
  # CommonJS. As a node module.
  else if typeof exports is 'object'
    module.exports = factory(
      require('lodash'),
      require('moment'),
      require('bignumber.js')
    )
)(this, (_, moment, BigNumber) ->
  # Override the templating delimiters to distinguish from HTML tags
  _.templateSettings.interpolate = /@\{([\s\S]+?)\}@/g
  _.templateSettings.escape = /\{\{([\s\S]+?)\}\}/g
  _.templateSettings.evaluate = /\$\{([\s\S]+?)\}\$/g
  _.templateSettings.variable = 'od'
  _.templateSettings.imports = {
    '_': _            # Pass the default lodash object
    'moment': moment    # Pass moment for time transformations
    'ZERO': new BigNumber(0)  # Since bigNumber isn't really required,
                              # so just send a big ZERO to enable maths.
  };

  class Odysseus
    ###*
     * A map of the default markup tags to be inserted into the rendered HTML
     * in-case no object is supplied in the constructor
     * @type {Object}
    ###
    @default_markup: {
      content: "od-content",
      image: "od-image",
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
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}} created \
              the {{od.ctx.isTeam ? 'team' : 'process'}} \
              '{{od.story.team ? od.story.team.name || od.story.team.id :\
                od.story.process.name || od.story.process.id}}'."

        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                "</span> created the {{od.ctx.isTeam ? 'team' : 'process'}} "+
                "<span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>."+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "delete": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}} deleted \
              the {{od.ctx.isTeam ? 'team' : 'process'}} \
              '{{od.story.team ? od.story.team.name || od.story.team.id :\
                od.story.process.name || od.story.process.id}}'."

        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                "</span> deleted the {{od.ctx.isTeam ? 'team' : 'process'}} "+
                "<span class='@{od.markup.object}@'>"+
                  "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                  "od.story.process.name || od.story.process.id}}"+
                "</span>."+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "join": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{ od.story.admin ? '[Admin Event] ' : '' }}\
              {{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}} joined \
              {{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                 '{{od.story.team ? od.story.team.name || od.story.team.id :\
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$ as \
              ${ if (od.ctx.isTeam) { }$\
                {{_.keys(od.story.roles).join(', ')}}\
              ${ } else if (od.ctx.isProcess) { }$\
                {{_.reduce(od.story.roles, function(list, role, lane) {\
                  list.push([\
                    role + ' in ' + \
                    (lane === '*' ? 'All lanes' : \
                      lane === '~' ? 'No lanes' : (lane + ' lane'))\
                  ]);\
                  return list;\
                }, []).join(', ')}}\
              ${ } }$."

        html: "<div class='@{od.markup.content}@'>\
                <span class='@{od.markup.actor}@'>\
                  {{od.ctx.amActor ? 'You' : \
                    od.story.actor.alias||od.story.actor.id}}\
                </span> joined \
                {{od.ctx.isItem ? 'this' : 'the'}} \
                {{od.ctx.isTeam ? 'team' : 'process'}}\
                ${ if (!od.ctx.isItem) { }$ \
                  <span class='@{od.markup.object}@'>\
                    {{od.story.team ? od.story.team.name || od.story.team.id :\
                      od.story.process.name || od.story.process.id}}\
                  </span>\
                ${ } }$ as \
                <ul class='@{od.markup.role_list}@'>\
                ${ if (od.ctx.isTeam) { }$\
                  ${ _.forEach(od.story.roles, function(enabled, role) { }$\
                    <li><span class='@{od.markup.role}@'>{{role}}</span></li>\
                  ${ }) }$\
                ${ } else if (od.ctx.isProcess) { }$\
                  ${ _.forEach(od.story.roles, function(role, lane) { }$\
                    <li>\
                      <span class='@{od.markup.role}@'>{{role}}</span> in \
                      <span class='@{od.markup.lane}@'>\
                        {{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}}\
                      </span> \
                      {{lane === '*'||lane === '~' ? 'lanes' : 'lane' }}\
                    </li>\
                  ${ })}$\
                ${ } }$</ul>.\
                ${ if (!!od.story.admin) { }$\
                  <footer class='@{od.markup.footer}@'>\
                    <span class='@{od.markup.admin}@'>Admin Event</span>\
                  </footer>\
                ${ } }$\
              </div>\
              <time class='@{od.markup.timestamp}@' title='On \
                {{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>\
                {{ts.fromNow()}}</time>",
        image: """
                ${ if (od.ctx.isDummy) { }$\
                  <i class='@{od.markup.dummy_icon}@'></i>\
                ${ } else { }$\
                  <img \
                    src='{{od.ext.base_url}}/{{od.ctx.amActor ? \
                      od.ext.profile.id : od.story.actor.id}}'>\
                ${ } }$
               """
      },
      "leave": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}} left \
              {{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                 '{{od.story.team ? od.story.team.name || od.story.team.id :\
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$.",

        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                "</span> left "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$."+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "kick": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}} kicked \
              {{od.ctx.amPlayer ? 'you' : od.story.player.alias||od.story.player.id}} from \
              {{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                 '{{od.story.team ? od.story.team.name || od.story.team.id :\
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$.",

        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                "</span> kicked "+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.ctx.amPlayer ? 'you' : od.story.player.alias||od.story.player.id}}"+
                "</span> from "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$."+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "join:request:accept": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amPlayer ? 'Your' : \
                (od.story.player.alias||od.story.player.id) + '\u2019s'}} \
              request to join \
              {{od.ctx.isItem ? 'this' : 'the'}} \
              {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                '{{od.story.team ? od.story.team.name || od.story.team.id :\
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$ has been accepted by \
              {{od.ctx.amActor ? 'You' : \
                od.story.actor.alias||od.story.actor.id}}.",

        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.ctx.amPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}}"+
                "</span> request to join "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been accepted by "+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'you' : od.story.actor.alias||od.story.actor.id}}"+
                "</span>."+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "join:request:reject": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amPlayer ? 'Your' : \
              (od.story.player.alias||od.story.player.id) + '\u2019s'}} \
              request to join \
              {{od.ctx.isItem ? 'this' : 'the'}} \
              {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                '{{od.story.team ? od.story.team.name || od.story.team.id :\
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$ has been rejected by \
              {{od.ctx.amActor ? 'You' : \
                od.story.actor.alias||od.story.actor.id}}."

        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.ctx.amPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}}"+
                "</span> request to join "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been rejected by "+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'you' : od.story.actor.alias||od.story.actor.id}}"+
                "</span>."+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "invite:accept": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amActor ? 'You' : \
                od.story.actor.alias||od.story.actor.id}} accepted \
              {{od.ctx.amInviter ? 'your' : \
                (od.story.inviter.alias||od.story.inviter.id) + '\u2019s'}} \
              invitation to join \
              {{od.ctx.isItem ? 'this' : 'the'}} \
              {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                '{{od.story.team ? od.story.team.name || od.story.team.id : \
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$ as \
              ${ if (od.ctx.isTeam) { }$\
                {{_.keys(od.story.roles).join(', ')}}\
              ${ } else if (od.ctx.isProcess) { }$\
                {{_.reduce(od.story.roles, function(list, role, lane) {\
                  list.push([\
                    role + ' in ' + \
                    (lane === '*' ? 'All lanes' : \
                      lane === '~' ? 'No lanes' : (lane + ' lane'))\
                  ]);\
                  return list;\
                }, []).join(', ')}}\
              ${ } }$."
        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                "</span> accepted "+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.ctx.amInviter ? 'your' : (od.story.inviter.alias||od.story.inviter.id) + '\u2019s'}}"+
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
                    "<li><span class='@{od.markup.role}@'>{{role}}</span></li>"+
                  "${ }) }$"+
                "${ } else if (od.ctx.isProcess) { }$"+
                  "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                      "<span class='@{od.markup.lane}@'>"+
                        "{{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}}"+
                      "</span> {{lane === '*'||lane === '~' ? 'lanes' : 'lane' }}"+
                    "</li>"+
                  "${ })}$"+
                "${ } }$</ul>."+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "invite:reject": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amActor ? 'You' : \
                od.story.actor.alias||od.story.actor.id}} rejected \
              {{od.ctx.amInviter ? 'your' : \
                (od.story.inviter.alias||od.story.inviter.id) + '\u2019s'}} \
              invitation to join \
              {{od.ctx.isItem ? 'this' : 'the'}} \
              {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                '{{od.story.team ? od.story.team.name || od.story.team.id : \
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$ as \
              ${ if (od.ctx.isTeam) { }$\
                {{_.keys(od.story.roles).join(', ')}}\
              ${ } else if (od.ctx.isProcess) { }$\
                {{_.reduce(od.story.roles, function(list, role, lane) {\
                  list.push([\
                    role + ' in ' + \
                    (lane === '*' ? 'All lanes' : \
                      lane === '~' ? 'No lanes' : (lane + ' lane'))\
                  ]);\
                  return list;\
                }, []).join(', ')}}\
              ${ } }$."
        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                "</span> rejected "+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.ctx.amInviter ? 'your' : (od.story.inviter.alias||od.story.inviter.id) + '\u2019s'}}"+
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
                      "<li><span class='@{od.markup.role}@'>{{role}}</span></li>"+
                    "${ }) }$"+
                "${ } else if (od.ctx.isProcess) { }$"+
                  "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                    "<li>"+
                      "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                      "<span class='@{od.markup.lane}@'>"+
                        "{{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}}"+
                      "</span> {{lane === '*'||lane === '~' ? 'lanes' : 'lane' }}"+
                    "</li>"+
                  "${ })}$"+
                "${ } }$</ul>."+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "role:request:accept": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amPlayer ? 'Your' : \
                (od.story.player.alias||od.story.player.id) + '\u2019s'}} \
              request for a change of roles in \
              {{od.ctx.isItem ? 'this' : 'the'}} \
              {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                '{{od.story.team ? od.story.team.name || od.story.team.id :\
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$ has been accepted by \
              {{od.ctx.amActor ? 'you' : \
                od.story.actor.alias||od.story.actor.id}}.\
              \n  Changes:\
              ${ if (od.ctx.isTeam) {\
                _.forEach(od.story.changes, function(diff, role) { }$\
                  \n    [{{ !diff.old ? '+' : '-'}}] {{role}}\
                ${ }); }$\
              ${ } else if (od.ctx.isProcess) {\
                _.forEach(od.story.changes, function(diff, lane) {\
                  if(!!diff['old'] && !!diff['new']) { }$\
                    \n    [+] {{diff['new']}} in {{lane}} lane\
                    \n    [-] {{diff['old']}} in {{lane}} lane\
                  ${ } else { }$\
                    \n    [{{ !diff.old ? '+' : '-'}}] \
                    {{diff['new'] || diff['old']}} in \
                    {{lane === '*' ? 'All lanes' : \
                      lane === '~' ? 'No lanes' : (lane + ' lane')}}\
                  ${ }\
                });\
              } }$"

        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.ctx.amPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}}"+
                "</span> request for a change of roles in "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been accepted by "+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'you' : od.story.actor.alias||od.story.actor.id}}"+
                "</span>."+
                "<ul class='@{od.markup.role_list}@ @{od.markup.diff_list}@'>"+
                  "<li class='@{od.markup.list_header}@'>Changes</li>"+
                  "${ if (od.ctx.isTeam) {"+
                    "_.forEach(od.story.changes, function(diff, role) { }$"+
                      "<li class='@{od.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                        "<span class='@{od.markup.role}@'>{{role}}</span>"+
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
                            "{{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}}"+
                          "</span> {{lane === '*'||lane === '~' ? 'lanes' : 'lane' }}"+
                        "</li>"+
                      "${ } }$"+
                    "${ }); }$"+
                  "${ } }$"+
                "</ul>."+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "role:request:reject": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amPlayer ? 'Your' : \
                (od.story.player.alias||od.story.player.id) + '\u2019s'}} \
              request for a change of roles in \
              {{od.ctx.isItem ? 'this' : 'the'}} \
              {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                '{{od.story.team ? od.story.team.name || od.story.team.id :\
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$ has been rejected by \
              {{od.ctx.amActor ? 'you' : \
                od.story.actor.alias||od.story.actor.id}}."

        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.ctx.amPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}}"+
                "</span> request for a change of roles in "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$ has been rejected by "+
                "<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'you' : od.story.actor.alias||od.story.actor.id}}"+
                "</span>."+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "role:change": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              ${ if (od.story.admin) { }$\
                [Admin Event] \
                {{od.ctx.amActor ? 'Your' : \
                  (od.story.actor.alias||od.story.actor.id)+'\u2019s'}}\
              ${ } else { }$\
                {{od.ctx.amActor ? 'You' : \
                  od.story.actor.alias||od.story.actor.id}} \
                {{od.ctx.amActor ? 'have' : 'has'}} changed\
              ${ } }$ roles in \
              {{od.ctx.isItem ? 'this' : 'the'}} \
              {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                '{{od.story.team ? od.story.team.name || od.story.team.id :\
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$\
              {{ !!od.story.admin ? ' have been changed' : ''}}.\
              \n  Changes:\
              ${ if (od.ctx.isTeam) {\
                _.forEach(od.story.changes, function(diff, role) { }$\
                  \n    [{{ !diff.old ? '+' : '-'}}] {{role}}\
                ${ }); }$\
              ${ } else if (od.ctx.isProcess) {\
                _.forEach(od.story.changes, function(diff, lane) {\
                  if(!!diff['old'] && !!diff['new']) { }$\
                    \n    [+] {{diff['new']}} in {{lane}} lane\
                    \n    [-] {{diff['old']}} in {{lane}} lane\
                  ${ } else { }$\
                    \n    [{{ !diff.old ? '+' : '-'}}] \
                    {{diff['new'] || diff['old']}} in \
                    {{lane === '*' ? 'All lanes' : \
                      lane === '~' ? 'No lanes' : (lane + ' lane')}}\
                  ${ }\
                });\
              } }$"
        html: "<div class='@{od.markup.content}@'>\
              ${ if (od.story.admin) { }$\
                <span class='@{od.markup.target}@'>\
                  {{od.ctx.amActor ? 'Your' : \
                    (od.story.actor.alias||od.story.actor.id)+'\u2019s'}}\
                </span>\
              ${ } else { }$\
                <span class='@{od.markup.actor}@'>\
                  {{od.ctx.amActor ? 'You' : \
                    od.story.actor.alias||od.story.actor.id}}\
                </span> \
                {{od.ctx.amActor ? 'have' : 'has'}} changed\
              ${ } }$ roles in \
                {{od.ctx.isItem ? 'this' : 'the'}} \
                {{od.ctx.isTeam ? 'team' : 'process'}}\
                ${ if (!od.ctx.isItem) { }$ \
                  <span class='@{od.markup.object}@'>\
                    {{od.story.team ? od.story.team.name || od.story.team.id :\
                    od.story.process.name || od.story.process.id}}\
                  </span>\
                ${ } }$\
                {{ !!od.story.admin ? ' have been changed' : ''}}.\
                <ul class='@{od.markup.role_list}@ @{od.markup.diff_list}@'>\
                  <li class='@{od.markup.list_header}@'>Changes</li>\
                  ${ if (od.ctx.isTeam) {\
                    _.forEach(od.story.changes, function(diff, role) { }$\
                      <li class='@{od.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>\
                        <span class='@{od.markup.role}@'>{{role}}</span>\
                      </li>\
                    ${ }); }$\
                  ${ } else if (od.ctx.isProcess) {\
                    _.forEach(od.story.changes, function(diff, lane) {\
                      if(!!diff['old'] && !!diff['new']) { }$\
                        <li class='@{od.markup.diff_change}@'>\
                          <span class='@{od.markup.role}@ @{od.markup.diff_add}@'>{{diff['new']}}</span> from \
                          <span class='@{od.markup.role}@ @{od.markup.diff_rem}@'>{{diff['old']}}</span> in \
                          <span class='@{od.markup.lane}@'>{{lane}}</span> lane\
                        </li>\
                      ${ } else { }$\
                        <li class='@{od.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>\
                          <span class='@{od.markup.role}@'>{{diff['new'] || diff['old']}}</span> in \
                          <span class='@{od.markup.lane}@'>\
                            {{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}}\
                          </span> {{lane === '*'||lane === '~' ? 'lanes' : 'lane' }}\
                        </li>\
                      ${ } }$\
                    ${ }); }$\
                  ${ } }$\
                </ul>.\
                ${ if (!!od.story.admin) { }$\
                  <footer class='@{od.markup.footer}@'>\
                    <span class='@{od.markup.admin}@'>Admin Event</span>\
                  </footer>\
                ${ } }$\
              </div>\
              <time class='@{od.markup.timestamp}@' title='On \
                {{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>\
                {{ts.fromNow()}}</time>"
        image: ''
      },
      "role:assign": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{ od.story.admin ? '[Admin Event] ' : '' }}\
              {{od.ctx.amPlayer ? 'Your' : \
                (od.story.player.alias||od.story.player.id) + '\u2019s'}} \
              roles in \
              {{od.ctx.isItem ? 'this' : 'the'}} \
              {{od.ctx.isTeam ? 'team' : 'process'}}\
              ${ if (!od.ctx.isItem) { }$ \
                '{{od.story.team ? od.story.team.name || od.story.team.id :\
                  od.story.process.name || od.story.process.id}}'\
              ${ } }$ have been changed\
              ${ if (!od.story.admin) { }$ \
                by {{od.ctx.amActor ? 'you' : \
                  od.story.actor.alias||od.story.actor.id}}\
              ${ } }$.\
              \n  Changes:\
              ${ if (od.ctx.isTeam) {\
                _.forEach(od.story.changes, function(diff, role) { }$\
                  \n    [{{ !diff.old ? '+' : '-'}}] {{role}}\
                ${ }); }$\
              ${ } else if (od.ctx.isProcess) {\
                _.forEach(od.story.changes, function(diff, lane) {\
                  if(!!diff['old'] && !!diff['new']) { }$\
                    \n    [+] {{diff['new']}} in {{lane}} lane\
                    \n    [-] {{diff['old']}} in {{lane}} lane\
                  ${ } else { }$\
                    \n    [{{ !diff.old ? '+' : '-'}}] \
                    {{diff['new'] || diff['old']}} in \
                    {{lane === '*' ? 'All lanes' : \
                      lane === '~' ? 'No lanes' : (lane + ' lane')}}\
                  ${ }\
                });\
              } }$"

        html: "<div class='@{od.markup.content}@'>"+
                "<span class='@{od.markup.target}@'>"+
                  "{{od.ctx.amPlayer ? 'Your' : (od.story.player.alias||od.story.player.id) + '\u2019s'}}"+
                "</span> roles in "+
                "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                "${ if (!od.ctx.isItem) { }$"+
                  " <span class='@{od.markup.object}@'>"+
                    "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                    "od.story.process.name || od.story.process.id}}"+
                  "</span>"+
                "${ } }$ have been changed"+
                "${ if (!od.story.admin) { }$"+
                  " by <span class='@{od.markup.actor}@'>"+
                    "{{od.ctx.amActor ? 'you' : "+
                      "od.story.actor.alias||od.story.actor.id}}"+
                  "</span>"+
                "${ } }$."+
                "<ul class='@{od.markup.role_list}@ @{od.markup.diff_list}@'>"+
                  "<li class='@{od.markup.list_header}@'>Changes</li>"+
                  "${ if (od.ctx.isTeam) {"+
                    "_.forEach(od.story.changes, function(diff, role) { }$"+
                      "<li class='@{od.markup[!diff.old ? 'diff_add' : 'diff_rem']}@'>"+
                        "<span class='@{od.markup.role}@'>{{role}}</span>"+
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
                            "{{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}}"+
                          "</span> {{lane === '*'||lane === '~' ? 'lanes' : 'lane' }}"+
                        "</li>"+
                      "${ } }$"+
                    "${ }); }$"+
                  "${ } }$"+
                "</ul>."+
                "${ if (!!od.story.admin) { }$\
                  <footer class='@{od.markup.footer}@'>\
                    <span class='@{od.markup.admin}@'>Admin Event</span>\
                  </footer>\
                ${ } }$"+
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "join:request": {
        text: "${ if(od.story.state === 'PENDING') { }$\
                [{{moment(od.story.timestamp).format('llll')}}] - \
                ${ if(od.ctx.amActor) { }$\
                  Your request to join \
                ${ } else { }$\
                  {{od.story.actor.alias||od.story.actor.id}} wants to join \
                ${ } }$\
                {{od.ctx.isItem ? 'this' : 'the'}} \
                {{od.ctx.isTeam ? 'team' : 'process'}}\
                ${ if (!od.ctx.isItem) { }$ \
                  '{{od.story.team ? od.story.team.name || od.story.team.id :\
                    od.story.process.name || od.story.process.id}}'\
                ${ } }$ as \
                ${ if (od.ctx.isTeam) { }$\
                  {{_.keys(od.story.roles).join(', ')}}\
                ${ } else if (od.ctx.isProcess) { }$\
                  {{_.reduce(od.story.roles, function(list, role, lane) {\
                    list.push([\
                      role + ' in ' + \
                      (lane === '*' ? 'All lanes' : \
                        lane === '~' ? 'No lanes' : (lane + ' lane'))\
                    ]);\
                    return list;\
                  }, []).join(', ')}}\
                ${ } }$\
                {{ od.ctx.amActor ? ' is pending' : '' }}.\
              ${ } else if(od.story.state === 'CANCELLED') { }$\
                [{{moment(od.story.cancelled_at).format('llll')}}] - \
                {{od.ctx.amActor ? 'You' : \
                  od.story.actor.alias||od.story.actor.id}} \
                cancelled the request to join \
                {{od.ctx.isItem ? 'this' : 'the'}} \
                {{od.ctx.isTeam ? 'team' : 'process'}}\
                ${ if (!od.ctx.isItem) { }$ \
                  '{{od.story.team ? od.story.team.name || od.story.team.id :\
                    od.story.process.name || od.story.process.id}}'\
                ${ } }$.\
              ${ } else if(od.story.state === 'ACCEPTED') { }$\
                [{{moment(od.story.accepted_at).format('llll')}}] - \
                {{od.ctx.amActor ? 'Your' : \
                  (od.story.actor.alias||od.story.actor.id) + '\u2019s'}} \
                request to join \
                {{od.ctx.isItem ? 'this' : 'the'}} \
                {{od.ctx.isTeam ? 'team' : 'process'}}\
                ${ if (!od.ctx.isItem) { }$ \
                  '{{od.story.team ? od.story.team.name || od.story.team.id :\
                    od.story.process.name || od.story.process.id}}'\
                ${ } }$ has been accepted by \
                {{od.ctx.amMetaActor ? 'you' : \
                  od.story.accepted_by.alias||od.story.accepted_by.id}}.\
              ${ } else if(od.story.state === 'REJECTED') { }$\
                [{{moment(od.story.rejected_at).format('llll')}}] - \
                {{od.ctx.amActor ? 'Your' : \
                  (od.story.actor.alias||od.story.actor.id) + '\u2019s'}} \
                request to join \
                {{od.ctx.isItem ? 'this' : 'the'}} \
                {{od.ctx.isTeam ? 'team' : 'process'}}\
                ${ if (!od.ctx.isItem) { }$ \
                  '{{od.story.team ? od.story.team.name || od.story.team.id :\
                    od.story.process.name || od.story.process.id}}'\
                ${ } }$ has been rejected by \
                {{od.ctx.amMetaActor ? 'you' : \
                  od.story.rejected_by.alias||od.story.rejected_by.id}}.\
              ${ } }$"

        html: "${ if(od.story.state === 'PENDING') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "${ if(od.ctx.amActor) { }$"+
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
                      "<li><span class='@{od.markup.role}@'>{{role}}</span></li>"+
                    "${ }) }$"+
                  "${ } else if (od.ctx.isProcess) { }$"+
                      "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                        "<li>"+
                          "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                          "<span class='@{od.markup.lane}@'>"+
                            "{{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}}"+
                          "</span> {{lane === '*'||lane === '~' ? 'lanes' : 'lane' }}"+
                        "</li>"+
                      "${ })}$"+
                  "${ } }$</ul>"+
                  "{{ od.ctx.amActor ? ' is pending' : '' }}."+
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'CANCELLED') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "<span class='@{od.markup.actor}@'>"+
                    "{{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                  "</span>"+
                  " cancelled the request to join "+
                  "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                  "${ if (!od.ctx.isItem) { }$"+
                    " <span class='@{od.markup.object}@'>"+
                      "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                      "od.story.process.name || od.story.process.id}}"+
                    "</span>"+
                  "${ } }$."+
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.cancelled_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'ACCEPTED') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "<span class='@{od.markup.actor}@'>"+
                    "{{od.ctx.amActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
                  "</span> request to join "+
                  "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                  "${ if (!od.ctx.isItem) { }$"+
                    " <span class='@{od.markup.object}@'>"+
                      "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                      "od.story.process.name || od.story.process.id}}"+
                    "</span>"+
                  "${ } }$ has been accepted by "+
                  "<span class='@{od.markup.target}@'>"+
                    "{{od.ctx.amMetaActor ? 'you' : "+
                      "od.story.accepted_by.alias||od.story.accepted_by.id}}"+
                  "</span>."+
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.accepted_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'REJECTED') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "<span class='@{od.markup.actor}@'>"+
                    "{{od.ctx.amActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
                  "</span> request to join "+
                  "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                  "${ if (!od.ctx.isItem) { }$"+
                    " <span class='@{od.markup.object}@'>"+
                      "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                      "od.story.process.name || od.story.process.id}}"+
                    "</span>"+
                  "${ } }$ has been rejected by "+
                  "<span class='@{od.markup.target}@'>"+
                    "{{od.ctx.amMetaActor ? 'you' : "+
                      "od.story.rejected_by.alias||od.story.rejected_by.id}}"+
                  "</span>."+
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.rejected_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } }$"
      image: ''
      },
      "invite": {
        text: "${ if(od.story.state === 'PENDING') { }$\
                [{{moment(od.story.timestamp).format('llll')}}] - \
                ${ if(od.ctx.amActor) { }$\
                  Your invitation to \
                  {{od.story.invitee.alias||od.story.invitee.id}} to join \
                ${ } else { }$\
                  {{od.story.actor.alias||od.story.actor.id}} \
                  invited you to join \
                ${ } }$\
                the {{od.ctx.isTeam ? 'team' : 'process'}} \
                '{{od.story.team ? od.story.team.name || od.story.team.id :\
                  od.story.process.name || od.story.process.id}}' as \
                ${ if (od.ctx.isTeam) { }$\
                  {{_.keys(od.story.roles).join(', ')}}\
                ${ } else if (od.ctx.isProcess) { }$\
                  {{_.reduce(od.story.roles, function(list, role, lane) {\
                    list.push([\
                      role + ' in ' + \
                      (lane === '*' ? 'All lanes' : \
                        lane === '~' ? 'No lanes' : (lane + ' lane'))\
                    ]);\
                    return list;\
                  }, []).join(', ')}}\
                ${ } }$\
                {{ od.ctx.amActor ? ' is pending' : '' }}.\
              ${ } else if(od.story.state === 'CANCELLED') { }$\
                [{{moment(od.story.cancelled_at).format('llll')}}] - \
                {{od.story.actor.alias||od.story.actor.id}} \
                withdrew the invitation to join \
                the {{od.ctx.isTeam ? 'team' : 'process'}} \
                '{{od.story.team ? od.story.team.name || od.story.team.id : \
                  od.story.process.name || od.story.process.id}}'.\
              ${ } else if(od.story.state === 'ACCEPTED' || \
                od.story.state === 'REJECTED') { }$\
                [{{moment(od.story.accepted_at||\
                  od.story.rejected_at).format('llll')}}] - \
                {{od.ctx.amInvitee ? 'You' : \
                  od.story.invitee.alias||od.story.invitee.id}} \
                {{od.story.accepted_at ? 'accepted' : 'rejected'}} \
                {{od.ctx.amActor ? 'your' : \
                  (od.story.actor.alias||od.story.actor.id)+'\u2019s'}} \
                invitation to join \
                the {{od.ctx.isTeam ? 'team' : 'process'}} \
                '{{od.story.team ? od.story.team.name || od.story.team.id : \
                  od.story.process.name || od.story.process.id}}' as \
                ${ if (od.ctx.isTeam) { }$\
                  {{_.keys(od.story.roles).join(', ')}}\
                ${ } else if (od.ctx.isProcess) { }$\
                  {{_.reduce(od.story.roles, function(list, role, lane) {\
                    list.push([\
                      role + ' in ' + \
                      (lane === '*' ? 'All lanes' : \
                        lane === '~' ? 'No lanes' : (lane + ' lane'))\
                    ]);\
                    return list;\
                  }, []).join(', ')}}\
                ${ } }$.\
              ${ } }$"
        html: "${ if(od.story.state === 'PENDING') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "${ if(od.ctx.amActor) { }$"+
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
                      "<li><span class='@{od.markup.role}@'>{{role}}</span></li>"+
                    "${ }) }$"+
                  "${ } else if (od.ctx.isProcess) { }$"+
                    "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                      "<li>"+
                        "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                        "<span class='@{od.markup.lane}@'>"+
                          "{{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}}"+
                        "</span> {{lane === '*'||lane === '~' ? 'lanes' : 'lane' }}"+
                      "</li>"+
                    "${ })}$"+
                  "${ } }$</ul>"+
                  "{{ od.ctx.amActor ? ' is pending' : '' }}."+
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'CANCELLED') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "<span class='@{od.markup.actor}@'>"+
                    "{{od.story.actor.alias||od.story.actor.id}}"+
                  "</span>"+
                  " withdrew the invitation to join "+
                  "the {{od.ctx.isTeam ? 'team' : 'process'}}"+
                    " <span class='@{od.markup.object}@'>"+
                      "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                      "od.story.process.name || od.story.process.id}}"+
                    "</span>."+
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.cancelled_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'ACCEPTED' || od.story.state === 'REJECTED') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "<span class='@{od.markup.target}@'>"+
                    "{{od.ctx.amInvitee ? 'You' : \
                      od.story.invitee.alias||od.story.invitee.id}}"+
                  "</span> {{od.story.accepted_at ? 'accepted' : 'rejected'}} "+
                  "<span class='@{od.markup.actor}@'>"+
                    "{{od.ctx.amActor ? 'your' : \
                      (od.story.actor.alias||od.story.actor.id)+'\u2019s'}}"+
                  "</span>"+
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
                      "<li><span class='@{od.markup.role}@'>{{role}}</span></li>"+
                    "${ }) }$"+
                  "${ } else if (od.ctx.isProcess) { }$"+
                    "${ _.forEach(od.story.roles, function(role, lane) { }$"+
                      "<li>"+
                        "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                        "<span class='@{od.markup.lane}@'>"+
                          "{{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}}"+
                        "</span> {{lane === '*'||lane === '~' ? 'lanes' : 'lane' }}"+
                      "</li>"+
                    "${ })}$"+
                  "${ } }$</ul>."+
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.accepted_at||od.story.rejected_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } }$"
      image: ''
      },
      "role:request": {
        text: "${ if(od.story.state === 'PENDING') { }$\
                [{{moment(od.story.timestamp).format('llll')}}] - \
                ${ if(od.ctx.amActor) { }$\
                  Your request for change of roles in \
                ${ } else { }$\
                  {{od.story.actor.alias||od.story.actor.id}} \
                  wants to change roles in \
                ${ } }$\
                {{od.ctx.isItem ? 'this' : 'the'}} \
                {{od.ctx.isTeam ? 'team' : 'process'}}\
                ${ if (!od.ctx.isItem) { }$ \
                  '{{od.story.team ? od.story.team.name || od.story.team.id : \
                    od.story.process.name || od.story.process.id}}'\
                ${ } }$\
                {{ od.ctx.amActor ? ' is pending' : '' }}.\
                \n  New Roles:\
                ${ if (od.ctx.isTeam) { }$\
                  \n    [*] {{_.keys(od.story.roles).join(', ')}}\
                ${ } else if (od.ctx.isProcess) {\
                  _.forEach(od.story.roles, function(role, lane) { }$\
                    \n    [*] {{role}} in \
                    {{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}} \
                    {{lane === '*' || lane === '~' ? 'lanes' : 'lane'}}\
                  ${ });\
                } }$\
              ${ } else if(od.story.state === 'CANCELLED') { }$\
                [{{moment(od.story.cancelled_at).format('llll')}}] - \
                {{od.ctx.amActor ? 'You' : \
                  od.story.actor.alias||od.story.actor.id}} \
                cancelled the request for change of roles in \
                {{od.ctx.isItem ? 'this' : 'the'}} \
                {{od.ctx.isTeam ? 'team' : 'process'}}\
                ${ if (!od.ctx.isItem) { }$ \
                  '{{od.story.team ? od.story.team.name || od.story.team.id :\
                    od.story.process.name || od.story.process.id}}'\
                ${ } }$.\
              ${ } else if(od.story.state === 'ACCEPTED') { }$\
                [{{moment(od.story.accepted_at).format('llll')}}] - \
                {{od.ctx.amActor ? 'Your' : \
                  (od.story.actor.alias||od.story.actor.id) + '\u2019s'}} \
                request for change of roles in \
                {{od.ctx.isItem ? 'this' : 'the'}} \
                {{od.ctx.isTeam ? 'team' : 'process'}}\
                ${ if (!od.ctx.isItem) { }$ \
                  '{{od.story.team ? od.story.team.name || od.story.team.id :\
                    od.story.process.name || od.story.process.id}}'\
                ${ } }$ has been accepted by \
                {{od.story.accepted_by.alias||od.story.accepted_by.id}}.\
              ${ } else if(od.story.state === 'REJECTED') { }$\
                [{{moment(od.story.rejected_at).format('llll')}}] - \
                {{od.ctx.amActor ? 'Your' : \
                (od.story.actor.alias||od.story.actor.id) + '\u2019s'}} \
                request for change of roles in \
                {{od.ctx.isItem ? 'this' : 'the'}} \
                {{od.ctx.isTeam ? 'team' : 'process'}}\
                ${ if (!od.ctx.isItem) { }$ \
                   '{{od.story.team ? od.story.team.name || od.story.team.id :\
                    od.story.process.name || od.story.process.id}}'\
                ${ } }$ has been rejected by \
                {{od.story.rejected_by.alias||od.story.rejected_by.id}}.\
              ${ } }$"
        html: "${ if(od.story.state === 'PENDING') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "${ if(od.ctx.amActor) { }$"+
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
                  "{{ od.ctx.amActor ? ' is pending' : '' }}."+
                  "<ul class='@{od.markup.role_list}@'>"+
                    "<li class='@{od.markup.list_header}@'>New Roles</li>"+
                  "${ if (od.ctx.isTeam) {"+
                    "_.forEach(od.story.roles, function(enabled, role) { }$"+
                      "<li><span class='@{od.markup.role}@'>{{role}}</span></li>"+
                    "${ })"+
                  "} else if (od.ctx.isProcess) {"+
                    "_.forEach(od.story.roles, function(role, lane) { }$"+
                      "<li>"+
                        "<span class='@{od.markup.role}@'>{{role}}</span> in "+
                        "<span class='@{od.markup.lane}@'>"+
                          "{{lane === '*' ? 'All' : lane === '~' ? 'No' : lane}}"+
                        "</span> {{lane === '*'||lane === '~' ? 'lanes' : 'lane' }}"+
                      "</li>"+
                    "${ });"+
                  "} }$"+
                  "</ul>"+
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'CANCELLED') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "<span class='@{od.markup.actor}@'>"+
                    "{{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
                  "</span>"+
                  " cancelled the request for change of roles in "+
                  "{{od.ctx.isItem ? 'this' : 'the'}} {{od.ctx.isTeam ? 'team' : 'process'}}"+
                  "${ if (!od.ctx.isItem) { }$"+
                    " <span class='@{od.markup.object}@'>"+
                      "{{od.story.team ? od.story.team.name || od.story.team.id :"+
                      "od.story.process.name || od.story.process.id}}"+
                    "</span>"+
                  "${ } }$."+
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.cancelled_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'ACCEPTED') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "<span class='@{od.markup.actor}@'>"+
                    "{{od.ctx.amActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
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
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.accepted_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } else if(od.story.state === 'REJECTED') { }$"+
                "<div class='@{od.markup.content}@'>"+
                  "<span class='@{od.markup.actor}@'>"+
                    "{{od.ctx.amActor ? 'Your' : (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}"+
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
                "</div>"+
                "<time class='@{od.markup.timestamp}@' title='On "+
                  "{{(ts = moment(od.story.rejected_at)).format(\'llll\')}}'>"+
                  "{{ts.fromNow()}}</time>"+
              "${ } }$"
      image: ''
      },
      "progress": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] -
              {{od.ctx.amActor ? 'You' : \
                od.story.actor.alias||od.story.actor.id}} completed \
              '{{od.story.activity.name}}' in \
              {{od.ctx.isItem ? 'this' : 'the'}} process\
              ${ if(!od.ctx.isItem) { }$ \
                 '{{od.story.process.name || od.story.process.id}}'\
              ${ } }$.\
              ${ if (od.story.changes) { }$\
                \n  Changes:\
              ${ } }$\
              ${ _.forEach(od.story.changes, function (change) {\
               if(change.metric.type === 'point') {\
                  diff = ZERO.plus(change.delta['new'])\
                            .minus(change.delta['old']);\
                  diff = (diff.gt(ZERO) ? '+' : '') + diff.toString();
               }$\
                 \n    [*] {{diff}} {{change.metric.name}}\
               ${ } else if(change.metric.type === 'set') { }$\
                 \n  [>] {{change.metric.name}}\
                 ${ _.forEach(change.delta, function(delta, item) {\
                   diff = ZERO.plus(delta['new']).minus(delta['old']);\
                   diff = (diff.gt(ZERO) ? '+' : '') + diff.toString();\
                 }$\
                   \n    [*] {{diff}} {{item}}\
                 ${ }); }$\
               ${ } else if(change.metric.type === 'state') { }$\
                 \n  [>] {{change.metric.name}}\
                 \n    [+] {{change.delta['new']}}\
                 \n    [-] {{change.delta['old']}}\
               ${ }\
              }) }$"
        html: """
              <div class='@{od.markup.content}@'>\
                <span class='@{od.markup.actor}@'>\
                  {{od.ctx.amActor ? 'You' : \
                    od.story.actor.alias||od.story.actor.id}}\
                </span> completed \
                <span class='@{od.markup.score_activity}@'>\
                  {{od.story.activity.name}}\
                </span>.\
                ${ if(od.story.changes) { }$\
                  <table class='@{od.markup.score_table}@'>\
                ${ }\
                _.forEach(od.story.changes, function(change) {\
                  if (change.metric.type === 'point') {\
                     diff = ZERO.plus(change.delta['new'])\
                                .minus(change.delta['old']);\
                     diff = (diff.gt(ZERO) ? '+' : '') + diff.toString();\
                  }$\
                    <tbody class='@{od.markup.score_table_header}@'>\
                    <tr>\
                      <td>\
                        <span class='@{od.markup.score_metric}@'>\
                          {{change.metric.name}}\
                        </span>\
                      </td>\
                      <td>\
                        <span class='@{od.markup.score_delta_value}@'>\
                          {{diff}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                  ${ } else if(change.metric.type === 'set') { }$\
                    <tbody class='@{od.markup.score_table_header}@'>\
                    <tr>\
                      <td colspan='2'>\
                        <span class='@{od.markup.score_metric}@'>\
                          {{change.metric.name}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                    <tbody class='@{od.markup.score_table_body}@'>\
                    ${ _.forEach(change.delta, function(delta, item) {\
                      diff = ZERO.plus(delta['new']).minus(delta['old']);\
                      diff = (diff.gt(ZERO) ? '+' : '') + diff.toString();\
                    }$\
                      <tr>\
                        <td>\
                          <span class='@{od.markup.score_delta_item}@'>\
                            {{item}}\
                          </span>\
                        </td>\
                        <td>\
                          <span class='@{od.markup.score_delta_value}@'>\
                            {{diff}}\
                          </span>\
                        </td>\
                      </tr>\
                    ${ }); }$\
                    </tbody>\
                  ${ } else if(change.metric.type === 'state') { }$\
                    <tbody class='@{od.markup.score_table_header}@'>\
                    <tr>\
                      <td colspan='2'>\
                        <span class='@{od.markup.score_metric}@'>\
                          {{change.metric.name}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                    <tbody class='@{od.markup.score_table_body}@'>\
                    <tr>\
                      <td>\
                        <span class='@{od.markup.score_delta_value}@ \
                          @{od.markup.diff_add}@'>{{change.delta['new']}}\
                        </span>\
                      </td>\
                      <td>\
                        <span class='@{od.markup.score_delta_value}@ \
                          @{od.markup.diff_rem}@'>\
                          {{change.delta['old'] || '--'}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                  ${ }\
                });\
                if(od.story.changes) { }$\
                  </table>\
                ${ }\
                if(!od.ctx.isItem) { }$\
                  <footer class='@{od.markup.footer}@'>\
                    <span class='@{od.markup.object}@'>\
                      {{od.story.process.name||od.story.process.id}}\
                    </span>\
                  </footer>\
                ${ } }$\
              </div>\
              <time class='@{od.markup.timestamp}@' title='On \
                {{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>\
                {{ts.fromNow()}}</time>
              """
        image: ''
      },
      "resolution": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amActor ? 'You' : \
                od.story.actor.alias||od.story.actor.id}} completed \
              '{{od.story.activity.name}}' in \
              {{od.ctx.isItem ? 'this' : 'the'}} process\
              ${ if(!od.ctx.isItem) { }$ \
                '{{od.story.process.name || od.story.process.id}}'\
              ${ } }$ and credited \
              {{od.ctx.amPlayer ? \
                (od.ctx.amActor ? 'yourself' : 'you') : \
                od.story.deferred.actor.alias||od.story.deferred.actor.id}} \
              for completing '{{od.story.deferred.activity.name}}'.\n  \
              Changes:\
              ${ _.forEach(od.story.deferred.changes, function (change) {\
                if(change.metric.type === 'point') {\
                  diff = ZERO.plus(change.delta['new']).minus(change.delta['old']);\
                  diff = (diff.gt(ZERO) ? '+' : '') + diff.toString()\
                }$\
                 \n    [*] {{diff}} {{change.metric.name}}\
                ${ } else if(change.metric.type === 'set') { }$\
                 \n  [>] {{change.metric.name}}\
                 ${ _.forEach(change.delta, function(delta, item) {\
                   diff = ZERO.plus(delta['new']).minus(delta['old']);\
                   diff = (diff.gt(ZERO) ? '+' : '') + diff.toString()\
                 }$\
                   \n    [*] {{diff}} {{item}}\
                 ${ }); }$\
                ${ } else if(change.metric.type === 'state') { }$\
                 \n  [>] {{change.metric.name}}\
                 \n    [+] {{change.delta['new']}}\
                 \n    [-] {{change.delta['old']}}\
                ${ }\
              }) }$"
        html: "<div class='@{od.markup.content}@'>\
                <span class='@{od.markup.actor}@'>\
                  {{od.ctx.amActor ? 'You' : \
                    od.story.actor.alias||od.story.actor.id}}\
                </span> completed \
                <span class='@{od.markup.score_activity}@'>\
                  {{od.story.activity.name}}\
                </span> and credited \
                <span class='@{od.markup.target}@'>\
                  {{od.ctx.amPlayer ? \
                    (od.ctx.amActor ? 'yourself' : 'you') : \
                    od.story.deferred.actor.alias||od.story.deferred.actor.id}}\
                </span> for completing \
                <span class='@{od.markup.score_activity}@'>\
                  {{od.story.deferred.activity.name}}\
                </span>.\
                <table class='@{od.markup.score_table}@'>\
                ${ _.forEach(od.story.deferred.changes, function(change) {\
                  if(change.metric.type === 'point') {\
                     diff = ZERO.plus(change.delta['new'])\
                              .minus(change.delta['old']);\
                     diff = (diff.gt(ZERO) ? '+' : '') + diff.toString();\
                  }$\
                    <tbody class='@{od.markup.score_table_header}@'>\
                    <tr>\
                      <td>\
                        <span class='@{od.markup.score_metric}@'>\
                          {{change.metric.name}}\
                        </span>\
                      </td>\
                      <td>\
                        <span class='@{od.markup.score_delta_value}@'>\
                          {{diff}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                  ${ } else if(change.metric.type === 'set') { }$\
                    <tbody class='@{od.markup.score_table_header}@'>\
                    <tr>\
                      <td colspan='2'>\
                        <span class='@{od.markup.score_metric}@'>\
                          {{change.metric.name}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                    <tbody class='@{od.markup.score_table_body}@'>\
                    ${ _.forEach(change.delta, function(delta, item) {\
                      diff = ZERO.plus(delta['new']).minus(delta['old']);\
                      diff = (diff.gt(ZERO) ? '+' : '') + diff.toString();\
                    }$\
                      <tr>\
                        <td>\
                          <span class='@{od.markup.score_delta_item}@'>\
                            {{item}}\
                          </span>\
                        </td>\
                        <td>\
                          <span class='@{od.markup.score_delta_value}@'>\
                            {{diff}}\
                          </span>\
                        </td>\
                      </tr>\
                    ${ }); }$\
                    </tbody>\
                  ${ } else if(change.metric.type === 'state') { }$\
                    <tbody class='@{od.markup.score_table_header}@'>\
                    <tr>\
                      <td colspan='2'>\
                        <span class='@{od.markup.score_metric}@'>\
                          {{change.metric.name}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                    <tbody class='@{od.markup.score_table_body}@'>\
                    <tr>\
                      <td>\
                        <span class='@{od.markup.score_delta_value}@ @{od.markup.diff_add}@'>\
                          {{change.delta['new']}}\
                        </span>\
                      </td>\
                      <td>\
                        <span class='@{od.markup.score_delta_value}@ @{od.markup.diff_rem}@'>\
                          {{change.delta['old']}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                  ${ }\
                }); }$\
                </table>\
                ${ if(!od.ctx.isItem) { }$\
                  <footer class='@{od.markup.footer}@'>\
                    <span class='@{od.markup.object}@'>\
                      {{od.story.process.name||od.story.process.id}}\
                    </span>\
                  </footer>\
                ${ } }$\
              </div>\
              <time class='@{od.markup.timestamp}@' title='On \
                {{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>\
                {{ts.fromNow()}}</time>"
        image: ''
      },
      "level": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amActor ? 'Your' : \
                (od.story.actor.alias||od.story.actor.id) + '\u2019s'}} \
              ${ change = od.story.changes[0]; }$\
              '{{change.metric.name}}' level changed to \
              '{{change.delta['new']}}'\
              ${ if (change.delta['old']) { }$ \
                from '{{change.delta['old']}}'\
              ${ } }$."
        html: "<div class='@{od.markup.content}@'>\
                  <span class='@{od.markup.actor}@'>\
                  {{od.ctx.amActor ? 'Your' : \
                    (od.story.actor.alias||od.story.actor.id) + '\u2019s'}}\
                </span> \
                ${ change = od.story.changes[0]; }$\
                <span class='@{od.markup.score_metric}@'>\
                  {{change.metric.name}}</span> level changed to \
                <span class='@{od.markup.score_delta_value}@ \
                  @{od.markup.diff_add}@'>{{change.delta['new']}}</span>\
                ${ if (change.delta['old']) { }$ \
                  from \
                  <span class='@{od.markup.score_delta_value}@ \
                    @{od.markup.diff_rem}@'>{{change.delta['old']}}\
                  </span>\
                ${ } }$.\
              </div>\
              <time class='@{od.markup.timestamp}@' title='On \
                {{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>\
                {{ts.fromNow()}}</time>"
        image: ''
      },
      "achievement": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.ctx.amActor ? 'Congratulations! You' : \
                od.story.actor.alias||od.story.actor.id}} \
              unlocked an achievement.\n"+
              "  Changes:"+
              "${ _.forEach(od.story.changes, function(change) { }$"+
                "\n  [>] {{change.metric.name}}"+
                "${ _.forEach(change.delta, function(delta, item) {"+
                  "diff = ZERO.plus(delta['new']).minus(delta['old']);"+
                  "diff = (diff.gt(ZERO) ? '+' : '') + diff.toString();"+
                "}$"+
                "\n    [*] {{diff}} {{item}}"+
                "${ }); }$"+
              "${ }); }$",

        html: "<div class='@{od.markup.content}@'>"+
                  "{{od.ctx.amActor ? 'Congratulations! ' : ''}}<span class='@{od.markup.actor}@'>"+
                  "{{od.ctx.amActor ? 'You' : od.story.actor.alias||od.story.actor.id}}"+
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
                      "diff = ZERO.plus(delta['new']).minus(delta['old']);"+
                      "diff = (diff.gt(ZERO) ? '+' : '') + diff.toString();"+
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
              "</div>"+
              "<time class='@{od.markup.timestamp}@' title='On "+
                "{{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>"+
                "{{ts.fromNow()}}</time>"
        image: ''
      },
      "score": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] -
              {{ od.story.admin ? '[Admin Event] ' : '' }}\
              {{od.ctx.amPlayer ? 'Your' : \
                (od.story.player.alias||od.story.player.id) + '\u2019s'}} \
              scores were changed.\
              \n  New Scores:\
              ${ _.forEach(od.story.changes, function (change) {\
               if(change.metric.type === 'point') { }$\
                 \n    [*] {{change.delta['new']}} {{change.metric.name}}\
               ${ } else if(change.metric.type === 'set') { }$\
                 \n  [>] {{change.metric.name}}\
                 ${ _.forEach(change.delta, function(delta, item) { }$\
                   \n    [*] {{delta['new']}} {{item}}\
                 ${ }); }$\
               ${ } else if(change.metric.type === 'state') { }$\
                 \n  [*] {{change.metric.name}} - {{change.delta['new']}}\
               ${ }\
              }); }$"
        html: "<div class='@{od.markup.content}@'>\
                <span class='@{od.markup.target}@'>\
                  {{od.ctx.amPlayer ? 'Your' : \
                      (od.story.player.alias||od.story.player.id) + '\u2019s'}}\
                </span> scores were changed.\
                <table class='@{od.markup.score_table}@'>\
                ${ _.forEach(od.story.changes, function(change) {\
                  if (change.metric.type === 'point') { }$\
                    <tbody class='@{od.markup.score_table_header}@'>\
                    <tr>\
                      <td>\
                        <span class='@{od.markup.score_metric}@'>\
                          {{change.metric.name}}\
                        </span>\
                      </td>\
                      <td>\
                        <span class='@{od.markup.score_delta_value}@'>\
                          {{change.delta['new']}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                  ${ } else if(change.metric.type === 'set') { }$\
                    <tbody class='@{od.markup.score_table_header}@'>\
                    <tr>\
                      <td colspan='2'>\
                        <span class='@{od.markup.score_metric}@'>\
                          {{change.metric.name}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                    <tbody class='@{od.markup.score_table_body}@'>\
                    ${ _.forEach(change.delta, function(delta, item) { }$\
                      <tr>\
                        <td>\
                          <span class='@{od.markup.score_delta_item}@'>\
                            {{item}}\
                          </span>\
                        </td>\
                        <td>\
                          <span class='@{od.markup.score_delta_value}@'>\
                            {{delta['new']}}\
                          </span>\
                        </td>\
                      </tr>\
                    ${ }); }$\
                    </tbody>\
                  ${ } else if(change.metric.type === 'state') { }$\
                    <tbody class='@{od.markup.score_table_header}@'>\
                    <tr>\
                      <td>\
                        <span class='@{od.markup.score_metric}@'>\
                          {{change.metric.name}}\
                        </span>\
                      </td>\
                      <td>\
                        <span class='@{od.markup.score_delta_value}@'>\
                          {{change.delta['new']}}\
                        </span>\
                      </td>\
                    </tr>\
                    </tbody>\
                  ${ }\
                }); }$\
                </table>\
                ${ if (!!od.story.admin) { }$\
                  <footer class='@{od.markup.footer}@'>\
                    <span class='@{od.markup.admin}@'>Admin Event</span>\
                  </footer>\
                ${ } }$\
              </div>\
              <time class='@{od.markup.timestamp}@' title='On \
                {{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>\
                {{ts.fromNow()}}</time>"
        image: ''
      },
      "escalation": {
        text: "[{{moment(od.story.timestamp).format('llll')}}] - \
              {{od.story.message}}"
        html: "<div class='@{od.markup.content}@'>\
                {{od.story.message}}\
              </div>\
              <time class='@{od.markup.timestamp}@' title='On \
                {{(ts = moment(od.story.timestamp)).format(\'llll\')}}'>\
                {{ts.fromNow()}}</time>"
        image: ''
      }
    }

    constructor: (options) ->
      options = options or {}
      @options = _.defaults options, {
        markup: Odysseus.default_markup
        external: {}
      }

    buildContext: (story, ext) ->
      ctx = {}
      ctx.isDummy = ext.env is 'debug'

      # Determine whether the current story is for a team or process
      # to simplify template code.
      ctx.isItem = ext.context in ['team', 'process']
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
        unless story.actor? and ext.profile?.id isnt story.actor.id
          ctx.amActor = true

      # Determine whether the target is the current player
      if story.event in [
        'kick',
        'join:request:accept',
        'join:request:reject',
        'role:request:accept',
        'role:request:reject',
        'role:assign'
        'score'
      ]
        unless story.player? and ext.profile?.id isnt story.player.id
          ctx.amPlayer = true
      else if story.event is 'resolution'
        unless story.deferred.actor? and ext.profile?.id isnt story.deferred.actor.id
          ctx.amPlayer = true
      else if story.event in ['invite:accept', 'invite:reject']
        unless story.inviter? and ext.profile?.id isnt story.inviter.id
          ctx.amInviter = true
      else if story.event is 'invite'
        unless story.invitee? and ext.profile?.id isnt story.invitee.id
          ctx.amInvitee = true

      if story.event is 'join:request'
        if story.state is 'ACCEPTED' and
          ext.profile?.id is story.accepted_by.id or
          story.state is 'REJECTED' and
          ext.profile?.id is story.rejected_by.id
            ctx.amMetaActor = true

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

    toHTML: (story, external_data = {}, config = {}) ->
      unless story?
        throw 'The story is not available'
      template = @compile story.event, 'html'
      context = @buildContext story, external_data
      html = template({
        story: story,
        ext: external_data,
        ctx: context,
        markup: @options.markup
      })
      if config.image is true
        image = """
          <div class='#{@options.markup.image}'>\
            #{@getImage(story, external_data)}\
          </div>
        """
        html = image + html
      html

    getImage: (story, external_data = {}) ->
      unless story?
        throw 'The story is not available'
      unless external_data.base_url?
        throw 'The base source url is not specified'
      template = @compile story.event, 'image'
      context = @buildContext story, external_data
      template({
        story: story,
        ext: external_data,
        ctx: context,
        markup: @options.markup
      })

  Odysseus;
)
