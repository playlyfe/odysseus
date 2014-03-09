Odysseus = require '../../odysseus'
_ = require 'lodash'
moment = require 'moment'

describe 'The Notification Story Builder', ->
  before (next) ->
    @odysseus = new Odysseus(global.config)
    @iso_date = global.iso_date
    @text_date = global.text_date
    @rel_date = global.rel_date
    next()

  ###*
   * The Join Request Event
  ###
  describe 'for the "join:request" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'join:request',
          actor: {
            id: 'mata',
            alias: 'Juan Mata'
          },
          team: {
            id: 'mufc',
            name: 'Manchester United'
          },
          roles: {
            'midfielder': true
          }
          timestamp: @iso_date
        }
        next()


      describe 'when state is PENDING', ->
        before (next) ->
          @story_state = _.extend {}, @story, { state: 'PENDING' }
          next()

        describe 'in global context', ->
          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@text_date}] - Juan Mata wants to join the team \
              'Manchester United' as midfielder.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> wants to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - Juan Mata wants to join this team as midfielder.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> wants to join this team as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - Your request to join the team \
              'Manchester United' as midfielder is pending.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li></ul> is pending.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @cancel_date = moment(date).format('llll')
          @cancel_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'CANCELLED'
            cancelled_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@cancel_date}] - Juan Mata cancelled the request to join \
              the team 'Manchester United'.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> cancelled the request to join the team <span class='pl-object'>Manchester United</span>.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@cancel_date}] - Juan Mata cancelled the request to \
              join this team.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> cancelled the request to join this team.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@cancel_date}] - You cancelled the request to join \
              the team 'Manchester United'.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>You</span> cancelled the request to join the team <span class='pl-object'>Manchester United</span>.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @accept_date = moment(date).format('llll')
          @accept_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'ACCEPTED'
            accepted_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
            accepted_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@accept_date}] - Juan Mata\u2019s request to join the team \
              'Manchester United' has been accepted by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request to join the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@accept_date}] - Juan Mata\u2019s request to join this team \
              has been accepted by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request to join this team has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@accept_date}] - Your request to join the team \
              'Manchester United' has been accepted by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request to join the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @reject_date = moment(date).format('llll')
          @reject_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'REJECTED'
            rejected_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
            rejected_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@reject_date}] - Juan Mata\u2019s request to join the \
              team 'Manchester United' has been rejected by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request to join the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@reject_date}] - Juan Mata\u2019s request to join this \
              team has been rejected by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request to join this team has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@reject_date}] - Your request to join the team \
              'Manchester United' has been rejected by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request to join the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'join:request',
          actor: {
            id: 'juan',
            alias: 'Juan Mata'
          },
          process: {
            id: 'hold_midfield',
            name: 'Strengthen Midfield'
          },
          roles: {
            'midfield': 'player'
            '~': 'admin'
          }
          timestamp: @iso_date
        }
        next()

      describe 'when state is PENDING', ->
        before (next) ->
          @story_state = _.extend {}, @story, { state: 'PENDING' }
          next()

        describe 'in global context', ->
          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@text_date}] - Juan Mata wants to join the process \
              'Strengthen Midfield' as player in midfield lane, \
              admin in No lanes.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> wants to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - Juan Mata wants to join this process \
              as player in midfield lane, admin in No lanes.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> wants to join this process as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - Your request to join the process \
              'Strengthen Midfield' as player in midfield lane, \
              admin in No lanes is pending.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul> is pending.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @cancel_date = moment(date).format('llll')
          @cancel_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'CANCELLED'
            cancelled_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@cancel_date}] - Juan Mata cancelled the request to join \
              the process 'Strengthen Midfield'.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> cancelled the request to join the process <span class='pl-object'>Strengthen Midfield</span>.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@cancel_date}] - Juan Mata cancelled the request to join \
              this process.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> cancelled the request to join this process.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@cancel_date}] - You cancelled the request to join the \
              process 'Strengthen Midfield'.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>You</span> cancelled the request to join the process <span class='pl-object'>Strengthen Midfield</span>.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @accept_date = moment(date).format('llll')
          @accept_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'ACCEPTED'
            accepted_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
            accepted_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@accept_date}] - Juan Mata\u2019s request to join the process \
              'Strengthen Midfield' has been accepted by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request to join the process <span class='pl-object'>Strengthen Midfield</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@accept_date}] - Juan Mata\u2019s request to join this \
              process has been accepted by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request to join this process has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@accept_date}] - Your request to join the process \
              'Strengthen Midfield' has been accepted by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request to join the process <span class='pl-object'>Strengthen Midfield</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @reject_date = moment(date).format('llll')
          @reject_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'REJECTED'
            rejected_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
            rejected_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@reject_date}] - Juan Mata\u2019s request to join the \
              process 'Strengthen Midfield' has been rejected by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request to join the process <span class='pl-object'>Strengthen Midfield</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@accept_date}] - Juan Mata\u2019s request to join this \
              process has been rejected by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request to join this process has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@accept_date}] - Your request to join the process \
              'Strengthen Midfield' has been rejected by Jose Mourinho.
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request to join the process <span class='pl-object'>Strengthen Midfield</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()


  ###*
   * The Join Request Reject Event
  ###
  describe 'for the "join:request:reject" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'join:request:reject',
          actor: {
            id: 'david',
            alias: 'David Moyes'
          },
          player: {
            id: 'mata',
            alias: 'Juan Mata'
          },
          team: {
            id: 'mufc',
            name: 'Manchester United'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the join request reject story (text)', (next) ->
          expect(@odysseus.toString(@story)).to.equal """
            [#{@text_date}] - Juan Mata\u2019s request to join the team \
            'Manchester United' has been rejected by David Moyes.
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story)).to.equal """
            <div class='pl-content'><span class='pl-target'>Juan Mata\u2019s</span> request to join the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-actor'>David Moyes</span>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the join request reject story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - Juan Mata\u2019s request to join this team \
            has been rejected by David Moyes.
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story, @externals)).to.equal """
            <div class='pl-content'><span class='pl-target'>Juan Mata\u2019s</span> request to join this team has been rejected by <span class='pl-actor'>David Moyes</span>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
          next()

        it 'builds the join request reject story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - Your request to join the team \
            'Manchester United' has been rejected by David Moyes.
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-target'>Your</span> request to join the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-actor'>David Moyes</span>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'join:request:reject',
          actor: {
            id: 'alex',
            alias: 'Sir Alex Ferguson'
          },
          player: {
            id: 'david',
            alias: 'David Moyes'
          }
          process: {
            id: 'ucl_2014',
            name: 'Qualify for UEFA Champions League 2014'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the join request reject story (text)', (next) ->
          expect(@odysseus.toString(@story)).to.equal """
            [#{@text_date}] - David Moyes\u2019s request to join the \
            process 'Qualify for UEFA Champions League 2014' has been \
            rejected by Sir Alex Ferguson.
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story)).to.equal """
            <div class='pl-content'><span class='pl-target'>David Moyes\u2019s</span> request to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been rejected by <span class='pl-actor'>Sir Alex Ferguson</span>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the join request reject story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - David Moyes\u2019s request to join this process \
            has been rejected by Sir Alex Ferguson.
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-target'>David Moyes\u2019s</span> request to join this process has been rejected by <span class='pl-actor'>Sir Alex Ferguson</span>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the join request reject story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - Your request to join the process \
            'Qualify for UEFA Champions League 2014' has been \
            rejected by Sir Alex Ferguson.
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-target'>Your</span> request to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been rejected by <span class='pl-actor'>Sir Alex Ferguson</span>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()


  ###*
   * The Role Request Event
  ###
  describe 'for the "role:request" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'role:request',
          actor: {
            id: 'mata',
            alias: 'Juan Mata'
          },
          team: {
            id: 'mufc',
            name: 'Manchester United'
          },
          roles: {
            'midfielder': true
          }
          timestamp: @iso_date
        }
        next()


      describe 'when state is PENDING', ->
        before (next) ->
          @story_state = _.extend {}, @story, { state: 'PENDING' }
          next()

        describe 'in global context', ->
          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@text_date}] - Juan Mata wants to change roles in \
              the team 'Manchester United'.
                New Roles:
                  [*] midfielder
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> wants to change roles in the team <span class='pl-object'>Manchester United</span>.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li><span class='pl-role'>midfielder</span></li></ul></div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - Juan Mata wants to change roles in this team.
                New Roles:
                  [*] midfielder
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> wants to change roles in this team.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li><span class='pl-role'>midfielder</span></li></ul></div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - Your request for change of roles in \
              the team 'Manchester United' is pending.
                New Roles:
                  [*] midfielder
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request for change of roles in the team <span class='pl-object'>Manchester United</span> is pending.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li><span class='pl-role'>midfielder</span></li></ul></div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @cancel_date = moment(date).format('llll')
          @cancel_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'CANCELLED'
            cancelled_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@cancel_date}] - Juan Mata cancelled the request for \
              change of roles in the team 'Manchester United'.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> cancelled the request for change of roles in the team <span class='pl-object'>Manchester United</span>.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@cancel_date}] - Juan Mata cancelled the request for \
              change of roles in this team.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> cancelled the request for change of roles in this team.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@cancel_date}] - You cancelled the request for \
              change of roles in the team 'Manchester United'.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>You</span> cancelled the request for change of roles in the team <span class='pl-object'>Manchester United</span>.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @accept_date = moment(date).format('llll')
          @accept_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'ACCEPTED'
            accepted_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
            accepted_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@accept_date}] - Juan Mata\u2019s request for \
              change of roles in the team 'Manchester United' has \
              been accepted by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@accept_date}] - Juan Mata\u2019s request for change of \
              roles in this team has been accepted by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in this team has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@accept_date}] - Your request for change of roles in the \
              team 'Manchester United' has been accepted by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request for change of roles in the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @reject_date = moment(date).format('llll')
          @reject_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'REJECTED'
            rejected_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
            rejected_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@reject_date}] - Juan Mata\u2019s request for change of \
              roles in the team 'Manchester United' has been \
              rejected by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@reject_date}] - Juan Mata\u2019s request for change of \
              roles in this team has been rejected by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in this team has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@reject_date}] - Your request for change of roles in the \
              team 'Manchester United' has been rejected by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request for change of roles in the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'role:request',
          actor: {
            id: 'juan',
            alias: 'Juan Mata'
          },
          process: {
            id: 'hold_midfield',
            name: 'Strengthen Midfield'
          },
          roles: {
            'midfield': 'player'
            '~': 'admin'
          }
          timestamp: @iso_date
        }
        next()

      describe 'when state is PENDING', ->
        before (next) ->
          @story_state = _.extend {}, @story, { state: 'PENDING' }
          next()

        describe 'in global context', ->
          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@text_date}] - Juan Mata wants to change roles in the \
              process 'Strengthen Midfield'.
                New Roles:
                  [*] player in midfield lane
                  [*] admin in No lanes
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> wants to change roles in the process <span class='pl-object'>Strengthen Midfield</span>.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul></div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - Juan Mata wants to change roles in this process.
                New Roles:
                  [*] player in midfield lane
                  [*] admin in No lanes
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> wants to change roles in this process.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul></div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - Your request for change of roles in the \
              process 'Strengthen Midfield' is pending.
                New Roles:
                  [*] player in midfield lane
                  [*] admin in No lanes
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span> is pending.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul></div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @cancel_date = moment(date).format('llll')
          @cancel_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'CANCELLED'
            cancelled_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@cancel_date}] - Juan Mata cancelled the request for change \
              of roles in the process 'Strengthen Midfield'.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> cancelled the request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span>.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@cancel_date}] - Juan Mata cancelled the request for \
              change of roles in this process.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata</span> cancelled the request for change of roles in this process.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@cancel_date}] - You cancelled the request for change of \
              roles in the process 'Strengthen Midfield'.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>You</span> cancelled the request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span>.</div><time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_rel_date}</time>
            """
            next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @accept_date = moment(date).format('llll')
          @accept_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'ACCEPTED'
            accepted_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
            accepted_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@accept_date}] - Juan Mata\u2019s request for change \
              of roles in the process 'Strengthen Midfield' has \
              been accepted by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@accept_date}] - Juan Mata\u2019s request for change of \
              roles in this process has been accepted by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in this process has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@accept_date}] - Your request for change of roles in the \
              process 'Strengthen Midfield' has been accepted by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @reject_date = moment(date).format('llll')
          @reject_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'REJECTED'
            rejected_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
            rejected_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@reject_date}] - Juan Mata\u2019s request for change of \
              roles in the process 'Strengthen Midfield' has been \
              rejected by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@reject_date}] - Juan Mata\u2019s request for change of \
              roles in this process has been rejected by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in this process has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@reject_date}] - Your request for change of roles in \
              the process 'Strengthen Midfield' has been \
              rejected by Jose Mourinho.
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()


  ###*
   * The Invite Event
  ###
  describe 'for the "invite" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'invite',
          actor: {
            id: 'david',
            alias: 'David Moyes'
          },
          invitee: {
            id: 'mata'
            alias: 'Juan Mata'
          },
          team: {
            id: 'mufc',
            name: 'Manchester United'
          },
          roles: {
            'midfielder': true
          }
          timestamp: @iso_date
        }
        next()


      describe 'when state is PENDING', ->
        before (next) ->
          @story_state = _.extend {}, @story, { state: 'PENDING' }
          next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'david', alias: 'David Moyes'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - Your invitation to Juan Mata to join the \
              team 'Manchester United' as midfielder is pending.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> invitation to <span class='pl-target'>Juan Mata</span> to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li></ul> is pending.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

        describe "in invitee's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'invitee'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - David Moyes invited you to join the team \
              'Manchester United' as midfielder.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>David Moyes</span> invited <span class='pl-target'>you</span> to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @cancel_date = moment(date).format('llll')
          @cancel_rel_date = moment(date).fromNow()
          @story_state = _.chain({}).extend(@story, {
            state: 'CANCELLED'
            cancelled_at: date
          }).omit('invitee').value()
          next()

        it 'builds the invite story (text)', (next) ->
          expect(@odysseus.toString(@story_state)).to.equal """
            [#{@cancel_date}] - David Moyes withdrew the invitation \
            to join the team 'Manchester United'.
          """
          next()

        it 'builds the invite story (html)', (next) ->
          expect(@odysseus.toHTML(@story_state)).to.equal """
            <div class='pl-content'>\
              <span class='pl-actor'>David Moyes</span> \
              withdrew the invitation to join the team \
              <span class='pl-object'>Manchester United</span>.\
            </div>\
            <time class='pl-ts' title='On #{@cancel_date}'>\
              #{@cancel_rel_date}</time>
          """
          next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @accept_date = moment(date).format('llll')
          @accept_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'ACCEPTED'
            accepted_at: date
          }
          next()

        describe "in global context", ->
          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@accept_date}] - Juan Mata accepted David Moyes\u2019s \
              invitation to join the team 'Manchester United' as midfielder.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-target'>Juan Mata</span> accepted <span class='pl-actor'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li></ul>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_state_actor = _.omit @story_state, 'actor'
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_state_actor)).to.equal """
              [#{@accept_date}] - Juan Mata accepted your invitation to \
              join the team 'Manchester United' as midfielder.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state_actor)).to.equal """
              <div class='pl-content'><span class='pl-target'>Juan Mata</span> accepted <span class='pl-actor'>your</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li></ul>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe "in invitee's context", ->
          before (next) ->
            @story_state_invitee = _.omit @story_state, 'invitee'
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_state_invitee)).to.equal """
              [#{@accept_date}] - You accepted David Moyes\u2019s invitation to \
              join the team 'Manchester United' as midfielder.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state_invitee)).to.equal """
              <div class='pl-content'>\
                <span class='pl-target'>You</span> \
                accepted <span class='pl-actor'>David Moyes\u2019s</span> \
                invitation to join the team \
                <span class='pl-object'>Manchester United</span> as \
                <ul class='pl-role-list'>\
                  <li><span class='pl-role'>midfielder</span></li>\
                </ul>.\
              </div>\
              <time class='pl-ts' title='On #{@accept_date}'>\
                #{@accept_rel_date}\
              </time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @reject_date = moment(date).format('llll')
          @reject_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'REJECTED'
            rejected_at: date
          }
          next()

        describe "in global context", ->
          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_state)).to.equal """
              [#{@accept_date}] - Juan Mata rejected David Moyes\u2019s \
              invitation to join the team 'Manchester United' as midfielder.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state)).to.equal """
              <div class='pl-content'><span class='pl-target'>Juan Mata</span> rejected <span class='pl-actor'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li></ul>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_state_actor = _.omit @story_state, 'actor'
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_state_actor)).to.equal """
              [#{@accept_date}] - Juan Mata rejected your invitation to \
              join the team 'Manchester United' as midfielder.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state_actor)).to.equal """
              <div class='pl-content'><span class='pl-target'>Juan Mata</span> rejected <span class='pl-actor'>your</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li></ul>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe "in invitee's context", ->
          before (next) ->
            @story_state_invitee = _.omit @story_state, 'invitee'
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_state_invitee)).to.equal """
              [#{@accept_date}] - You rejected David Moyes\u2019s invitation to \
              join the team 'Manchester United' as midfielder.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_state_invitee)).to.equal """
              <div class='pl-content'>\
                <span class='pl-target'>You</span> \
                rejected <span class='pl-actor'>David Moyes\u2019s</span> \
                invitation to join the team \
                <span class='pl-object'>Manchester United</span> as \
                <ul class='pl-role-list'>\
                  <li><span class='pl-role'>midfielder</span></li>\
                </ul>.\
              </div>\
              <time class='pl-ts' title='On #{@accept_date}'>\
                #{@accept_rel_date}\
              </time>
            """
            next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'invite',
          actor: {
            id: 'david',
            alias: 'David Moyes'
          },
          invitee: {
            id: 'mata'
            alias: 'Juan Mata'
          },
          process: {
            id: 'hold_midfield',
            name: 'Strengthen Midfield'
          },
          roles: {
            'midfielder': 'player'
            '~': 'admin'
          }
          timestamp: @iso_date
        }
        next()

      describe 'when state is PENDING', ->
        before (next) ->
          @story_state = _.extend {}, @story, { state: 'PENDING' }
          next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx)).to.equal """
              [#{@text_date}] - Your invitation to Juan Mata to join the \
              process 'Strengthen Midfield' as player in midfielder lane, \
              admin in No lanes is pending.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx)).to.equal """
              <div class='pl-content'><span class='pl-actor'>Your</span> invitation to <span class='pl-target'>Juan Mata</span> to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfielder</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul> is pending.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

        describe "in invitee's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'invitee'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@text_date}] - David Moyes invited you to join the process \
              'Strengthen Midfield' as player in midfielder lane, \
              admin in No lanes.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-actor'>David Moyes</span> invited <span class='pl-target'>you</span> to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfielder</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @cancel_date = moment(date).format('llll')
          @cancel_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'CANCELLED'
            cancelled_at: date
          }
          next()

        it 'builds the invite story (text)', (next) ->
          expect(@odysseus.toString(@story_state)).to.equal """
            [#{@cancel_date}] - David Moyes withdrew the invitation \
            to join the process 'Strengthen Midfield'.
          """
          next()

        it 'builds the invite story (html)', (next) ->
          expect(@odysseus.toHTML(@story_state)).to.equal """
            <div class='pl-content'>\
              <span class='pl-actor'>David Moyes</span> \
              withdrew the invitation to join the process \
              <span class='pl-object'>Strengthen Midfield</span>.\
            </div>\
            <time class='pl-ts' title='On #{@cancel_date}'>\
              #{@cancel_rel_date}</time>
          """
          next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @accept_date = moment(date).format('llll')
          @accept_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'ACCEPTED'
            accepted_at: date
          }
          next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx)).to.equal """
              [#{@accept_date}] - Juan Mata accepted your invitation to join \
              the process 'Strengthen Midfield' as player in midfielder lane, \
              admin in No lanes.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx)).to.equal """
              <div class='pl-content'><span class='pl-target'>Juan Mata</span> accepted <span class='pl-actor'>your</span> invitation to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfielder</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

        describe "in invitee's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'invitee'
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx)).to.equal """
              [#{@accept_date}] - You accepted David Moyes\u2019s \
              invitation to join the process 'Strengthen Midfield' as \
              player in midfielder lane, admin in No lanes.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx)).to.equal """
              <div class='pl-content'><span class='pl-target'>You</span> accepted <span class='pl-actor'>David Moyes\u2019s</span> invitation to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfielder</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul>.</div><time class='pl-ts' title='On #{@accept_date}'>#{@accept_rel_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          date = new Date(+global.date + 6e5).toISOString()
          @reject_date = moment(date).format('llll')
          @reject_rel_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'REJECTED'
            rejected_at: date
          }
          next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'david', alias: 'David Moyes'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
              [#{@reject_date}] - Juan Mata rejected your invitation to join \
              the process 'Strengthen Midfield' as player in midfielder lane, \
              admin in No lanes.
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
              <div class='pl-content'><span class='pl-target'>Juan Mata</span> rejected <span class='pl-actor'>your</span> invitation to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfielder</span> lane</li><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li></ul>.</div><time class='pl-ts' title='On #{@reject_date}'>#{@reject_rel_date}</time>
            """
            next()

  ###*
   * The Invite Reject Event
  ###
  describe 'for the "invite:reject" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'invite:reject',
          actor: {
            id: 'mata',
            alias: 'Juan Mata'
          },
          inviter: {
            id: 'david',
            alias: 'David Moyes'
          },
          team: {
            id: 'mufc',
            name: 'Manchester United'
          },
          roles: {
            'midfielder': true,
            'playmaker': true
          }
          timestamp: @iso_date
        }
        next()

      describe 'for single role', ->
        before (next) ->
          @special_story = _.extend({}, @story, {
            roles: { 'midfielder': true }
          })
          next()

        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@special_story)).to.equal """
            [#{@text_date}] - Juan Mata rejected David Moyes\u2019s \
            invitation to join the team 'Manchester United' as midfielder.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@special_story)).to.equal """
            <div class='pl-content'><span class='pl-actor'>Juan Mata</span> rejected <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe 'for multiple roles', ->
        before (next) ->
          @special_story = _.extend({}, @story, {
            roles: { 'midfielder': true, 'playmaker': true }
          })
          next()

        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@special_story)).to.equal """
            [#{@text_date}] - Juan Mata rejected David Moyes\u2019s \
            invitation to join the team 'Manchester United' as \
            midfielder, playmaker.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@special_story)).to.equal """
            <div class='pl-content'><span class='pl-actor'>Juan Mata</span> rejected <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li><li><span class='pl-role'>playmaker</span></li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@story)).to.equal """
            [#{@text_date}] - Juan Mata rejected David Moyes\u2019s \
            invitation to join the team 'Manchester United' as \
            midfielder, playmaker.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story)).to.equal """
            <div class='pl-content'><span class='pl-actor'>Juan Mata</span> rejected <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li><li><span class='pl-role'>playmaker</span></li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - Juan Mata rejected David Moyes\u2019s \
            invitation to join this team as midfielder, playmaker.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story, @externals)).to.equal """
            <div class='pl-content'><span class='pl-actor'>Juan Mata</span> rejected <span class='pl-target'>David Moyes\u2019s</span> invitation to join this team as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li><li><span class='pl-role'>playmaker</span></li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
          next()

        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - You rejected David Moyes\u2019s invitation \
            to join the team 'Manchester United' as midfielder, playmaker.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-actor'>You</span> rejected <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li><li><span class='pl-role'>playmaker</span></li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe "in inviter's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'inviter'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - Juan Mata rejected your invitation to \
            join the team 'Manchester United' as midfielder, playmaker.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-actor'>Juan Mata</span> rejected <span class='pl-target'>your</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li><span class='pl-role'>midfielder</span></li><li><span class='pl-role'>playmaker</span></li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'invite:reject',
          actor: {
            id: 'david',
            alias: 'David Moyes'
          },
          inviter: {
            id: 'alex',
            alias: 'Sir Alex Ferguson'
          },
          process: {
            id: 'ucl_2014',
            name: 'Qualify for UEFA Champions League 2014'
          },
          roles: {
            team: 'admin',
            board: 'player'
          }
          timestamp: @iso_date
        }
        next()

      describe 'for single role', ->
        before (next) ->
          @special_story = _.extend({}, @story, {
            roles: { 'team': 'admin' }
          })
          next()

        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@special_story)).to.equal """
            [#{@text_date}] - David Moyes rejected Sir Alex Ferguson\u2019s \
            invitation to join the process 'Qualify for UEFA Champions \
            League 2014' as admin in team lane.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@special_story)).to.equal """
            <div class='pl-content'><span class='pl-actor'>David Moyes</span> rejected <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe 'for multiple roles', ->
        before (next) ->
          @special_story = _.extend({}, @story, {
            roles: {
              '~': 'admin',
              'board': 'player'
            }
          })
          next()

        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@special_story)).to.equal """
            [#{@text_date}] - David Moyes rejected Sir Alex Ferguson\u2019s \
            invitation to join the process 'Qualify for UEFA Champions \
            League 2014' as admin in No lanes, player in board lane.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@special_story)).to.equal """
            <div class='pl-content'><span class='pl-actor'>David Moyes</span> rejected <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>No</span> lanes</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@story)).to.equal """
            [#{@text_date}] - David Moyes rejected Sir Alex Ferguson\u2019s \
            invitation to join the process 'Qualify for UEFA Champions \
            League 2014' as admin in team lane, player in board lane.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story)).to.equal """
            <div class='pl-content'><span class='pl-actor'>David Moyes</span> rejected <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - David Moyes rejected Sir Alex Ferguson\u2019s \
            invitation to join this process as \
            admin in team lane, player in board lane.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-actor'>David Moyes</span> rejected <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join this process as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - You rejected Sir Alex Ferguson\u2019s \
            invitation to join the process 'Qualify for UEFA Champions \
            League 2014' as admin in team lane, player in board lane.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-actor'>You</span> rejected <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe "in inviter's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'inviter'
          @externals = { profile: {id: 'alex', alias: 'Sir Alex Ferguson'} }
          next()

        it 'builds the invite reject story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - David Moyes rejected your invitation to join \
            the process 'Qualify for UEFA Champions League 2014' as \
            admin in team lane, player in board lane.
          """
          next()

        it 'builds the invite reject story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-actor'>David Moyes</span> rejected <span class='pl-target'>your</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

  ###*
   * The Role Request Reject Event
  ###
  describe 'for the "role:request:reject" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'role:request:reject',
          actor: {
            id: 'david',
            alias: 'David Moyes'
          },
          player: {
            id: 'vidic',
            alias: 'Nemanja Vidic'
          },
          team: {
            id: 'mufc',
            name: 'Manchester United'
          },
          changes: {
            'captain': { 'old': null, 'new': true }
            'player': { 'old': true, 'new': null }
          }
          timestamp: @iso_date
        }
        next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the role request rejection story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - Nemanja Vidic\u2019s request for a change \
            of roles in the team 'Manchester United' has been rejected by you.
          """
          next()

        it 'builds the role request rejection story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-target'>Nemanja Vidic\u2019s</span> request for a change of roles in the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-actor'>you</span>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'vidic', alias: 'Nemanja Vidic'} }
          next()

        it 'builds the role request rejection story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - Your request for a change of roles in the \
            team 'Manchester United' has been rejected by David Moyes.
          """
          next()

        it 'builds the role request rejection story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-target'>Your</span> request for a change of roles in the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-actor'>David Moyes</span>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'role:request:reject',
          actor: {
            id: 'alex',
            alias: 'Sir Alex Ferguson'
          },
          player: {
            id: 'david',
            alias: 'David Moyes'
          },
          process: {
            id: 'ucl_2014',
            name: 'Qualify for UEFA Champions League 2014'
          },
          changes: {
            'board': { 'old': null, 'new': 'player'}
            'team': { 'old': 'admin', 'new': 'super_admin'}
            'external': { 'old': 'observer', 'new': null }
          }
          timestamp: @iso_date
        }
        next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'alex', alias: 'Sir Alex Ferguson'} }
          next()

        it 'builds the role request rejection story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - David Moyes\u2019s request for a change of \
            roles in the process 'Qualify for UEFA Champions \
            League 2014' has been rejected by you.
          """
          next()

        it 'builds the role request rejection story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-target'>David Moyes\u2019s</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been rejected by <span class='pl-actor'>you</span>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'vidic', alias: 'David Moyes'} }
          next()

        it 'builds the role request rejection story (text)', (next) ->
          expect(@odysseus.toString(@story_ctx, @externals)).to.equal """
            [#{@text_date}] - Your request for a change of roles in the \
            process 'Qualify for UEFA Champions League 2014' has been \
            rejected by Sir Alex Ferguson.
          """
          next()

        it 'builds the role request rejection story (html)', (next) ->
          expect(@odysseus.toHTML(@story_ctx, @externals)).to.equal """
            <div class='pl-content'><span class='pl-target'>Your</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been rejected by <span class='pl-actor'>Sir Alex Ferguson</span>.</div><time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
          """
          next()


  ###*
   * For Escalation Event
  ###
  describe 'for the "escalation" event', ->
    before (next) ->
      @story = {
        event: "escalation",
        message: "There is a potential transfer target!",
        process: {
          id: "epl2014",
          name: "Premier League Campaign"
        },
        triggers: [
          {
            trigger: "defender",
            name: "Grab a World Class Defender",
            actions: [
              {
                metric: {
                  id: "defences",
                  type: "point",
                  name: "Defences"
                },
                value: "10",
                verb: "add"
              }
            ]
          }
        ],
        timestamp: @iso_date
        code: "229...a92c",
        id: "b61...c4e1"
        play_token: "YmS...TjEz",
      }
      next()

    it 'builds the escalation story (text)', (next) ->
      expect(@odysseus.toString(@story)).to.equal """
        [#{@text_date}] - There is a potential transfer target!
      """
      next()

    it 'builds the escalation story (html)', (next) ->
      expect(@odysseus.toHTML(@story)).to.equal """
        <div class='pl-content'>\
          There is a potential transfer target!\
        </div>\
        <time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
      """
      next()

  ###*
   * For Score Event
  ###
  describe 'for the "score" event', ->
    before (next) ->
      @story = {
        event: "score",
        player: {
          id: 'juan',
          alias: 'Juan Mata'
        }
        timestamp: @iso_date
      }
      next()

    describe 'for "point" metric changes', ->
      before (next) ->
        @score_story = _.extend {}, @story, {
          changes: [
            {
              metric: {
                name: "Goals"
                id: "goals"
                type: "point"
              },
              delta: {
                'old': "1",
                'new': "3"
              }
            }
          ]
        }
        next()

      it 'builds the score story (text)', (next) ->
        expect(@odysseus.toString(@score_story)).to.equal """
          [#{@text_date}] - Juan Mata\u2019s scores were changed.
            New Scores:
              [*] 3 Goals
        """
        next()

      it 'builds the score story (html)', (next) ->
        expect(@odysseus.toHTML(@score_story)).to.equal """
          <div class='pl-content'>\
            <span class='pl-target'>Juan Mata\u2019s</span> scores \
            were changed.\
            <table class='pl-score-table'>\
              <tbody class='pl-score-header'>\
                <tr>\
                  <td><span class='pl-score-metric'>Goals</span></td>\
                  <td><span class='pl-score-delta-value'>3</span></td>\
                </tr>\
              </tbody>\
            </table>\
          </div>\
          <time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
        """
        next()

    describe 'for "set" metric changes', ->
      before (next) ->
        @score_story = _.extend {}, @story, {
          changes: [
            {
              metric: {
                name: "UEFA Awards"
                type: "set"
                id: "uefa_awards"
              },
              delta: {
                "Golden Boot": {
                  "old": "0",
                  "new": "1"
                },
                "Champion": {
                  "old": "3",
                  "new": "4"
                },
                "Suspensions": {
                  "old": "1",
                  "new": "0"
                }
              }
            }
          ]
        }
        next()

      it 'builds the score story (text)', (next) ->
        expect(@odysseus.toString(@score_story)).to.equal """
          [#{@text_date}] - Juan Mata\u2019s scores were changed.
            New Scores:
            [>] UEFA Awards
              [*] 1 Golden Boot
              [*] 4 Champion
              [*] 0 Suspensions
        """
        next()

      it 'builds the score story (html)', (next) ->
        expect(@odysseus.toHTML(@score_story)).to.equal """
          <div class='pl-content'>\
            <span class='pl-target'>Juan Mata\u2019s</span> scores \
            were changed.\
            <table class='pl-score-table'>\
              <tbody class='pl-score-header'>\
                <tr>\
                  <td colspan='2'><span class='pl-score-metric'>\
                    UEFA Awards</span></td>\
                </tr>\
              </tbody>\
              <tbody class='pl-score-body'>\
                <tr>\
                  <td><span class='pl-score-delta-item'>Golden Boot</span></td>\
                  <td><span class='pl-score-delta-value'>1</span></td>\
                </tr>\
                <tr>\
                  <td><span class='pl-score-delta-item'>Champion</span></td>\
                  <td><span class='pl-score-delta-value'>4</span></td>\
                </tr>\
                <tr>\
                  <td><span class='pl-score-delta-item'>Suspensions</span></td>\
                  <td><span class='pl-score-delta-value'>0</span></td>\
                </tr>\
              </tbody>\
            </table>\
          </div>\
          <time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
        """
        next()

    describe 'for "state" metric changes', ->
      before (next) ->
        @score_story = _.extend {}, @story, {
          changes: [
            {
              metric: {
                name: "Transfer Market Standing"
                type: "state"
                id: "transfers"
              },
              delta: {
                "old": "Meh"
                "new": "Hot Property"
              }
            }
          ]
        }
        next()

      it 'builds the score story (text)', (next) ->
        expect(@odysseus.toString(@score_story)).to.equal """
          [#{@text_date}] - Juan Mata\u2019s scores were changed.
            New Scores:
            [*] Transfer Market Standing - Hot Property
        """
        next()

      it 'builds the score story (html)', (next) ->
        expect(@odysseus.toHTML(@score_story)).to.equal """
          <div class='pl-content'>\
            <span class='pl-target'>Juan Mata\u2019s</span> scores \
            were changed.\
            <table class='pl-score-table'>\
              <tbody class='pl-score-header'>\
                <tr>\
                  <td><span class='pl-score-metric'>Transfer Market Standing</span></td>\
                  <td><span class='pl-score-delta-value'>Hot Property</span></td>\
                </tr>\
              </tbody>\
            </table>\
          </div>\
          <time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
        """
        next()

    describe "in target player's context", ->
      before (next) ->
        @score_story = _.extend {}, @story, {
          changes: [
            {
              metric: {
                name: "Goals"
                id: "goals"
                type: "point"
              },
              delta: {
                'old': "1",
                'new': "3"
              }
            }
          ]
        }
        @score_story = _.omit @score_story, 'player'
        next()

      it 'builds the score story (text)', (next) ->
        expect(@odysseus.toString(@score_story)).to.equal """
          [#{@text_date}] - Your scores were changed.
            New Scores:
              [*] 3 Goals
        """
        next()

      it 'builds the score story (html)', (next) ->
        expect(@odysseus.toHTML(@score_story)).to.equal """
          <div class='pl-content'>\
            <span class='pl-target'>Your</span> scores \
            were changed.\
            <table class='pl-score-table'>\
              <tbody class='pl-score-header'>\
                <tr>\
                  <td><span class='pl-score-metric'>Goals</span></td>\
                  <td><span class='pl-score-delta-value'>3</span></td>\
                </tr>\
              </tbody>\
            </table>\
          </div>\
          <time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
        """
        next()

    describe "as an admin event", ->
      before (next) ->
        @score_story = _.extend {}, @story, {
          admin: 'foo'
          changes: [
            {
              metric: {
                name: "Goals"
                id: "goals"
                type: "point"
              },
              delta: {
                'old': "1",
                'new': "3"
              }
            }
          ]
        }, 'player'
        next()

      it 'builds the score story (text)', (next) ->
        expect(@odysseus.toString(@score_story)).to.equal """
          [#{@text_date}] - [Admin Event] Juan Mata\u2019s scores \
          were changed.
            New Scores:
              [*] 3 Goals
        """
        next()

      it 'builds the score story (html)', (next) ->
        expect(@odysseus.toHTML(@score_story)).to.equal """
          <div class='pl-content'>\
            <span class='pl-target'>Juan Mata\u2019s</span> scores \
            were changed.\
            <table class='pl-score-table'>\
              <tbody class='pl-score-header'>\
                <tr>\
                  <td><span class='pl-score-metric'>Goals</span></td>\
                  <td><span class='pl-score-delta-value'>3</span></td>\
                </tr>\
              </tbody>\
            </table>\
            <footer class='pl-footer'>\
              <span class='pl-admin'>Admin Event</span>\
            </footer>\
          </div>\
          <time class='pl-ts' title='On #{@text_date}'>#{@rel_date}</time>
        """
        next()
