Athena = require '../../index'
_ = require 'lodash'

describe 'The Activity Story Builder', ->
  before (next) ->
    @athena = new Athena(global.config)
    @iso_date = global.iso_date
    @text_date = global.text_date
    @relative_date = global.relative_date
    next()

  ###*
   * The Create Event
  ###
  describe 'for the "create" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'create',
          actor: {
            id: 'bill',
            alias: 'Mr. Gates'
          },
          team: {
            id: 'msft',
            name: 'Microsoft Inc.'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the team creation story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Mr. Gates created the team 'Microsoft Inc.'.
            [#{@text_date}]
          """
          next()

        it 'builds the team creation story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Mr. Gates</span> created the team <span class='pl-object'>Microsoft Inc.</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in player context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'bill', alias: 'Mr. Gates'} }
          next()

        it 'builds the team creation story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You created the team 'Microsoft Inc.'.
            [#{@text_date}]
          """
          next()

        it 'builds the team creation story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> created the team <span class='pl-object'>Microsoft Inc.</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'create',
          actor: {
            id: 'bill',
            alias: 'Mr. Gates'
          },
          process: {
            id: 'init',
            name: 'The Microsoft Creation'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the process creation story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Mr. Gates created the process 'The Microsoft Creation'.
            [#{@text_date}]
          """
          next()

        it 'builds the process creation story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Mr. Gates</span> created the process <span class='pl-object'>The Microsoft Creation</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in player context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'bill', alias: 'Mr. Gates'} }
          next()

        it 'builds the process creation story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You created the process 'The Microsoft Creation'.
            [#{@text_date}]
          """
          next()

        it 'builds the process creation story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> created the process <span class='pl-object'>The Microsoft Creation</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

  ###*
   * The Delete Event
  ###
  describe 'for the "delete" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'delete',
          actor: {
            id: 'bill',
            alias: 'Mr. Gates'
          },
          team: {
            id: 'msft',
            name: 'Microsoft Inc.'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the team deletion story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Mr. Gates deleted the team 'Microsoft Inc.'.
            [#{@text_date}]
          """
          next()

        it 'builds the team deletion story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Mr. Gates</span> deleted the team <span class='pl-object'>Microsoft Inc.</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in player context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'bill', alias: 'Mr. Gates'} }
          next()

        it 'builds the team deletion story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You deleted the team 'Microsoft Inc.'.
            [#{@text_date}]
          """
          next()

        it 'builds the team deletion story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> deleted the team <span class='pl-object'>Microsoft Inc.</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'delete',
          actor: {
            id: 'bill',
            alias: 'Mr. Gates'
          },
          process: {
            id: 'init',
            name: 'The Microsoft Creation'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the process deletion story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Mr. Gates deleted the process 'The Microsoft Creation'.
            [#{@text_date}]
          """
          next()

        it 'builds the process deletion story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Mr. Gates</span> deleted the process <span class='pl-object'>The Microsoft Creation</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in player context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'bill', alias: 'Mr. Gates'} }
          next()

        it 'builds the process deletion story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You deleted the process 'The Microsoft Creation'.
            [#{@text_date}]
          """
          next()

        it 'builds the process deletion story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> deleted the process <span class='pl-object'>The Microsoft Creation</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()


  ###*
   * The Join Event
  ###
  describe 'for the "join" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'join',
          actor: {
            id: 'snadella',
            alias: 'Satya'
          },
          team: {
            id: 'msft',
            name: 'Microsoft Inc.'
          },
          roles: {
            ceo: true,
            board_member: true
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the team joining story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Satya joined the team 'Microsoft Inc.' as ceo, board_member.
            [#{@text_date}]
          """
          next()

        it 'builds the team joining story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Satya</span> joined the team <span class='pl-object'>Microsoft Inc.</span> as <ul class='pl-role-list'><li class='pl-role'>ceo</li><li class='pl-role'>board_member</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the team joining story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Satya joined this team as ceo, board_member.
            [#{@text_date}]
          """
          next()

        it 'builds the team joining story (html)', (next) ->
          expect(@athena.toHTML(@story, @externals)).to.equal """
            <span class='pl-actor'>Satya</span> joined this team as <ul class='pl-role-list'><li class='pl-role'>ceo</li><li class='pl-role'>board_member</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in player context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'snadella', alias: 'Satya'} }
          next()

        it 'builds the team joining story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You joined the team 'Microsoft Inc.' as ceo, board_member.
            [#{@text_date}]
          """
          next()

        it 'builds the team joining story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> joined the team <span class='pl-object'>Microsoft Inc.</span> as <ul class='pl-role-list'><li class='pl-role'>ceo</li><li class='pl-role'>board_member</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'join',
          actor: {
            id: 'snadella',
            alias: 'Satya'
          },
          process: {
            id: 'revolution',
            name: 'The Revamping of Microsoft'
          },
          roles: {
            '*': 'ceo',
            'management': 'super_admin'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the process joining story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Satya joined the process 'The Revamping of Microsoft' as ceo in All lanes, super_admin in management lane.
            [#{@text_date}]
          """
          next()

        it 'builds the process joining story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Satya</span> joined the process <span class='pl-object'>The Revamping of Microsoft</span> as <ul class='pl-role-list'><li><span class='pl-role'>ceo</span> in <span class='pl-lane'>All</span> lanes</li><li><span class='pl-role'>super_admin</span> in <span class='pl-lane'>management</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the process joining story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Satya joined this process as ceo in All lanes, super_admin in management lane.
            [#{@text_date}]
          """
          next()

        it 'builds the process joining story (html)', (next) ->
          expect(@athena.toHTML(@story, @externals)).to.equal """
            <span class='pl-actor'>Satya</span> joined this process as <ul class='pl-role-list'><li><span class='pl-role'>ceo</span> in <span class='pl-lane'>All</span> lanes</li><li><span class='pl-role'>super_admin</span> in <span class='pl-lane'>management</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in player context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'snadella', alias: 'Satya'} }
          next()

        it 'builds the process joining story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You joined the process 'The Revamping of Microsoft' as ceo in All lanes, super_admin in management lane.
            [#{@text_date}]
          """
          next()

        it 'builds the process joining story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> joined the process <span class='pl-object'>The Revamping of Microsoft</span> as <ul class='pl-role-list'><li><span class='pl-role'>ceo</span> in <span class='pl-lane'>All</span> lanes</li><li><span class='pl-role'>super_admin</span> in <span class='pl-lane'>management</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()


  ###*
   * The Leave Event
  ###
  describe 'for the "leave" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'leave',
          actor: {
            id: 'ballmer',
            alias: 'Steve Ballmer'
          },
          team: {
            id: 'msft',
            name: 'Microsoft Inc.'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the team leaving story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Steve Ballmer left the team 'Microsoft Inc.'.
            [#{@text_date}]
          """
          next()

        it 'builds the team leaving story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Steve Ballmer</span> left the team <span class='pl-object'>Microsoft Inc.</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the team leaving story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Steve Ballmer left this team.
            [#{@text_date}]
          """
          next()

        it 'builds the team leaving story (html)', (next) ->
          expect(@athena.toHTML(@story, @externals)).to.equal """
            <span class='pl-actor'>Steve Ballmer</span> left this team.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in player context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'ballmer', alias: 'Steve Ballmer'} }
          next()

        it 'builds the team leaving story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You left the team 'Microsoft Inc.'.
            [#{@text_date}]
          """
          next()

        it 'builds the team leaving story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> left the team <span class='pl-object'>Microsoft Inc.</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'leave',
          actor: {
            id: 'ballmer',
            alias: 'Steve Ballmer'
          },
          process: {
            id: 'revolution',
            name: 'The Revamping of Microsoft'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the process leaving story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Steve Ballmer left the process 'The Revamping of Microsoft'.
            [#{@text_date}]
          """
          next()

        it 'builds the process leaving story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Steve Ballmer</span> left the process <span class='pl-object'>The Revamping of Microsoft</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the process leaving story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Steve Ballmer left this process.
            [#{@text_date}]
          """
          next()

        it 'builds the process leaving story (html)', (next) ->
          expect(@athena.toHTML(@story, @externals)).to.equal """
            <span class='pl-actor'>Steve Ballmer</span> left this process.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in player context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'ballmer', alias: 'Steve Ballmer'} }
          next()

        it 'builds the process leaving story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You left the process 'The Revamping of Microsoft'.
            [#{@text_date}]
          """
          next()

        it 'builds the process leaving story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> left the process <span class='pl-object'>The Revamping of Microsoft</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()


  ###*
   * The Kick Event
  ###
  describe 'for the "kick" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'kick',
          actor: {
            id: 'ballmer',
            alias: 'Steve Ballmer'
          },
          player: {
            id: 'sinof',
            alias: 'Steven Sinofsky'
          }
          team: {
            id: 'msft',
            name: 'Microsoft Inc.'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the member kick story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Steve Ballmer kicked Steven Sinofsky from the team 'Microsoft Inc.'.
            [#{@text_date}]
          """
          next()

        it 'builds the member kick story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Steve Ballmer</span> kicked <span class='pl-target'>Steven Sinofsky</span> from the team <span class='pl-object'>Microsoft Inc.</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the member kick story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Steve Ballmer kicked Steven Sinofsky from this team.
            [#{@text_date}]
          """
          next()

        it 'builds the member kick story (html)', (next) ->
          expect(@athena.toHTML(@story, @externals)).to.equal """
            <span class='pl-actor'>Steve Ballmer</span> kicked <span class='pl-target'>Steven Sinofsky</span> from this team.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'ballmer', alias: 'Steve Ballmer'} }
          next()

        it 'builds the member kick story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You kicked Steven Sinofsky from the team 'Microsoft Inc.'.
            [#{@text_date}]
          """
          next()

        it 'builds the member kick story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> kicked <span class='pl-target'>Steven Sinofsky</span> from the team <span class='pl-object'>Microsoft Inc.</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'steven', alias: 'Steven Sinofsky'} }
          next()

        it 'builds the member kick story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Steve Ballmer kicked you from the team 'Microsoft Inc.'.
            [#{@text_date}]
          """
          next()

        it 'builds the member kick story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>Steve Ballmer</span> kicked <span class='pl-target'>you</span> from the team <span class='pl-object'>Microsoft Inc.</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'kick',
          actor: {
            id: 'ballmer',
            alias: 'Steve Ballmer'
          },
          process: {
            id: 'office',
            name: 'Office Redesign'
          },
          player: {
            id: 'elop',
            alias: 'Elop'
          }
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the performer kick story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Steve Ballmer kicked Elop from the process 'Office Redesign'.
            [#{@text_date}]
          """
          next()

        it 'builds the performer kick story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Steve Ballmer</span> kicked <span class='pl-target'>Elop</span> from the process <span class='pl-object'>Office Redesign</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the performer kick story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Steve Ballmer kicked Elop from this process.
            [#{@text_date}]
          """
          next()

        it 'builds the performer kick story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>Steve Ballmer</span> kicked <span class='pl-target'>Elop</span> from this process.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'ballmer', alias: 'Steve Ballmer'} }
          next()

        it 'builds the performer kick story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You kicked Elop from the process 'Office Redesign'.
            [#{@text_date}]
          """
          next()

        it 'builds the performer kick story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> kicked <span class='pl-target'>Elop</span> from the process <span class='pl-object'>Office Redesign</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'elop', alias: 'Elop'} }
          next()

        it 'builds the performer kick story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Steve Ballmer kicked you from the process 'Office Redesign'.
            [#{@text_date}]
          """
          next()

        it 'builds the performer kick story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>Steve Ballmer</span> kicked <span class='pl-target'>you</span> from the process <span class='pl-object'>Office Redesign</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()


  ###*
   * The Join Request Accept Event
  ###
  describe 'for the "join:request:accept" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'join:request:accept',
          actor: {
            id: 'david',
            alias: 'David Moyes'
          },
          player: {
            id: 'mata',
            alias: 'Juan Mata'
          }
          team: {
            id: 'mufc',
            name: 'Manchester United'
          },
          timestamp: @iso_date
        }
        next()

      describe 'in global context', ->
        it 'builds the join request accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Juan Mata\u2019s request to join the team 'Manchester United' has been accepted by David Moyes.
            [#{@text_date}]
          """
          next()

        it 'builds the join request accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-target'>Juan Mata\u2019s</span> request to join the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-actor'>David Moyes</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the join request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Juan Mata\u2019s request to join this team has been accepted by David Moyes.
            [#{@text_date}]
          """
          next()

        it 'builds the join request accept story (html)', (next) ->
          expect(@athena.toHTML(@story, @externals)).to.equal """
            <span class='pl-target'>Juan Mata\u2019s</span> request to join this team has been accepted by <span class='pl-actor'>David Moyes</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
          next()

        it 'builds the join request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Your request to join the team 'Manchester United' has been accepted by David Moyes.
            [#{@text_date}]
          """
          next()

        it 'builds the join request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Your</span> request to join the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-actor'>David Moyes</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'join:request:accept',
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
        it 'builds the join request accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            David Moyes\u2019s request to join the process 'Qualify for UEFA Champions League 2014' has been accepted by Sir Alex Ferguson.
            [#{@text_date}]
          """
          next()

        it 'builds the join request accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been accepted by <span class='pl-actor'>Sir Alex Ferguson</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the join request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            David Moyes\u2019s request to join this process has been accepted by Sir Alex Ferguson.
            [#{@text_date}]
          """
          next()

        it 'builds the join request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request to join this process has been accepted by <span class='pl-actor'>Sir Alex Ferguson</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the join request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Your request to join the process 'Qualify for UEFA Champions League 2014' has been accepted by Sir Alex Ferguson.
            [#{@text_date}]
          """
          next()

        it 'builds the join request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Your</span> request to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been accepted by <span class='pl-actor'>Sir Alex Ferguson</span>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()


  ###*
   * The Invite Accept Event
  ###
  describe 'for the "invite:accept" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'invite:accept',
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
            Juan Mata accepted David Moyes\u2019s invitation to join the team 'Manchester United' as midfielder.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@special_story)).to.equal """
            <span class='pl-actor'>Juan Mata</span> accepted <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
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
            Juan Mata accepted David Moyes\u2019s invitation to join the team 'Manchester United' as midfielder, playmaker.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@special_story)).to.equal """
            <span class='pl-actor'>Juan Mata</span> accepted <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li><li class='pl-role'>playmaker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Juan Mata accepted David Moyes\u2019s invitation to join the team 'Manchester United' as midfielder, playmaker.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Juan Mata</span> accepted <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li><li class='pl-role'>playmaker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Juan Mata accepted David Moyes\u2019s invitation to join this team as midfielder, playmaker.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story, @externals)).to.equal """
            <span class='pl-actor'>Juan Mata</span> accepted <span class='pl-target'>David Moyes\u2019s</span> invitation to join this team as <ul class='pl-role-list'><li class='pl-role'>midfielder</li><li class='pl-role'>playmaker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'mata', alias: 'Juan Mata'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You accepted David Moyes\u2019s invitation to join the team 'Manchester United' as midfielder, playmaker.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> accepted <span class='pl-target'>David Moyes\u2019s</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li><li class='pl-role'>playmaker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in inviter's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'inviter'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Juan Mata accepted your invitation to join the team 'Manchester United' as midfielder, playmaker.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>Juan Mata</span> accepted <span class='pl-target'>your</span> invitation to join the team <span class='pl-object'>Manchester United</span> as <ul class='pl-role-list'><li class='pl-role'>midfielder</li><li class='pl-role'>playmaker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'invite:accept',
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
            David Moyes accepted Sir Alex Ferguson\u2019s invitation to join the process 'Qualify for UEFA Champions League 2014' as admin in team lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@special_story)).to.equal """
            <span class='pl-actor'>David Moyes</span> accepted <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
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
            David Moyes accepted Sir Alex Ferguson\u2019s invitation to join the process 'Qualify for UEFA Champions League 2014' as admin in team lane, player in board lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@special_story)).to.equal """
            <span class='pl-actor'>David Moyes</span> accepted <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            David Moyes accepted Sir Alex Ferguson\u2019s invitation to join the process 'Qualify for UEFA Champions League 2014' as admin in team lane, player in board lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>David Moyes</span> accepted <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            David Moyes accepted Sir Alex Ferguson\u2019s invitation to join this process as admin in team lane, player in board lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>David Moyes</span> accepted <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join this process as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You accepted Sir Alex Ferguson\u2019s invitation to join the process 'Qualify for UEFA Champions League 2014' as admin in team lane, player in board lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> accepted <span class='pl-target'>Sir Alex Ferguson\u2019s</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in inviter's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'inviter'
          @externals = { profile: {id: 'alex', alias: 'Sir Alex Ferguson'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            David Moyes accepted your invitation to join the process 'Qualify for UEFA Champions League 2014' as admin in team lane, player in board lane.
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>David Moyes</span> accepted <span class='pl-target'>your</span> invitation to join the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> as <ul class='pl-role-list'><li><span class='pl-role'>admin</span> in <span class='pl-lane'>team</span> lane</li><li><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

  ###*
   * The Role Request Accept Event
  ###
  describe 'for the "role:request:accept" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'role:request:accept',
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

      describe 'for single addition', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'captain': { 'old': null, 'new': true }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Nemanja Vidic\u2019s request for a change of roles in the team 'Manchester United' has been accepted by David Moyes.
            Changes:
              [+] captain
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>Nemanja Vidic\u2019s</span> request for a change of roles in the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>captain</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for one role deletion', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'player': { 'old': true, 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Nemanja Vidic\u2019s request for a change of roles in the team 'Manchester United' has been accepted by David Moyes.
            Changes:
              [-] player
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>Nemanja Vidic\u2019s</span> request for a change of roles in the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-rem'>player</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for mixed role additions and deletions', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'captain': { 'old': null, 'new': true }
              'player': { 'old': true, 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Nemanja Vidic\u2019s request for a change of roles in the team 'Manchester United' has been accepted by David Moyes.
            Changes:
              [+] captain
              [-] player
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>Nemanja Vidic\u2019s</span> request for a change of roles in the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>captain</li><li class='pl-role pl-diff-rem'>player</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Nemanja Vidic\u2019s request for a change of roles in the team 'Manchester United' has been accepted by David Moyes.
            Changes:
              [+] captain
              [-] player
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-target'>Nemanja Vidic\u2019s</span> request for a change of roles in the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>captain</li><li class='pl-role pl-diff-rem'>player</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Nemanja Vidic\u2019s request for a change of roles in this team has been accepted by David Moyes.
            Changes:
              [+] captain
              [-] player
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Nemanja Vidic\u2019s</span> request for a change of roles in this team has been accepted by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>captain</li><li class='pl-role pl-diff-rem'>player</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Nemanja Vidic\u2019s request for a change of roles in the team 'Manchester United' has been accepted by you.
            Changes:
              [+] captain
              [-] player
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Nemanja Vidic\u2019s</span> request for a change of roles in the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-actor'>you</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>captain</li><li class='pl-role pl-diff-rem'>player</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'vidic', alias: 'Nemanja Vidic'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Your request for a change of roles in the team 'Manchester United' has been accepted by David Moyes.
            Changes:
              [+] captain
              [-] player
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Your</span> request for a change of roles in the team <span class='pl-object'>Manchester United</span> has been accepted by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>captain</li><li class='pl-role pl-diff-rem'>player</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'role:request:accept',
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

      describe 'for single addition', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'board': { 'old': null, 'new': 'player'}
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            David Moyes\u2019s request for a change of roles in the process 'Qualify for UEFA Champions League 2014' has been accepted by Sir Alex Ferguson.
            Changes:
              [+] player in board lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been accepted by <span class='pl-actor'>Sir Alex Ferguson</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for one role deletion', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'external': { 'old': 'observer', 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            David Moyes\u2019s request for a change of roles in the process 'Qualify for UEFA Champions League 2014' has been accepted by Sir Alex Ferguson.
            Changes:
              [-] observer in external lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been accepted by <span class='pl-actor'>Sir Alex Ferguson</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-rem'><span class='pl-role'>observer</span> in <span class='pl-lane'>external</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for one role change', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'team': { 'old': 'admin', 'new': 'super_admin'}
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            David Moyes\u2019s request for a change of roles in the process 'Qualify for UEFA Champions League 2014' has been accepted by Sir Alex Ferguson.
            Changes:
              [+] super_admin in team lane
              [-] admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been accepted by <span class='pl-actor'>Sir Alex Ferguson</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>super_admin</span> from <span class='pl-role pl-diff-rem'>admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for mixed role additions and deletions', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'board': { 'old': null, 'new': 'player'}
              'team': { 'old': 'admin', 'new': 'super_admin'}
              'external': { 'old': 'observer', 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            David Moyes\u2019s request for a change of roles in the process 'Qualify for UEFA Champions League 2014' has been accepted by Sir Alex Ferguson.
            Changes:
              [+] player in board lane
              [+] super_admin in team lane
              [-] admin in team lane
              [-] observer in external lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been accepted by <span class='pl-actor'>Sir Alex Ferguson</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>super_admin</span> from <span class='pl-role pl-diff-rem'>admin</span> in <span class='pl-lane'>team</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>observer</span> in <span class='pl-lane'>external</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            David Moyes\u2019s request for a change of roles in the process 'Qualify for UEFA Champions League 2014' has been accepted by Sir Alex Ferguson.
            Changes:
              [+] player in board lane
              [+] super_admin in team lane
              [-] admin in team lane
              [-] observer in external lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been accepted by <span class='pl-actor'>Sir Alex Ferguson</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>super_admin</span> from <span class='pl-role pl-diff-rem'>admin</span> in <span class='pl-lane'>team</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>observer</span> in <span class='pl-lane'>external</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            David Moyes\u2019s request for a change of roles in this process has been accepted by Sir Alex Ferguson.
            Changes:
              [+] player in board lane
              [+] super_admin in team lane
              [-] admin in team lane
              [-] observer in external lane
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request for a change of roles in this process has been accepted by <span class='pl-actor'>Sir Alex Ferguson</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>super_admin</span> from <span class='pl-role pl-diff-rem'>admin</span> in <span class='pl-lane'>team</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>observer</span> in <span class='pl-lane'>external</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'david', alias: 'Sir Alex Ferguson'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            David Moyes\u2019s request for a change of roles in the process 'Qualify for UEFA Champions League 2014' has been accepted by you.
            Changes:
              [+] player in board lane
              [+] super_admin in team lane
              [-] admin in team lane
              [-] observer in external lane
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>David Moyes\u2019s</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been accepted by <span class='pl-actor'>you</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>super_admin</span> from <span class='pl-role pl-diff-rem'>admin</span> in <span class='pl-lane'>team</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>observer</span> in <span class='pl-lane'>external</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'vidic', alias: 'David Moyes'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Your request for a change of roles in the process 'Qualify for UEFA Champions League 2014' has been accepted by Sir Alex Ferguson.
            Changes:
              [+] player in board lane
              [+] super_admin in team lane
              [-] admin in team lane
              [-] observer in external lane
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Your</span> request for a change of roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> has been accepted by <span class='pl-actor'>Sir Alex Ferguson</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>super_admin</span> from <span class='pl-role pl-diff-rem'>admin</span> in <span class='pl-lane'>team</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>observer</span> in <span class='pl-lane'>external</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()


  ###*
   * The Role Change Event
  ###
  describe 'for the "role:change" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'role:change',
          actor: {
            id: 'david',
            alias: 'David Moyes'
          },
          team: {
            id: 'mufc',
            name: 'Manchester United'
          },
          changes: {
            'manager': { 'old': null, 'new': true }
            'watcher': { 'old': true, 'new': null }
          }
          timestamp: @iso_date
        }
        next()

      describe 'for single addition', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'manager': { 'old': null, 'new': true }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            David Moyes has changed roles in the team 'Manchester United'.
            Changes:
              [+] manager
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-actor'>David Moyes</span> has changed roles in the team <span class='pl-object'>Manchester United</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>manager</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for one role deletion', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'watcher': { 'old': true, 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            David Moyes has changed roles in the team 'Manchester United'.
            Changes:
              [-] watcher
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-actor'>David Moyes</span> has changed roles in the team <span class='pl-object'>Manchester United</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-rem'>watcher</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for mixed role additions and deletions', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'manager': { 'old': null, 'new': true }
              'watcher': { 'old': true, 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            David Moyes has changed roles in the team 'Manchester United'.
            Changes:
              [+] manager
              [-] watcher
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-actor'>David Moyes</span> has changed roles in the team <span class='pl-object'>Manchester United</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>manager</li><li class='pl-role pl-diff-rem'>watcher</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            David Moyes has changed roles in the team 'Manchester United'.
            Changes:
              [+] manager
              [-] watcher
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>David Moyes</span> has changed roles in the team <span class='pl-object'>Manchester United</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>manager</li><li class='pl-role pl-diff-rem'>watcher</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            David Moyes has changed roles in this team.
            Changes:
              [+] manager
              [-] watcher
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>David Moyes</span> has changed roles in this team.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>manager</li><li class='pl-role pl-diff-rem'>watcher</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You have changed roles in the team 'Manchester United'.
            Changes:
              [+] manager
              [-] watcher
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> have changed roles in the team <span class='pl-object'>Manchester United</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>manager</li><li class='pl-role pl-diff-rem'>watcher</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'role:change',
          actor: {
            id: 'alex',
            alias: 'Sir Alex Ferguson'
          },
          process: {
            id: 'ucl_2014',
            name: 'Qualify for UEFA Champions League 2014'
          },
          changes: {
            'board': { 'old': 'player', 'new': 'admin'}
            'ex': { 'old': null, 'new': 'player' }
            'team': { 'old': 'super_admin', 'new': null }
          }
          timestamp: @iso_date
        }
        next()

      describe 'for single addition', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'ex': { 'old': null, 'new': 'player' }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Sir Alex Ferguson has changed roles in the process 'Qualify for UEFA Champions League 2014'.
            Changes:
              [+] player in ex lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-actor'>Sir Alex Ferguson</span> has changed roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for single deletion', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'team': { 'old': 'super_admin', 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Sir Alex Ferguson has changed roles in the process 'Qualify for UEFA Champions League 2014'.
            Changes:
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-actor'>Sir Alex Ferguson</span> has changed roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for single role change', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'board': { 'old': 'player', 'new': 'admin'}
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Sir Alex Ferguson has changed roles in the process 'Qualify for UEFA Champions League 2014'.
            Changes:
              [+] admin in board lane
              [-] player in board lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-actor'>Sir Alex Ferguson</span> has changed roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for mixed role additions and deletions', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'board': { 'old': 'player', 'new': 'admin'}
              'ex': { 'old': null, 'new': 'player' }
              'team': { 'old': 'super_admin', 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Sir Alex Ferguson has changed roles in the process 'Qualify for UEFA Champions League 2014'.
            Changes:
              [+] admin in board lane
              [-] player in board lane
              [+] player in ex lane
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-actor'>Sir Alex Ferguson</span> has changed roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Sir Alex Ferguson has changed roles in the process 'Qualify for UEFA Champions League 2014'.
            Changes:
              [+] admin in board lane
              [-] player in board lane
              [+] player in ex lane
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-actor'>Sir Alex Ferguson</span> has changed roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Sir Alex Ferguson has changed roles in this process.
            Changes:
              [+] admin in board lane
              [-] player in board lane
              [+] player in ex lane
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>Sir Alex Ferguson</span> has changed roles in this process.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'alex', alias: 'Sir Alex Ferguson'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            You have changed roles in the process 'Qualify for UEFA Champions League 2014'.
            Changes:
              [+] admin in board lane
              [-] player in board lane
              [+] player in ex lane
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-actor'>You</span> have changed roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

  ###*
   * The Role Assign Event
  ###
  describe 'for the "role:assign" event', ->
    describe 'for teams', ->
      before (next) ->
        @story = {
          event: 'role:assign',
          actor: {
            id: 'david',
            alias: 'David Moyes'
          },
          player: {
            id: 'wayne'
            alias: 'Rooney'
          },
          team: {
            id: 'mufc',
            name: 'Manchester United'
          },
          changes: {
            'striker': { 'old': null, 'new': true }
            'roamer': { 'old': true, 'new': null }
          }
          timestamp: @iso_date
        }
        next()

      describe 'for single addition', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'striker': { 'old': null, 'new': true }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Rooney\u2019s roles in the team 'Manchester United' have been changed by David Moyes.
            Changes:
              [+] striker
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>Rooney\u2019s</span> roles in the team <span class='pl-object'>Manchester United</span> have been changed by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>striker</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for one role deletion', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'roamer': { 'old': true, 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Rooney\u2019s roles in the team 'Manchester United' have been changed by David Moyes.
            Changes:
              [-] roamer
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>Rooney\u2019s</span> roles in the team <span class='pl-object'>Manchester United</span> have been changed by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-rem'>roamer</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for mixed role additions and deletions', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'striker': { 'old': null, 'new': true }
              'roamer': { 'old': true, 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Rooney\u2019s roles in the team 'Manchester United' have been changed by David Moyes.
            Changes:
              [+] striker
              [-] roamer
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>Rooney\u2019s</span> roles in the team <span class='pl-object'>Manchester United</span> have been changed by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>striker</li><li class='pl-role pl-diff-rem'>roamer</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Rooney\u2019s roles in the team 'Manchester United' have been changed by David Moyes.
            Changes:
              [+] striker
              [-] roamer
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-target'>Rooney\u2019s</span> roles in the team <span class='pl-object'>Manchester United</span> have been changed by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>striker</li><li class='pl-role pl-diff-rem'>roamer</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in team context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'team'
          @externals = {context: 'team'}
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Rooney\u2019s roles in this team have been changed by David Moyes.
            Changes:
              [+] striker
              [-] roamer
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Rooney\u2019s</span> roles in this team have been changed by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>striker</li><li class='pl-role pl-diff-rem'>roamer</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'david', alias: 'David Moyes'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Rooney\u2019s roles in the team 'Manchester United' have been changed by you.
            Changes:
              [+] striker
              [-] roamer
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Rooney\u2019s</span> roles in the team <span class='pl-object'>Manchester United</span> have been changed by <span class='pl-actor'>you</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>striker</li><li class='pl-role pl-diff-rem'>roamer</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'wayne', alias: 'Rooney'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Your roles in the team 'Manchester United' have been changed by David Moyes.
            Changes:
              [+] striker
              [-] roamer
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Your</span> roles in the team <span class='pl-object'>Manchester United</span> have been changed by <span class='pl-actor'>David Moyes</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-role pl-diff-add'>striker</li><li class='pl-role pl-diff-rem'>roamer</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

    describe 'for processes', ->
      before (next) ->
        @story = {
          event: 'role:assign',
          actor: {
            id: 'malcolm',
            alias: 'Mr. Glazer'
          },
          player: {
            id: 'alex'
            alias: 'Sir Alex Ferguson'
          }
          process: {
            id: 'ucl_2014',
            name: 'Qualify for UEFA Champions League 2014'
          },
          changes: {
            'board': { 'old': 'player', 'new': 'admin'}
            'ex': { 'old': null, 'new': 'player' }
            'team': { 'old': 'super_admin', 'new': null }
          }
          timestamp: @iso_date
        }
        next()

      describe 'for single addition', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'ex': { 'old': null, 'new': 'player' }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Sir Alex Ferguson\u2019s roles in the process 'Qualify for UEFA Champions League 2014' have been changed by Mr. Glazer.
            Changes:
              [+] player in ex lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>Sir Alex Ferguson\u2019s</span> roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> have been changed by <span class='pl-actor'>Mr. Glazer</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for single deletion', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'team': { 'old': 'super_admin', 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Sir Alex Ferguson\u2019s roles in the process 'Qualify for UEFA Champions League 2014' have been changed by Mr. Glazer.
            Changes:
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>Sir Alex Ferguson\u2019s</span> roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> have been changed by <span class='pl-actor'>Mr. Glazer</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for single role change', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'board': { 'old': 'player', 'new': 'admin'}
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Sir Alex Ferguson\u2019s roles in the process 'Qualify for UEFA Champions League 2014' have been changed by Mr. Glazer.
            Changes:
              [+] admin in board lane
              [-] player in board lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>Sir Alex Ferguson\u2019s</span> roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> have been changed by <span class='pl-actor'>Mr. Glazer</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'for mixed role additions and deletions', ->
        before (next) ->
          @story_ctx = _.extend {}, @story, {
            changes:
              'board': { 'old': 'player', 'new': 'admin'}
              'ex': { 'old': null, 'new': 'player' }
              'team': { 'old': 'super_admin', 'new': null }
          }
          next()

        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx)).to.equal """
            Sir Alex Ferguson\u2019s roles in the process 'Qualify for UEFA Champions League 2014' have been changed by Mr. Glazer.
            Changes:
              [+] admin in board lane
              [-] player in board lane
              [+] player in ex lane
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx)).to.equal """
            <span class='pl-target'>Sir Alex Ferguson\u2019s</span> roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> have been changed by <span class='pl-actor'>Mr. Glazer</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in global context', ->
        it 'builds the role request accept story (text)', (next) ->
          expect(@athena.toString(@story)).to.equal """
            Sir Alex Ferguson\u2019s roles in the process 'Qualify for UEFA Champions League 2014' have been changed by Mr. Glazer.
            Changes:
              [+] admin in board lane
              [-] player in board lane
              [+] player in ex lane
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the role request accept story (html)', (next) ->
          expect(@athena.toHTML(@story)).to.equal """
            <span class='pl-target'>Sir Alex Ferguson\u2019s</span> roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> have been changed by <span class='pl-actor'>Mr. Glazer</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe 'in process context', ->
        before (next) ->
          @story_ctx = _.omit @story, 'process'
          @externals = {context: 'process'}
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Sir Alex Ferguson\u2019s roles in this process have been changed by Mr. Glazer.
            Changes:
              [+] admin in board lane
              [-] player in board lane
              [+] player in ex lane
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Sir Alex Ferguson\u2019s</span> roles in this process have been changed by <span class='pl-actor'>Mr. Glazer</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in actor's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'actor'
          @externals = { profile: {id: 'malcolm', alias: 'Mr. Glazer'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Sir Alex Ferguson\u2019s roles in the process 'Qualify for UEFA Champions League 2014' have been changed by you.
            Changes:
              [+] admin in board lane
              [-] player in board lane
              [+] player in ex lane
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Sir Alex Ferguson\u2019s</span> roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> have been changed by <span class='pl-actor'>you</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()

      describe "in target player's context", ->
        before (next) ->
          @story_ctx = _.omit @story, 'player'
          @externals = { profile: {id: 'alex', alias: 'Sir Alex Ferguson'} }
          next()

        it 'builds the invite accept story (text)', (next) ->
          expect(@athena.toString(@story_ctx, @externals)).to.equal """
            Your roles in the process 'Qualify for UEFA Champions League 2014' have been changed by Mr. Glazer.
            Changes:
              [+] admin in board lane
              [-] player in board lane
              [+] player in ex lane
              [-] super_admin in team lane
            [#{@text_date}]
          """
          next()

        it 'builds the invite accept story (html)', (next) ->
          expect(@athena.toHTML(@story_ctx, @externals)).to.equal """
            <span class='pl-target'>Your</span> roles in the process <span class='pl-object'>Qualify for UEFA Champions League 2014</span> have been changed by <span class='pl-actor'>Mr. Glazer</span>.<ul class='pl-role-list pl-diff-list'><li class='pl-list-header'>Changes</li><li class='pl-diff-change'><span class='pl-role pl-diff-add'>admin</span> from <span class='pl-role pl-diff-rem'>player</span> in <span class='pl-lane'>board</span> lane</li><li class='pl-diff-add'><span class='pl-role'>player</span> in <span class='pl-lane'>ex</span> lane</li><li class='pl-diff-rem'><span class='pl-role'>super_admin</span> in <span class='pl-lane'>team</span> lane</li></ul>.<time class='pl-ts' title='On #{@text_date}'>#{@relative_date}</time>
          """
          next()
