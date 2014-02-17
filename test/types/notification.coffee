Athena = require '../../index'
_ = require 'lodash'
moment = require 'moment'

describe 'The Notification Story Builder', ->
  before (next) ->
    @athena = new Athena(global.config)
    @iso_date = global.iso_date
    @text_date = global.text_date
    @relative_date = global.relative_date
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
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata wants to join the team 'Manchester United' as midfielder.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata</span> wants to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata wants to join this team as midfielder.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata</span> wants to join this team as <ul class='pl-role-list'><li class='pl-role'>midfielder</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request to join the team 'Manchester United' as midfielder is pending.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li></ul> is pending.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @cancel_date = moment(date).format('llll')
          @cancel_relative_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'CANCELLED'
            cancelled_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata cancelled the request to join the team 'Manchester United'.
              [#{@cancel_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata</span> cancelled the request to join the team <span class='pl-object'>Manchester United</span>.<time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_relative_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata cancelled the request to join this team.
              [#{@cancel_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata</span> cancelled the request to join this team.<time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              You cancelled the request to join the team 'Manchester United'.
              [#{@cancel_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>You</span> cancelled the request to join the team <span class='pl-object'>Manchester United</span>.<time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_relative_date}</time>
            """
            next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @accept_date = moment(date).format('llll')
          @accept_relative_date = moment(date).fromNow()
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
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata\u2019s request to join the team 'Manchester United' has been accepted by Jose Mourinho.
              [#{@accept_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request to join the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@accept_date}'>#{@accept_relative_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata\u2019s request to join this team has been accepted by Jose Mourinho.
              [#{@accept_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request to join this team has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@accept_date}'>#{@accept_relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request to join the team 'Manchester United' has been accepted by Jose Mourinho.
              [#{@accept_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request to join the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@accept_date}'>#{@accept_relative_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @reject_date = moment(date).format('llll')
          @reject_relative_date = moment(date).fromNow()
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
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata\u2019s request to join the team 'Manchester United' has been rejected by Jose Mourinho.
              [#{@reject_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request to join the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@reject_date}'>#{@reject_relative_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata\u2019s request to join this team has been rejected by Jose Mourinho.
              [#{@reject_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request to join this team has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@reject_date}'>#{@reject_relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request to join the team 'Manchester United' has been rejected by Jose Mourinho.
              [#{@reject_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request to join the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@reject_date}'>#{@reject_relative_date}</time>
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
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata wants to join the process 'Strengthen Midfield' as player in midfield lane.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata</span> wants to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata wants to join this process as player in midfield lane.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata</span> wants to join this process as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request to join the process 'Strengthen Midfield' as player in midfield lane is pending.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li></ul> is pending.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          @story_state = _.extend {}, @story, { state: 'CANCELLED' }
          next()

        describe 'in global context', ->
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata cancelled the request to join the process 'Strengthen Midfield'.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata</span> cancelled the request to join the process <span class='pl-object'>Strengthen Midfield</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata cancelled the request to join this process.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata</span> cancelled the request to join this process.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              You cancelled the request to join the process 'Strengthen Midfield'.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>You</span> cancelled the request to join the process <span class='pl-object'>Strengthen Midfield</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          @story_state = _.extend {}, @story, {
            state: 'ACCEPTED'
            accepted_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
          }
          next()

        describe 'in global context', ->
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata\u2019s request to join the process 'Strengthen Midfield' has been accepted by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request to join the process <span class='pl-object'>Strengthen Midfield</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata\u2019s request to join this process has been accepted by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request to join this process has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request to join the process 'Strengthen Midfield' has been accepted by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request to join the process <span class='pl-object'>Strengthen Midfield</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          @story_state = _.extend {}, @story, {
            state: 'REJECTED'
            rejected_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
          }
          next()

        describe 'in global context', ->
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata\u2019s request to join the process 'Strengthen Midfield' has been rejected by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request to join the process <span class='pl-object'>Strengthen Midfield</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata\u2019s request to join this process has been rejected by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request to join this process has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the join request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request to join the process 'Strengthen Midfield' has been rejected by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the join request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request to join the process <span class='pl-object'>Strengthen Midfield</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
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
          expect(@athena.toString(@story)).to.equal """
            Juan Mata\u2019s request to join the team 'Manchester United' has been rejected by David Moyes.
            [#{@text_date}]
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-target'>Juan Mata\u2019s</span> request to join the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-actor'>David Moyes</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the join request reject story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Juan Mata\u2019s request to join this team has been rejected by David Moyes.
            [#{@text_date}]
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@athena.toHTML(@story, @externals)).to.equal """
            <span class='pl-target'>Juan Mata\u2019s</span> request to join this team has been rejected by <span class='pl-actor'>David Moyes</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
          next()

        it 'builds the join request reject story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Your request to join the team 'Manchester United' has been rejected by David Moyes.
            [#{@text_date}]
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Your</span> request to join the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-actor'>David Moyes</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
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
          expect(@athena.toString(@story)).to.equal """
            David Moyes\u2019s request to join the process 'Qualify for UEFA Champions League 2014' has been rejected by Sir Alex Ferguson.
            [#{@text_date}]
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been rejected by <span class='pl-actor'>Sir Alex Ferguson</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the join request reject story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            David Moyes\u2019s request to join this process has been rejected by Sir Alex Ferguson.
            [#{@text_date}]
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request to join this process has been rejected by <span class='pl-actor'>Sir Alex Ferguson</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the join request reject story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Your request to join the process 'Qualify for UEFA Champions League 2014' has been rejected by Sir Alex Ferguson.
            [#{@text_date}]
          """
          next()

        it 'builds the join request reject story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Your</span> request to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been rejected by <span class='pl-actor'>Sir Alex Ferguson</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
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
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata wants to change roles in the team 'Manchester United'.
              New Roles:
                [*] midfielder
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata</span> wants to change roles in the team <span class='pl-object'>Manchester United</span>.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li class='pl-role'>midfielder</li></ul><time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata wants to change roles in this team.
              New Roles:
                [*] midfielder
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata</span> wants to change roles in this team.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li class='pl-role'>midfielder</li></ul><time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request for change of roles in the team 'Manchester United' is pending.
              New Roles:
                [*] midfielder
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request for change of roles in the team <span class='pl-object'>Manchester United</span> is pending.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li class='pl-role'>midfielder</li></ul><time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @cancel_date = moment(date).format('llll')
          @cancel_relative_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'CANCELLED'
            cancelled_at: date
          }
          next()

        describe 'in global context', ->
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata cancelled the request for change of roles in the team 'Manchester United'.
              [#{@cancel_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata</span> cancelled the request for change of roles in the team <span class='pl-object'>Manchester United</span>.<time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_relative_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata cancelled the request for change of roles in this team.
              [#{@cancel_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata</span> cancelled the request for change of roles in this team.<time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              You cancelled the request for change of roles in the team 'Manchester United'.
              [#{@cancel_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>You</span> cancelled the request for change of roles in the team <span class='pl-object'>Manchester United</span>.<time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_relative_date}</time>
            """
            next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @accept_date = moment(date).format('llll')
          @accept_relative_date = moment(date).fromNow()
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
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata\u2019s request for change of roles in the team 'Manchester United' has been accepted by Jose Mourinho.
              [#{@accept_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@accept_date}'>#{@accept_relative_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata\u2019s request for change of roles in this team has been accepted by Jose Mourinho.
              [#{@accept_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in this team has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@accept_date}'>#{@accept_relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request for change of roles in the team 'Manchester United' has been accepted by Jose Mourinho.
              [#{@accept_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request for change of roles in the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@accept_date}'>#{@accept_relative_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @reject_date = moment(date).format('llll')
          @reject_relative_date = moment(date).fromNow()
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
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata\u2019s request for change of roles in the team 'Manchester United' has been rejected by Jose Mourinho.
              [#{@reject_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@reject_date}'>#{@reject_relative_date}</time>
            """
            next()

        describe 'in team context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'team'
            @externals = {context: 'team'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata\u2019s request for change of roles in this team has been rejected by Jose Mourinho.
              [#{@reject_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in this team has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@reject_date}'>#{@reject_relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request for change of roles in the team 'Manchester United' has been rejected by Jose Mourinho.
              [#{@reject_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request for change of roles in the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@reject_date}'>#{@reject_relative_date}</time>
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
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata wants to change roles in the process 'Strengthen Midfield'.
              New Roles:
                [*] player in midfield lane
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata</span> wants to change roles in the process <span class='pl-object'>Strengthen Midfield</span>.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li></ul><time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata wants to change roles in this process.
              New Roles:
                [*] player in midfield lane
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata</span> wants to change roles in this process.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li></ul><time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request for change of roles in the process 'Strengthen Midfield' is pending.
              New Roles:
                [*] player in midfield lane
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span> is pending.<ul class='pl-role-list'><li class='pl-list-header'>New Roles</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfield</span> lane</li></ul><time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          @story_state = _.extend {}, @story, { state: 'CANCELLED' }
          next()

        describe 'in global context', ->
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata cancelled the request for change of roles in the process 'Strengthen Midfield'.
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata</span> cancelled the request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata cancelled the request for change of roles in this process.
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata</span> cancelled the request for change of roles in this process.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              You cancelled the request for change of roles in the process 'Strengthen Midfield'.
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>You</span> cancelled the request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          @story_state = _.extend {}, @story, {
            state: 'ACCEPTED'
            accepted_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
          }
          next()

        describe 'in global context', ->
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata\u2019s request for change of roles in the process 'Strengthen Midfield' has been accepted by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata\u2019s request for change of roles in this process has been accepted by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in this process has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request for change of roles in the process 'Strengthen Midfield' has been accepted by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span> has been accepted by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          @story_state = _.extend {}, @story, {
            state: 'REJECTED'
            rejected_by: {
              id: 'jose'
              alias: 'Jose Mourinho'
            }
          }
          next()

        describe 'in global context', ->
          it 'builds the join request cancel story (text)', (next) ->
            expect(@athena.toString(@story_state)).to.equal """
              Juan Mata\u2019s request for change of roles in the process 'Strengthen Midfield' has been rejected by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_state)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe 'in process context', ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'process'
            @externals = {context: 'process'}
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata\u2019s request for change of roles in this process has been rejected by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Juan Mata\u2019s</span> request for change of roles in this process has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the role request story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your request for change of roles in the process 'Strengthen Midfield' has been rejected by Jose Mourinho.
              [#{@text_date}]
            """
            next()

          it 'builds the role request story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> request for change of roles in the process <span class='pl-object'>Strengthen Midfield</span> has been rejected by <span class='pl-target'>Jose Mourinho</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
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
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your invitation to Juan Mata to join the team 'Manchester United' as midfielder is pending.
              [#{@text_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> invitation to <span class='pl-target'>Juan Mata</span> to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li></ul> is pending.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in invitee's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'invitee'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              David Moyes invited you to join the team 'Manchester United' as midfielder.
              [#{@text_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>David Moyes</span> invited <span class='pl-target'>you</span> to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @cancel_date = moment(date).format('llll')
          @cancel_relative_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'CANCELLED'
            cancelled_at: date
          }
          next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'david', alias: 'David Moyes'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              You cancelled the invitation for Juan Mata to join the team 'Manchester United'.
              [#{@cancel_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>You</span> cancelled the invitation for <span class='pl-target'>Juan Mata</span> to join the team <span class='pl-object'>Manchester United</span>.<time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_relative_date}</time>
            """
            next()

        describe "in invitee's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'invitee'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              David Moyes cancelled the invitation for you to join the team 'Manchester United'.
              [#{@cancel_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>David Moyes</span> cancelled the invitation for <span class='pl-target'>you</span> to join the team <span class='pl-object'>Manchester United</span>.<time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_relative_date}</time>
            """
            next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @accept_date = moment(date).format('llll')
          @accept_relative_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'ACCEPTED'
            accepted_at: date
          }
          next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'david', alias: 'David Moyes'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata accepted your invitation to join the team 'Manchester United' as midfielder.
              [#{@accept_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-target'>Juan Mata</span> accepted <span class='pl-actor'>your</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li></ul>.<time class='pl-ts' title='On #{@accept_date}'>#{@accept_relative_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @reject_date = moment(date).format('llll')
          @reject_relative_date = moment(date).fromNow()
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
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata rejected your invitation to join the team 'Manchester United' as midfielder.
              [#{@reject_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-target'>Juan Mata</span> rejected <span class='pl-actor'>your</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li></ul>.<time class='pl-ts' title='On #{@reject_date}'>#{@reject_relative_date}</time>
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
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Your invitation to Juan Mata to join the process 'Strengthen Midfield' as player in midfielder lane is pending.
              [#{@text_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>Your</span> invitation to <span class='pl-target'>Juan Mata</span> to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfielder</span> lane</li></ul> is pending.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

        describe "in invitee's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'invitee'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              David Moyes invited you to join the process 'Strengthen Midfield' as player in midfielder lane.
              [#{@text_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>David Moyes</span> invited <span class='pl-target'>you</span> to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfielder</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
            """
            next()

      describe 'when state is CANCELLED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @cancel_date = moment(date).format('llll')
          @cancel_relative_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'CANCELLED'
            cancelled_at: date
          }
          next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'david', alias: 'David Moyes'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              You cancelled the invitation for Juan Mata to join the process 'Strengthen Midfield'.
              [#{@cancel_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>You</span> cancelled the invitation for <span class='pl-target'>Juan Mata</span> to join the process <span class='pl-object'>Strengthen Midfield</span>.<time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_relative_date}</time>
            """
            next()

        describe "in invitee's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'invitee'
            @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              David Moyes cancelled the invitation for you to join the process 'Strengthen Midfield'.
              [#{@cancel_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-actor'>David Moyes</span> cancelled the invitation for <span class='pl-target'>you</span> to join the process <span class='pl-object'>Strengthen Midfield</span>.<time class='pl-ts' title='On #{@cancel_date}'>#{@cancel_relative_date}</time>
            """
            next()

      describe 'when state is ACCEPTED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @accept_date = moment(date).format('llll')
          @accept_relative_date = moment(date).fromNow()
          @story_state = _.extend {}, @story, {
            state: 'ACCEPTED'
            accepted_at: date
          }
          next()

        describe "in actor's context", ->
          before (next) ->
            @story_ctx = _.omit @story_state, 'actor'
            @externals = { profile: {id: 'david', alias: 'David Moyes'} }
            next()

          it 'builds the invite story (text)', (next) ->
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata accepted your invitation to join the process 'Strengthen Midfield' as player in midfielder lane.
              [#{@accept_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-target'>Juan Mata</span> accepted <span class='pl-actor'>your</span> invitation to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfielder</span> lane</li></ul>.<time class='pl-ts' title='On #{@accept_date}'>#{@accept_relative_date}</time>
            """
            next()

      describe 'when state is REJECTED', ->
        before (next) ->
          date = new Date(new Date().getTime() + 1e8).toISOString()
          @reject_date = moment(date).format('llll')
          @reject_relative_date = moment(date).fromNow()
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
            expect(@athena.toString(@story_ctx, @externals)).to.equal """
              Juan Mata rejected your invitation to join the process 'Strengthen Midfield' as player in midfielder lane.
              [#{@reject_date}]
            """
            next()

          it 'builds the invite story (html)', (next) ->
            expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
              <span class='pl-target'>Juan Mata</span> rejected <span class='pl-actor'>your</span> invitation to join the process <span class='pl-object'>Strengthen Midfield</span> as <ul class='pl-role-list'><li><span class='pl-role'>player</span> in <span class='pl-lane'>midfielder</span> lane</li></ul>.<time class='pl-ts' title='On #{@reject_date}'>#{@reject_relative_date}</time>
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

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@special_story)).to.equal """
            Juan Mata rejected David Moyes\u2019s invitation to join the team 'Manchester United' as midfielder.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@special_story)).to.equal """
            <span class='pl-actor'>Juan Mata</span> rejected <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for multiple roles', ->
        before (next) ->
          @special_story = _.extend({}, @story, {
            roles: { 'midfielder': true, 'playmaker': true }
          })
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@special_story)).to.equal """
            Juan Mata rejected David Moyes\u2019s invitation to join the team 'Manchester United' as midfielder, playmaker.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@special_story)).to.equal """
            <span class='pl-actor'>Juan Mata</span> rejected <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li><li class='pl-role'>playmaker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Juan Mata rejected David Moyes\u2019s invitation to join the team 'Manchester United' as midfielder, playmaker.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Juan Mata</span> rejected <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li><li class='pl-role'>playmaker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Juan Mata rejected David Moyes\u2019s invitation to join this team as midfielder, playmaker.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story, @externals)).to.equal """
            <span class='pl-actor'>Juan Mata</span> rejected <span class='pl-target'>David Moyes\u2019s</span> invitation to join this team as <ul class='pl-role-list'><li class='pl-role'>midfielder</li><li class='pl-role'>playmaker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You rejected David Moyes\u2019s invitation to join the team 'Manchester United' as midfielder, playmaker.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> rejected <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li><li class='pl-role'>playmaker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in inviter's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'inviter'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Juan Mata rejected your invitation to join the team 'Manchester United' as midfielder, playmaker.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>Juan Mata</span> rejected <span class='pl-target'>your</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li><li class='pl-role'>playmaker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
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

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@special_story)).to.equal """
            David Moyes rejected Sir Alex Ferguson\u2019s invitation to join the process 'Qualify for UEFA Champions League 2014' as admin in team lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@special_story)).to.equal """
            <span class='pl-actor'>David Moyes</span> rejected <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for multiple roles', ->
        before (next) ->
          @special_story = _.extend({}, @story, {
            roles: { 'team': 'admin', 'board': 'player' }
          })
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@special_story)).to.equal """
            David Moyes rejected Sir Alex Ferguson\u2019s invitation to join the process 'Qualify for UEFA Champions League 2014' as admin in team lane, player in board lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@special_story)).to.equal """
            <span class='pl-actor'>David Moyes</span> rejected <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            David Moyes rejected Sir Alex Ferguson\u2019s invitation to join the process 'Qualify for UEFA Champions League 2014' as admin in team lane, player in board lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>David Moyes</span> rejected <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            David Moyes rejected Sir Alex Ferguson\u2019s invitation to join this process as admin in team lane, player in board lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>David Moyes</span> rejected <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join this process as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You rejected Sir Alex Ferguson\u2019s invitation to join the process 'Qualify for UEFA Champions League 2014' as admin in team lane, player in board lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> rejected <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in inviter's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'inviter'
          @externals = { profile: {id: 'alex', alias: 'Sir Alex Ferguson'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            David Moyes rejected your invitation to join the process 'Qualify for UEFA Champions League 2014' as admin in team lane, player in board lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>David Moyes</span> rejected <span class='pl-target'>your</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
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

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Nemanja Vidic\u2019s request for a change of roles in the team 'Manchester United' has been rejected by you.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Nemanja Vidic\u2019s</span> request for a change of roles in the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-actor'>you</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'vidic', alias: 'Nemanja Vidic'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Your request for a change of roles in the team 'Manchester United' has been rejected by David Moyes.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Your</span> request for a change of roles in the team <span class='pl-object'>Manchester United</span> has been rejected by <span class='pl-actor'>David Moyes</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
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
          @externals = { profile: {id: 'david', alias: 'Sir Alex Ferguson'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            David Moyes\u2019s request for a change of roles in the process 'Qualify for UEFA Champions League 2014' has been rejected by you.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been rejected by <span class='pl-actor'>you</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'vidic', alias: 'David Moyes'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Your request for a change of roles in the process 'Qualify for UEFA Champions League 2014' has been rejected by Sir Alex Ferguson.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Your</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been rejected by <span class='pl-actor'>Sir Alex Ferguson</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()
